
%{
// Secao do Flex de definicao de vriaveis da linguagem C, e inclusap  de arquivos de cabecalho
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include "tipos.h"
#include "Sintatico.h"
char msg[500];
extern void yyerror( char const   *s); 
int numLinha=1;
int erroOrigem=1;
int num_erro = 0;
%}

/*Secao do Flex destinada a definicoes regulares */

DIGIT [0-9]
PALAVRA [a-zA-Z_]
%x Comentario

%%

"/*"		    BEGIN(Comentario);
<Comentario>[^*\n]*  /*se esta em uma start condition correspondente a comentario, consome 
                                    qualquer caractere que nao seja * ou \n */

<Comentario>"*"+[^/\n]  
<Comentario><<EOF>> {
                    strcpy(msg,"ERRO: COMENTÁRIO NÃO TERMINA");
		    erroOrigem = 0; /* erro lexico */ 
		    yyerror(msg);
                  }
<Comentario>\n numLinha++;    
<Comentario>"*"+"/"    BEGIN(INITIAL);


"programa" 		{yylval.nlinha= numLinha ;return PROGRAMA;}
"car" 			{yylval.nlinha= numLinha ;return CAR;}
"int" 			{yylval.nlinha= numLinha ;return INT;}
"retorne" 		{yylval.nlinha= numLinha ;return RETORNE;}
"leia" 			{yylval.nlinha= numLinha ;return LEIA;}
"escreva" 		{yylval.nlinha= numLinha ;return ESCREVA;}
"novalinha" 	{yylval.nlinha= numLinha ;return NOVALINHA;}
"se" 			{yylval.nlinha= numLinha ;return SE;}
"entao" 		{yylval.nlinha= numLinha ;return ENTAO;}
"senao" 		{yylval.nlinha= numLinha ;return SENAO;}
"enquanto" 		{yylval.nlinha= numLinha ;return ENQUANTO;}
"execute" 		{yylval.nlinha= numLinha ;return EXECUTE;}


"+" 			{yylval.nlinha= numLinha ;return MAIS; }
"-" 			{yylval.nlinha= numLinha ;return MENOS; }
"*" 			{yylval.nlinha= numLinha ;return VEZES; }
"/" 			{yylval.nlinha= numLinha ;return DIVIDIDO; }
"%" 			{yylval.nlinha= numLinha ;return RESTO; }
"="			 	{yylval.nlinha= numLinha ;return IGUAL; }
"=="			{yylval.nlinha= numLinha ;return IGUALIGUAL; }
">" 			{yylval.nlinha= numLinha ;return MAIOR; }
">="			{yylval.nlinha= numLinha ;return MAIORIGUAL; }
"<" 			{yylval.nlinha= numLinha ;return MENOR; }
"<="			{yylval.nlinha= numLinha ;return MENORIGUAL; }
"&&"			{yylval.nlinha= numLinha ; return E; }
"||"			{yylval.nlinha= numLinha ; return OU; }
"!" 			{yylval.nlinha= numLinha ; return EXCLAMACAO; }
"("			 	{yylval.nlinha= numLinha ; return ABRI_PAREN; }	
")" 			{yylval.nlinha= numLinha ; return FECHA_PAREN; }
"[" 			{yylval.nlinha= numLinha ; return ABRI_COLCHETES; }
"]" 			{yylval.nlinha= numLinha ; return FECHA_COLCHETES; }
"{" 			{yylval.nlinha= numLinha ; return ABRI_CHAVE; }
"}" 			{yylval.nlinha= numLinha ; return FECHA_CHAVE; }
"?" 			{yylval.nlinha= numLinha ; return INTERROGACAO; }
":" 			{yylval.nlinha= numLinha ; return DOISPONTOS; }
";" 			{yylval.nlinha= numLinha ; return PONTOEVIRGULA; }
"," 			{yylval.nlinha= numLinha ; return VIRGULA; }


[A-Za-z][A-Za-z_0-9]*	{yylval.nlinha= numLinha ;return ID;}
[0-9]+ 					{yylval.nlinha= numLinha ; return CONSINT; }
[A-Za-z_0-9]+ 			{yylval.nlinha= numLinha ; return CONSCAR; } 
\"(\\.|[^\\"])*\"		{yylval.nlinha= numLinha ;return CADEIACARACTERES;} 
[ \t\r] 				{}

\n 			numLinha++;

{PALAVRA}({PALAVRA}|{DIGIT})*(\r|\n|\r\n){PALAVRA}({PALAVRA}|{DIGIT})* {
					erroOrigem = 0; /* erro lexico */ 
					strcpy(msg,"ERRO: Palavra não termina");
					yyerror(msg);
			}

. 			{		
					erroOrigem = 0; /* erro lexico */ 
					strcpy(msg,"ERRO: CARACTER INVÁLIDO");
					yyerror(msg);
			}

%%
int yywrap(){return 1;}