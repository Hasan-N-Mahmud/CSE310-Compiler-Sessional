%{
#include<cstdio>
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
//#define YYSTYPE SymbolInfo*
#include "1605050_symbolTable.h"

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
FILE *fp;
FILE *error=fopen("error.txt","w");
FILE *parser= fopen("parsertext.txt","w");

int line_count=1;
int error_count=0;

SymbolTable st(20);


void yyerror(char *s)
{
	//write your code
}


%}

%token IF ELSE FOR WHILE DO BREAK MAIN
%token INT FLOAT CHAR DOUBLE VOID
%token RETURN SWITCH CASE DEFAULT CONTINUE
%token CONST_INT CONST_FLOAT CONST_CHAR
%token ADDOP MULOP INCOP RELOP ASSIGNOP LOGICOP BITOP NOT DECOP
%token LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON
%token STRING ID PRINTLN
%type <info>type_specifier
%type <info> factor

%union{
	SymbolInfo * info;
}


%%

start : program
	{
    printf("in");

    //write your code in this block in all the similar blocks below
	}
	;

program : program unit{

}
	| unit
	;

unit : var_declaration
     | func_declaration
     | func_definition
     ;

func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
		| type_specifier ID LPAREN RPAREN SEMICOLON
		;

func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
		| type_specifier ID LPAREN RPAREN compound_statement
 		;


parameter_list  : parameter_list COMMA type_specifier ID
		| parameter_list COMMA type_specifier
 		| type_specifier ID
		| type_specifier
 		;


compound_statement : LCURL statements RCURL
 		    | LCURL RCURL
 		    ;

var_declaration : type_specifier declaration_list SEMICOLON
 		 ;

type_specifier	: INT{
          $$ = new SymbolInfo();

				}
 		| FLOAT{$$ = new SymbolInfo();}
 		| VOID{$$ = new SymbolInfo();}
 		;

declaration_list : declaration_list COMMA ID
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
 		  | ID
 		  | ID LTHIRD CONST_INT RTHIRD
 		  ;

statements : statement
	   | statements statement
	   ;

statement : var_declaration
	  | expression_statement
	  | compound_statement
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  | IF LPAREN expression RPAREN statement
	  | IF LPAREN expression RPAREN statement ELSE statement
	  | WHILE LPAREN expression RPAREN statement
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  | RETURN expression SEMICOLON
	  ;

expression_statement 	: SEMICOLON
			| expression SEMICOLON
			;

variable : ID
	 | ID LTHIRD expression RTHIRD
	 ;

 expression : logic_expression
	   | variable ASSIGNOP logic_expression
	   ;

logic_expression : rel_expression
		 | rel_expression LOGICOP rel_expression
		 ;

rel_expression	: simple_expression
		| simple_expression RELOP simple_expression
		;

simple_expression : term
		  | simple_expression ADDOP term
		  ;

term :	unary_expression
     |  term MULOP unary_expression
     ;

unary_expression : ADDOP unary_expression
		 | NOT unary_expression
		 | factor
		 ;

factor	: variable{$$ = new SymbolInfo();}
	| ID LPAREN argument_list RPAREN{$$ = new SymbolInfo();}
	| LPAREN expression RPAREN{$$ = new SymbolInfo();}
	| CONST_INT {
      $$ = new SymbolInfo();
      //fprintf(parser,"Line at %d : factor->CONST_INT\n\n",line_count);
      //fprintf(parser,"%s\n\n",str2.c_str());

  }
	| CONST_FLOAT{$$ = new SymbolInfo();}
	| variable INCOP{$$ = new SymbolInfo();}
	| variable DECOP{$$ = new SymbolInfo();}
	;

argument_list : arguments
			  |
			  ;

arguments : arguments COMMA logic_expression
	      | logic_expression
	      ;


%%
int main(int argc,char *argv[])
{
	FILE * fp;

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	yyin=fp;
	yyparse();

  fclose(error);
  fclose(parser);
  printf("1");
	return 0;
}
