Sintatico:  Sintatico.o lexico.o
	gcc Sintatico.o lexico.o -o Cafezinho
Sintatico.o: Sintatico.c
	gcc -c Sintatico.c -o Sintatico.o
Sintatico.c:  Sintatico.y
	bison -d -oSintatico.c Sintatico.y
lexico.o: lexico.c
	gcc -c lexico.c -o lexico.o
lexico.c: lexico.l
	flex -olexico.c  lexico.l
clean: 
	rm *.o  Cafezinho *.c
