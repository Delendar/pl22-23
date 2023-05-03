%option noyywrap
%{
#include <stdio.h>
#include "analizador.tab.h"
int lines = 0;
%}
%option yylineno

spaces  [ \t]
eol     \n
ws      [ \n\t]
comma ,

selector_start "{"
selector_end "}"

prop_start ":"
prop_end ";"


/* Simplificadores de expresiones. */
std_name [a-zA-Z][a-zA-Z0-9-]*
std_num  [0-9]*


/* Reconocedores de selectores. */
element      {std_name}
id           "#"{std_name}
class        "."{std_name}
subclass     {class}{class}+
pseudoclass  {std_name}":"{std_name}
pseudoelement {std_name}"::"{std_name}


/* Esto debe de reconocerlo la gramática.
    NE_HEAD whitespaces NE_TAIL */
nested_element_head {element}|{class}|{subclass}
nested_element_tail {class}|{subclass}
nested_element      {nested_element_head}{spaces}+{nested_element_tail}
nested_element_weol {nested_element_head}{ws}+{nested_element_tail}

/* Reconocedores de propiedades. */
prop_name       {std_name}
prop_value_txt  {std_name}
prop_value_perc {std_num}"%"
prop_value_px   {std_num}"px"

%%

/* Caracteres necesarios */
{eol}           { /* PH numero de linea */ }
{comma}         { printf("comma: [%s]", yytext); return COMMA; }
{selector_start} { /* Empiezan propiedades */ }
{selector_end}   { /* Empiezan propiedades */ }
{prop_start}     { return COLON; }
{prop_end}       { return SEMICOLON; }

/* Comentarios */
"/*"[^*/]*"*/"  { printf("\ncomment: [%s]", yytext); 
                /* PH stat comentario */}

/* Selectores */
{element}       { printf("\nelement: [%s]", yytext); 
                return ELEMENT; 
                /* PH stat elemento */}
{id}            { printf("\nid: [%s]", yytext); 
                return ID; 
                /* PH stat identificador */}
{class}         { printf("\nclass: [%s]", yytext); 
                return CLASS; 
                /* PH stat clase */}
{subclass}      { printf("\nsubclass: [%s]", yytext); 
                return SUBCLAS; 
                /* PH stat subclase */}
{pseudoclass}   { printf("\npseudoclass: [%s]", yytext); 
                return PSEUDOCLASS; 
                /* PH stat pseudoclase */}
{pseudoelement} { printf("\npseudoelement: [%s]", yytext); 
                return PSEUDOELEMENT; 
                /* PH stat pseudoelementos */}
{nested_element} { printf("\npseudoelement: [%s]", yytext); 
                return NESTED_ELEM; }
{nested_element_weol} { printf("\npseudoelement: [%s]", yytext); 
                /* PH scan string for EOLs */
                return NESTED_ELEM; }


/* Propiedades */
{prop_name}         { printf("\tp{%s}", yytext); 
                    /* PH stat num propiedades */}
{prop_value_txt}    { printf("vtxt{%s}",yytext); }
{prop_value_perc}   { printf("vperc{%s}",yytext); 
                    /* PH stat num propiedades percentiles */}
{prop_value_px}     { printf("vpx{%s}",yytext); 
                    /* PH stat num propiedades en pixeles*/}

.   { /* Error? */ }
%%
/*
int main() {
    yylex();
    return 0;
}*/

void yyerror (char const *message) { 
    fprintf (stderr, "%s {%d} [%d]\n", message, yylineno, lines);
}