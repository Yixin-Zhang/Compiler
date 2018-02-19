#include <string>
using namespace std;
//==============================================================================
//
// Definitions
//
//==============================================================================

// Defines the types of expressions available.
enum kal_ast_node_type_e {
    KAL_AST_TYPE_PROG,
    
    KAL_AST_TYPE_EXTERS,
    KAL_AST_TYPE_EXTER,
    KAL_AST_TYPE_TDECLS,
    
    KAL_AST_TYPE_FUNCTIONS,
    KAL_AST_TYPE_FUNCTION,
    KAL_AST_TYPE_VDECLS,
    KAL_AST_TYPE_VDECL,
    
    KAL_AST_TYPE_BLK,
    KAL_AST_TYPE_STMTS,
    KAL_AST_TYPE_RETURN,
    KAL_AST_TYPE_VDECL_ASSIGN,
    KAL_AST_TYPE_WHILE,
    KAL_AST_TYPE_IF_EXPR,
    KAL_AST_TYPE_EXPR,
    KAL_AST_TYPE_PRINT_EXPR,
    KAL_AST_TYPE_PRINT_SLIT,
    
    KAL_AST_TYPE_BINARY_EXPR,
    KAL_AST_TYPE_UOP_EXPR,
    KAL_AST_TYPE_NUMBER,
    KAL_AST_TYPE_VARIABLE,
    KAL_AST_TYPE_CALL,
    KAL_AST_TYPE_EXPRS,
    
};

// Defines the types of binary expressions.
enum kal_ast_binop_e {
    KAL_BINOP_PLUS,
    KAL_BINOP_MINUS,
    KAL_BINOP_MUL,
    KAL_BINOP_DIV,
    KAL_BINOP_EQL,
    KAL_BINOP_LSS,
    KAL_BINOP_GTR,
    KAL_BINOP_AND,
    KAL_BINOP_OR,
    KAL_BINOP_ASSIGN,
};

// Defines the types of unary expressions.
enum kal_ast_uop_e {
    KAL_UOP_NOT,
    KAL_UOP_MINUS,
};

struct kal_ast_node;

// Represents a program in the AST.
struct kal_ast_prog {
    struct kal_ast_node *exters;
    struct kal_ast_node *functions;
};

// Represents a node which may have multiple arguments in the AST.
struct kal_ast_multi {
    int count = 0;
    struct kal_ast_node **args;
};

// Represents a extern in the AST.
struct kal_ast_exter {
    char* ret_type;
    char* globid;
    struct kal_ast_node *tdecls;
};

// Represents a variable in the AST.
struct kal_ast_variable {
    char* name;
    char* type;
};

// Represents a extern tdecls node in the AST.
struct kal_ast_tdecls {
    char **args;
    int count;
};

// Represents a function in the AST.
struct kal_ast_function {
    char* ret_type;
    char* globid;
    struct kal_ast_node *vdecls;
    struct kal_ast_node *blk;
};

// Represents a vdecl in the AST.
struct kal_ast_vdecl {
    char* type;
    char* var;
};

// Represents a BLK in the AST.
struct kal_ast_blk {
    struct kal_ast_node *stmts;
};

// Represents a return stmt in the AST.
struct kal_ast_return {
    struct kal_ast_node *expr;
};

// Represents a expr stmt in the AST.
struct kal_ast_expr {
    struct kal_ast_node *expr;
};

// Represents a vdecl assignment stmt in the AST.
struct kal_ast_vdecl_assign {
    struct kal_ast_node *vdecl;
    struct kal_ast_node *expr;
};

// Represents a while stmt in the AST.
struct kal_ast_while {
    struct kal_ast_node *expr;
    struct kal_ast_node *stmt;
};

// Represents an if stmt in the AST.
struct kal_ast_if_expr {
    struct kal_ast_node *condition;
    struct kal_ast_node *true_expr;
    struct kal_ast_node *false_expr;
};

// Represents a print stmt in the AST.
struct kal_ast_print {
    struct kal_ast_node *expr;
};

// Represents a print slit stmt in the AST.
struct kal_ast_print_slit {
    char* print_slit;
};

// Represents a binary expression in the AST.
struct kal_ast_binary_expr {
    kal_ast_binop_e op;
    struct kal_ast_node *lhs;
    struct kal_ast_node *rhs;
    char* type;
};

// Represents a uop expression in the AST.
struct kal_ast_uop_expr {
    kal_ast_uop_e op;
    struct kal_ast_node *hs;
    char* type;
};

// Represents a variable in the AST.
struct kal_ast_call {
    char* globid;
    struct kal_ast_node *exprs;
    char* type;
};

// Represents a number in the AST.
struct kal_ast_number {
    double value;
    char* type;
};

// Represents an expression in the AST.
struct kal_ast_node {
    kal_ast_node_type_e type;
    union {
        kal_ast_prog prog;
        kal_ast_multi multi;
        kal_ast_exter exter;
        kal_ast_variable variable;
        kal_ast_tdecls tdecls;
        kal_ast_function function;
        kal_ast_vdecl vdecl;
        kal_ast_blk blk;
        kal_ast_return return_stmt;
        kal_ast_vdecl_assign vdecl_assign;
        kal_ast_while while_stmt;
        kal_ast_if_expr if_expr;
        kal_ast_expr expr;
        kal_ast_print print_stmt;
        kal_ast_print_slit print_slit;
        kal_ast_binary_expr binary_expr;
        kal_ast_uop_expr uop_expr;
        kal_ast_call call;
        kal_ast_number number;
    };
};



//==============================================================================
//
// Functions
//
//==============================================================================

kal_ast_node *kal_ast_prog_create(kal_ast_node *exters, kal_ast_node *functions);

kal_ast_node *kal_ast_functions_create(int count, kal_ast_node **args);

kal_ast_node *kal_ast_exters_create(int count, kal_ast_node **args);

kal_ast_node *kal_ast_vdecls_create(int count, kal_ast_node **args);

kal_ast_node *kal_ast_stmts_create(int count, kal_ast_node **args);

kal_ast_node *kal_ast_exprs_create(int count, kal_ast_node **args);

kal_ast_node *kal_ast_exter_create(char* ret_type, char* globid, kal_ast_node *tdecls);

kal_ast_node *kal_ast_variable_create(char* name, char* type);

kal_ast_node *kal_ast_tdecls_create(int count, char **args);

kal_ast_node *kal_ast_function_create(char* ret_type, char* globid, kal_ast_node *vdecls, kal_ast_node *blk);

kal_ast_node *kal_ast_vdecl_create(char* type, char* var);

kal_ast_node *kal_ast_blk_create(kal_ast_node *stmts);

kal_ast_node *kal_ast_return_create(kal_ast_node *expr);

kal_ast_node *kal_ast_expr_create(kal_ast_node *expr);

kal_ast_node *kal_ast_vdecl_assign_create(kal_ast_node *vdecl, kal_ast_node *expr);

kal_ast_node *kal_ast_while_create(kal_ast_node *expr, kal_ast_node *stmt);

kal_ast_node *kal_ast_if_expr_create(kal_ast_node *condition, kal_ast_node *true_expr, kal_ast_node *false_expr);

kal_ast_node *kal_ast_print_create(kal_ast_node *expr);

kal_ast_node *kal_ast_print_slit_create(char* print_slit);

kal_ast_node *kal_ast_binary_expr_create(kal_ast_binop_e op, kal_ast_node *lhs, kal_ast_node *rhs, char *type);

kal_ast_node *kal_ast_uop_expr_create(kal_ast_uop_e op, kal_ast_node *hs, char *type);

kal_ast_node *kal_ast_call_create(char* globid, kal_ast_node *exprs, char *type);

kal_ast_node *kal_ast_number_create(double value, char *type);



//==============================================================================
//
// Code Generation Functions
//
//==============================================================================

Value* kal_ast_prog_codegen(CodeGenContext& context, kal_ast_node *node);

Value* kal_ast_functions_codegen(CodeGenContext& context, kal_ast_node *node);

Value* kal_ast_exters_codegen(CodeGenContext& context, kal_ast_node *node);

Value* kal_ast_vdecls_codegen(CodeGenContext& context, kal_ast_node *node);

Value* kal_ast_stmts_codegen(CodeGenContext& context, kal_ast_node *node);

Value* kal_ast_exprs_codegen(CodeGenContext& context, kal_ast_node *node);

Value* kal_ast_exter_codegen(CodeGenContext& context, kal_ast_node *node);

Value* kal_ast_variable_codegen(CodeGenContext& context, kal_ast_node *node);

Value* kal_ast_tdecls_codegen(CodeGenContext& context, kal_ast_node *node);

Value* kal_ast_function_codegen(CodeGenContext& context, kal_ast_node *node);

Value* kal_ast_vdecl_codegen(CodeGenContext& context, kal_ast_node *node);

Value* kal_ast_blk_codegen(CodeGenContext& context, kal_ast_node *node);

Value* kal_ast_return_codegen(CodeGenContext& context, kal_ast_node *node);

Value* kal_ast_expr_codegen(CodeGenContext& context, kal_ast_node *node);

Value* kal_ast_vdecl_assign_codegen(CodeGenContext& context, kal_ast_node *node);

Value* kal_ast_while_codegen(CodeGenContext& context, kal_ast_node *node);

Value* kal_ast_if_expr_codegen(CodeGenContext& context, kal_ast_node *node);

Value* kal_ast_print_codegen(CodeGenContext& context, kal_ast_node *node);

Value* kal_ast_print_slit_codegen(CodeGenContext& context, kal_ast_node *node);

Value* kal_ast_binary_expr_codegen(CodeGenContext& context, kal_ast_node *node);

Value* kal_ast_uop_expr_codegen(CodeGenContext& context, kal_ast_node *node);

Value* kal_ast_call_codegen(CodeGenContext& context, kal_ast_node *node);

Value* kal_ast_number_create(CodeGenContext& context, kal_ast_node *node);
