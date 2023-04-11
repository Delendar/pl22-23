%{
#include <stdlib.h>
#include <stdbool.h>
#include "practica2.tab.h"

int count_newlines(const char*);
%}

lt "<"
gt ">"
slash "/"
quest "?"
new_line [\n]
ws [ \n\t]*
visual_formatters [\t ]*
double [0-9]+"."[0-9]+
cdata [^<>\"\'\n]+

encoding_id     [a-zA-Z0-9\-]+
version_info    {ws}"version="\"{double}\"{ws}
encoding_info   {ws}"encoding="\"{encoding_id}\"{ws}
xmlheader_start {lt}{quest}"xml"
xmlheader_close {quest}{gt}
xmlheader       {xmlheader_start}{version_info}{encoding_info}{xmlheader_close}

comment         "<!--".*"-->"
open_tag        {lt}[a-zA-Z][a-zA-Z0-9]+{gt}
close_tag       {lt}{slash}[a-zA-Z][a-zA-Z0-9]+{gt}

%%

{xmlheader} { printf("XML_HEADER:[%s]\n", yytext); return XML_HEADER;}
{comment}   { printf("COMMENT:[%s]\n", yytext); return COMMENT; }
{open_tag}  { printf("OPEN_TAG:[%s]\n", yytext);
            yylval.current_tag=yytext; 
            return OPEN_TAG; }
{close_tag}  { printf("CLOSE_TAG:[%s]\n", yytext); yylval.current_tag=yytext; return CLOSE_TAG; }
{gt}        { printf("GT:[%s]\n", yytext); return GT; }
{lt}        { printf("LT:[%s]\n", yytext); return LT; }
{new_line}  { printf("NL:[%s]\n", yytext); return EOL; }
{visual_formatters}  { printf("VF:[%s]\n", yytext);
             yylval.current_text = yytext;
             return VF; }
{cdata}     { printf("CDATA:[%s]\n", yytext);
             yylval.current_text = yytext;
             return CDATA; }

%%