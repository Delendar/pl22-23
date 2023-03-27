digit     [0-9]
letter    [A-Za-z]
delim     [ \t\n]
ws        {delim}+
%%
{ws}      { /* ignore white space */ }    
{digit}+  { printf("%s", yytext);  printf(" = number\n"); }
{letter}+ { printf("%s", yytext); printf(" = word\n"); }
%%
main()
{
	yylex();
}
