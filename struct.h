/*************************************************************************
	> File Name: struct.h
	> Author: kuanshn
	> Mail: [email protected] 
	> Created Time: Fri May 27 10:41:14 2022
 ************************************************************************/
#define MAXLEN 256
#define REGNUM 32
#include<stdbool.h>
enum Type{
	F,
	I
};
enum Kind{
	Normal,
	Reg,
	Func,
	Array
};
struct symtab{
	char* name;
	enum Type type;
	enum Kind kind;
	double val;
	int size;
	bool declare;
	char* subVarName;
};

struct VEntry{
	char* name;
	enum Type type;
	enum Kind kind;
	int size;
};
struct rangeDec{
	char* start;
	char* end;
	bool dec;	//increment or decrement
	char iterName[MAXLEN];
	int labelInd;
	int step;
};
struct ifStmt{
	int elseLabel;
	int seqLabel;
};
struct symtab* symlook(char* s);
int findReg();
void releaseReg(int i);
void checkDeclare(struct symtab* first);
struct symtab* operation(char op,struct symtab* first,struct symtab* second);
