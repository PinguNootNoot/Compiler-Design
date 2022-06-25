%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "y.tab.h"

%}

KEY	for|do|while|break|continue|switch|case|default|struct|if|else|return|int|char|float|double|void|const|unsigned|signed|long|short

MARCO	NULL|__COUNTER__|INT_MAX|INT_MIN|CHAR_MAX|CHAR_MIN

OPTOR	"+"|"-"|"++"|"--"|"*"|"/"|"%"|"^"|"&"|"|"|"&&"|"||"|"!"|">"|"<"|">="|"<="|"="|"=="|"!="|">>"|"<<"

PUNC	";"|","|":"|"("|")"|"["|"]"|"{"|"}"

ID	[a-zA-Z_][a-zA-Z0-9_]*

NUM	[0-9]+

DOUBLE	[0-9]+[.][0-9]+

CHAR	[']("\n"|"\t"|"\b"|"\a"|"\f")[']|[']([']|["]|"\")[']|[']([^'"\\]|[ ])[']

STR	["][^"]*["]

space	[ ]+

tab	\t

newline	\n

%x COMMENT_SINGLE
%x COMMENT_MULTI

%%

{KEY} {

  if(strcmp(yytext, "for") == 0) return FOR;
  else if(strcmp(yytext, "do") == 0) return DO;
  else if(strcmp(yytext, "while") == 0) return WHILE;
  else if(strcmp(yytext, "break") == 0) return BREAK;
  else if(strcmp(yytext, "continue") == 0) return CONTINUE;
  else if(strcmp(yytext, "switch") == 0) return SWITCH;
  else if(strcmp(yytext, "case") == 0) return CASE;
  else if(strcmp(yytext, "default") == 0) return DEFAULT;
  else if(strcmp(yytext, "struct") == 0) return STRUCT;
  else if(strcmp(yytext, "if") == 0) return IF;
  else if(strcmp(yytext, "else") == 0) return ELSE;
  else if(strcmp(yytext, "return") == 0) return RETURN;
  else if(strcmp(yytext, "int") == 0) return INT;
  else if(strcmp(yytext, "char") == 0) return CHAR;
  else if(strcmp(yytext, "float") == 0) return FLOAT;
  else if(strcmp(yytext, "double") == 0) return DOUBLE;
  else if(strcmp(yytext, "void") == 0) return VOID;
  else if(strcmp(yytext, "const") == 0) return CONST;
  else if(strcmp(yytext, "unsigned") == 0) return UNSIGNED;
  else if(strcmp(yytext, "signed") == 0) return SIGNED;
  else if(strcmp(yytext, "long") == 0) return LONG;
  else if(strcmp(yytext, "short") == 0) return SHORT;

}

{MARCO} {

  if(strcmp(yytext, "NULL") == 0) return ZERO;
  else if(strcmp(yytext, "INT_MAX") == 0) return INTEGER_MAX;
  else if(strcmp(yytext, "INT_MIN") == 0) return INTEGER_MIN;

}

{OPTOR} {

  if(strlen(yytext) == 1) return *yytext;
  else if(strcmp(yytext, "==") == 0) return EQUAL;
  else if(strcmp(yytext, "!=") == 0) return NEQUAL;
  else if(strcmp(yytext, ">=") == 0) return GEQUAL;
  else if(strcmp(yytext, "<=") == 0) return SEQUAL;
  else if(strcmp(yytext, "++") == 0) return PLUSONE;
  else if(strcmp(yytext, "--") == 0) return MINUSONE;
  else if(strcmp(yytext, "&&") == 0) return CONDI_AND;
  else if(strcmp(yytext, "||") == 0) return CONDI_OR;
  else if(strcmp(yytext, ">>") == 0) return SHIFT_RIGHT;
  else if(strcmp(yytext, "<<") == 0) return SHIFT_LEFT;

}

{PUNC} { return *yytext; }

{STR} { yylval.strVal = strdup(yytext); return STRING; }

{ID} { yylval.strVal = strdup(yytext); return ID; }

{NUM} { yylval.strVal = strdup(yytext); return NUM; }

{DOUBLE} { yylval.strVal = strdup(yytext); return DOUB; }

{CHAR} { yylval.strVal = strdup(yytext); return CH; }


"//" { BEGIN COMMENT_SINGLE; }

<COMMENT_SINGLE>. { }

<COMMENT_SINGLE>\n { BEGIN 0; }

"/*" { BEGIN COMMENT_MULTI; }

<COMMENT_MULTI>. { }

<COMMENT_MULTI>\n { }

<COMMENT_MULTI>"*/" { BEGIN 0; }

{space} { }

{tab} { }

{newline} { }

%%

/*
int main(){
  yylex();
  return 0;
}
*/

