/* A Bison parser, made by GNU Bison 3.0.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2013 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    TITLE = 258,
    PART = 259,
    CHAPTER = 260,
    SECTION = 261,
    SUBSECTION = 262,
    SUBSUBSECTION = 263,
    PARAGRAPH = 264,
    SUBPARAGRAPH = 265,
    FLUSHRIGHT = 266,
    FLUSHLEFT = 267,
    CENTER = 268,
    NEWLINE = 269,
    SPACE = 270,
    NEWPARAGRAPH = 271,
    TINY = 272,
    SCRIPTSIZE = 273,
    FOOTNOTESIZE = 274,
    SMALL = 275,
    NORMALSIZE = 276,
    LARGE = 277,
    VERYLARGE = 278,
    VERYVERYLARGE = 279,
    HUGE = 280,
    VERYHUGE = 281,
    TEXTCOLOR = 282,
    FONTFAMILY = 283,
    NORMALFONT = 284,
    BFSERIES = 285,
    ITSHAPE = 286,
    TEXTSC = 287,
    TEXTSUPERSCRIPT = 288,
    FBOX = 289,
    UL = 290,
    BARRER = 291,
    LABEL = 292,
    REF = 293,
    PAGEREF = 294,
    INDEX = 295,
    CITE = 296,
    FOOTNOTE = 297,
    DATE = 298,
    TODAY = 299,
    BEGIN_ENV = 300,
    END_ENV = 301,
    ITEM = 302,
    ROW_SEPARATOR = 303,
    DOCUMENT = 304,
    TITLEPAGE = 305,
    ENV_CENTER = 306,
    TABLE = 307,
    TABULAR = 308,
    ENUMERATE = 309,
    ITEMIZE = 310,
    EQUATION = 311,
    NUMEROTED_EQUATION = 312,
    DOLLAR_PRINTED = 313,
    AND_PRINTED = 314,
    OPSQRBRK_PRINTED = 315,
    CLSQRBRK_PRINTED = 316,
    OPBRC_PRINTED = 317,
    CLBRC_PRINTED = 318,
    DOUBLE_AND = 319,
    BACKSLASH = 320,
    STRING = 321,
    ERROR = 322
  };
#endif
/* Tokens.  */
#define TITLE 258
#define PART 259
#define CHAPTER 260
#define SECTION 261
#define SUBSECTION 262
#define SUBSUBSECTION 263
#define PARAGRAPH 264
#define SUBPARAGRAPH 265
#define FLUSHRIGHT 266
#define FLUSHLEFT 267
#define CENTER 268
#define NEWLINE 269
#define SPACE 270
#define NEWPARAGRAPH 271
#define TINY 272
#define SCRIPTSIZE 273
#define FOOTNOTESIZE 274
#define SMALL 275
#define NORMALSIZE 276
#define LARGE 277
#define VERYLARGE 278
#define VERYVERYLARGE 279
#define HUGE 280
#define VERYHUGE 281
#define TEXTCOLOR 282
#define FONTFAMILY 283
#define NORMALFONT 284
#define BFSERIES 285
#define ITSHAPE 286
#define TEXTSC 287
#define TEXTSUPERSCRIPT 288
#define FBOX 289
#define UL 290
#define BARRER 291
#define LABEL 292
#define REF 293
#define PAGEREF 294
#define INDEX 295
#define CITE 296
#define FOOTNOTE 297
#define DATE 298
#define TODAY 299
#define BEGIN_ENV 300
#define END_ENV 301
#define ITEM 302
#define ROW_SEPARATOR 303
#define DOCUMENT 304
#define TITLEPAGE 305
#define ENV_CENTER 306
#define TABLE 307
#define TABULAR 308
#define ENUMERATE 309
#define ITEMIZE 310
#define EQUATION 311
#define NUMEROTED_EQUATION 312
#define DOLLAR_PRINTED 313
#define AND_PRINTED 314
#define OPSQRBRK_PRINTED 315
#define CLSQRBRK_PRINTED 316
#define OPBRC_PRINTED 317
#define CLBRC_PRINTED 318
#define DOUBLE_AND 319
#define BACKSLASH 320
#define STRING 321
#define ERROR 322

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
