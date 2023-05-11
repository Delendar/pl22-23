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

/* Simplificadores de expresiones. */
std_name [a-zA-Z][a-zA-Z0-9-]*
std_num  [0-9]*
comment "/*"[^*/]*"*/"

/* Reconocedores de selectores. */
element      {std_name}
id           "#"{std_name}
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
prop_name            {std_name}{spaces}*":"
prop_name_weol       {std_name}{ws}*":"
prop_value_txt       {std_name}{spaces}*";"
prop_value_txt_weol  {std_name}{ws}*";"
prop_value_perc      {std_num}"%"{spaces}*";"
prop_value_perc_weol {std_num}"%"{ws}*";"
prop_value_px        {std_num}"px"{spaces}*";"
prop_value_px_weol   {std_num}"px"{ws}*";"
prop_value_html      "#"{std_num}{spaces}*";"
prop_value_html_weol "#"{std_num}{ws}*";"

%%

{comma} { return COMMA; }
{lkey}  { return SELECTOR_START; }
{rkey}  { return SELECTOR_END; }
{comment}  { yylineno += count_newlines(yytext);}

{element}       { return ELEMENT; }
{id}            { return ID; }
{class}         { return CLASS; }
{subclass}      { return SUBCLASS; }
{pseudoclass}   { return PSEUDOCLASS; }
{pseudoelement} { return PSEUDOELEMENT; }
{nested_element}        { return NESTED_ELEMENT; }
{nested_element_weol}   { yylineno += count_newlines(yytext);
                        return NESTED_ELEMENT; }

{prop_name}             { return PROP_NAME; }
{prop_name_weol}        { yylineno += count_newlines(yytext);
                        return PROP_NAME;  }
{prop_value_txt}        { return VALUE_TXT;  }
{prop_value_txt_weol}   { yylineno += count_newlines(yytext);
                        return VALUE_TXT; }
{prop_value_perc}       { return VALUE_PERCENTAGE; }
{prop_value_perc_weol}  { yylineno += count_newlines(yytext);
                        return VALUE_PERCENTAGE; }
{prop_value_px}         { return VALUE_PX; }
{prop_value_px_weol}    { yylineno += count_newlines(yytext);
                        return VALUE_PX; }
{prop_value_html}       { return VALUE_HTML_COLOR; }
{prop_value_html_weol}  { yylineno += count_newlines(yytext);
                        return VALUE_HTML_COLOR; }

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