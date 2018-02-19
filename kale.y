%{
  #include "ast.h"
  #include <iostream>
  #include <string>
  #include <fstream>
  #include <unordered_set>
  #include <unordered_map>
  #include <stdlib.h>
  using namespace std;

// stuff from flex that bison needs to know about:
  extern "C" int yylex();
  extern "C" int yyparse();
  extern "C" FILE *yyin;

  kal_ast_node *root;  //the root of the AST
  unordered_set<string> defined_function_names;  //record the function which has already been recorded
  unordered_set<string> used_function_names;  //record the function which has been used
  unordered_map<string, int> ref_varibles;  //record the ref type variables which has been declared
  unordered_map<string, string> globid_type;  //record the return type of each function
  unordered_map<string, string> var_type;  //record the type of each variable
  bool has_run;  //record if the program has a valid run function
  char *expr_type;  //hold the type of each expression


  void yyerror(const char *s);
  void foutput(kal_ast_node *node, ofstream &ofs, int indent);
  void fout_indent(ofstream &ofs, int indent);
  bool init_expr(kal_ast_node *node);
  char *type_inference(kal_ast_node *node);

%}

// Bison fundamentally works by asking flex to get the next token, which it
// returns as an object of type "yystype".  But tokens could be of any
// arbitrary data type!  So we deal with that in Bison by defining a C union
// holding each of the types of tokens that Flex could return, and have Bison
// use that union instead of "int" for the definition of "yystype":
%union {
  float fval;
  char *sval;
  char *identifer;
  struct kal_ast_node *node;
  struct kal_ast_multi {
    kal_ast_node **args;
    int count;
  } multi;
  struct kal_ast_tdecls {
    char **args;
    int count;
  } tdecls;
}

// define the constant-string tokens:
%token TIMES SLASH PLUS MINUS 
%token ASSIGN 
%token EQL LSS GTR 
%token AND OR
%token NOT

%token LP RP SEMICOLON LB RB COMMA DOLLOR
%token EXTERNSYM DEFSYM RETURNSYM WHILESYM IFSYM PRINTSYM ELSESYM
%token INTTYPE CINTTYPE FLOATTYPE SFLOATTYPE VOIDTYPE REFTYPE NOALIASTYPE


%right ASSIGN
%left OR
%left AND
%left EQL
%left LSS GTR
%left PLUS MINUS
%left TIMES SLASH
%right NEG NOT


// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
%token <fval> LITERAL
%token <sval> STRING 
%token <identifer> IDENTIFER

%type <sval> globid var ident slit type
%type <node> prog exter func blk stmt opt_else exp binop uop lit vdecl opt_exters opt_vdecls opt_stmts opt_exps opt_tdecls
%type <multi> exters funcs vdecls stmts exps
%type <tdecls> tdecls

%%


prog:
    opt_exters funcs { root = kal_ast_prog_create($1, kal_ast_functions_create($2.count, $2.args)); }
    ;
opt_exters:
       exters { $$ = kal_ast_exters_create($1.count, $1.args); }
       | { $$ = kal_ast_exters_create(0, NULL); }
       ;
exters:
        exters exter { ++$1.count; $1.args = (kal_ast_node**)realloc($1.args, sizeof(kal_ast_node*) * $1.count); $1.args[$1.count-1] = $2; $$ = $1; }
        | exter { $$.count = 1; $$.args = (kal_ast_node**)malloc(sizeof(kal_ast_node*)); $$.args[0] = $1; }
        ;
exter:
      EXTERNSYM type globid LP opt_tdecls RP SEMICOLON { $$ = kal_ast_exter_create($2, $3, $5); }
      ;

opt_tdecls:
          tdecls { $$ = kal_ast_tdecls_create($1.count, $1.args); }
          | { $$ = kal_ast_tdecls_create(0, NULL); }
          ;
funcs:
     funcs func { ++$1.count; $1.args = (kal_ast_node**)realloc($1.args, sizeof(kal_ast_node*) * $1.count); $1.args[$1.count-1] = $2; $$ = $1; }
     | func { $$.count = 1; $$.args = (kal_ast_node**)malloc(sizeof(kal_ast_node*)); $$.args[0] = $1; }
func:
    DEFSYM type globid LP opt_vdecls RP blk { $$ = kal_ast_function_create($2, $3, $5, $7); defined_function_names.insert($3); 
      for (auto a : used_function_names) { if (defined_function_names.find(a) == defined_function_names.end()) 
        cout << "error: All functions must be declared and/or defined before they are used." << endl; }
      used_function_names.clear(); 
      var_type.clear();
      globid_type[$3] = $2;
    }
    ;
opt_vdecls:
         vdecls { $$ = kal_ast_vdecls_create($1.count, $1.args); }
         | { $$ = kal_ast_vdecls_create(0, NULL); }
         ;
blk:
   LB opt_stmts RB { $$ = kal_ast_blk_create($2); }
   ;
opt_stmts:
         stmts { $$ = kal_ast_stmts_create($1.count, $1.args); }
       | { $$ = kal_ast_stmts_create(0, NULL); }
         ;
stmts:
     stmts stmt { ++$1.count; $1.args = (kal_ast_node**)realloc($1.args, sizeof(kal_ast_node*) * $1.count); $1.args[$1.count-1] = $2; $$ = $1; }
     | stmt { $$.count = 1; $$.args = (kal_ast_node**)malloc(sizeof(kal_ast_node*)); $$.args[0] = $1; }
     ;
stmt:
    blk { $$ = $1; }
    | RETURNSYM SEMICOLON { $$ = kal_ast_return_create(NULL); }
    | RETURNSYM exp SEMICOLON { $$ = kal_ast_return_create($2); }
    | vdecl ASSIGN exp SEMICOLON { $$ = kal_ast_vdecl_assign_create($1, $3); }
    | exp SEMICOLON { $$ = kal_ast_expr_create($1); }
    | WHILESYM LP exp  RP stmt { $$ = kal_ast_while_create($3, $5); }
    | IFSYM LP exp RP stmt opt_else { $$ = kal_ast_if_expr_create($3, $5, $6); }
    | PRINTSYM exp SEMICOLON { $$ = kal_ast_print_create($2); }
    | PRINTSYM slit SEMICOLON { $$ = kal_ast_print_slit_create($2); }
    ;
opt_else:
      ELSESYM stmt { $$ = $2; }
      | { $$ = NULL; }
      ;
exps:
    exp { $$.count = 1; $$.args = (kal_ast_node**)malloc(sizeof(kal_ast_node*)); $$.args[0] = $1; }
    |  exps COMMA exp { ++$1.count; $1.args = (kal_ast_node**)realloc($1.args, sizeof(kal_ast_node*) * $1.count); $1.args[$1.count-1] = $3; $$ = $1; }
    ;
exp:
   LP exp RP { $$ = $2; }
   | binop { $$ = $1; }
   | uop { $$ = $1; }
   | lit { $$ = $1; }
   | var { string s_temp = var_type[$1];
           auto found = s_temp.find("ref ");
           if (found != string::npos)
             expr_type = (char *)s_temp.substr(found+4).c_str();
           else expr_type = (char *)s_temp.c_str();
           $$ = kal_ast_variable_create($1, expr_type); }
   | globid LP opt_exps RP { expr_type = (char *)globid_type[$1].c_str(); $$ = kal_ast_call_create($1, $3, expr_type); used_function_names.insert($1); }
   ;
opt_exps:
        exps { $$ = kal_ast_exprs_create($1.count, $1.args); }
        | { $$ = kal_ast_exprs_create(0, NULL); }
        ;
binop:
     exp TIMES exp { $$ = kal_ast_binary_expr_create(KAL_BINOP_MUL, $1, $3, type_inference($1)); }
     |exp SLASH exp { $$ = kal_ast_binary_expr_create(KAL_BINOP_DIV, $1, $3, type_inference($1)); }
     |exp PLUS exp { $$ = kal_ast_binary_expr_create(KAL_BINOP_PLUS, $1, $3, type_inference($1)); }
     |exp MINUS exp { $$ = kal_ast_binary_expr_create(KAL_BINOP_MINUS, $1, $3, type_inference($1)); }
     |exp EQL exp { $$ = kal_ast_binary_expr_create(KAL_BINOP_EQL, $1, $3, type_inference($1)); }
     |exp LSS exp { $$ = kal_ast_binary_expr_create(KAL_BINOP_LSS, $1, $3, type_inference($1)); }
     |exp GTR exp { $$ = kal_ast_binary_expr_create(KAL_BINOP_GTR, $1, $3, type_inference($1)); }
     |exp AND exp { $$ = kal_ast_binary_expr_create(KAL_BINOP_AND, $1, $3, type_inference($1)); }
     |exp OR exp { $$ = kal_ast_binary_expr_create(KAL_BINOP_OR, $1, $3, type_inference($1)); }
     |exp ASSIGN exp { $$ = kal_ast_binary_expr_create(KAL_BINOP_ASSIGN, $1, $3, type_inference($1)); }
     ;
uop:
   NOT exp { $$ = kal_ast_uop_expr_create(KAL_UOP_NOT, $2, type_inference($2)); }
	 | MINUS exp %prec NEG { $$ = kal_ast_uop_expr_create(KAL_UOP_MINUS, $2, type_inference($2)); }
   ;
lit:
		LITERAL { if (abs($1 - int($1)) < 0.000000000001)
                expr_type = strdup("int");
              else expr_type = strdup("float");
              $$ = kal_ast_number_create($1, expr_type); }
		;
slit:
		STRING { $$ = strdup($1); }
		;
ident:
		IDENTIFER { $$ = strdup($1); }
		;

var:
   DOLLOR ident { $$ = strdup($2); }
   ;
globid:
      ident { $$ = strdup($1); }
      ;
type:
    INTTYPE { $$ = strdup("int"); }
    | CINTTYPE { $$ = strdup("cint"); }
    | FLOATTYPE { $$ = strdup("float"); }
    | SFLOATTYPE { $$ = strdup("sfloat"); }
    | VOIDTYPE { $$ = strdup("void"); }
    | REFTYPE type { $$ = strdup(strcat(strdup("ref "), $2)); 
      if (strcmp($2, "void") == 0 || strstr($2, "ref")) cout << "error: In ​ref ​<type>​, the type may not be void or itself a reference type." << endl;}
    | NOALIASTYPE REFTYPE type { $$ = strdup(strcat(strdup("noalias ref "), $3)); }
    ;
vdecls:
      vdecl { $$.count = 1; $$.args = (kal_ast_node**)malloc(sizeof(kal_ast_node*)); $$.args[0] = $1; }
      | vdecls COMMA vdecl { ++$1.count; $1.args = (kal_ast_node**)realloc($1.args, sizeof(kal_ast_node*) * $1.count); $1.args[$1.count-1] = $3; $$ = $1; }
      ;
tdecls:
      type { $$.count = 1; $$.args = (char**)malloc(sizeof(char*)); $$.args[0] = $1; }
      | tdecls COMMA type { ++$1.count; $1.args = (char**)realloc($1.args, sizeof(char*) * $1.count); $1.args[$1.count-1] = strdup($3); $$ = $1; }
      ;
vdecl:
      type var { $$ = kal_ast_vdecl_create($1, $2); if (strstr($1, "ref")) ++ref_varibles[$2]; 
                var_type[$2] = $1;}
      ;
%%


kal_ast_node * kale_parse(char* filename, char* outputfilename) {
  has_run = false;

  ofstream ofs(outputfilename);

  FILE *myfile = fopen(filename, "r");
  // make sure it's valid:
  if (!myfile) {
    cout << "I can't open a kale file!" << endl;
    return -1;
  }
  // set flex to read from it instead of defaulting to STDIN:
  yyin = myfile;

  // parse through the input until there is no more:
  do {
    yyparse();
  } while (!feof(yyin));
  //cout << "1" << endl;

  // TODO: Only output to ofs if specified.
  foutput(root, ofs, 0);

  if (!has_run) {
    cout << "error: All programs must define exactly one function named 'run' which returns an integer (the program exit status) and takes no arguments." << endl;
    return NULL;
  }
  return root;
}

void foutput(kal_ast_node *node, ofstream &ofs, int indent) {
/*write the parsing result to the file*/
  ofstream *fout = &ofs;
  if(!node) return;

  switch(node->type) {
    case KAL_AST_TYPE_PROG: {
      *fout << "---\nname: prog\n";
      foutput(node->prog.exters, ofs, indent);
      foutput(node->prog.functions, ofs, indent);
      *fout << "...\n";
      break;
    } 
    case KAL_AST_TYPE_EXTERS: {
      if (node->multi.count > 0) {
        *fout << "externs:\n";
        fout_indent(ofs, indent+2);
        *fout << "name: externs\n";
        fout_indent(ofs, indent+2);
        *fout << "externs：\n";
        for (int i = 0; i < node->multi.count; ++i) {
          foutput(node->multi.args[i], ofs, indent+4);
        }
      }
      break;
    } 
    case KAL_AST_TYPE_EXTER: {
      fout_indent(ofs, indent);
      *fout << "-\n";
      fout_indent(ofs, indent+2);
      *fout << "name: extern\n";
      fout_indent(ofs, indent+2);
      *fout << "ret_type: " << node->exter.ret_type << "\n";
      fout_indent(ofs, indent+2);
      *fout << "globid: " << node->exter.globid << "\n";
      foutput(node->exter.tdecls, ofs, indent+2);
      break;
    }
    case KAL_AST_TYPE_VARIABLE: {
      fout_indent(ofs, indent);
      *fout << "name: varval\n";

      fout_indent(ofs, indent);
      *fout << "expr_type: " << node->variable.type << "\n";

      fout_indent(ofs, indent);
      *fout << "var: " << node->variable.name << "\n";
      break;
    }
    case KAL_AST_TYPE_TDECLS: {
      if (node->tdecls.count == 0) break;
      fout_indent(ofs, indent);
      *fout << "tdecls:\n";
      fout_indent(ofs, indent+2);
      *fout << "name: tdecls\n";
      fout_indent(ofs, indent+2);
      *fout << "types:\n";
      for (int i = 0; i < node->tdecls.count; ++i) {
        fout_indent(ofs, indent+4);
        *fout << "- " << node->tdecls.args[i] << "\n";
      }
      break;
    }
    case KAL_AST_TYPE_FUNCTIONS: {
      *fout << "funcs:\n";
      fout_indent(ofs, indent+2);
      *fout << "name: funcs\n";
      fout_indent(ofs, indent+2);
      *fout << "funcs\n";
      for (int i = 0; i < node->multi.count; ++i) {
        foutput(node->multi.args[i], ofs, indent+4);
        ref_varibles.clear();
      }
      break;
    }
    case KAL_AST_TYPE_FUNCTION: {
      fout_indent(ofs, indent);
      *fout << "-\n";
      fout_indent(ofs, indent+2);
      *fout << "name: func\n";
      fout_indent(ofs, indent+2);
      *fout << "ret_type: " << node->function.ret_type << "\n";
      fout_indent(ofs, indent+2);
      *fout << "globid: " << node->function.globid << "\n";
      foutput(node->function.vdecls, ofs, indent+2);
      fout_indent(ofs, indent+2);
      *fout << "blk:\n";
      foutput(node->function.blk, ofs, indent+4);

      if (strstr(node->function.ret_type, "ref")) {
        cout << "error: A function may not return a ref type." << endl;
      }

      if (strcmp(node->function.globid, "run") == 0 && node->function.vdecls->multi.count == 0 && strcmp(node->function.ret_type, "int") == 0) {
        has_run = true;
      }

      break;
    }
    case KAL_AST_TYPE_VDECLS: {
      if (node->multi.count == 0) break;
      fout_indent(ofs, indent);
      *fout << "vdecls:\n";
      fout_indent(ofs, indent+2);
      *fout << "name: vdecls\n";
      fout_indent(ofs, indent+2);
      *fout << "vars:\n";
      for (int i = 0; i < node->multi.count; ++i) {
        fout_indent(ofs, indent+4);
        *fout << "-\n";
        foutput(node->multi.args[i], ofs, indent+6);
      }
      break;
    }
    case KAL_AST_TYPE_VDECL: {
      fout_indent(ofs, indent);
      *fout << "node: vdecl\n";
      fout_indent(ofs, indent);
      *fout << "type: " << node->vdecl.type << "\n";
      fout_indent(ofs, indent);
      *fout << "var: " << node->vdecl.var << "\n";

      if (strcmp(node->vdecl.type, "void") == 0) {
        cout << "error: In ​<vdecl>​, the type may not be void." << endl;
      }

      break;
    }
    case KAL_AST_TYPE_BLK: {
      fout_indent(ofs, indent);
      *fout << "name: blk\n";
      fout_indent(ofs, indent);
      *fout << "contents:\n";
      foutput(node->blk.stmts, ofs, indent+2);
      break;
    }
    case KAL_AST_TYPE_STMTS: {
      if (node->multi.count == 0) break;
      fout_indent(ofs, indent);
      *fout << "name: stmts\n";
      fout_indent(ofs, indent);
      *fout << "stmts:\n";
      for (int i = 0; i < node->multi.count; ++i) {
        fout_indent(ofs, indent+2);
        *fout << "-\n";
        foutput(node->multi.args[i], ofs, indent+4);
      }
      break;
    }
    case KAL_AST_TYPE_RETURN: {
      fout_indent(ofs, indent);
      *fout << "name: ret\n";
      if (node->return_stmt.expr) {
        fout_indent(ofs, indent);
        *fout << "exp:\n";
        foutput(node->return_stmt.expr, ofs, indent+2);
      }
      break;
    }
    case KAL_AST_TYPE_EXPR: {
      fout_indent(ofs, indent);
      *fout << "name: expstmt\n";
      fout_indent(ofs, indent);
      *fout << "exp:\n";
      foutput(node->return_stmt.expr, ofs, indent+2);
      break;
    }
    case KAL_AST_TYPE_VDECL_ASSIGN: {
      fout_indent(ofs, indent);
      *fout << "name: vardeclstmt\n";
      fout_indent(ofs, indent);
      *fout << "vdecl:\n";
      foutput(node->vdecl_assign.vdecl, ofs, indent+2);
      fout_indent(ofs, indent);
      *fout << "exp:\n";
      foutput(node->vdecl_assign.expr, ofs, indent+2);

      if (ref_varibles[node->vdecl_assign.vdecl->vdecl.var] == 0 && !init_expr(node->vdecl_assign.expr)) {
        cout << "error: The initialization expression for a reference variable (including function arguments) must be a variable." << endl;
        ++ref_varibles[node->vdecl_assign.vdecl->vdecl.var];
        //cout << node->vdecl_assign.vdecl->vdecl.var << endl;
      }

      break;
    }
    case KAL_AST_TYPE_WHILE: {
      fout_indent(ofs, indent);
      *fout << "name: while\n";
      fout_indent(ofs, indent);
      *fout << "cond:\n";
      foutput(node->while_stmt.expr, ofs, indent+2);
      fout_indent(ofs, indent);
      *fout << "stmt:\n";
      foutput(node->while_stmt.stmt, ofs, indent+2);
      break;
    }
    case KAL_AST_TYPE_IF_EXPR: {
      fout_indent(ofs, indent);
      *fout << "name: if\n";
      fout_indent(ofs, indent);
      *fout << "cond:\n";
      foutput(node->if_expr.condition, ofs, indent+2);
      fout_indent(ofs, indent);
      *fout << "stmt:\n";
      foutput(node->if_expr.true_expr, ofs, indent+2);
      if (node->if_expr.false_expr) {
        fout_indent(ofs, indent);
        *fout << "else_stmt:\n";
        foutput(node->if_expr.false_expr, ofs, indent+2);
      }
      break;
    }
    case KAL_AST_TYPE_PRINT_EXPR: {
      fout_indent(ofs, indent);
      *fout << "name: print\n";
      fout_indent(ofs, indent);
      *fout << "exp:\n";
      foutput(node->print_stmt.expr, ofs, indent+2);
      break;
    }
    case KAL_AST_TYPE_PRINT_SLIT: {
      fout_indent(ofs, indent);
      *fout << "name: printslit\n";
      fout_indent(ofs, indent);
      *fout << "string: " << node->print_slit.print_slit << "\n";
      break;
    }
    case KAL_AST_TYPE_BINARY_EXPR: {
      fout_indent(ofs, indent);
      *fout << "name: binop\n";

      fout_indent(ofs, indent);
      *fout << "expr_type: " << node->binary_expr.type << "\n";

      fout_indent(ofs, indent);
      *fout << "op: ";
      switch(node->binary_expr.op) {
        case KAL_BINOP_PLUS: {
          *fout << "add";
          break;
        }
        case KAL_BINOP_MINUS: {
          *fout << "sub";
          break;
        }
        case KAL_BINOP_MUL: {
          *fout << "mul";
          break;
        }
        case KAL_BINOP_DIV: {
          *fout << "div";
          break;
        }
        case KAL_BINOP_EQL: {
          *fout << "eq";
          break;
        }
        case KAL_BINOP_LSS: {
          *fout << "lt";
          break;
        }
        case KAL_BINOP_GTR: {
          *fout << "gt";
          break;
        }
        case KAL_BINOP_AND: {
          *fout << "and";
          break;
        }
        case KAL_BINOP_OR: {
          *fout << "or";
          break;
        }
        case KAL_BINOP_ASSIGN: {
          *fout << "assign";

          if (ref_varibles[node->binary_expr.lhs->variable.name] == 0 && !init_expr(node->binary_expr.rhs)) {
            cout << "error: The initialization expression for a reference variable (including function arguments) must be a variable." << endl;
            ++ref_varibles[node->binary_expr.lhs->variable.name]; 
            //cout << node->binary_expr.lhs->variable.name << endl;
          }

          break;
        }
      }
      *fout << "\n";
      fout_indent(ofs, indent);
      *fout << "lhs:\n";
      foutput(node->binary_expr.lhs, ofs, indent+2);
      fout_indent(ofs, indent);
      *fout << "rhs:\n";
      foutput(node->binary_expr.rhs, ofs, indent+2);
      break;
    }
    case KAL_AST_TYPE_UOP_EXPR: {
      fout_indent(ofs, indent);
      *fout << "name: uop\n";

      fout_indent(ofs, indent);
      *fout << "expr_type: " << node->uop_expr.type << "\n";

      fout_indent(ofs, indent);
      *fout << "op: ";
      switch(node->uop_expr.op) {
        case KAL_UOP_NOT: {
          *fout << "not";
          break;
        }
        case KAL_UOP_MINUS: {
          *fout << "neg";
          break;
        }
      }
      *fout << "\n";
      fout_indent(ofs, indent);
      *fout << "exp:\n";
      foutput(node->uop_expr.hs, ofs, indent+2);
      break;
    }
    case KAL_AST_TYPE_NUMBER: {
      fout_indent(ofs, indent);
      *fout << "name: lit\n";

      fout_indent(ofs, indent);
      *fout << "expr_type: " << node->number.type << "\n";

      fout_indent(ofs, indent);
      *fout << "value: " << node->number.value << "\n";
      break;
    }
    case KAL_AST_TYPE_CALL: {
      fout_indent(ofs, indent);
      *fout << "name: funccall\n";

      node->call.type = (char *)globid_type[node->call.globid].c_str();
      fout_indent(ofs, indent);
      *fout << "expr_type: " << node->call.type << "\n";

      fout_indent(ofs, indent);
      *fout << "globid: " << node->call.globid << "\n";
      fout_indent(ofs, indent);
      *fout << "params:\n";
      foutput(node->call.exprs, ofs, indent+2);
      break;
    }
    case KAL_AST_TYPE_EXPRS: {
      if (node->multi.count == 0) break;
      fout_indent(ofs, indent);
      *fout << "name: exps\n";
      fout_indent(ofs, indent);
      *fout << "exps:\n";
      for (int i = 0; i < node->multi.count; ++i) {
        fout_indent(ofs, indent+2);
        *fout << "-\n";
        foutput(node->multi.args[i], ofs, indent+4);
      }
      break;
    }
  }
}
void fout_indent(ofstream &ofs, int indent) {
/*output the indentation*/
  ofstream *fout = &ofs;
  for (int i = 0; i < indent; ++i)
    *fout << " ";
}
bool init_expr(kal_ast_node *node) {
/*determine if an expression includes a variable*/
  switch(node->type) {
    case KAL_AST_TYPE_VARIABLE: {
      return true;
      break;
    }
    case KAL_AST_TYPE_NUMBER: {
      return false;
      break;
    }
    /*case KAL_AST_TYPE_CALL: {
      bool temp = false;
      for (int i = 0; i < node->call.exprs->multi.count; ++i) {
        temp |= init_expr(node->call.exprs->multi.args[i]);
      }
      return temp;
      break;
    }*/
    case KAL_AST_TYPE_CALL: {
      return true;
    }
    case KAL_AST_TYPE_UOP_EXPR: {
      return init_expr(node->uop_expr.hs);
      break;
    }
    case KAL_AST_TYPE_BINARY_EXPR: {
      return init_expr(node->binary_expr.lhs) || init_expr(node->binary_expr.rhs);
      break;
    }
    default: {
      return false;
      break;
    }
  }
}
char *type_inference(kal_ast_node *node) {
    switch(node->type) {
    case KAL_AST_TYPE_VARIABLE: {
      string s_temp = var_type[node->variable.name];
      auto found = s_temp.find("ref ");
      if (found != string::npos)
        s_temp = s_temp.substr(found+4);
      return (char *)s_temp.c_str();
      break;
    }
    case KAL_AST_TYPE_NUMBER: {
      if (abs(node->number.value - int(node->number.value)) < 0.000000000001)
        return strdup("int");
      else return strdup("float");
      break;
    }
    case KAL_AST_TYPE_CALL: {
      return (char *)globid_type[node->call.globid].c_str();
      break;
    }
    case KAL_AST_TYPE_UOP_EXPR: {
      return type_inference(node->uop_expr.hs);
      break;
    }
    case KAL_AST_TYPE_BINARY_EXPR: {
      return type_inference(node->binary_expr.lhs);
      break;
    }
    default: {
      return NULL;
      break;
    }
  }
}

void yyerror(const char *s) {
  cout << "EEK, parse error!  Message: " << s << endl;
  // might as well halt now:
  exit(-1);
}