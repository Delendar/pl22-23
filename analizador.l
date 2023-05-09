%option noyywrap
%{
#include <stdio.h>
#include "analizador.tab.h"
int lines = 0;
%}
%option yylineno

lkey "{"
rkey "}"
comma ,
eol  \n
spaces   [ \t]
ws [ \t\n]

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

{comma} { printf(" comma "); 
        return COMMA; }
{lkey}  { printf(" SS "); 
        return SELECTOR_START; }
{rkey}  { printf(" SE "); 
        return SELECTOR_END; }
"/*"[^*/]*"*/"  { }

{element}       { printf("\nelement");  
                return ELEMENT; }
{id}            { printf("\nid");  
                return ID; }
{class}         { printf("\nclass");  
                return CLASS; }
{subclass}      { printf("\nsubclass");  
                return SUBCLASS; }
{pseudoclass}   { printf("\npseudoclass");  
                return PSEUDOCLASS; }
{pseudoelement} { printf("\npseudoelement");  
                return PSEUDOELEMENT; }
{nested_element}      { printf("\nnested_element");  
                      return NESTED_ELEMENT; }
{nested_element_weol} { printf("\nnested_element");
                      return NESTED_ELEMENT; }

{prop_name}             { printf(" prop_name"); 
                         return PROP_NAME; }
{prop_name_weol}        { printf(" prop_name"); 
                         return PROP_NAME;  }
{prop_value_txt}        { printf("prop_value"); 
                         return VALUE_TXT;  }
{prop_value_txt_weol}   { printf("prop_value"); 
                         return VALUE_TXT; }
{prop_value_perc}       { printf("prop_value"); 
                         return VALUE_PERCENTAGE; }
{prop_value_perc_weol}  { printf("prop_value"); 
                         return VALUE_PERCENTAGE; }
{prop_value_px}         { printf("prop_value"); 
                         return VALUE_PX; }
{prop_value_px_weol}    { printf("prop_value"); 
                         return VALUE_PX; }
{prop_value_html}       { printf("prop_value"); 
                         return VALUE_HTML_COLOR; }
{prop_value_html_weol}  { printf("prop_value"); 
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

void yyerror (char const *message) { 
    fprintf (stderr, "%s {%d} [%d]\n", message, yylineno, lines);
}