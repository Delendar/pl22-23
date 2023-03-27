%{
/*
**      lex program for simple dc
**      input of the form:  opd opr opd
**      output of the form: opd opr opd = ans
*/
#define NUM 1
#define PLUS 2
#define MINUS 3 
#define MUL 4
#define DIV 5
#define MOD 6
#define DELIM 7
%}

ws	[ \t]+

%%
{ws}	;
-?[0-9]+        {
        printf("%s",yytext);
        return (NUM);
        }

"+"     {
        ECHO;
        return (PLUS);
        }
"-"     {
        ECHO;
        return (MINUS);
        }
"*"     {
        ECHO;
        return (MUL);
        }
"/"     {
        ECHO;
        return (DIV);
        }
"%"     {
        ECHO;
        return (MOD);
        }
.|\n    {
        ECHO;
        return (DELIM);
        }
%%
/* main.c */
# include <stdio.h>

main()
{
int opd1, opd2, opr;

	/* Look for first operand. */
        if (yylex() != NUM)
                {
                printf("missing operand\n");
                exit(1);
                }
        opd1 = atoi(yytext);
	/* Check for operator. */
        opr = yylex();
        if (opr == DELIM)
                {
                printf("missing operator\n");
                exit(1);
                }
	else if (opr == NUM)
		{
		if ((opd2=atoi(yytext)) >= 0)
 			{
			 printf("missing operator\n");
			 exit(1); 
			}
		else 
			{
			opr = MINUS;
			opd2 = -opd2;
			}
		}
        else if (yylex() != NUM)
                {
                printf("missing operand\n");
                exit(1);
                }
	else /* Must have found operand 2 */
        	opd2 = atoi(yytext);
        switch (opr)
        {
        case PLUS:      {
                        printf(" = %d\n",opd1 + opd2);
                        break;
                        }
        case MINUS:     {
                        printf(" = %d\n",opd1 - opd2);
                        break;
                        }
        case MUL:       {
                        printf(" = %d\n",opd1 * opd2);
                        break;
                        }
        case DIV:       {
			if (opd2 == 0)
			 	{
				printf("\nERROR: attempt to divide by zero!\n");
				exit(1);
				}
			else
				{
                        	printf(" = %d\n",opd1 / opd2);
                        	break;
				}
                        }
        case MOD:       {
			if (opd2 == 0)
	 			{
				printf("\nERROR: attempt to divide by zero!\n");
				exit(1);
				}
			else
				{
                       		printf(" = %d\n",opd1 % opd2);
                        	break;
				}
                        }
        }
}

