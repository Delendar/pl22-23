%{
#include <stdlib.h>
#include <stdbool.h>
#include "practica2.tab.h"

bool is_content = true;
%}

lt "<"
gt ">"
slash "/"
quest "?"
eq "="
ws [ \t]+
double [0-9]+"."[0-9]+

encoding_id     [a-zA-Z0-9\-]+
version_info    "version"{eq}"\""{double}"\""
encoding_info   "encoding"{eq}"\""{encoding_id}"\""
xmlheader_start {lt}{quest}"xml"
xmlheader_close {quest}{gt}

comment         "<!--".*"-->"
open_tag        {lt}[a-zA-Z][a-zA-Z0-9]+{gt}
close_tag       {lt}{slash}[a-zA-Z][a-zA-Z0-9]+{gt}

%%

{xmlheader_start} { printf("HEADER_START "); return HEADER_START; }
{xmlheader_close} { printf("HEADER_CLOSE "); return HEADER_CLOSE; }
{version_info}    { printf("V_INFO "); return VERSION_INFO; }
{encoding_info}   { printf("E_INFO "); return ENCODING_INFO; } 
{comment}   { printf("COMMENT "); return COMMENT; }
{open_tag}  { printf("OPEN_TAG "); yylval.current_tag=yytext; return OPEN_TAG; }
{close_tag}  { printf("CLOSE_TAG "); yylval.current_tag=yytext; return CLOSE_TAG; }
{gt}        { printf("GT "); return GT; }
{lt}        { printf("LT "); return LT; }

%%