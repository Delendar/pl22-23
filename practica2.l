%{
#include <stdlib.h>
#include "practica2.tab.h"
%}

lt    "<"
gt    ">"
slash "/"
quest "?"
spaces   [ \n\t]*
new_line [\n]
ws       [\t ]*
double   [0-9]+"."[0-9]+
cdata    [^<>\"\'\n]+
encoding_id     [a-zA-Z0-9\-]+

version_info    {spaces}"version="\"{double}\"{spaces}
encoding_info   {spaces}"encoding="\"{encoding_id}\"{spaces}
xmlheader_start {lt}{quest}"xml"
xmlheader_close {quest}{gt}
xmlheader       {xmlheader_start}{version_info}{encoding_info}{xmlheader_close}

comment         "<!--".*"-->"
open_tag        {lt}[a-zA-Z][a-zA-Z0-9]+{gt}
close_tag       {lt}{slash}[a-zA-Z][a-zA-Z0-9]+{gt}

%%

{xmlheader} { return XML_HEADER; }
{comment}   { return COMMENT; }
{open_tag}  { yylval.current_tag=yytext; return OPEN_TAG; }
{close_tag} { yylval.current_tag=yytext; return CLOSE_TAG; }
{new_line}  { return EOL; }
{ws}        { return WS; }
{cdata}     { return CDATA; }
{gt}        { return GT; }
{lt}        { return LT; }

%%