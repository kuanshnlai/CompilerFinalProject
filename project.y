%{
#include"struct.h"
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
struct symtab STable[MAXLEN];
struct VEntry VTable[MAXLEN];
int cnt = 0;
bool regUsed[32]={};
int labelCur = 0;
int elseLabelStack[MAXLEN];
int eTop = 0;
int seqLabelStack[MAXLEN];
int sTop = 0;
%}
%union{
	struct symtab* symp;
	enum Type type;
	struct rangeDec* range; 
	char* op;
}

%token<symp> NAME
%token<symp> Double Int
%token Float Integer
%token Program Begin Declare As For To DownTo Step EndFor Assign End If Then Else EndIf While EndWhile
%token LT GT EQU LTE GTE
%type<type> Type
%type<symp> Expression
%type<symp> Var NUMBER
%type<range> Range_dec
%type<op> Compare
%type<symp> Start
%left '-' '+'
%left '*' '/'
%nonassoc UMINUS

%%

Goal: Start Begin Stmt_list End {
											printf("\tHalt %s\n",$1->name);
								}
Start: Program NAME{
						printf("\tStart%s\n",$2->name);
						$$ = $2;
					}
Stmt_list: Stmt 
		 | Stmt Stmt_list
		 ;
Stmt: Dec_stmt
	| For_stmt
	| Exp_stmt
	| If_stmt
	| While_stmt
	;
Dec_stmt : Declare Var_list As Type';' {
										for(int i=cnt-1;i>=0;i--){
											char *name = strdup(VTable[i].name);
											int size = VTable[i].size;
											struct symtab* sp = symlook(name);
											if(VTable[i].kind == Array){
												printf("\tDeclare %s,%s_array,%d\n",name,($4 == F)?"Float":"Integer",size);	
											}
											else{
												printf("\tDeclare %s,%s\n",name,($4==F)?"Float":"Integer");
											}
											sp->declare = true;
											sp->type = $4;
											sp->kind = VTable[i].kind;
											sp->size = size;
										}
										cnt = 0;
									   }; 
For_stmt: For '('Range_dec')' Stmt_list EndFor {
											if($3->step == 1){
												printf("\t%s %s\n",(!$3->dec)?"INC":"DEC",$3->iterName);
											}
											else{
												printf("\tI_%s %s,%d,%s\n",(!$3->dec)?"ADD":"SUB",$3->iterName,$3->step,$3->iterName);
											}
											printf("\tI_CMP %s,%s\n",$3->iterName,$3->end);
											printf("\tJ%s lb&%d\n",(!$3->dec)?"LE":"GE",$3->labelInd);
										};


Range_dec: NAME Assign Expression To Expression {	
											printf("Hello 1\n");
											if(!$1->declare){
												yyerror("%s has not been declared.\n",$1->name);
											}
											struct rangeDec* rptr = malloc(sizeof(struct rangeDec));
											printf("\tI_STORE %s,%s\n",$3->name,$1->name);
											printf("lb&%d:\n",labelCur);
											rptr->start = $3->name;
											rptr->end = $5->name;
											rptr->dec = false;
											rptr->step = 1;
											strncpy(rptr->iterName,$1->name,strlen($1->name));	
											rptr->labelInd = labelCur;
											labelCur++;
											$$ = rptr;
										}
		|	NAME Assign Expression DownTo Expression{
												if(!$1->declare){
													yyerror("%s has not been declared.\n",$1->name);
												}
												struct rangeDec* rptr = malloc(sizeof(struct rangeDec));
												printf("\tI_STORE %s,%s\n",$3->name,$1->name);
												printf("lb&%d:\n",labelCur);
												rptr->start = $3->name;
												rptr->end = $5->name;
												rptr->step = 1;
												rptr->dec = true;
												strncpy(rptr->iterName,$1->name,strlen($1->name));	
												rptr->labelInd = labelCur;
												labelCur++;
												$$ = rptr;
											}
		| NAME Assign Expression To Expression Step Int {
															if(!$1->declare){
																yyerror("%s has not been declared.\n",$1->name);
															}
															struct rangeDec* rptr = malloc(sizeof(struct rangeDec));
															printf("\tI_STORE %s,%s\n",$3->name,$1->name);
															printf("lb&%d:\n",labelCur);
															rptr->start = $3->name;
															rptr->end = $5->name;
															rptr->dec = false;
															rptr->step = $7->val;
															strncpy(rptr->iterName,$1->name,strlen($1->name));	
															rptr->labelInd = labelCur;
															labelCur++;
															$$ = rptr;
														}
		| NAME Assign Expression DownTo Expression Step Int {
																if(!$1->declare){
																	yyerror("%s has not been declared.\n",$1->name);
																}
																struct rangeDec* rptr = malloc(sizeof(struct rangeDec));
																printf("\tI_STORE %s,%s\n",$3->name,$1->name);
																printf("lb&%d:\n",labelCur);
																rptr->start = $3->name;
																rptr->end = $5->name;
																rptr->dec = true;
																rptr->step = $7->val;
																strncpy(rptr->iterName,$1->name,strlen($1->name));	
																rptr->labelInd = labelCur;
																labelCur++;
																$$ = rptr;
				
															}

		;
While_stmt: While'('Cmp_expr')' Stmt_list EndWhile	{
														printf("While statement\n");
													}
Exp_stmt: Var Assign Expression';'{
								  printf("\t%s_STORE %s,%s\n",($1->type == F)?"F":"I",$3->name,$1->name);
								  }
		;
Expression: Expression '+' Expression{
										$$ = operation('+',$1,$3);
									 }
		  | Expression '-' Expression{
										$$ = operation('-',$1,$3);
									 }
		  | Expression '*' Expression{
										$$ = operation('*',$1,$3);
									 }
		  | Expression '/' Expression{
										$$ = operation('/',$1,$3);
									 }
		  | '-'Expression %prec UMINUS{
										enum Type type = $2->type;
										int index = findReg();
										char regName[MAXLEN]={};
										char Var1[MAXLEN]={};
										if($2->kind == Array){
											if($2->subVarName == NULL){
												yyerror("Array type variable can\'t do operaion");
												exit(1);
											}
											snprintf(Var1,sizeof(Var1),"%s[%s]",$2->name,$2->subVarName);
										}
										else{
											strncpy(Var1,$2->name,sizeof(Var1));
												
										}
										snprintf(regName,sizeof(regName),"T&%d",index);
										printf("\t%s_UMINUS %s,%s\n",(type==I)?"I":"F",Var1,regName);
										struct symtab* sp = symlook(regName);
										sp->type = type;
										sp->size = $2->size;
										sp->kind = Reg;
										$$ = sp;
									}
		  | '('Expression')' {
								$$ = $2;
							 }
		  | Var     {
					}
		  | NUMBER	{
						$$ = $1;
					}
		  ;
If_stmt:If '(' Cmp_expr ')' Then If_condition Else Else_condition EndIf {
																		}
		;
Cmp_expr: Var Compare Var	{
								printf("\t%s_CMP %s,%s\n",($1->type == I&&$3->type == I)?"I":"F",$1->name,$3->name);
								if($2 == "<"){
									printf("\tJGE ");
								}
								else if($2 == ">"){
									printf("\tJLE ");
								}
								else if($2 == "<="){
									printf("\tJG");
								}
								else if($2 == ">="){
									printf("\tJL");
								}
								else if($2 == "=="){
									printf("\tJNE ");
								}
								else{
									printf("Error\n");
									exit(1);
								}
								printf("lb&%d\n",labelCur);
								elseLabelStack[eTop++] = labelCur;
								labelCur++;
								seqLabelStack[sTop++] = labelCur;
								labelCur++;
							}
		| Var Compare NUMBER	{
								printf("\t%s_CMP %s,",($1->type ==I && $3->type == I)?"I":"F",$1->name);
								if($3->type == I){
									printf("%d\n",(int)$3->val);
								}
								else{
									printf("%f\n",$3->val);
								}
								if($2 == "<"){
									printf("\tJGE ");
								}
								else if($2 == ">"){
									printf("\tJLE ");
								}
								else if($2 == "<="){
									printf("\tJG");
								}
								else if($2 == ">="){
									printf("\tJL");
								}
								else if($2 == "=="){
									printf("\tJNE ");
								}
								else{
									printf("Error\n");
									exit(1);
								}
								printf("lb&%d\n",labelCur);
								elseLabelStack[eTop++] = labelCur;
								labelCur++;
								seqLabelStack[sTop++] = labelCur;
								labelCur++;
							}
		;
If_condition: Stmt_list		{
								
								printf("\tJ lb&%d\n",seqLabelStack[sTop-1]);		
								printf("lb&%d:\n",elseLabelStack[--eTop]);
							}
			;
Else_condition: Stmt_list	{
								printf("lb&%d:\n",seqLabelStack[--sTop]);
							}
			;
Compare: LT		{$$ = "<";}	
	   | GT		{$$ = ">";}
	   | EQU	{$$ = "==";}
	   | LTE	{$$ = "<=";}
	   | GTE	{$$ = ">=";}
	   ;
Var_list: NAME		{	
						struct VEntry ve;
						//strncpy(ve.name,$1->name,MAXLEN);
						ve.name = strdup($1->name);
						ve.kind = Normal;
						VTable[cnt] = ve;
						cnt++;
					}
		| NAME ',' Var_list {
							 struct VEntry ve;
							 //strncpy(ve.name,$1->name,MAXLEN);
							 ve.name = strdup($1->name);
							 ve.kind = Normal;
							 VTable[cnt] = ve;
							 cnt++;	
							}
		| NAME'['Int']'  {
							 struct VEntry ve;
							 //strncpy(ve.name,$1->name,MAXLEN);
							 ve.name = strdup($1->name);
							 ve.kind = Array;
							 ve.size = (int)$3->val;
							 VTable[cnt] = ve;
							 cnt++;	
							}
		| NAME'['Int']' ',' Var_list	{
										struct VEntry ve;
										//strncpy(ve.name,$1->name,MAXLEN);
										ve.name = strdup($1->name);
										ve.kind = Array;
										ve.size = (int)$3->val;
										VTable[cnt] = ve;
										cnt++;	
										}
		;


Type: Float	  {
				$$ = F;
			  }
	| Integer {
				$$ = I;
			  }
	;

Var: NAME			  {
						checkDeclare($1);
						
						if($1->kind == Array){
							yyerror("Array type cannot assign to variable or do other operation");
							exit(1);
						}
					  }
   | NAME'['Int']' {
					  }
   | NAME'['NAME']'	  {
						checkDeclare($1);
						checkDeclare($3);
						if($1->kind!=Array){
							printf("%s is not array type",$1->name);
							yyerror("Syntax error");
							exit(1);
						}
						$$->subVarName = $3->name;
					  }
   ;
NUMBER: Int		{
					$$ = symlook($1->name);
					$$->val = (int)$1->val;
					$$->type = I;
					$$->declare = true;
				}
	  | Double	{
					$$ = symlook($1->name);
					$$->val = $1->val;
					$$->type = F;
					$$->declare = true;
				}
	  ;
%%

struct symtab* symlook(char* name){
	struct symtab* sp;
	for(sp = STable;sp<&STable[MAXLEN];sp++){
		if(sp->name && !(strcmp(sp->name,name))){
			return sp;
		}
		if(!sp->name){
			sp->name = strdup(name);
			return sp;
		}
	}
	yyerror("Too many symbol");
	exit(1);

}
struct symtab* operation(char op,struct symtab* first,struct symtab* second){	
	int index = findReg();
	enum Type type=(first->type==second->type && first->type == I)?I:F;
	char regName[MAXLEN]={};
	snprintf(regName,sizeof(regName),"T&%d",index);
	struct symtab* lhs = symlook(regName);
	lhs->type = type;
	lhs->kind = Reg;
	char Var1[MAXLEN]={};
	char Var2[MAXLEN]={};
	if(first->kind == Array){
		if(first->subVarName==NULL){
			yyerror("Array type variable can\'t do operaion");
			exit(1);
		}
		snprintf(Var1,sizeof(Var1),"%s[%s]",first->name,first->subVarName);
	}
	else{
		strncpy(Var1,first->name,sizeof(Var1));
	}
	if(second->kind == Array){
		if(second->subVarName==NULL){
			yyerror("Array type variable can\'t do operaion");
			exit(1);
		}
		snprintf(Var2,sizeof(Var2),"%s[%s]",second->name,second->subVarName);

	}
	else{
		strncpy(Var2,second->name,sizeof(Var2));
	}
	switch(op){
		case '+':
			printf("\t%s_ADD %s,%s,%s\n",(type==I)?"I":"F",Var1,Var2,lhs->name);
			break;
		case '-':
			printf("\t%s_SUB %s,%s,%s\n",(type==I)?"I":"F",Var1,Var2,lhs->name);
			break;
		case '*':
			printf("\t%s_MUL %s,%s,%s\n",(type==I)?"I":"F",Var1,Var2,lhs->name);
			break;
		case '/':
			printf("\t%s_DIV %s,%s,%s\n",(type==I)?"I":"F",Var1,Var2,lhs->name);
			break;
	}
	if(first->kind==Reg){
		int tempIndex;
		sscanf(first->name,"T&%d",&tempIndex);
		releaseReg(tempIndex);
	}
	if(second->kind==Reg){
		int tempIndex;
		sscanf(second->name,"T&%d",&tempIndex);
		releaseReg(tempIndex);
	}
	return lhs;
}
int findReg(){
	for(int i=0;i<REGNUM;i++){
		if(regUsed[i]==false){
			regUsed[i] = true;
			return i;
		}
	}
	yyerror("There are not available register to use");
	exit(1);
}
void releaseReg(int i){
	regUsed[i] = false;
}

void checkDeclare(struct symtab* first){
	if(!first){
		printf("First para is null\n");
		return;
	}
	if(first->declare == false){
		printf("Variable %s hasn\'t been declared\n",first->name);
		yyerror("syntax error\n");
		exit(1);
	}
}
