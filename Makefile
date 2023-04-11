SRC = practica2
LIB = lfl

all: compile test-ok test-fail

test: compile test

compile:
	flex $(SRC).l
	bison -o $(SRC).tab.c $(SRC).y -yd
	gcc -o $(SRC) lex.yy.c $(SRC).tab.c -$(LIB)

test-ok:
	./$(SRC) < testOK.xml
	./$(SRC) < testOK2.xml

test-fail:
	./$(SRC) < testFAIL.xml
	./$(SRC) < testFAIL2.xml
	./$(SRC) < testFAIL3.xml
	./$(SRC) < testFAIL4.xml
	./$(SRC) < testFAIL5.xml

clean:
	rm $(SRC) lex.yy.c $(SRC).tab.c $(SRC).tab.h
