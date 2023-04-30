/*LIBRARIES*/
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern int yylex (void);
extern int yylineno;
void yyerror (char const *);
%}
%locations
%union{
    int linea;
}
/*TOKENS*/
%token LKEY RKEY COMMA CHILD ADJ_SIB GEN_SIB
%token WS EOL
%token COMMENT
%token ID SELECTOR_NAME
%token PROP_NAME PROP_VALUE
%start css
%%
/*RULES*/
css : selector css
    | selector

selector: selectors LKEY declarations RKEY

selectors: SELECTOR_NAME
    | SELECTOR_NAME character selectors

character: COMMA
    | CHILD
    | ADJ_SIB
    | GEN_SIB
    | WS

declarations: declaration declarations
    | declaration

declaration: PROP_NAME PROP_VALUE
%%
/*CODE*/
int main(){
    yylval.linea=0;
    extern FILE *yyin;
    yyin=stdin;
    if(yyin == NULL){
        perror("fopen");
        exit(EXIT_FAILURE);
    }
    else {
        yyparse();
        fclose(yyin);
    }
    return 0;
}