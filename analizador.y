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
%token SELECTOR_START SELECTOR_END COMMA COLON SEMICOLON
%token SPACES EOL
%token ELEMENT ID CLASS SUBCLASS PSEUDOCLASS PSEUDOELEMENT NESTED_ELEM
%token PROP_NAME PROP_VALUE
%start css
%%
/*RULES*/
css : selector
    | selector css

selector: selectors SELECTOR_START declarations SELECTOR_END

selectors: 
      /* Selector normal. */
      selector_name
      /* Selectores anidados. */
    | selector_nested
      /* Múltiples selectores. */
    | selector_name COMMA selectors

selector_name: ELEMENT | CLASS | SUBCLASS | ID | PSEUDOCLASS | PSEUDOELEMENT

selector_nested: 
      selector_name ws CLASS
    | selector_name ws SUBCLASS

declarations: property
    | property declarations

property: PROP_NAME COLON PROP_VALUE SEMICOLON

/* Gramática reconocedora de espacios en blanco. */
ws: 


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