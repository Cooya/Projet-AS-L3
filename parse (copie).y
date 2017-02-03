%{

#include <string.h>
#include <stdio.h>

extern int yylex();
extern void yyerror(const char *);
extern FILE *yyout;

#include "RenderFile.h"

%}

%union {
	char *str;
}

%token<str> IDENTIFIER
%token	I_CONSTANT F_CONSTANT STRING_LITERAL FUNC_NAME SIZEOF
%token	PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token	AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token	SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token	XOR_ASSIGN OR_ASSIGN
%token	TYPEDEF_NAME ENUMERATION_CONSTANT

%token	TYPEDEF EXTERN STATIC AUTO REGISTER INLINE
%token	CONST RESTRICT VOLATILE
%token	BOOL CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE VOID
%token	COMPLEX IMAGINARY 
%token	STRUCT UNION ENUM ELLIPSIS

%token	CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%token	ALIGNAS ALIGNOF ATOMIC GENERIC NORETURN STATIC_ASSERT THREAD_LOCAL

%start translation_unit

%%

primary_expression
	: IDENTIFIER {writeHTML_Identifier($1); free($1);}
	| constant
	| string
	| '(' {writeHTML_Operator("(");} expression ')' {writeHTML_Operator(")");}
	| generic_selection
	;

constant
	: I_CONSTANT		/* includes character_constant */
	| F_CONSTANT
	| ENUMERATION_CONSTANT	/* after it has been defined as such */
	;

enumeration_constant		/* before it has been defined as such */
	: IDENTIFIER
	;

string
	: STRING_LITERAL
	| FUNC_NAME
	;

generic_selection
	: GENERIC '(' {writeHTML_Operator("(");} assignment_expression ',' {writeHTML_Operator(",");} generic_assoc_list ')' {writeHTML_Operator(")");}
	;

generic_assoc_list
	: generic_association
	| generic_assoc_list ',' {writeHTML_Operator(",");} generic_association
	;

generic_association
	: type_name ':' {writeHTML_Operator(":");} assignment_expression
	| DEFAULT ':' {writeHTML_Operator(":");} assignment_expression
	;

postfix_expression
	: primary_expression
	| postfix_expression '[' {writeHTML_Operator("[");} expression ']' {writeHTML_Operator("]");}
	| postfix_expression '(' {writeHTML_Operator("(");} ')' {writeHTML_Operator(")");}
	| postfix_expression '(' {writeHTML_Operator("(");} argument_expression_list ')' {writeHTML_Operator(")");}
	| postfix_expression '.' {writeHTML_Operator(".");} IDENTIFIER
	| postfix_expression PTR_OP {writeHTML_Operator("->");} IDENTIFIER
	| postfix_expression INC_OP {writeHTML_Operator("++");}
	| postfix_expression DEC_OP {writeHTML_Operator("--");}
	| '(' {writeHTML_Operator("(");} type_name ')' {writeHTML_Operator(")");} '{' {writeHTML_Operator("{");} initializer_list '}' {writeHTML_Operator("}");}
	| '(' {writeHTML_Operator("(");} type_name ')' {writeHTML_Operator(")");} '{' {writeHTML_Operator("{");} initializer_list ',' {writeHTML_Operator(",");} '}' {writeHTML_Operator("}");}
	;

argument_expression_list
	: assignment_expression
	| argument_expression_list ',' {writeHTML_Operator(",");} assignment_expression
	;

unary_expression
	: postfix_expression
	| INC_OP {writeHTML_Operator("++");} unary_expression
	| DEC_OP {writeHTML_Operator("--");} unary_expression
	| unary_operator cast_expression
	| SIZEOF unary_expression
	| SIZEOF '(' {writeHTML_Operator("(");} type_name ')' {writeHTML_Operator(")");}
	| ALIGNOF '(' {writeHTML_Operator("(");} type_name ')' {writeHTML_Operator(")");}
	;

unary_operator
	: '&' {writeHTML_Operator("&");}
	| '*' {writeHTML_Operator("*");}
	| '+' {writeHTML_Operator("+");}
	| '-' {writeHTML_Operator("-");}
	| '~' {writeHTML_Operator("~");}
	| '!' {writeHTML_Operator("!");}
	;

cast_expression
	: unary_expression
	| '(' {writeHTML_Operator("(");} type_name ')' {writeHTML_Operator(")");} cast_expression
	;

multiplicative_expression
	: cast_expression
	| multiplicative_expression '*' {writeHTML_Operator("*");} cast_expression
	| multiplicative_expression '/' {writeHTML_Operator("/");} cast_expression
	| multiplicative_expression '%' {writeHTML_Operator("%");} cast_expression
	;

additive_expression
	: multiplicative_expression
	| additive_expression '+' {writeHTML_Operator("+");} multiplicative_expression
	| additive_expression '-' {writeHTML_Operator("-");} multiplicative_expression
	;

shift_expression
	: additive_expression
	| shift_expression LEFT_OP {writeHTML_Operator("<<");} additive_expression
	| shift_expression RIGHT_OP {writeHTML_Operator(">>");} additive_expression
	;

relational_expression
	: shift_expression
	| relational_expression '<' {writeHTML_Operator("<");} shift_expression
	| relational_expression '>' {writeHTML_Operator(">");} shift_expression
	| relational_expression LE_OP {writeHTML_Operator("<=");} shift_expression
	| relational_expression GE_OP {writeHTML_Operator(">=");} shift_expression
	;

equality_expression
	: relational_expression
	| equality_expression EQ_OP {writeHTML_Operator("==");} relational_expression
	| equality_expression NE_OP {writeHTML_Operator("!=");} relational_expression
	;

and_expression
	: equality_expression
	| and_expression '&' {writeHTML_Operator("&");} equality_expression
	;

exclusive_or_expression
	: and_expression
	| exclusive_or_expression '^' {writeHTML_Operator("^");} and_expression
	;

inclusive_or_expression
	: exclusive_or_expression
	| inclusive_or_expression '|' {writeHTML_Operator("|");} exclusive_or_expression
	;

logical_and_expression
	: inclusive_or_expression
	| logical_and_expression AND_OP {writeHTML_Operator("&&");} inclusive_or_expression
	;

logical_or_expression
	: logical_and_expression
	| logical_or_expression OR_OP {writeHTML_Operator("||");} logical_and_expression
	;

conditional_expression
	: logical_or_expression
	| logical_or_expression '?' {writeHTML_Operator("?");} expression ':' {writeHTML_Operator(":");} conditional_expression
	;

assignment_expression
	: conditional_expression
	| unary_expression assignment_operator assignment_expression
	;

assignment_operator
	: '=' {writeHTML_Operator("=");}
	| MUL_ASSIGN {writeHTML_Operator("*=");}
	| DIV_ASSIGN {writeHTML_Operator("/=");}
	| MOD_ASSIGN {writeHTML_Operator("%=");}
	| ADD_ASSIGN {writeHTML_Operator("+=");}
	| SUB_ASSIGN {writeHTML_Operator("-=");}
	| LEFT_ASSIGN {writeHTML_Operator("<<=");}
	| RIGHT_ASSIGN {writeHTML_Operator(">>=");}
	| AND_ASSIGN {writeHTML_Operator("&=");}
	| XOR_ASSIGN {writeHTML_Operator("^=");}
	| OR_ASSIGN {writeHTML_Operator("|=");}
	;

expression
	: assignment_expression
	| expression ',' {writeHTML_Operator(",");} assignment_expression
	;

constant_expression
	: conditional_expression	/* with constraints */
	;

declaration
	: declaration_specifiers ';' {writeHTML_Operator(";");}
	| declaration_specifiers init_declarator_list ';' {writeHTML_Operator(";");}
	| static_assert_declaration
	;

declaration_specifiers
	: storage_class_specifier declaration_specifiers
	| storage_class_specifier
	| type_specifier declaration_specifiers
	| type_specifier
	| type_qualifier declaration_specifiers
	| type_qualifier
	| function_specifier declaration_specifiers
	| function_specifier
	| alignment_specifier declaration_specifiers
	| alignment_specifier
	;

init_declarator_list
	: init_declarator
	| init_declarator_list ',' {writeHTML_Operator(",");} init_declarator
	;

init_declarator
	: declarator '=' {writeHTML_Operator("=");} initializer
	| declarator
	;

storage_class_specifier
	: TYPEDEF	/* identifiers must be flagged as TYPEDEF_NAME */
	| EXTERN
	| STATIC
	| THREAD_LOCAL
	| AUTO
	| REGISTER
	;

type_specifier
	: VOID
	| CHAR
	| SHORT
	| INT
	| LONG
	| FLOAT
	| DOUBLE
	| SIGNED
	| UNSIGNED
	| BOOL
	| COMPLEX
	| IMAGINARY	  	/* non-mandated extension */
	| atomic_type_specifier
	| struct_or_union_specifier
	| enum_specifier
	| TYPEDEF_NAME		/* after it has been defined as such */
	;

struct_or_union_specifier
	: struct_or_union '{' {writeHTML_Operator("{");} struct_declaration_list '}' {writeHTML_Operator("}");}
	| struct_or_union IDENTIFIER '{' {writeHTML_Operator("{");} struct_declaration_list '}' {writeHTML_Operator("}");}
	| struct_or_union IDENTIFIER
	;

struct_or_union
	: STRUCT
	| UNION
	;

struct_declaration_list
	: struct_declaration
	| struct_declaration_list struct_declaration
	;

struct_declaration
	: specifier_qualifier_list ';' {writeHTML_Operator(";");}	/* for anonymous struct/union */
	| specifier_qualifier_list struct_declarator_list ';' {writeHTML_Operator(";");}
	| static_assert_declaration
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list
	| type_specifier
	| type_qualifier specifier_qualifier_list
	| type_qualifier
	;

struct_declarator_list
	: struct_declarator
	| struct_declarator_list ',' {writeHTML_Operator(",");} struct_declarator
	;

struct_declarator
	: ':' {writeHTML_Operator(":");} constant_expression
	| declarator ':' {writeHTML_Operator(":");} constant_expression
	| declarator
	;

enum_specifier
	: ENUM '{' {writeHTML_Operator("{");} enumerator_list '}' {writeHTML_Operator("}");}
	| ENUM '{' {writeHTML_Operator("{");} enumerator_list ',' {writeHTML_Operator(",");} '}' {writeHTML_Operator("}");}
	| ENUM IDENTIFIER '{' {writeHTML_Operator("{");} enumerator_list '}' {writeHTML_Operator("}");}
	| ENUM IDENTIFIER '{' {writeHTML_Operator("{");} enumerator_list ',' {writeHTML_Operator(",");} '}' {writeHTML_Operator("}");}
	| ENUM IDENTIFIER
	;

enumerator_list
	: enumerator
	| enumerator_list ',' {writeHTML_Operator(",");} enumerator
	;

enumerator	/* identifiers must be flagged as ENUMERATION_CONSTANT */
	: enumeration_constant '=' {writeHTML_Operator("=");} constant_expression
	| enumeration_constant
	;

atomic_type_specifier
	: ATOMIC '(' {writeHTML_Operator("(");} type_name ')' {writeHTML_Operator(")");}
	;

type_qualifier
	: CONST
	| RESTRICT
	| VOLATILE
	| ATOMIC
	;

function_specifier
	: INLINE
	| NORETURN
	;

alignment_specifier
	: ALIGNAS '(' {writeHTML_Operator("(");} type_name ')' {writeHTML_Operator(")");}
	| ALIGNAS '(' {writeHTML_Operator("(");} constant_expression ')' {writeHTML_Operator(")");}
	;

declarator
	: pointer direct_declarator
	| direct_declarator
	;

direct_declarator
	: IDENTIFIER
	| '(' {writeHTML_Operator("(");} declarator ')' {writeHTML_Operator(")");}
	| direct_declarator '[' {writeHTML_Operator("[");} ']' {writeHTML_Operator("]");}
	| direct_declarator '[' {writeHTML_Operator("[");} '*' {writeHTML_Operator("*");} ']' {writeHTML_Operator("]");}
	| direct_declarator '[' {writeHTML_Operator("[");} STATIC type_qualifier_list assignment_expression ']' {writeHTML_Operator("]");}
	| direct_declarator '[' {writeHTML_Operator("[");} STATIC assignment_expression ']' {writeHTML_Operator("]");}
	| direct_declarator '[' {writeHTML_Operator("[");} type_qualifier_list '*' {writeHTML_Operator("*");} ']' {writeHTML_Operator("]");}
	| direct_declarator '[' {writeHTML_Operator("[");} type_qualifier_list STATIC assignment_expression ']' {writeHTML_Operator("]");}
	| direct_declarator '[' {writeHTML_Operator("[");} type_qualifier_list assignment_expression ']' {writeHTML_Operator("]");}
	| direct_declarator '[' {writeHTML_Operator("[");} type_qualifier_list ']' {writeHTML_Operator("]");}
	| direct_declarator '[' {writeHTML_Operator("[");} assignment_expression ']' {writeHTML_Operator("]");}
	| direct_declarator '(' {writeHTML_Operator("(");} parameter_type_list ')' {writeHTML_Operator(")");}
	| direct_declarator '(' {writeHTML_Operator("(");} ')' {writeHTML_Operator(")");}
	| direct_declarator '(' {writeHTML_Operator("(");} identifier_list ')' {writeHTML_Operator(")");}
	;

pointer
	: '*' {writeHTML_Operator("*");} type_qualifier_list pointer
	| '*' {writeHTML_Operator("*");} type_qualifier_list
	| '*' {writeHTML_Operator("*");} pointer
	| '*' {writeHTML_Operator("*");}
	;

type_qualifier_list
	: type_qualifier
	| type_qualifier_list type_qualifier
	;


parameter_type_list
	: parameter_list ',' {writeHTML_Operator(",");} ELLIPSIS
	| parameter_list
	;

parameter_list
	: parameter_declaration
	| parameter_list ',' {writeHTML_Operator(",");} parameter_declaration
	;

parameter_declaration
	: declaration_specifiers declarator
	| declaration_specifiers abstract_declarator
	| declaration_specifiers
	;

identifier_list
	: IDENTIFIER
	| identifier_list ',' {writeHTML_Operator(",");} IDENTIFIER
	;

type_name
	: specifier_qualifier_list abstract_declarator
	| specifier_qualifier_list
	;

abstract_declarator
	: pointer direct_abstract_declarator
	| pointer
	| direct_abstract_declarator
	;

direct_abstract_declarator
	: '(' {writeHTML_Operator("(");} abstract_declarator ')' {writeHTML_Operator(")");}
	| '[' {writeHTML_Operator("[");} ']' {writeHTML_Operator("]");}
	| '[' {writeHTML_Operator("[");} '*' {writeHTML_Operator("*");} ']' {writeHTML_Operator("]");}
	| '[' {writeHTML_Operator("[");} STATIC type_qualifier_list assignment_expression ']' {writeHTML_Operator("]");}
	| '[' {writeHTML_Operator("[");} STATIC assignment_expression ']' {writeHTML_Operator("]");}
	| '[' {writeHTML_Operator("[");} type_qualifier_list STATIC assignment_expression ']' {writeHTML_Operator("]");}
	| '[' {writeHTML_Operator("[");} type_qualifier_list assignment_expression ']' {writeHTML_Operator("]");}
	| '[' {writeHTML_Operator("[");} type_qualifier_list ']' {writeHTML_Operator("]");}
	| '[' {writeHTML_Operator("[");} assignment_expression ']' {writeHTML_Operator("]");}
	| direct_abstract_declarator '[' {writeHTML_Operator("[");} ']' {writeHTML_Operator("]");}
	| direct_abstract_declarator '[' {writeHTML_Operator("[");} '*' {writeHTML_Operator("*");} ']' {writeHTML_Operator("]");}
	| direct_abstract_declarator '[' {writeHTML_Operator("[");} STATIC type_qualifier_list assignment_expression ']' {writeHTML_Operator("]");}
	| direct_abstract_declarator '[' {writeHTML_Operator("[");} STATIC assignment_expression ']' {writeHTML_Operator("]");}
	| direct_abstract_declarator '[' {writeHTML_Operator("[");} type_qualifier_list assignment_expression ']' {writeHTML_Operator("]");}
	| direct_abstract_declarator '[' {writeHTML_Operator("[");} type_qualifier_list STATIC assignment_expression ']' {writeHTML_Operator("]");}
	| direct_abstract_declarator '[' {writeHTML_Operator("[");} type_qualifier_list ']' {writeHTML_Operator("]");}
	| direct_abstract_declarator '[' {writeHTML_Operator("[");} assignment_expression ']' {writeHTML_Operator("]");}
	| '(' {writeHTML_Operator("(");} ')' {writeHTML_Operator(")");}
	| '(' {writeHTML_Operator("(");} parameter_type_list ')' {writeHTML_Operator(")");}
	| direct_abstract_declarator '(' {writeHTML_Operator("(");} ')' {writeHTML_Operator(")");}
	| direct_abstract_declarator '(' {writeHTML_Operator("(");} parameter_type_list ')' {writeHTML_Operator(")");}
	;

initializer
	: '{' {writeHTML_Operator("{");} initializer_list '}' {writeHTML_Operator("}");}
	| '{' {writeHTML_Operator("{");} initializer_list ',' {writeHTML_Operator(",");} '}' {writeHTML_Operator("}");}
	| assignment_expression
	;

initializer_list
	: designation initializer
	| initializer
	| initializer_list ',' {writeHTML_Operator(",");} designation initializer
	| initializer_list ',' {writeHTML_Operator(",");} initializer
	;

designation
	: designator_list '=' {writeHTML_Operator("=");}
	;

designator_list
	: designator
	| designator_list designator
	;

designator
	: '[' {writeHTML_Operator("[");} constant_expression ']' {writeHTML_Operator("]");}
	| '.' {writeHTML_Operator(".");} IDENTIFIER
	;

static_assert_declaration
	: STATIC_ASSERT '(' {writeHTML_Operator("(");} constant_expression ',' {writeHTML_Operator(",");} STRING_LITERAL ')' {writeHTML_Operator(")");} ';' {writeHTML_Operator(";");}
	;

statement
	: labeled_statement
	| compound_statement
	| expression_statement
	| selection_statement
	| iteration_statement
	| jump_statement
	;

labeled_statement
	: IDENTIFIER ':' {writeHTML_Operator(":");} statement
	| CASE constant_expression ':' {writeHTML_Operator(":");} statement
	| DEFAULT ':' {writeHTML_Operator(":");} statement
	;

compound_statement
	: '{' {writeHTML_Operator("{");} '}' {writeHTML_Operator("}");}
	| '{' {writeHTML_Operator("{");} block_item_list '}' {writeHTML_Operator("}");}
	;

block_item_list
	: block_item
	| block_item_list block_item
	;

block_item
	: declaration
	| statement
	;

expression_statement
	: ';' {writeHTML_Operator(";");}
	| expression ';' {writeHTML_Operator(";");}
	;

selection_statement
	: IF '(' {writeHTML_Operator("(");} expression ')' {writeHTML_Operator(")");} statement ELSE statement
	| IF '(' {writeHTML_Operator("(");} expression ')' {writeHTML_Operator(")");} statement
	| SWITCH '(' {writeHTML_Operator("(");} expression ')' {writeHTML_Operator(")");} statement
	;

iteration_statement
	: WHILE '(' {writeHTML_Operator("(");} expression ')' {writeHTML_Operator(")");} statement
	| DO statement WHILE '(' {writeHTML_Operator("(");} expression ')' {writeHTML_Operator(")");} ';' {writeHTML_Operator(";");}
	| FOR '(' {writeHTML_Operator("(");} expression_statement expression_statement ')' {writeHTML_Operator(")");} statement
	| FOR '(' {writeHTML_Operator("(");} expression_statement expression_statement expression ')' {writeHTML_Operator(")");} statement
	| FOR '(' {writeHTML_Operator("(");} declaration expression_statement ')' {writeHTML_Operator(")");} statement
	| FOR '(' {writeHTML_Operator("(");} declaration expression_statement expression ')' {writeHTML_Operator(")");} statement
	;

jump_statement
	: GOTO IDENTIFIER ';' {writeHTML_Operator(";");}
	| CONTINUE ';' {writeHTML_Operator(";");}
	| BREAK ';' {writeHTML_Operator(";");}
	| RETURN ';' {writeHTML_Operator(";");}
	| RETURN expression ';' {writeHTML_Operator(";");}
	;

translation_unit
	: external_declaration
	| translation_unit external_declaration
	;

external_declaration
	: function_definition
	| declaration
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement
	| declaration_specifiers declarator compound_statement
	;

declaration_list
	: declaration
	| declaration_list declaration
	;

%%
#include <stdio.h>

void yyerror(const char *s)
{
	fflush(stdout);
	fprintf(stderr, "*** %s\n", s);
}
