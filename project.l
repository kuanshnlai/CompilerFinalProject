%{

#include"struct.h"
#include"y.tab.h"
#include<stdio.h>
#include<stdlib.h>
%}

%%
Declare	| 
declare {return Declare;}
Program  {return Program;}
Begin	 {return Begin;}
End		 {return End;}
As	| 
as      {return As;}
Integer	| 
integer {return Integer;}
Float	| 
float   {return Float;}
WHILE	|
While	{return While;}
EndWhile |
ENDWHILE {return EndWhile;}
FOR		|
For     {return For;}
:=		{return Assign;}
TO		|
To		{return To;}
DownTo	|
DOWNTO  {return DownTo;}
Step	|
STEP	{return Step;}
ENDFOR	|
EndFor	{return EndFor;}
If		|
IF		|
if		{return If;}
THEN	|
Then	|
then	{return Then;}
Else	|
ELSE	|
else	{return Else;}
EndIf	|
endif	|
ENDIF	{return EndIf;}
"<"		{return LT;}
">"		{return GT;}
"=="	{return EQU;}
"<="		{return LTE;}
">="		{return GTE;}
([0-9]*\.[0-9]+)([eE][-+]?[0-9]+)? {
		
		yylval.symp = symlook(yytext);
		yylval.symp->val = atof(yytext);
		return Double;
	}
[0-9]+	{	
			yylval.symp = symlook(yytext);
			yylval.symp->val = atoi(yytext);
			
			return Int;
		}
[ \t\n] ;
[A-Za-z][A-Za-z0-9]* {
		yylval.symp = symlook(yytext);
		return NAME;
	}
"$"	{return 0;}
.	return yytext[0];
%%

