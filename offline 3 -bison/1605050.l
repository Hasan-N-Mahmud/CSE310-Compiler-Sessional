%{
#include<iostream>
#include<stdlib.h>
#include<string.h>
#include<stdio.h>
#include "1605050_symbolTable.h"
#include "y.tab.h"


using namespace std;

extern YYSTYPE yylval;
//extern SymbolTable *table;
void yyerror(char *);

extern int line_count;
extern int error;


%}



digit [0-9]
letter [A-Za-z]
delim [ \t\r\f\v]
newline \n
ws [delim]+
id (_|{letter})(_|{letter}|{digit})*
integer {digit}+
number {digit}*(\.{digit}+)?(E[+-]?{digit}+)?
ADDOP [+-]
MULOP [*/%]

%%

{delim}+	{}
{newline} {line_count++;}

"if" {return IF;}
"else" {return ELSE;}
"for" {return FOR;}
"while" {return WHILE;}
"int" {return INT;}
"float" {return FLOAT;}
"double" {return DOUBLE;}
"char" {return CHAR;}
"return" {return RETURN;}
"void" {return VOID;}
"main"	{return MAIN;}
"println"	{return PRINTLN;}

{ADDOP} {
  string s1 = "ADDOP";
  string s2 = yytext;
			SymbolInfo *s= new  SymbolInfo(s2, s1);
			yylval.info = (SymbolInfo*)s;
			return ADDOP;
		}



{MULOP}	{
			/* SymbolInfo *s= new  SymbolInfo(yytext, (char *)"MULOP");
			yylval = (YYSTYPE)s;
			return MULOP; */
		}


"=" 	{return ASSIGNOP;}

">" |
"<" |
">=" |
"<=" |
"==" |
"!=" {
		/* SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RELOP");
		yylval = (YYSTYPE)s;
		return RELOP; */
	}

"&&"	|
"||"	{
			/* SymbolInfo *s= new  SymbolInfo(yytext, (char *)"LOGICOP");
			yylval = (YYSTYPE)s;
			return LOGICOP; */
		}
"!"		{	return NOT; }


";" 	{ return SEMICOLON;}
"," 	{return COMMA;}
"(" 	{return LPAREN;}
")" 	{return RPAREN;}
"{" 	{return LCURL;}
"}" 	{return RCURL;}
"[" 	{return LTHIRD;}
"]" 	{return RTHIRD;}
"++" 	{return INCOP;}
"--" 	{return DECOP;}



{integer}	{
  string s1 = "CONST_INT";
  string s2 = yytext;
      SymbolInfo *s= new  SymbolInfo(s2, s1);
      yylval.info = (SymbolInfo*)s;
      return CONST_INT;
			}
{number} 	{
				/* SymbolInfo *s= new  SymbolInfo(yytext, (char *)"CONST_FLOAT");
				yylval = (YYSTYPE)s;
				return CONST_FLOAT; */
			}
{id} 		{

				/* SymbolInfo *s= table->lookup(yytext);
				if(s==NULL)
				{
					s= new SymbolInfo(yytext, (char *)"ID");
				}
				yylval = (YYSTYPE)s; */

				return ID;
			}


%%

int yywrap(void)
{
	return 1;
}
