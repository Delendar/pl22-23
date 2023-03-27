%option noyywrap
%{
int charCounter = 0;
int wordCounter = 0;
int upperWordCounter = 0;
int lowerWordCounter = 0;
int numberCounter = 0;
int phraseCounter = 0;
%}
char        [^ \t]
blanks      [ \t\n]*
endOfPhrase [.]+
digit       [0-9]
lowerLetter [a-z]
upperLetter [A-Z]
word        [^ \t\n.]+
upperWord   {upperLetter}+
lowerWord   {lowerLetter}+
number      {digit}+

%%

{blanks}      { printf("---\n");}
{endOfPhrase} { printf("%s \n", yytext); phraseCounter += 1; wordCounter += 1; charCounter += yyleng;}
{upperWord}   { printf("%s ", yytext); upperWordCounter += 1; wordCounter += 1; charCounter += yyleng; printf("UW\n");}
{lowerWord}   { printf("%s ", yytext); lowerWordCounter += 1; wordCounter += 1; charCounter += yyleng; printf("LW\n");}
{number}      { printf("%s ", yytext); numberCounter += 1; wordCounter += 1; charCounter += yyleng; printf("NN\n");}
{word}        { printf("%s ", yytext); wordCounter += 1; charCounter += yyleng; printf("W\n");}

%%

int main() {
    yylex();
    printf("Number of characters: %d\n", charCounter);
    printf("Number of words: %d\n", wordCounter);
    printf("Number of uppercase words: %d\n", upperWordCounter);
    printf("Number of lowercase words: %d\n", lowerWordCounter);
    printf("Number of numbers: %d\n", numberCounter);
    printf("Number of phrases: %d\n", phraseCounter);
    return 0;
}