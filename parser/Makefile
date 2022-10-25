# Makefile for myparser
# Make sure to use tab of indentation
CC = cc -g
LEX = flex
YACC = bison
CFLAGS = -DYYDEBUG=1
PROGRAMS = myparser
all: ${PROGRAMS}
myparser: parse.tab.o parse.o
	${CC} -o $@ parse.tab.o parse.o
parse.tab.c parse.tab.h: parse.y
	${YACC} -vd parse.y
parse.c: scan.l
	${LEX} -o $*.c $<
parse.o: parse.c parse.tab.h
.SUFFIXES: .pgm .l .y .c