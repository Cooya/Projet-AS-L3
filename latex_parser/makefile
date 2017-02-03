CC = gcc
LEX = flex
YACC = bison
CFLAGS = -std=c99

all: bison flex parser

bison: 
	$(YACC) -dvy parse.y

flex:
	$(LEX) scan.l

parser: *.c
	$(CC) $(CFLAGS) $^ -o $@ -lfl -ly
