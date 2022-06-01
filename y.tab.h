/* A Bison parser, made by GNU Bison 3.5.1.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

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

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

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
    NAME = 258,
    Double = 259,
    Int = 260,
    Float = 261,
    Integer = 262,
    Program = 263,
    Begin = 264,
    Declare = 265,
    As = 266,
    For = 267,
    To = 268,
    DownTo = 269,
    Step = 270,
    EndFor = 271,
    Assign = 272,
    End = 273,
    If = 274,
    Then = 275,
    Else = 276,
    EndIf = 277,
    While = 278,
    EndWhile = 279,
    LT = 280,
    GT = 281,
    EQU = 282,
    LTE = 283,
    GTE = 284,
    UMINUS = 285
  };
#endif
/* Tokens.  */
#define NAME 258
#define Double 259
#define Int 260
#define Float 261
#define Integer 262
#define Program 263
#define Begin 264
#define Declare 265
#define As 266
#define For 267
#define To 268
#define DownTo 269
#define Step 270
#define EndFor 271
#define Assign 272
#define End 273
#define If 274
#define Then 275
#define Else 276
#define EndIf 277
#define While 278
#define EndWhile 279
#define LT 280
#define GT 281
#define EQU 282
#define LTE 283
#define GTE 284
#define UMINUS 285

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 16 "project.y"

	struct symtab* symp;
	enum Type type;
	struct rangeDec* range; 
	char* op;

#line 124 "y.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
