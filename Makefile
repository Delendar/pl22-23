all: flex
	gcc -o practica1 lex.yy.c

flex: flex practica1.l

test1: practica1.exe < test1.txt

test2: practica1.exe < test2.txt