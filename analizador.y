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
%token SELECTOR_START SELECTOR_END COMMA
%token ELEMENT ID CLASS SUBCLASS PSEUDOCLASS PSEUDOELEMENT NESTED_ELEMENT
%token PROP_NAME VALUE_TXT VALUE_PX VALUE_PERCENTAGE VALUE_HTML_COLOR
%start css
%%
/*RULES*/
css : css style_modifier | /* vacio */

style_modifier: selectors SELECTOR_START declarations SELECTOR_END

selectors: 
      /* Selector normal. */
      selector_name
      /* Selectores múltiples. */
    | selectors COMMA selector_name

selector_name: 
    | ELEMENT   { /* Añadir a lista de elementos modificados */ }
    | CLASS     { /* Añadir a clases modificadas */ }
    | SUBCLASS  { /* Añadir a subclases modificadas */ }
    | ID        { /* Añadir a id's modificados */ }
    | PSEUDOCLASS   { /* Añadir a pseudoclases modificadas */ }
    | PSEUDOELEMENT { /* Añadir a pseudoelementos modificados */ }
    | NESTED_ELEMENT { /* Añadir a elementos anidados modificados */ }

declarations: declarations property
    | /* vacio */

property: PROP_NAME property_value

property_value:
    | VALUE_TXT
    | VALUE_PX
    | VALUE_PERCENTAGE
    | VALUE_HTML_COLOR

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