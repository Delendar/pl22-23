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
nested_element {nested_element_head}{ws}+{nested_element_tail}

/* Reconocedores de propiedades. */
prop_value_perc      {std_num}"%"
prop_value_px        {std_num}"px"

%%

{comma}     { return COMMA; }
{lkey}      { return SELECTOR_START; }
{rkey}      { return SELECTOR_END; }
{colon}     { return COLON; }
{semicolon} { return SEMICOLON; }
{hash}      { return HASH; }
{comment}   { yylval.comment_counter++; }

{std_name}      { yylval.string = strdup(yytext); return STANDARD_NAME; }
{std_num}       { return STANDARD_NUM; }

{class}         { yylval.string = strdup(yytext); return CLASS; }
{subclass}      { yylval.string = strdup(yytext); return SUBCLASS; }
{pseudoclass}   { yylval.string = strdup(yytext); return PSEUDOCLASS; }
{pseudoelement} { yylval.string = strdup(yytext); return PSEUDOELEMENT; }
{nested_element}   { yylval.string = strdup(yytext); return NESTED_ELEMENT; }

{prop_value_perc}       { return VALUE_PERCENTAGE; }

{prop_value_px}         { return VALUE_PX; }

{eol} {  }
%%

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