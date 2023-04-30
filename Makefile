SOURCE = analizador
TEST_FILE = prueba.css
LIB = lfl

all: compile

lex: lex-compile lex-test

lex-compile:
	flex $(SOURCE).l
	gcc -o $(SOURCE) lex.yy.c

lex-test:
	./$(SOURCE) < $(TEST_FILE)

compile:
	flex $(SOURCE).l
	bison -o $(SOURCE).tab.c $(SOURCE).y -yd
	gcc -o $(SOURCE) lex.yy.c $(SOURCE).tab.c -$(LIB) -Ly

test:
	./$(SOURCE) < $(TEST_FILE)