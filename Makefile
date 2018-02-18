kale.tab.c kale.tab.h: kale.y
	bison -d kale.y

lex.yy.c: kale.l kale.tab.h
	flex kale.l

kale: 	lex.yy.c kale.tab.c kale.tab.h
	g++ -std=c++11 ast.o kale.tab.c lex.yy.c -ll -o kale

clean:
	rm -rf ast.o kale.tab.c lex.yy.c kale.tab.h
