#ifndef _codegen_h
#define _codegen_h

#include "ast.h"

#include "llvm/include/llvm/IR/Module.h"
#include "llvm/include/llvm/IR/Function.h"
#include "llvm/include/llvm/IR/PassManager.h"
#include "llvm/include/llvm/CallingConv.h"
#include "llvm/include/llvm/Analysis/Verifier.h"
#include "llvm/include/llvm/Assembly/PrintModulePass.h"
#include "llvm/include/llvm/Support/IRBuilder.h"
#include "llvm/include/llvm/Support/raw_ostream.h"


// Used to hold references to arguments by name.
typedef struct kal_named_value {
    const char *name;             
    LLVMValueRef value;
    UT_hash_handle hh;
} kal_named_value;


//==============================================================================
//
// Functions
//
//==============================================================================

//--------------------------------------
// Codegen
//--------------------------------------

LLVMValueRef kal_codegen(kal_ast_node *node, LLVMModuleRef module,
    LLVMBuilderRef builder);


//--------------------------------------
// Utility
//--------------------------------------

void kal_codegen_reset();

kal_named_value *kal_co


#endif