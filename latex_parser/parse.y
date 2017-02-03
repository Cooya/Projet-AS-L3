%token TITLE PART CHAPTER SECTION SUBSECTION SUBSUBSECTION PARAGRAPH SUBPARAGRAPH
%token FLUSHRIGHT FLUSHLEFT CENTER NEWLINE SPACE NEWPARAGRAPH
%token TINY SCRIPTSIZE FOOTNOTESIZE SMALL NORMALSIZE LARGE VERYLARGE VERYVERYLARGE HUGE VERYHUGE TEXTCOLOR FONTFAMILY NORMALFONT BFSERIES ITSHAPE TEXTSC TEXTSUPERSCRIPT FBOX UL BARRER
%token LABEL REF PAGEREF INDEX CITE FOOTNOTE
%token DATE TODAY
%token BEGIN_ENV END_ENV ITEM ROW_SEPARATOR 
%token DOCUMENT TITLEPAGE ENV_CENTER TABLE TABULAR ENUMERATE ITEMIZE EQUATION NUMEROTED_EQUATION
%token DOLLAR_PRINTED AND_PRINTED OPSQRBRK_PRINTED CLSQRBRK_PRINTED OPBRC_PRINTED CLBRC_PRINTED DOUBLE_AND BACKSLASH STRING
%token ERROR

%start document

%{
	#define YYDEBUG 1
	#include <stdio.h>

	int yydebug = 1;
	int yyparse(void);
	int yylex(void);
	void yyerror (char const *s);
	extern FILE* yyin;

	int main() {
		yyin = fopen("test.tex", "r");
		if(yyin)
			printf("%d\n",yyparse());
		return 0;
	}

%}

%%
command_name
	: TITLE
	| PART
	| CHAPTER
	| SECTION
	| SUBSECTION
	| SUBSUBSECTION
	| PARAGRAPH
	| SUBPARAGRAPH
	| FLUSHRIGHT
	| FLUSHLEFT
	| CENTER
	| NEWLINE
	| TINY
	| SCRIPTSIZE
	| FOOTNOTESIZE
	| SMALL
	| NORMALSIZE
	| LARGE
	| VERYLARGE
	| VERYVERYLARGE
	| HUGE
	| VERYHUGE
	| TEXTCOLOR
	| FONTFAMILY
	| NORMALFONT
	| BFSERIES
	| ITSHAPE
	| TEXTSC
	| TEXTSUPERSCRIPT
	| FBOX
	| UL
	| BARRER
	| LABEL
	| REF
	| PAGEREF
	| INDEX
	| CITE
	| FOOTNOTE
	| DATE
	| TODAY
	;

separated_strings
	: separated_strings ',' STRING
	| STRING
	;

optional_options_list
	: optional_options_list '[' separated_strings ']'
	| '[' separated_strings ']'
	;

items_list
	: items_list ITEM elements_list
	| ITEM elements_list
	;

columns_list
	: columns_list '&' elements_list
	| elements_list
	;

rows_list
	: rows_list ROW_SEPARATOR columns_list
	| columns_list
	;

env
	/* Mise en page */
	: BEGIN_ENV '{' DOCUMENT '}' optional_options_list elements_list END_ENV '{' DOCUMENT '}'
	| BEGIN_ENV '{' DOCUMENT '}' elements_list END_ENV '{' DOCUMENT'}'

	| BEGIN_ENV '{' TITLEPAGE '}' optional_options_list elements_list END_ENV '{' TITLEPAGE '}'
	| BEGIN_ENV '{' TITLEPAGE '}' elements_list END_ENV '{' TITLEPAGE'}'

	| BEGIN_ENV '{' ENV_CENTER '}' optional_options_list elements_list END_ENV '{' ENV_CENTER '}'
	| BEGIN_ENV '{' ENV_CENTER '}' elements_list END_ENV '{' ENV_CENTER '}'
	/* --- */

	/* Listes */
	| BEGIN_ENV '{' ENUMERATE '}' items_list END_ENV '{' ENUMERATE '}'
	| BEGIN_ENV '{' ITEMIZE '}' items_list END_ENV '{' ITEMIZE '}'
	/* --- */

	/* Tableaux */
	| BEGIN_ENV '{' TABLE '}' '{' STRING '}' rows_list END_ENV '{' TABLE '}'
	| BEGIN_ENV '{' TABLE '}' '{' STRING '}' rows_list ROW_SEPARATOR END_ENV '{' TABLE '}'

	| BEGIN_ENV '{' TABULAR '}' '{' STRING '}' rows_list END_ENV '{' TABULAR '}'
	| BEGIN_ENV '{' TABULAR '}' '{' STRING '}' rows_list ROW_SEPARATOR END_ENV '{' TABULAR '}'
	/* --- */

	/* Equations */
	| BEGIN_ENV '{' EQUATION '}' elements_list END_ENV '{' EQUATION '}'
	| BEGIN_ENV '{' NUMEROTED_EQUATION '}' elements_list END_ENV '{' NUMEROTED_EQUATION '}'
	/* --- */
	;

command 
	: command_name
	| command_name optional_options_list
	;

escaped_char
	: DOLLAR_PRINTED;
	| AND_PRINTED;
	| OPSQRBRK_PRINTED;
	| CLSQRBRK_PRINTED;
	| OPBRC_PRINTED;
	| CLBRC_PRINTED; 

text
	: escaped_char
	| STRING
	;

element
	: text
	| command
	| env
	| SPACE
	| '{' elements_list '}' 
	;

elements_list
	: elements_list element
	| element
	;

document
	: elements_list
	;
%%




