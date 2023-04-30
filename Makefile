SOURCE = analizador
TEST_FILE = prueba.css

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
	gcc -o $(SOURCE) lex.yy.c $(SOURCE).tab.c -lfl
	
test: test1 test2 test3

test1:
	./$(SOURCE) < test1.txt

test2:
	./$(SOURCE) < test2.txt

test3:
	./$(SOURCE) < practica1.txt