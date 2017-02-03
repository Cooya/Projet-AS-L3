%e  1019
%p  2807
%n  371
%k  284
%a  1213
%o  1117

O   [0-7]
D   [0-9]
NZ  [1-9]
L   [a-zA-Z_]
A   [a-zA-Z_0-9]
H   [a-fA-F0-9]
HP  (0[xX])
E   ([Ee][+-]?{D}+)
P   ([Pp][+-]?{D}+)
FS  (f|F|l|L)
IS  (((u|U)(l|L|ll|LL)?)|((l|L|ll|LL)(u|U)?))
CP  (u|U|L)
SP  (u8|u|U|L)
ES  (\\(['"\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))
 /*WS  [ \t\v\n\f]*/
CR \r?[\v\n\f]
WS [ \t]

%option nounput yylineno

%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"
#include "RenderFile.h"

#define ASSOC_STR yylval.str = malloc((strlen(yytext)+1)*sizeof(char)); strcpy(yylval.str, yytext)


extern void yyerror(const char *);  /* prints grammar violation message */
extern int yylex(void);
extern int sym_type(const char *);  /* returns type from symbol table */

extern void parsingError(const char *format, ...);

extern RenderFile yyRenderFile;

#define sym_type(identifier) IDENTIFIER /* with no symbol table, fake it */

static void comment(void);
static int check_type(void);

extern int fileno(FILE*);

//int identifiersCpt = 0;

%}

%%
"/*"                                    { comment(); }
"//".*                                    { /* consume //-comment */ }

"auto"					{ writeHTML_Special(yyRenderFile, yytext); return(AUTO); }
"break"					{ writeHTML_Special(yyRenderFile, yytext); return(BREAK); }
"case"					{ writeHTML_Special(yyRenderFile, yytext); return(CASE); }
"char"					{ writeHTML_Special(yyRenderFile, yytext); return(CHAR); }
"const"					{ writeHTML_Special(yyRenderFile, yytext); return(CONST); }
"continue"				{ writeHTML_Special(yyRenderFile, yytext); return(CONTINUE); }
"default"				{ writeHTML_Special(yyRenderFile, yytext); return(DEFAULT); }
"do"					{ writeHTML_Special(yyRenderFile, yytext); return(DO); }
"double"				{ writeHTML_Special(yyRenderFile, yytext); return(DOUBLE); }
"else"					{ writeHTML_Special(yyRenderFile, yytext); return(ELSE); }
"enum"					{ writeHTML_Special(yyRenderFile, yytext); return(ENUM); }
"extern"				{ writeHTML_Special(yyRenderFile, yytext); return(EXTERN); }
"float"					{ writeHTML_Special(yyRenderFile, yytext); return(FLOAT); }
"for"					{ writeHTML_Special(yyRenderFile, yytext); return(FOR); }
"goto"					{ writeHTML_Special(yyRenderFile, yytext); return(GOTO); }
"if"					{ writeHTML_Special(yyRenderFile, yytext); return(IF); }
"inline"				{ writeHTML_Special(yyRenderFile, yytext); return(INLINE); }
"int"					{ writeHTML_Special(yyRenderFile, yytext); return(INT); }
"long"					{ writeHTML_Special(yyRenderFile, yytext); return(LONG); }
"register"				{ writeHTML_Special(yyRenderFile, yytext); return(REGISTER); }
"restrict"				{ writeHTML_Special(yyRenderFile, yytext); return(RESTRICT); }
"return"				{ writeHTML_Special(yyRenderFile, yytext); return(RETURN); }
"short"					{ writeHTML_Special(yyRenderFile, yytext); return(SHORT); }
"signed"				{ writeHTML_Special(yyRenderFile, yytext); return(SIGNED); }
"sizeof"				{ writeHTML_Special(yyRenderFile, yytext); return(SIZEOF); }
"static"				{ writeHTML_Special(yyRenderFile, yytext); return(STATIC); }
"struct"				{ writeHTML_Special(yyRenderFile, yytext); return(STRUCT); }
"switch"				{ writeHTML_Special(yyRenderFile, yytext); return(SWITCH); }
"typedef"				{ writeHTML_Special(yyRenderFile, yytext); return(TYPEDEF); }
"union"					{ writeHTML_Special(yyRenderFile, yytext); return(UNION); }
"unsigned"				{ writeHTML_Special(yyRenderFile, yytext); return(UNSIGNED); }
"void"					{ writeHTML_Special(yyRenderFile, yytext); return(VOID); }
"volatile"				{ writeHTML_Special(yyRenderFile, yytext); return(VOLATILE); }
"while"					{ writeHTML_Special(yyRenderFile, yytext); return(WHILE); }
"_Alignas"                              { writeHTML_Special(yyRenderFile, yytext); return ALIGNAS; }
"_Alignof"                              { writeHTML_Special(yyRenderFile, yytext); return ALIGNOF; }
"_Atomic"                               { writeHTML_Special(yyRenderFile, yytext); return ATOMIC; }
"_Bool"                                 { writeHTML_Special(yyRenderFile, yytext); return BOOL; }
"_Complex"                              { writeHTML_Special(yyRenderFile, yytext); return COMPLEX; }
"_Generic"                              { writeHTML_Special(yyRenderFile, yytext); return GENERIC; }
"_Imaginary"                            { writeHTML_Special(yyRenderFile, yytext); return IMAGINARY; }
"_Noreturn"                             { writeHTML_Special(yyRenderFile, yytext); return NORETURN; }
"_Static_assert"                        { writeHTML_Special(yyRenderFile, yytext); return STATIC_ASSERT; }
"_Thread_local"                         { writeHTML_Special(yyRenderFile, yytext); return THREAD_LOCAL; }
"__func__"                              { writeHTML_Special(yyRenderFile, yytext); return FUNC_NAME; }

{L}{A}*					{ ASSOC_STR;/*writeHTML_Identifier(yyRenderFile, yytext, identifiersCpt); yylval.integer = identifiersCpt++;*/ return check_type(); }

{HP}{H}+{IS}?				{ writeHTML_Constant(yyRenderFile, yytext); return I_CONSTANT; }
{NZ}{D}*{IS}?				{ writeHTML_Constant(yyRenderFile, yytext); return I_CONSTANT; }
"0"{O}*{IS}?				{ writeHTML_Constant(yyRenderFile, yytext); return I_CONSTANT; }
{CP}?"'"([^'\\\n]|{ES})+"'"		{ writeHTML_Constant(yyRenderFile, yytext); return I_CONSTANT; }

{D}+{E}{FS}?				{ writeHTML_Constant(yyRenderFile, yytext); return F_CONSTANT; }
{D}*"."{D}+{E}?{FS}?			{ writeHTML_Constant(yyRenderFile, yytext); return F_CONSTANT; }
{D}+"."{E}?{FS}?			{ writeHTML_Constant(yyRenderFile, yytext); return F_CONSTANT; }
{HP}{H}+{P}{FS}?			{ writeHTML_Constant(yyRenderFile, yytext); return F_CONSTANT; }
{HP}{H}*"."{H}+{P}{FS}?			{ writeHTML_Constant(yyRenderFile, yytext); return F_CONSTANT; }
{HP}{H}+"."{P}{FS}?			{ writeHTML_Constant(yyRenderFile, yytext); return F_CONSTANT; }

({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+	{ writeHTML_String(yyRenderFile, yytext); return STRING_LITERAL; }

"..."					{ writeHTML_Operator(yyRenderFile, yytext); return ELLIPSIS; }
">>="					{ writeHTML_Operator(yyRenderFile, yytext); return RIGHT_ASSIGN; }
"<<="					{ writeHTML_Operator(yyRenderFile, yytext); return LEFT_ASSIGN; }
"+="					{ writeHTML_Operator(yyRenderFile, yytext); return ADD_ASSIGN; }
"-="					{ writeHTML_Operator(yyRenderFile, yytext); return SUB_ASSIGN; }
"*="					{ writeHTML_Operator(yyRenderFile, yytext); return MUL_ASSIGN; }
"/="					{ writeHTML_Operator(yyRenderFile, yytext); return DIV_ASSIGN; }
"%="					{ writeHTML_Operator(yyRenderFile, yytext); return MOD_ASSIGN; }
"&="					{ writeHTML_Operator(yyRenderFile, yytext); return AND_ASSIGN; }
"^="					{ writeHTML_Operator(yyRenderFile, yytext); return XOR_ASSIGN; }
"|="					{ writeHTML_Operator(yyRenderFile, yytext); return OR_ASSIGN; }
">>"					{ writeHTML_Operator(yyRenderFile, yytext); return RIGHT_OP; }
"<<"					{ writeHTML_Operator(yyRenderFile, yytext); return LEFT_OP; }
"++"					{ writeHTML_Operator(yyRenderFile, yytext); return INC_OP; }
"--"					{ writeHTML_Operator(yyRenderFile, yytext); return DEC_OP; }
"->"					{ writeHTML_Operator(yyRenderFile, yytext); return PTR_OP; }
"&&"					{ writeHTML_Operator(yyRenderFile, yytext); return AND_OP; }
"||"					{ writeHTML_Operator(yyRenderFile, yytext); return OR_OP; }
"<="					{ writeHTML_Operator(yyRenderFile, yytext); return LE_OP; }
">="					{ writeHTML_Operator(yyRenderFile, yytext); return GE_OP; }
"=="					{ writeHTML_Operator(yyRenderFile, yytext); return EQ_OP; }
"!="					{ writeHTML_Operator(yyRenderFile, yytext); return NE_OP; }
";"					{ writeHTML_Operator(yyRenderFile, yytext); return ';'; }
("{"|"<%")				{ shiftIndent(yyRenderFile); writeHTML_Operator(yyRenderFile, yytext);  return '{'; }
("}"|"%>")				{ unshiftIndent(yyRenderFile, false); writeHTML_Operator(yyRenderFile, yytext); return '}'; }
","					{ writeHTML_Operator(yyRenderFile, yytext); return ','; }
":"					{ writeHTML_Operator(yyRenderFile, yytext); return ':'; }
"="					{ writeHTML_Operator(yyRenderFile, yytext); return '='; }
"("					{ writeHTML_Operator(yyRenderFile, yytext); return '('; }
")"					{ writeHTML_Operator(yyRenderFile, yytext); return ')'; }
("["|"<:")				{ writeHTML_Operator(yyRenderFile, yytext); return '['; }
("]"|":>")				{ writeHTML_Operator(yyRenderFile, yytext); return ']'; }
"."					{ writeHTML_Operator(yyRenderFile, yytext); return '.'; }
"&"					{ writeHTML_Operator(yyRenderFile, yytext); return '&'; }
"!"					{ writeHTML_Operator(yyRenderFile, yytext); return '!'; }
"~"					{ writeHTML_Operator(yyRenderFile, yytext); return '~'; }
"-"					{ writeHTML_Operator(yyRenderFile, yytext); return '-'; }
"+"					{ writeHTML_Operator(yyRenderFile, yytext); return '+'; }
"*"					{ writeHTML_Operator(yyRenderFile, yytext); return '*'; }
"/"					{ writeHTML_Operator(yyRenderFile, yytext); return '/'; }
"%"					{ writeHTML_Operator(yyRenderFile, yytext); return '%'; }
"<"					{ writeHTML_Operator(yyRenderFile, yytext); return '<'; }
">"					{ writeHTML_Operator(yyRenderFile, yytext); return '>'; }
"^"					{ writeHTML_Operator(yyRenderFile, yytext); return '^'; }
"|"					{ writeHTML_Operator(yyRenderFile, yytext); return '|'; }
"?"					{ writeHTML_Operator(yyRenderFile, yytext); return '?'; }

{CR}{WS}*("}")     { unshiftIndent(yyRenderFile, true); writeHTML_NewLine(yyRenderFile, true); writeHTML_Operator(yyRenderFile, "}"); return '}'; }
{CR}{WS}*("%>")     { unshiftIndent(yyRenderFile, true); writeHTML_NewLine(yyRenderFile, true); writeHTML_Operator(yyRenderFile, "%>"); return '}'; }
{CR}{WS}*               { writeHTML_NewLine(yyRenderFile, true); }
{WS}                    { writeHTML_Space(yyRenderFile, yytext); /* whitespace separates tokens */ }
.					{ /* discard bad characters */ }

%%

int yywrap(void)        /* called at end of input */
{
    return 1;           /* terminate now */
}

void flush_buffer() {
	YY_FLUSH_BUFFER;
    yylineno = 1;
}

static void comment(void)
{
    int c;

    while ((c = input()) != 0)
        if (c == '*')
        {
            while ((c = input()) == '*')
                ;

            if (c == '/')
                return;

            if (c == 0)
                break;
        }
    parsingError("unterminated comment");
}

static int check_type(void)
{//printf("CHECK TYPE\n");
    switch (sym_type(yytext))
    {
    case TYPEDEF_NAME:                /* previously defined */
        return TYPEDEF_NAME;
    case ENUMERATION_CONSTANT:        /* previously defined */
        return ENUMERATION_CONSTANT;
    default:                          /* includes undefined */
        return IDENTIFIER;
    }
}
