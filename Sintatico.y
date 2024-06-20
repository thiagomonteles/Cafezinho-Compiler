%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tipos.h"

extern char * yytext;
extern int yylex();
extern int numLinha;
extern FILE* yyin;
extern int erroOrigem;
void yyerror( char const *s);
//Definicões das funções utilizadas na Árvore Abstrata

Toperador* CriaNoTernario(TespecieOperador tipoOperador,  int linha, Toperador* filho1, Toperador* filho2,Toperador* filho3, char* lexema);
void percorreArvore(Toperador* raiz);
void obtemEspecieNoEnumLin(Toperador* no, char* nomeOperador);
void printTenario(Toperador* raiz, int nivel);

Toperador* raiz;
char nomeOperador[200];

%}
/* Secao de definicoes para o Bison 
 define os simbolos usados na gramatica e tipos dos valores
 semanticos associados a cada simbolo (terminal e não terminal)*/

/* UNION para os valores da pilha semantica do YACC. Os elementos dessa pilha sao acessados através 
das referências $$, $1, ...Sn. Iremos construir a AST para a linguagem passando os enderecos dos nos da
arvore atraves da pilha semantica do parser gerado pelo YACC */
%union{
    int nlinha;
    char* cadeia;
    Toperador* Tpont;
}

/*
Cada elemento da pilha semântica e do tipo union acima. Isso significa que um elemento da pilha ora e um
int (linha), ora e um ponteiro para algum no da arvore, ora e um ponteiro para char
*/
%start  Programa /* Inidica que o simbolo incial da gramatica e programm */
%type<Tpont> DeclFuncVar DeclProg DeclVar DeclFunc ListaParametros ListaParametrosCont Bloco ListaDeclVar 
%type<Tpont> Tipo ListaComando Comando Expr AssignExpr CondExpr OrExpr AndExpr EqExpr DesigExpr AddExpr MulExpr UnExpr LValueExpr PrimExpr ListExpr


/* Definicao de terminais (que não são apenas caracteres), com o uso da diretiva %token. */
%token PROGRAMA ID CAR INT RETORNE LEIA ESCREVA NOVALINHA SE ENTAO SENAO ENQUANTO 
%token EXECUTE CONSINT CONSCAR CADEIACARACTERES MAIS MENOS VEZES DIVIDIDO RESTO 
%token IGUAL IGUALIGUAL MAIOR MAIORIGUAL MENOR MENORIGUAL E OU 
%token ABRI_PAREN FECHA_PAREN  ABRI_COLCHETES  FECHA_COLCHETES ABRI_CHAVE FECHA_CHAVE 
%token INTERROGACAO EXCLAMACAO DOISPONTOS PONTOEVIRGULA VIRGULA 

%% /* Secao de regras - producoes da gramatica - Veja as normas de formação de produçoes na 
       secao 3.3 do manual */



Programa : DeclFuncVar DeclProg                             {raiz = CriaNoTernario(Programa ,numLinha,$1,$2,NULL,NULL);}

DeclFuncVar : Tipo ID DeclVar PONTOEVIRGULA DeclFuncVar                             {$$ = CriaNoTernario(DeclFuncVar1,numLinha,$1,$3,$5,NULL);}
            | Tipo ID  ABRI_COLCHETES CONSINT FECHA_COLCHETES  DeclVar PONTOEVIRGULA DeclFuncVar   {$$ = CriaNoTernario(DeclFuncVar1,numLinha,$1,$6,$8,NULL);} 
            | Tipo ID DeclFunc DeclFuncVar                                          {$$ = CriaNoTernario(DeclFuncVar2,numLinha,$1,$3,$4,NULL);}
            | /*cadeia vazia */                                                     {$$=NULL;}
            ;

DeclProg    : PROGRAMA Bloco                                {$$ = $2;}
            ;

DeclVar     : VIRGULA ID DeclVar                            {$$ = $3;}
            | VIRGULA ID  ABRI_COLCHETES CONSINT FECHA_COLCHETES  DeclVar  {$$ = $6;}
            | /*cadeia vazia */                             {$$=NULL;}
            ;
            
DeclFunc    :  ABRI_PAREN ListaParametros FECHA_PAREN  Bloco {$$ = CriaNoTernario(DeclFunc ,numLinha,$2,$4,NULL,NULL);}
            ;

ListaParametros :                           {$$=NULL;}
                |ListaParametrosCont        {$$=$1;}
                ;           
            
ListaParametrosCont : Tipo ID                                               {$$=$1;}
                    | Tipo ID ABRI_COLCHETES  FECHA_COLCHETES                              {$$=$1;}
                    | Tipo ID VIRGULA  ListaParametrosCont                  {$$ = CriaNoTernario(ListaParametrosCont2 ,numLinha,$1,$4,NULL,NULL);}
                    | Tipo ID ABRI_COLCHETES  FECHA_COLCHETES VIRGULA ListaParametrosCont  {$$ = CriaNoTernario(ListaParametrosCont3 ,numLinha,$1,$6,NULL,NULL);}
                    ;
                    
Bloco               :  ABRI_CHAVE ListaDeclVar ListaComando FECHA_CHAVE {$$ = CriaNoTernario(Bloco ,numLinha,$2,$3, NULL, NULL);}
                    |  ABRI_CHAVE  ListaDeclVar  FECHA_CHAVE            {$$=$2;}
                    ;
                    
ListaDeclVar        :                                                                           {$$=NULL;}
                    | Tipo ID DeclVar PONTOEVIRGULA ListaDeclVar                                {$$ = CriaNoTernario(ListaDeclVar,numLinha,$1,$3,$5,NULL);}
                    | Tipo ID  ABRI_COLCHETES  CONSINT  FECHA_COLCHETES  DeclVar PONTOEVIRGULA ListaDeclVar    {$$ = CriaNoTernario(VetorDeclVar,numLinha,$1,$6,$8,NULL);}
                    ;
                    
Tipo                : INT                                       {$$ = CriaNoTernario(Tipo ,numLinha,NULL,NULL,NULL ,"int");}
                    | CAR                                       {$$ = CriaNoTernario(Tipo,numLinha,NULL,NULL,NULL,"car");}
                    ;
            
ListaComando        : Comando                                   {$$ = $1;}
                    | Comando ListaComando                      {$$ = CriaNoTernario(ListaComando ,numLinha,$1,$2,NULL,NULL);}
                    ;
                    
Comando             : PONTOEVIRGULA                                             {$$=NULL;}
                    | Expr PONTOEVIRGULA                                        {$$=$1;}
                    | RETORNE Expr PONTOEVIRGULA                                {$$ = CriaNoTernario(Retorne ,numLinha,$2,NULL,NULL,NULL);}
                    | LEIA LValueExpr PONTOEVIRGULA                             {$$ = CriaNoTernario(Leia ,numLinha,$2,NULL,NULL,NULL);}
                    | ESCREVA Expr PONTOEVIRGULA                                {$$ = CriaNoTernario(Escreva ,numLinha,$2,NULL,NULL,NULL);}
                    | ESCREVA CADEIACARACTERES PONTOEVIRGULA                    {$$ = CriaNoTernario(EscrevaC ,numLinha,NULL,NULL,NULL,NULL);}
                    | NOVALINHA PONTOEVIRGULA                                   {$$ = CriaNoTernario(NovaLinha ,numLinha,NULL,NULL,NULL,NULL);}
                    | SE  ABRI_PAREN  Expr  FECHA_PAREN  ENTAO Comando                 {$$ =CriaNoTernario(Se ,numLinha,$3,$6, NULL,NULL);}
                    | SE  ABRI_PAREN  Expr  FECHA_PAREN  ENTAO Comando SENAO Comando   {$$ = CriaNoTernario(SeSenao,numLinha,$3,$6,$8, NULL);}
                    | ENQUANTO  ABRI_PAREN  Expr  FECHA_PAREN  EXECUTE Comando         {$$ = CriaNoTernario(Enquanto ,numLinha,$3,$6, NULL,NULL);}
                    | Bloco                                                     {$$=$1;}
                    ;

Expr                : AssignExpr {$$=$1;}
                    ;
                    
AssignExpr          : CondExpr                    {$$=$1;}
                    | LValueExpr IGUAL AssignExpr {$$ = CriaNoTernario(Atribuir ,numLinha,$1,$3, NULL,NULL);}
                    ;
                    
CondExpr            : OrExpr                                       {$$=$1;}
                    | OrExpr INTERROGACAO Expr DOISPONTOS CondExpr {$$ = CriaNoTernario(SeTernario,numLinha,$1,$3,$5, NULL);}
                    ;
        
OrExpr              : OrExpr OU AndExpr {$$ = CriaNoTernario(Ou,numLinha,$1,$3, NULL,NULL);}
                    | AndExpr           {$$=$1;}
                    ;
                    
AndExpr             : AndExpr E EqExpr {$$ = CriaNoTernario(And,numLinha,$1,$3, NULL, NULL);}
                    | EqExpr            {$$=$1;}
                    ;
                    
EqExpr              : EqExpr IGUALIGUAL DesigExpr       {$$ = CriaNoTernario(IgualIgual,numLinha,$1,$3, NULL,NULL);}
                    | EqExpr EXCLAMACAO IGUAL DesigExpr {$$ = CriaNoTernario(Diferente,numLinha,$1,$4, NULL,NULL);}
                    | DesigExpr                         {$$=$1;}
                    ;

DesigExpr           : DesigExpr MENOR AddExpr       {$$ = CriaNoTernario(Menor,numLinha,$1,$3, NULL,NULL);}
                    | DesigExpr MAIOR AddExpr       {$$ = CriaNoTernario(Maior,numLinha,$1,$3, NULL,NULL);}
                    | DesigExpr MAIORIGUAL AddExpr  {$$ = CriaNoTernario(MaiorIgual,numLinha,$1,$3, NULL,NULL);}
                    | DesigExpr MENORIGUAL AddExpr  {$$ = CriaNoTernario(MenorIgual,numLinha,$1,$3, NULL,NULL);}
                    | AddExpr                       {$$=$1;} 
                    ;

AddExpr             : AddExpr MAIS MulExpr  {$$ = CriaNoTernario(Mais,numLinha,$1,$3, NULL,NULL);}
                    | AddExpr MENOS MulExpr {$$ = CriaNoTernario(Menos,numLinha,$1,$3, NULL,NULL);}
                    | MulExpr               {$$=$1;}
                    ;
                    
MulExpr             : MulExpr VEZES UnExpr      {$$ = CriaNoTernario(Mult,numLinha,$1,$3, NULL,NULL);}
                    | MulExpr DIVIDIDO UnExpr   {$$ = CriaNoTernario(Divisao,numLinha,$1,$3, NULL,NULL);}
                    | MulExpr RESTO UnExpr      {$$ = CriaNoTernario(Resto,numLinha,$1,$3, NULL,NULL);}
                    | UnExpr                    {$$=$1;}
                    ;
                    
UnExpr              : MENOS PrimExpr        {$$ = CriaNoTernario(Oposto,numLinha,$2,NULL, NULL,NULL);}
                    | EXCLAMACAO PrimExpr   {$$ = CriaNoTernario(Negacao,numLinha,$2,NULL, NULL,NULL);}
                    | PrimExpr              {$$=$1;}
                    ;
                    
LValueExpr          : ID ABRI_COLCHETES Expr FECHA_COLCHETES   {$$ = CriaNoTernario(IdentificadorCEC ,numLinha,$3,NULL, NULL,NULL);}
                    | ID                        {$$ = CriaNoTernario(Identificador ,numLinha,NULL,NULL, NULL,NULL);}
                    ;
                    
PrimExpr            : ID ABRI_PAREN  ListExpr  FECHA_PAREN {$$ = CriaNoTernario(IdentificadorL ,numLinha,$3,NULL, NULL,NULL);}
                    | ID ABRI_PAREN  FECHA_PAREN           {$$ = CriaNoTernario(Identificador ,numLinha,NULL,NULL, NULL,NULL);}
                    | ID ABRI_COLCHETES Expr FECHA_COLCHETES       {$$ = CriaNoTernario(IdentificadorCEC ,numLinha,$3,NULL, NULL,NULL);}
                    | ID                            {$$ = CriaNoTernario(Identificador ,numLinha,NULL,NULL,NULL, yytext);}
                    | CONSCAR                       {$$ = CriaNoTernario(ConsCar ,numLinha,NULL,NULL,NULL, yytext);}
                    | CONSINT                       {$$ = CriaNoTernario(ConsInt ,numLinha,NULL,NULL,NULL, yytext);}
                    | ABRI_PAREN  Expr  FECHA_PAREN        {$$=$2;}
                    ;
                    
ListExpr            : AssignExpr                    {$$=$1;}
                    | ListExpr VIRGULA  AssignExpr  {$$ = CriaNoTernario(Virgula ,numLinha,$1,$3,NULL, yytext);}
                    ;
%% /* Secao Epilogo*/   



int main(int argc, char** argv){
   if(argc!=2)
        yyerror("Uso correto: ./Cafezinho nome_arq_entrada");
   yyin=fopen(argv[1], "r");
   if(!yyin)
        yyerror("arquivo não pode ser aberto\n");
    //printf("entrou"); 
    yyparse();
    printTenario(raiz,0);
    printf("\n");
}

void yyerror( char const *s) {
    if(erroOrigem==0) /*Erro lexico*/
    {
        printf("%s na linha %d - token: %s\n", s, numLinha, yytext);
    }
    else
    {
        printf("Erro sintatico proximo a %s ", yytext);
        printf(" - linha: %d \n", numLinha);
        erroOrigem=1;
    }
    exit(1);
}

void percorreArvore(Toperador* raiz){
    if(raiz){
        obtemEspecieNoEnumLin(raiz, nomeOperador);
        printf("%s", nomeOperador);
        percorreArvore(raiz->filho1);
        percorreArvore(raiz->filho2);
        percorreArvore(raiz->filho3);
        }
}


void printTenario(Toperador* raiz, int nivel) {
    if (raiz) {
        obtemEspecieNoEnumLin(raiz, nomeOperador);
        printf("%*c%s\n", nivel * 2, '-', nomeOperador);
        
        //caso for os filhos
        if (raiz->filho1 || raiz->filho2 || raiz->filho3) {
            //printf("entrou filhos"); 
            printTenario(raiz->filho1, nivel + 1);
            printTenario(raiz->filho2, nivel + 1);
            printTenario(raiz->filho3, nivel + 1);
        }
    }
    else { // se não tiver filhos
        //printf("nn tem filho"); 
        printf("%*c\n", (nivel + 1) , '-');
        printf("%*c\n", (nivel + 1) , '-');
        printf("%*c\n", (nivel + 1) , '-');
    }
}


Toperador* CriaNoTernario(TespecieOperador tipoOperador, int linha, Toperador* filho1, Toperador* filho2,Toperador* filho3, char* lexema){
    
    Toperador* aux = (Toperador*) malloc(sizeof(Toperador));
    if (aux){
        //printf("entrei aqui\n");
        aux->tipoOperador=tipoOperador;
        aux->linha=linha;
        aux->filho1=filho1;
        aux->filho2=filho2;
        aux->filho3=filho3;
        if(lexema){
            aux->lexema= (char*)malloc(strlen(lexema)+1);
            strcpy(aux->lexema, lexema);
        }
        return(aux);
    }
    return(NULL);
}

void obtemEspecieNoEnumLin(Toperador* no, char* nomeOperador){
    switch(no->tipoOperador){
        case Programa:
        strcpy(nomeOperador,"programa\n");
        break;
        case Se:
        sprintf(nomeOperador, "Se - Lin: %d\n", no->linha);
        break;
        case Enquanto :
        sprintf(nomeOperador, "Enquanto - Lin: %d\n", no->linha);
        break;
        case Do:
        sprintf(nomeOperador, "Do - Lin: %d\n", no->linha);
        break;
        case ConsCar:
        sprintf(nomeOperador, "%s ConsCar- Lin: %d\n", no->lexema,no->linha);
        break;
        case ConsInt:
        sprintf(nomeOperador, "%s ConsInt- Lin: %d\n", no->lexema,no->linha);
        break;
        case Num:
        sprintf(nomeOperador, "%s NUM- Lin: %d\n", no->lexema,no->linha);
        break;
        case Mais:
        sprintf(nomeOperador, "+ - Lin: %d\n", no->linha);
        break;
        case Menos:
        sprintf(nomeOperador, "- - Lin: %d\n", no->linha);
        break;
        case Mult:
        sprintf(nomeOperador, "* - Lin: %d\n", no->linha);
        break;
        case Divisao:
        sprintf(nomeOperador, "/ - Lin: %d\n", no->linha);
        break;
        case Resto:
        sprintf(nomeOperador, "%% - Lin: %d\n", no->linha);
        break;
        case Menor:
        sprintf(nomeOperador, "< - Lin: %d\n", no->linha);
        break;
        case Maior:
        sprintf(nomeOperador, "> - Lin: %d\n", no->linha);
        break;
        case Igual:
        sprintf(nomeOperador, "== - Lin: %d\n", no->linha);
        break;
        case MenorIgual:
        sprintf(nomeOperador, "<= - Lin: %d\n", no->linha);
        break;
        case MaiorIgual:
        sprintf(nomeOperador, ">= - Lin: %d\n", no->linha);
        break;
        case Identificador:
        sprintf(nomeOperador, "ID - Lin: %d\n", no->linha);
        break;
        case Atribuir:
        sprintf(nomeOperador, "= - Lin: %d\n", no->linha);
        break;
        case DeclFuncVar:
        sprintf(nomeOperador, "DeclFuncVar - Lin: %d\n", no->linha);
        break;
        case Escreva:
        sprintf(nomeOperador, "Escreva Expr - Lin: %d\n", no->linha);
        break;
        case EscrevaC:
        sprintf(nomeOperador, "Escreva Cadeia - Lin: %d\n", no->linha);
        break;
        case Bloco:
        sprintf(nomeOperador, "Bloco - Lin: %d\n", no->linha);
        break;
        case ListaComando:
        sprintf(nomeOperador, "ListaComando - Lin: %d\n", no->linha);
        break;
        case lstStmt:
        sprintf(nomeOperador, "Faze de Teste - Lin: %d\n", no->linha);
        break;
        case IdentificadorCEC:
        sprintf(nomeOperador, "ID[Expr] - Lin: %d\n", no->linha);
        break;
        case IdentificadorL:
        sprintf(nomeOperador, "ID(ListExpr) - Lin: %d\n", no->linha);
        break;
        case Negacao:
        sprintf(nomeOperador, "! - Lin: %d\n", no->linha);
        break;
        case Oposto:
        sprintf(nomeOperador, "- Unario - Lin: %d\n", no->linha);
        break;
        case IgualIgual:
        sprintf(nomeOperador, "== - Lin: %d\n", no->linha);
        break;
        case Diferente:
        sprintf(nomeOperador, "!= - Lin: %d\n", no->linha);
        break;
        case And:
        sprintf(nomeOperador, "E - Lin: %d\n", no->linha);
        break;
        case Ou:
        sprintf(nomeOperador, "Ou - Lin: %d\n", no->linha);
        break;
        case SeTernario:
        sprintf(nomeOperador, "E ? E : E - Lin: %d\n", no->linha);
        break;
        case SeSenao:
        sprintf(nomeOperador, "SeSenao - Lin: %d\n", no->linha);
        break;
        case NovaLinha:
        sprintf(nomeOperador, "NovaLinha  - Lin: %d\n", no->linha);
        break;
        case Leia:
        sprintf(nomeOperador, "Leia  - Lin: %d\n", no->linha);
        break;
        case Retorne:
        sprintf(nomeOperador, "Retorne  - Lin: %d\n", no->linha);
        break;
        case Tipo:
        sprintf(nomeOperador, "Tipo %s  - Lin: %d\n",no->lexema, no->linha);
        break;
        case VetorDeclVar:
        sprintf(nomeOperador, "VetorDeclVar - Lin: %d\n",no->linha);
        break;
        case ListaDeclVar:
        sprintf(nomeOperador, "ListaDeclVar - Lin: %d\n",no->linha);
        break;
        case ListaParametrosCont2:
        sprintf(nomeOperador, "Tipo ID VIRGULA  ListaParametrosCont - Lin: %d\n",no->linha);
        break;
        case ListaParametrosCont3:
        sprintf(nomeOperador, "Tipo ID ABRI_COLCHETES  FECHA_COLCHETES VIRGULA ListaParametrosCont - Lin: %d\n",no->linha);
        break;
        case DeclFunc:
        sprintf(nomeOperador, "DeclFunc - Lin: %d\n",no->linha);
        break;
        case DeclFuncVar1:
        sprintf(nomeOperador, "DeclFuncVar1 - Lin: %d\n",no->linha);
        break;
        case DeclFuncVar2:
        sprintf(nomeOperador, "DeclFuncVar2 - Lin: %d\n",no->linha);
        break;
        case DeclFuncVar3:
        sprintf(nomeOperador, "DeclFuncVar3 - Lin: %d\n",no->linha);
        break;
        case Virgula:
        sprintf(nomeOperador, ", - Lin: %d\n",no->linha);
        break;
    }
}
