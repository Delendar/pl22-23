SOURCE = practica1

all: compile test

compile: 
	flex $(SOURCE).l
	gcc -o $(SOURCE) lex.yy.c

test: test1 test2 test3

test1:
	./$(SOURCE) < test1.txt

test2:
	./$(SOURCE) < test2.txt

test3:
	./$(SOURCE) < practica1.txt