parser: lex.yy.c y.tab.c
	gcc -o parser lex.yy.c y.tab.c -lfl

lex.yy.c: scanner.l parser.y
	flex scanner.l
	byacc -d parser.y

clean:
	rm lex.yy.c y.tab.c y.tab.h parser

