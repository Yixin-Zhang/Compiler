#include <stdlib.h>
#include <string.h>
#include <string>
#include "ast.h"
using namespace std;


//==============================================================================
//
// Functions
//
//==============================================================================

//--------------------------------------
// Program AST
//--------------------------------------

kal_ast_node *kal_ast_prog_create(kal_ast_node *exters, kal_ast_node *functions) {
  
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type = KAL_AST_TYPE_PROG;
    node->prog.exters = exters;
    node->prog.functions = functions;
    return node;
}


//--------------------------------------
// Functions arguments AST
//--------------------------------------

kal_ast_node *kal_ast_functions_create(int count, kal_ast_node **args) {
  
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type =  KAL_AST_TYPE_FUNCTIONS;
    node->multi.count = count;
    node->multi.args = (kal_ast_node **)malloc(sizeof(kal_ast_node*) * count);
    memcpy(node->multi.args, args, sizeof(kal_ast_node*) * count);
    return node;
}


//--------------------------------------
// Externs arguments AST
//--------------------------------------

kal_ast_node *kal_ast_exters_create(int count, kal_ast_node **args) {
    
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type =  KAL_AST_TYPE_EXTERS;
    node->multi.count = count;
    node->multi.args = (kal_ast_node **)malloc(sizeof(kal_ast_node*) * count);
    memcpy(node->multi.args, args, sizeof(kal_ast_node*) * count);
    return node;
}


//--------------------------------------
// Vdecls arguments AST
//--------------------------------------

kal_ast_node *kal_ast_vdecls_create(int count, kal_ast_node **args) {
    
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type =  KAL_AST_TYPE_VDECLS;
    node->multi.count = count;
    node->multi.args = (kal_ast_node **)malloc(sizeof(kal_ast_node*) * count);
    memcpy(node->multi.args, args, sizeof(kal_ast_node*) * count);
    return node;
}


//--------------------------------------
// Stmts arguments AST
//--------------------------------------

kal_ast_node *kal_ast_stmts_create(int count, kal_ast_node **args) {
    
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type =  KAL_AST_TYPE_STMTS;
    node->multi.count = count;
    node->multi.args = (kal_ast_node **)malloc(sizeof(kal_ast_node*) * count);
    memcpy(node->multi.args, args, sizeof(kal_ast_node*) * count);
    return node;
}


//--------------------------------------
// Exprs arguments AST
//--------------------------------------

kal_ast_node *kal_ast_exprs_create(int count, kal_ast_node **args) {
    
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type =  KAL_AST_TYPE_EXPRS;
    node->multi.count = count;
    node->multi.args = (kal_ast_node **)malloc(sizeof(kal_ast_node*) * count);
    memcpy(node->multi.args, args, sizeof(kal_ast_node*) * count);
    return node;
}


//--------------------------------------
// Extern AST
//--------------------------------------

kal_ast_node *kal_ast_exter_create(char* ret_type, char* globid, kal_ast_node *tdecls) {
  
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type =  KAL_AST_TYPE_EXTER;
    node->exter.ret_type  = strdup(ret_type);
    node->exter.globid = strdup(globid);
    node->exter.tdecls = tdecls;
    return node;
}
//--------------------------------------
// Function AST
//--------------------------------------

// Creates an AST node for a function declaration.
//
// body      - The body expression.
//
// Returns a Function AST Node.
kal_ast_node *kal_ast_function_create(char* ret_type, char* globid,
                                      kal_ast_node *vdecls, kal_ast_node *blk)
{
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type = KAL_AST_TYPE_FUNCTION;
    node->function.ret_type = strdup(ret_type);
    node->function.globid = strdup(globid);
    node->function.vdecls = vdecls;
    node->function.blk = blk;
    return node;
}


//--------------------------------------
// Blk AST
//--------------------------------------

kal_ast_node *kal_ast_blk_create(kal_ast_node *stmts) {
  
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type =  KAL_AST_TYPE_BLK;
    node->blk.stmts = stmts;
    return node;
}

//--------------------------------------
// Number AST
//--------------------------------------

// Creates an AST node for a number.
//
// value - The value of the AST.
//
// Returns a Number AST Node.
kal_ast_node *kal_ast_number_create(double value, char *type)
{
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type = KAL_AST_TYPE_NUMBER;
    node->number.value = value;
    node->number.type = strdup(type);
    return node;
}


//--------------------------------------
// Variable AST
//--------------------------------------

// Creates an AST node for a variable.
//
// name - The name of the variable.
//
// Returns a Variable AST Node.
kal_ast_node *kal_ast_variable_create(char* name, char *type)
{
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type = KAL_AST_TYPE_VARIABLE;
    node->variable.name = strdup(name);
    node->variable.type = strdup(type);
    return node;
}

//--------------------------------------
// Tdecls AST
//--------------------------------------

// Creates an AST node for a tdecls.
//
// Returns a Variable AST Node.
kal_ast_node *kal_ast_tdecls_create(int count, char **args)
{
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type = KAL_AST_TYPE_TDECLS;
    node->tdecls.count = count;
    node->tdecls.args = (char **)malloc(sizeof(char*) * count);
    for(int i=0; i < count; i++) {
        node->tdecls.args[i] = strdup(args[i]);
    }
    return node;
}


//--------------------------------------
// Vdecl AST
//--------------------------------------

// Creates an AST node for a vdecl.
//
// Returns a Variable AST Node.
kal_ast_node *kal_ast_vdecl_create(char *type, char *var)
{
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type = KAL_AST_TYPE_VDECL;
    node->vdecl.type = strdup(type);
    node->vdecl.var = strdup(var);
    return node;
}

//--------------------------------------
// Return AST
//--------------------------------------

// Creates an AST node for a return.
//
// Returns a Variable AST Node.
kal_ast_node *kal_ast_return_create(kal_ast_node *expr)
{
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type = KAL_AST_TYPE_RETURN;
    node->return_stmt.expr = expr;
    return node;
}


//--------------------------------------
// Expr Expression AST
//--------------------------------------

kal_ast_node *kal_ast_expr_create(kal_ast_node *expr)
{
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type = KAL_AST_TYPE_EXPR;
    node->expr.expr = expr;
    return node;
}


//--------------------------------------
// Vdecl Assignment Expression AST
//--------------------------------------

kal_ast_node *kal_ast_vdecl_assign_create(kal_ast_node *vdecl, kal_ast_node *expr)
{
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type = KAL_AST_TYPE_VDECL_ASSIGN;
    node->vdecl_assign.vdecl = vdecl;
    node->vdecl_assign.expr = expr;
    return node;
}


//--------------------------------------
// While Expression AST
//--------------------------------------

kal_ast_node *kal_ast_while_create(kal_ast_node *expr, kal_ast_node *stmt)
{
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type = KAL_AST_TYPE_WHILE;
    node->while_stmt.stmt = stmt;
    node->while_stmt.expr = expr;
    return node;
}



//--------------------------------------
// If Expression AST
//--------------------------------------

// Creates an AST node for an if statement.
//
// condition  - The condition to evaluate.
// true_expr  - The expression to evaluate if the condition is true.
// false_expr - The expression to evaluate if the condition is false.
//
// Returns a If Expression AST Node.
kal_ast_node *kal_ast_if_expr_create(kal_ast_node *condition,
                                     kal_ast_node *true_expr,
                                     kal_ast_node *false_expr)
{
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type = KAL_AST_TYPE_IF_EXPR;
    node->if_expr.condition = condition;
    node->if_expr.true_expr = true_expr;
    node->if_expr.false_expr = false_expr;
    return node;
}


//--------------------------------------
// Print Expression AST
//--------------------------------------

kal_ast_node *kal_ast_print_create(kal_ast_node *expr)
{
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type = KAL_AST_TYPE_PRINT_EXPR;
    node->print_stmt.expr = expr;
    return node;
}


//--------------------------------------
// Print Slit Expression AST
//--------------------------------------

kal_ast_node *kal_ast_print_slit_create(char *print_slit)
{
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type = KAL_AST_TYPE_PRINT_SLIT;
    node->print_slit.print_slit = strdup(print_slit);
    return node;
}

//--------------------------------------
// Binary Expression AST
//--------------------------------------

// Creates an AST node for a binary expression.
//
// op  - The operation being performed.
// lhs - The AST node for the left hand side of the expression.
// rhs - The AST node for the right hand side of the expression.
//
// Returns a Binary Expression AST Node.
kal_ast_node *kal_ast_binary_expr_create(kal_ast_binop_e op,
                                         kal_ast_node *lhs,
                                         kal_ast_node *rhs, char *type)
{
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type = KAL_AST_TYPE_BINARY_EXPR;
    node->binary_expr.op = op;
    node->binary_expr.lhs = lhs;
    node->binary_expr.rhs  = rhs;
    node->binary_expr.type = strdup(type);
    return node;
}


//--------------------------------------
// Unary Expression AST
//--------------------------------------

kal_ast_node *kal_ast_uop_expr_create(kal_ast_uop_e op, kal_ast_node *hs, char *type)
{
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type = KAL_AST_TYPE_UOP_EXPR;
    node->uop_expr.op = op;
    node->uop_expr.hs = hs;
    node->uop_expr.type = strdup(type);
    return node;
}

//--------------------------------------
// Function Call AST
//--------------------------------------

// Creates an AST node for a function call.
//
// name      - The name of the function being called.
// args      - A list of AST node expressions passed as arguments.
// arg_count - The number of arguments.
//
// Returns a Function Call AST Node.
kal_ast_node *kal_ast_call_create(char *globid, kal_ast_node *exprs, char *type) {
    kal_ast_node *node = (kal_ast_node *)malloc(sizeof(kal_ast_node));
    node->type = KAL_AST_TYPE_CALL; 
    node->call.globid = strdup(globid);
    node->call.exprs = exprs;
    node->call.type = strdup(type);
    return node;
}



