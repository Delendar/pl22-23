SOURCE = analizador
TEST_FILE = prueba.css
LIB = lfl

all: compile test

compile:
	flex $(SOURCE).l
	bison -o $(SOURCE).tab.c $(SOURCE).y -yd
	gcc -o $(SOURCE) lex.yy.c $(SOURCE).tab.c -$(LIB) -Ly

test:
	./$(SOURCE) < $(TEST_FILE)
	./$(SOURCE) < error1.css
	./$(SOURCE) < error2.css
	./$(SOURCE) < error3.css
	./$(SOURCE) < error4.css
	./$(SOURCE) < error5.css
	./$(SOURCE) < error6.css
	./$(SOURCE) < advertencias.css