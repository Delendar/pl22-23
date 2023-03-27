all: flex
	gcc -o practica1 lex.yy.c

flex: lex.yy.c
	flex practica1.l

test: test1 test2 test3

test1: 
	./practica1.exe < test1.txt

test2: 
	./practica1.exe < test2.txt

test3: 
	./practica1.exe < test3.txt