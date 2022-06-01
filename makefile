Result:
	yacc -d project.y
	lex project.l
	gcc -o Result y.tab.c lex.yy.c -ly -lfl

clear:
	rm Result
	rm lex.yy.c
	rm y.tab.c
