%{
	#include "y.tab.h"
	int fileno(FILE *stream);
%}

blank 	[[:blank:]]+|\n
word	[^ \t\n$&{}|\[\]\\]+
column 	[^, \t\n$&{}|\[\]\\]+
line	[^$&{}\\\n]+	

%option stack
%x CMD ARGS_LIST ENV_NAME ARRAY EQ EQ_CMD

/*  CMD représente une commande, sous la forme \commande
	ARGS_LIST représente une liste d'arguments, sous la forme [str1, str2, ..., strn]
	ENV_NAME représente la déclaration de début et de fin d'environnement, sous la forme \begin{str} ou \end{str}
	ARRAY représente un tableau, cet état est identique à l'état initial, mis à part qu'on retourne les '&'
*/

%%

 /* Mise en page */
<CMD>"title"							return TITLE;
<CMD>"part"								return PART;
<CMD>"chapter"							return CHAPTER;
<CMD>"section"							return SECTION;
<CMD>"subsection"						return SUBSECTION;
<CMD>"subsubsection"					return SUBSUBSECTION;
<CMD>"paragraph"						return PARAGRAPH;
<CMD>"subparagraph"						return SUBPARAGRAPH;
<CMD>"item"								return ITEM;

 /* Positionnement du texte */
<CMD>"flushright"						return FLUSHRIGHT;
<CMD>"flushletf"						return FLUSHLEFT;
<CMD>"center"							return CENTER;
<CMD>"newline"							return NEWLINE;
<CMD>"\\"								return NEWLINE;
 /* <*>\n 									return SPACE; */
<*>\n\n 								return NEWPARAGRAPH;

 /* Formattage du texte */
<CMD>"tiny"								return TINY;
<CMD>"scriptsize"						return SCRIPTSIZE;
<CMD>"footnotesize"						return FOOTNOTESIZE;
<CMD>"small"							return SMALL;
<CMD>"normalsize"						return NORMALSIZE;
<CMD>"large"							return LARGE;
<CMD>"Large"							return VERYLARGE;
<CMD>"LARGE"							return VERYVERYLARGE;
<CMD>"huge"								return HUGE;
<CMD>"Huge"								return VERYHUGE;
<CMD>"textcolor"						return TEXTCOLOR;
<CMD>"fontfamily"						return FONTFAMILY;
<CMD>"normalfont"						return NORMALFONT;
<CMD>"bfseries"							return BFSERIES;
<CMD>"itshape"							return ITSHAPE;
<CMD>"textsc"							return TEXTSC;
<CMD>"textsuperscript"					return TEXTSUPERSCRIPT;
<CMD>"fbox"								return FBOX;
<CMD>"ul"								return UL;
<CMD>"barrer"							return BARRER;

 /* Références */
<CMD>"label"							return LABEL;
<CMD>"ref"								return REF;
<CMD>"pageref"							return PAGEREF;
<CMD>"index"							return INDEX;
<CMD>"cite"								return CITE;
<CMD>"footnote"							return FOOTNOTE;

 /* Dates */
<CMD>"date"								return DATE;
<CMD>"today"							return TODAY;

 /* Blocs */
<CMD>"begin"							{yy_push_state(ENV_NAME); return BEGIN_ENV;}
<CMD>"end"								{yy_pop_state(); yy_push_state(ENV_NAME); return END_ENV;}

 /* Types de bloc */
<ENV_NAME>"document"					return DOCUMENT;
<ENV_NAME>"titlepage"					return TITLEPAGE;
<ENV_NAME>"center"						return ENV_CENTER;				
<ENV_NAME>"table"						{yy_push_state(ARRAY); return TABLE;}
<ENV_NAME>"tabular"						{yy_push_state(ARRAY); return TABULAR;}
<ENV_NAME>"enumerate"					return ENUMERATE;
<ENV_NAME>"itemize"						return ITEMIZE;
<ENV_NAME>"equation"					{yy_push_state(EQ); return EQUATION;}
<ENV_NAME>"equation*"					{yy_push_state(EQ); return NUMEROTED_EQUATION;}

 /* Caractères échappés */
"\\$"									return DOLLAR_PRINTED;
"\\&"									return AND_PRINTED;
"\\["									return OPSQRBRK_PRINTED;
"\\]"									return CLSQRBRK_PRINTED;
"\\{"									return OPBRC_PRINTED;
"\\}"									return CLBRC_PRINTED;
<CMD>"backslash"						{yy_pop_state(); return BACKSLASH;}

<INITIAL,ARRAY>"\\"						yy_push_state(CMD);	
<INITIAL,ARRAY,EQ>"{"					return '{';
<INITIAL,ARRAY,EQ>"}"					return '}';
<INITIAL,ARRAY,EQ>{line}				return STRING;
<ARRAY>"\\\\"							return ROW_SEPARATOR; /* séparateur de lignes dans un tableau */
<ARRAY>"&"								return '&'; /* séparateur de colonnes dans un tableau */
<EQ>"\\"								yy_push_state(CMD);
<EQ>"\\"[\\]+							return SPACE;

 /* pour sortir d'une commande, il faut soit un blanc soit un '{' */
<CMD>{blank}							yy_pop_state();
<CMD>"{"								{yy_pop_state(); return '{';}
<CMD>"["								{yy_push_state(ARGS_LIST); return '[';}

 /* pour sortir d'une liste d'arguments, il faut un ']' */
<ARGS_LIST>"]"							{yy_pop_state(); return ']';}
<ARGS_LIST>{column}						return STRING;			
<ARGS_LIST>","							return ',';

 /* pour sortir de la déclaration d'un environnement, il faut un '}' */
<ENV_NAME>"{"							return '{';
<ENV_NAME>"}"							{yy_pop_state(); return '}';}					

"&&"									return DOUBLE_AND; /* je ne sais pas à quoi il sert pour le moment */
<*>{blank}								/* règle vide pour ignorer les blancs et les sauts de ligne  */
<*>.									return ERROR; /* si cette ligne est atteinte, cela veut dire qu'il y a quelque chose d'inattendu */

%%


/* Pour le moment, les blancs (qui sont considérés comme un espace) ne sont pas gérés, ils ne sont jamais renvoyés. */