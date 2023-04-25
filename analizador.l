%{
#include <stdio.h>
#include "analizador.tab.h"
%}

lkey {
rkey }
comma ,
eol  \n
spaces   [ \t]
ws [ \t\n]

/* Simplificadores de expresiones. */
std_name [a-zA-Z][a-zA-Z0-9-]*

comment /*.*/

/* Reconocedores de selectores. */
element      {std_name}
id           #{std_name}
class        .{std_name}
subclass     {class}{class}+
pseudoclass :{std_name}
pseudoelement ::{std_name}

nested_element_head {element}|{class}|{subclass}
nested_element_tail {class}|{subclass}
nested_element {nested_element_head}{ws}+{nested_element_tail}

/* Reconocedores de propiedades. */
prop_name prop_name
prop_value prop_value

%%

{lkey}          { printf("lkey\n"); }
{rkey}          { printf("rkey\n"); }
{comma}         { printf("comma"); }
{comment}       { printf("comment\n"); }
{element}       { printf("element\n"); }
{id}            { printf("id\n"); }
{class}         { printf("class\n"); }
{subclass}      { printf("subclass\n"); }
{pseudoclass}   { printf("pseudoclass\n"); }
{pseudoelement}  { printf("pseudoelement\n"); }
{nested_element} { printf("nested_element\n"); }

%%

int main {
    yylex();
}