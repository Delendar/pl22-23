%option noyywrap
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

comment "/*"."*/"

/* Reconocedores de selectores. */
element      {std_name}
id           "#"{std_name}
class        "."{std_name}
subclass     {class}{class}+
pseudoclass  {std_name}":"{std_name}
pseudoelement {std_name}"::"{std_name}

nested_element_head {element}|{class}|{subclass}
nested_element_tail {class}|{subclass}
nested_element {nested_element_head}{ws}+{nested_element_tail}

/* Reconocedores de propiedades. */
prop_name prop_name
prop_value prop_value

%%

{comma}         { printf("comma: [%s]", yytext); }
{comment}       { printf("\ncomment: [%s]", yytext); }
{element}       { printf("\nelement: [%s]", yytext); }
{id}            { printf("\nid: [%s]", yytext); }
{class}         { printf("\nclass: [%s]", yytext); }
{subclass}      { printf("\nsubclass: [%s]", yytext); }
{pseudoclass}   { printf("\npseudoclass: [%s]", yytext); }
{pseudoelement}  { printf("\npseudoelement: [%s]", yytext); }
{nested_element} { printf("\nnested_element: [%s]", yytext); }

%%

int main() {
    yylex();
    return 0;
}