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

{blanks}      { }
{endOfPhrase} { phraseCounter += 1; charCounter += yyleng; }
{upperWord}   { upperWordCounter += 1; wordCounter += 1; charCounter += yyleng; }
{lowerWord}   { lowerWordCounter += 1; wordCounter += 1; charCounter += yyleng; }
{number}      { numberCounter += 1; wordCounter += 1; charCounter += yyleng; }
{word}        { wordCounter += 1; charCounter += yyleng; }

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