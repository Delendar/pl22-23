%{
#include <stdlib.h>
#include "practica2.tab.h"
%}

proper_tag_name [a-zA-Z][a-zA-Z0-9]+
number_start_word [0-9][a-zA-Z0-9]+
version_num \"[0-9]+"."[0-9]+\"
version_decl version
encoding_decl encoding
encoding_id \"[a-zA-Z0-9\-]+\"
lt "<"
gt ">"
slash "/"
quest "?"
eq "="

%%

{version_decl}  { return VERSION_DECL; }
{encoding_decl} { return ENCODING_DECL; }
{proper_tag_name}   { return TAG_NAME; }
{number_start_word} { return NUM_START_WORD; }
{version_num}   { return VERSION_NUM; }
{encoding_id}   { return ENCODING_ID; }

{gt}        { return GT; }
{lt}        { return LT; }
{slash}     { return SLASH; }
{quest}     { return QUEST; }
{eq}        { return EQ; }

<<EOF>>     { return EOF; }
%%