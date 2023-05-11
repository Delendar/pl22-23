%option noyywrap
%{
#include <stdio.h>
#include "analizador.tab.h"

int count_newlines(const char*);
%}
%option yylineno

lkey "{"
rkey "}"
comma ,
spaces [ \t]
eol \n
ws [ \t\n]
colon :
semicolon ;
hash #

/* Simplificadores de expresiones. */
/* STD_NAME puede ser, tanto elemento como nombre de propiedad. */
std_name [a-zA-Z][a-zA-Z0-9-]*
std_num  [0-9]*
comment "/*"[^*/]*"*/"

/* Reconocedores de selectores. */
element      {std_name}
class        "."{std_name}
subclass     {class}{class}+
pseudoclass  {std_name}":"{std_name}
pseudoelement {std_name}"::"{std_name}


/* Esto debe de reconocerlo la gramática. NE_HEAD whitespaces NE_TAIL */
nested_element_head {element}|{class}|{subclass}
nested_element_tail {class}|{subclass}
nested_element      {nested_element_head}{spaces}+{nested_element_tail}
/* Obtener numero de nuevas lineas */
nested_element_weol {nested_element_head}{ws}+{nested_element_tail}

/* Reconocedores de propiedades. */
prop_value_perc      {std_num}"%"
prop_value_px        {std_num}"px"

%%

{comma}     { printf("COMMA "); return COMMA; }
{lkey}      { printf("SELECTOR_START "); return SELECTOR_START; }
{rkey}      { printf("SELECTOR_END "); return SELECTOR_END; }
{colon}     { printf("COLON "); return COLON; }
{semicolon} { printf("SEMICOLON "); return SEMICOLON; }
{hash}      { printf("HASH "); return HASH; }
{comment}   { yylineno += count_newlines(yytext);}

{std_name}      { printf("STANDARD_NAME "); return STANDARD_NAME; }
{std_num}       { printf("STANDARD_NUM "); return STANDARD_NUM; }

{class}         { printf("CLASS "); return CLASS; }
{subclass}      { printf("SUBCLASS "); return SUBCLASS; }
{pseudoclass}   { printf("PSEUDOCLASS "); return PSEUDOCLASS; }
{pseudoelement} { printf("PSEUDOELEMENT"); return PSEUDOELEMENT; }
{nested_element}        { printf("NESTED_ELEMENT "); return NESTED_ELEMENT; }
{nested_element_weol}   { printf("NESTED_ELEMENT "); yylineno += count_newlines(yytext);
                        return NESTED_ELEMENT; }

{prop_value_perc}       { printf("PROP_VALUE_PERC "); return VALUE_PERCENTAGE; }

{prop_value_px}         { printf("PROP_VALUE_PX "); return VALUE_PX; }

{eol} {  }
%%

/*int main() {
    yylex();
    return 0;
} */

int count_newlines(const char* string) {
    int count = 0;
    while (*string) {
        if (*string == '\n') {
            count++;
        }
        string++;
    }
    return count;
}