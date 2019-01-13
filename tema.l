%option noyywrap
%{
	//#include "header.h"
	#include "y.tab.h"
	

//DUPA END LA FINAL ESTE .

	extern int lineNo ;
	extern int colNo ;
	extern int EsteCorecta;
%}

%%
"PROGRAM"			{ colNo++; return TOK_PROGRAM; }
"VAR"				{ colNo++; return TOK_VAR; }
"BEGIN"				{ colNo++; return TOK_BEGIN; }
"END"				{ colNo++; return TOK_END; }
"id"				{ colNo++; return TOK_ID; }
";"				{ colNo++; return ';'; }
":"				{ colNo++; return ':'; }
","				{ colNo++; return ','; }
"INTEGER"			{ colNo++; return TOK_INTEGER; }
":="				{ colNo++; return TOK_ATTRIBUTE; }
"+"				{ colNo++; return TOK_ADD; }
"-"				{ colNo++; return TOK_MINUS; }
"*"				{ colNo++; return TOK_MUL; }
"DIV"				{ colNo++; return TOK_DIV; }
"("				{ colNo++; return TOK_LEFT; }
")"				{ colNo++; return TOK_RIGHT; }
"READ"				{ colNo++; return TOK_READ; }
"WRITE"				{ colNo++; return TOK_WRITE; }
"FOR"				{ colNo++; return TOK_FOR; }
"DO"				{ colNo++; return TOK_DO; }
"TO"				{ colNo++; return TOK_TO; }
\.				{ colNo++; return TOK_POINT; }
(0|([1-9][0-9]*))	{  yylval.intVal = atoi(yytext); colNo+=strlen(yytext); yylval.intVal=atoi(yytext); return TOK_INT; }
[_a-zA-Z][_a-zA-Z0-9]* { yylval.strVal=strdup(yytext); colNo+=strlen(yytext); return TOK_ID;}				

[ ]				{ colNo++; }
\r\n				{ lineNo++; colNo=1; }
\n				{ lineNo++; colNo=1; }
.				{ colNo++; printf("Eroare lexicala: %s Nu face parte din alfabet!\n",yytext); EsteCorecta =0; }


%%
