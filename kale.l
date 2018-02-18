%{
#include <iostream>
using namespace std;
#define YY_DECL extern "C" int yylex()
#include "kale.tab.h" 
%}
%%


"*"           {return TIMES;}
"/"           {return SLASH;}
"+"           {return PLUS;}
"-"           {return MINUS;}
"=="          {return EQL;}
"="           {return ASSIGN;}
"<"           {return LSS;}
">"           {return GTR;}
"&&"          {return AND;}
"||"          {return OR;}
"!"           {return NOT;}

"("           {return LP;}
")"           {return RP;}
";"           {return SEMICOLON;}
"{"           {return LB;}
"}"           {return RB;}
","           {return COMMA;}
"$"           {return DOLLOR;}

"extern"      {return EXTERNSYM;}
"def"         {return DEFSYM;}
"return"      {return RETURNSYM;}
"while"       {return WHILESYM;}
"if"          {return IFSYM;}
"print"       {return PRINTSYM;}
"else"        {return ELSESYM;}
"int"         {return INTTYPE;}
"cint"        {return CINTTYPE;}
"float"       {return FLOATTYPE;}
"sfloat"      {return SFLOATTYPE;}
"void"        {return VOIDTYPE;}
"ref"         {return REFTYPE;}
"noalias"     {return NOALIASTYPE;}


#[^\n]*\n  		 ;
[ \t\n]          ;
[0-9]+(\.[0-9]+)?   { yylval.fval = atof(yytext); return LITERAL;}
[a-zA-Z_]+[a-zA-Z0-9_]*     { yylval.identifer = strdup(yytext); return IDENTIFER; }
\"[^"]*\"         { yylval.sval = strdup(yytext); return STRING;}
.                ;
%%

