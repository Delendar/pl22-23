%option noyywrap
%option yylineno
%{
#include <stdio.h>
%}

lkey {
rkey }
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
nested_element      {nested_element_head}{ws}+{nested_element_tail}

/* Reconocedores de propiedades. */
prop_name       {std_name}{ws}*":"
prop_value_txt  {std_name}{ws}*";"
prop_value_perc {std_num}"%"{ws}*";"
prop_value_px   {std_num}"px"{ws}*";"

%%

{comma}         { printf("comma: [%s]", yytext); }
"/*"[^*/]*"*/"       { printf("\ncomment: [%s]", yytext); }

{element}       { printf("\nelement: [%s]", yytext); }
{id}            { printf("\nid: [%s]", yytext); }
{class}         { printf("\nclass: [%s]", yytext); }
{subclass}      { printf("\nsubclass: [%s]", yytext); }
{pseudoclass}   { printf("\npseudoclass: [%s]", yytext); }
{pseudoelement}  { printf("\npseudoelement: [%s]", yytext); }
{nested_element} { printf("\nnested_element: [%s]", yytext); }

{prop_name}         { printf("\tp{%s}", yytext); }
{prop_value_txt}    { printf("vtxt{%s}",yytext); }
{prop_value_perc}   { printf("vperc{%s}",yytext); }
{prop_value_px}     { printf("vpx{%s}",yytext); }

%%

int main() {
    yylex();
    return 0;
}