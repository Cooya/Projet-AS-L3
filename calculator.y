%{

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "uthash.h"

extern int yylex();
//extern int yyerror();
//extern int yylval;
extern char *yytext;

int yyerror();

extern char *identificatorValue;

void addVar(char *id, int value);
int *getVar(char *id);

#define false 0
#define true 1

int assBool = false;
int exception = false;

%}

%union {
    char *str;
    int integer;
}

%token NB STR DOLLAR SEPARATOR IDENTIFICATOR /*POWEROPERATOR */

%type <integer> expression
%type <integer> conditionalExpression
%type <integer> additiveExpression
%type <integer> multiplicativeExpression
%type <integer> powerExpression
%type <integer> assExpr
%type <str>     identificator

%left '+' '-'
%left '*' '/' '%'
%right POWEROPERATOR

%start mainThread

%%

mainThread
	: mainThread analysisUnit
	| /* empty */
	| DOLLAR
	;

analysisUnit
	: expression SEPARATOR {if(!exception) printf("Result : %d\n", $1); exception = false;}

expression
	: expression '?' conditionalExpression ':' conditionalExpression {$$=($1?$3:$5);}
	| conditionalExpression {$$ = $1;}
	;

conditionalExpression
	: conditionalExpression '+' additiveExpression {$$ = $1 + $3;}
	| conditionalExpression '-' additiveExpression {$$ = $1 - $3;}
	| additiveExpression {$$ = $1;}
	;

additiveExpression
	: additiveExpression '*' multiplicativeExpression {$$ = $1 * $3;}
	| additiveExpression '/' multiplicativeExpression {if($3==0) {printf("Arithmetic Error\n"); exception = true;} else $$ = $1 / $3;}
	| additiveExpression '%' multiplicativeExpression {$$ = $1 % $3;}
	| multiplicativeExpression {$$ = $1;}
	;

multiplicativeExpression
	: powerExpression POWEROPERATOR multiplicativeExpression {$$ = 1; for(int i=0; i<$3; i++) $$*=$1;}
	| powerExpression {$$ = $1;}
	;

powerExpression
	: '(' expression ')' {$$ = $2;}
	| '{' expression '}' {$$ = $2;}
	| '[' expression ']' {$$ = $2;}
	| NB {$$ = yylval.integer;}
	| identificator assExpr {
		if(!assBool) {
			if(!getVar($1)) {
				printf("Variable undefined \"%s\"\n", $1);
				exception = true;
			}
			else
				$$ = *(getVar($1));
		}
		else {
			addVar($1, $2);
			$$ = $2;
		}
	}
	;

assExpr
	: '=' expression {$$ = $2; assBool = true;}
	| /* empty */ {/*$$ = 0; */assBool = false;}
	;

identificator
	: IDENTIFICATOR {$$ = yylval.str;}

%%

int yyerror() {
	printf("syntax error, had : '%s'\n", yytext);
	return 1;
}

/* VARIABLES */

int varCpt = 0;

struct varStruct {
    int id;            /* we'll use this field as the key */
    char name[32];
    int value;
    UT_hash_handle hh; /* makes this structure hashable */
};

struct varStruct *variables = NULL;

void addVar(char *name, int value) {
	struct varStruct *v = malloc(sizeof(struct varStruct));
	
	v->id = varCpt++;
	strcpy(v->name, name);
	
	v->value = value;
	
	HASH_ADD_STR(variables, name, v);    
}

int *getVar(char *name) {
	struct varStruct *v;

	HASH_FIND_STR(variables, name, v);

	if(v)
    	return &(v->value);
	return NULL;
}
