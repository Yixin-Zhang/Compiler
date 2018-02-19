
//==============================================================================
//
// Code Generation Functions Implementations
//
//==============================================================================

// TODO: fill in detailed implementations.

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
