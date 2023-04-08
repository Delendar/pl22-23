SRC = practica2
TEST = test.txt
LIB = lfl

all: compile run

compile:
	flex $(SRC).l
	bison -o $(SRC).tab.c $(SRC).y -yd
	gcc -o $(SRC) lex.yy.c $(SRC).tab.c -$(LIB)

run:
	./$(SRC) < $(TEST)

clean:
	rm $(SRC) lex.yy.c $(SRC).tab.c $(SRC).tab.h
