#include "codegen.h"
#include "ast.h"

#include <iostream>

using namespace std;

extern int yyparse();
extern kal_ast_node* root;

int main(int argc, char **argv) {

	// TODO: parse command line args
	cout << "Parsing " << argv[3] << " ..." << endl;
    kale_parse(argv[3]);

    cout << "Generating code ..." << endl;
    CodeGenContext context;
    context.generateCode(*root);
    
    cout << "Running code ..." << endl;
    context.runCode();

    cout << "Done." << endl;
    return 0;
}
