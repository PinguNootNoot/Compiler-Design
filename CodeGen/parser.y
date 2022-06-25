%{

#include <stdio.h>
#include <stdlib.h>
#include "symbol_table.h"
#define BUF_SIZE 100

int argu_num = 0;
char* buffer[BUF_SIZE];

%}

%union{
  int intVal;
  double dVal;
  char *strVal;
}

%type<strVal> SCALAR_DEC ARRAY_DEC FUNC_DEC FUNC_DEF idents ident id SIGN_EXPR CONST_EXPR ARRAY_EXPR TYPE ARRAYS ARRAY ARRAY_CONT FUNC_PARA FUNC_ARGU STMT IF_ELSE_STMT SWITCH_CASES SWITCH_CASE SWITCH_STMT FOR_STMT COMP_STMT COMP_STMT_PLUM
%type<intVal> EXPR

%token FOR WHILE DO CONTINUE BREAK IF SWITCH CASE RETURN DEFAULT ZERO STRUCT CONST INT FLOAT DOUBLE CHAR VOID LONG SHORT SIGNED UNSIGNED INTEGER_MAX INTEGER_MIN HIGH LOW
%token<strVal> ID NUM STRING DOUB CH

%nonassoc IFF
%nonassoc ELSE
%right '='
%left CONDI_OR
%left CONDI_AND
%left '|'
%left '&'
%left EQUAL NEQUAL
%left '>' '<' GEQUAL SEQUAL
%left SHIFT_LEFT SHIFT_RIGHT
%left '+' '-'
%left '*' '/' '%'
%right '^'
%right '!' PLUSONE MINUSONE UNIPLUS UNIMINUS TYPE_TRANS DEREFER ADDR_REFER
%left '(' RIGHT_PLUSONE RIGHT_MINUSONE

%%

/* NULL is ZERO */

GLOBAL_DEC : GLOBAL_DEC SCALAR_DEC {}
	   | GLOBAL_DEC ARRAY_DEC {}
	   | GLOBAL_DEC FUNC_DEC {}
	   | GLOBAL_DEC FUNC_DEF {}
	   | {}
	   ;


CONST_EXPR : CONST {}
	   | {}
	   ;


SIGN_EXPR : SIGNED {}
	  | UNSIGNED {}
	  | {}
	  ;


TYPE : CONST_EXPR SIGN_EXPR LONG LONG INT {}
     | CONST_EXPR SIGN_EXPR LONG INT {}
     | CONST_EXPR SIGN_EXPR INT {}
     | CONST_EXPR SIGN_EXPR SHORT INT {}
     | CONST_EXPR SIGN_EXPR CHAR {}
     | CONST_EXPR FLOAT {}
     | CONST_EXPR DOUBLE {}
     | CONST_EXPR VOID {}
     | CONST_EXPR SIGN_EXPR LONG LONG {}
     | CONST_EXPR SIGN_EXPR LONG {}
     | CONST_EXPR SIGN_EXPR SHORT {}
     | CONST_EXPR UNSIGNED {}
     | CONST_EXPR SIGNED {}
     | CONST {}
     ;


FUNC_DEC : TYPE id '(' FUNC_PARA ')' ';' {}
	 | TYPE id '(' ')' ';' {}
	 ;


FUNC_DEF : TYPE id '(' FUNC_PARA ')' 
	 {
	   ++cur_scope;
	   set_scope_and_offset_of_param($2);
	   code_gen_func_header($2);
	 } COMP_STMT {
	   pop_up_symbol(cur_scope);
	   --cur_scope;
	   code_gen_at_end_of_function_body($2);
	 }
	 | TYPE id '(' ')' 
	 {
	   ++cur_scope;
           set_scope_and_offset_of_param($2);
           code_gen_func_header($2);
	 } COMP_STMT {
	   pop_up_symbol(cur_scope);
           --cur_scope;
           code_gen_at_end_of_function_body($2);
	 }
	 ;


FUNC_PARA : FUNC_PARA ',' TYPE id {}
	  | TYPE id {}
	  ;


SCALAR_DEC : TYPE idents ';' {}
           ;


idents : idents ',' ident {}
       | ident {}
       ;


ident : id '=' EXPR
      {
	add_local_var(); // Set up the parameters of the local variable
	if($3 > 0){
	  // Already exists in the stack
	  printf("\tld t0, 0(sp)\n");
	  for(int r = 0; r < $3; ++r) printf("\tld t0, 0(t0)\n");
	  printf("\tsd t0, 0(sp)\n");
	} else if($3 < 0){
	  // Need to store into the stack
	  printf("\tld t0, %d(s0)\n\taddi sp, sp, -8\n", $3);
	  printf("\tsd t0, 0(sp)\n");
	}
      }
      | id 
      {
	/* Allocate space for upcoming identifier */
	add_local_var();
	printf("\taddi sp, sp, -8\n");
      }
      ;


id : ID 
   {
	// Insert new symbol into symbol table
	install_symbol($1);
	$$ = $1;
   }
   | '*' ID 
   {
	install_symbol($2);
	$$ = $2;
   }
   ;


ARRAY_DEC : TYPE ARRAYS ';' {}
	  ;


ARRAYS : ARRAYS ',' ARRAY '=' '{' ARRAY_CONT '}' {}
       | ARRAYS ',' ARRAY {}
       | ARRAY '=' '{' ARRAY_CONT '}' {}
       | ARRAY {}
       ;


ARRAY : ARRAY '[' EXPR ']' {}
      | id '[' EXPR ']' {}
      ;


ARRAY_CONT : ARRAY_CONT ',' '{' ARRAY_CONT '}' {}
	   | ARRAY_CONT ',' EXPR {}
	   | '{' ARRAY_CONT '}' {}
	   | EXPR {}
	   ;


EXPR : EXPR '+' EXPR
     {
	get_two_expr($1,$3); // get_two_expr() loads $1(1st parameter) into t1 and $3(2nd) in t0, respectively
	printf("\taddi sp, sp, -8\n\tadd t0, t0, t1\n\tsd t0, 0(sp)\n");
	$$ = 0;
     }
     | EXPR '-' EXPR 
     {
	get_two_expr($1,$3);
	printf("\taddi sp, sp, -8\n\tsub t0, t1, t0\n\tsd t0, 0(sp)\n");
	$$ = 0;
     }
     | EXPR '*' EXPR 
     {
	get_two_expr($1,$3);
	printf("\taddi sp, sp, -8\n\tmul t0, t0, t1\n\tsd t0, 0(sp)\n");
	$$ = 0;
     }
     | EXPR '/' EXPR 
     {
	get_two_expr($1,$3);
	printf("\taddi sp, sp, -8\n\tdiv t0, t1, t0\n\tsd t0, 0(sp)\n");
	$$ = 0;
     }
     | EXPR '%' EXPR {}
     | EXPR '^' EXPR {}
     | PLUSONE EXPR {}
     | MINUSONE EXPR {}
     | EXPR PLUSONE %prec RIGHT_PLUSONE {}
     | EXPR MINUSONE %prec RIGHT_MINUSONE {}
     | EXPR '=' EXPR
     {
	if($3 >= 0){
	  printf("\tld t0, 0(sp)\n");
	  for(int r = 0; r < $3; ++r) printf("\tld t0, 0(t0)\n");
	  printf("\taddi sp, sp, 8\n");
	} else {
	  printf("\tld t0, %d(s0)\n", $3);
	}

	if($1 > 0){
	  printf("\tld t1, 0(sp)\n"); // save the data stored at 0(sp) to t1 in case of being overwritten
	  for(int r = 1; r < $1; ++r) printf("\tld t1, 0(t1)\n");
	  printf("\taddi sp, sp, 8\n\tsd t0, 0(t1)\n"); // $1 = $3 for potentially upcoming use
	}
	else if($1 < 0){
	  printf("\tsd t0, %d(s0)\n", $1);
	}
	printf("\taddi sp, sp, -8\n\tsd t0, 0(sp)\n"); // save $1's new value to the stack for future use
	$$ = 0;
     }
     | EXPR '>' EXPR {}
     | EXPR '<' EXPR {}
     | EXPR EQUAL EXPR {}
     | EXPR NEQUAL EXPR {}
     | EXPR GEQUAL EXPR {}
     | EXPR SEQUAL EXPR {}
     | EXPR '&' EXPR {}
     | EXPR '|' EXPR {}
     | EXPR CONDI_AND EXPR {}
     | EXPR CONDI_OR EXPR {}
     | EXPR SHIFT_LEFT EXPR {}
     | EXPR SHIFT_RIGHT EXPR {}
     | '(' EXPR ')' { $$ = $2; }
     | '!' EXPR {}
     | '+' EXPR %prec UNIPLUS {}
     | '-' EXPR %prec UNIMINUS 
     {
	if($2 >= 0){
	  printf("\tld t0, 0(sp)\n");
	  for(int r = 0; r < $2; ++r) printf("\tld t0, 0(t0)\n"); // Consumes $2
	} else {
	  printf("\tld t0, %d(s0)\n\taddi sp, sp, -8\n", $2);
	}
	printf("\tsub t0, zero, t0\n\tsd t0, 0(sp)\n");
	$$ = 0;
     }
     | '*' EXPR %prec DEREFER 
     {
	// Handling variable pointer dereference
	if($2 < 0){
	  printf("\taddi sp, sp, -8\n\tld t0, %d(s0)\n\tsd t0, 0(sp)\n", $2); // address offset stored in EXPR
	}
	$$ = ($2 < 0) ? 1 : $2 + 1;
     }
     | '&' EXPR %prec ADDR_REFER 
     {
	// Handling variable address reference
	// use the offset we calculated in ID
	printf("\taddi sp, sp, -8\n\taddi t0, s0, %d\n\tsd t0, 0(sp)\n", $2);
	$$ = 0;
     }
     | '(' TYPE ')' EXPR %prec TYPE_TRANS {}
     | '(' TYPE '*' ')' EXPR %prec TYPE_TRANS {}
     | ARRAY_EXPR {}
     | STRING {}
     | ID '(' FUNC_ARGU ')' 
     {
	// Handling function call
	printf("\taddi sp, sp, -8\n\tsd ra, 0(sp)\n\tjal ra, %s\n", $1); // get ready to jump
	printf("\tld ra, 0(sp)\n\tsd a0, 0(sp)\n"); // return from subroutine
	$$ = 0;
     }
     | ID '(' ')' 
     {
	// same here
	printf("\taddi sp, sp, -8\n\tsd ra, 0(sp)\n\tjal ra, %s\n", $1);
	printf("\tld ra, 0(sp)\n\tsd a0, 0(sp)\n");
	$$ = 0;
     }
     | ID 
     {
	int functor_idx;
	int index = look_up_symbol($1); // find $1 in symbol table

	switch(S_Table[index].mode){
	  case ARGUMENT_MODE: // ID is an function argument
	    $$ = -104 - S_Table[index].offset * 8; // Compute the offset for stack pointer
	    break;

	  case LOCAL_MODE:
	    functor_idx = S_Table[index].functor_index;
	    $$ = -104 - (S_Table[functor_idx].total_args + S_Table[index].offset) * 8; // same here
	    break;
	}
     }
     | CH {}
     | NUM 
     {
	printf("\taddi sp, sp, -8\n\taddi t0, zero, %s\n\tsd t0, 0(sp)\n", $1); $$ = 0;
     }
     | DOUB {}
     | ZERO {}
     | HIGH
     {
	printf("\taddi sp, sp, -8\n\taddi t0, zero, 1\n\tsd t0, 0(sp)\n"); $$ = 0;
     }
     | LOW 
     {
	printf("\taddi sp, sp, -8\n\tadd t0, zero, zero\n\tsd t0, 0(sp)\n"); $$ = 0;
     }
     ;


FUNC_ARGU : FUNC_ARGU ',' EXPR
	  {
	    if($3 >= 0){
		printf("\tld t0, 0(sp)\n");
		for(int r = 0; r < $3; ++r) printf("\tld t0, 0(t0)\n"); // for-loop makes sure the number($3) reduces to 0 while ensuring the correctness of generated assembly code
		printf("\tadd a%d, t0, zero\n\taddi sp, sp, 8\n", argu_num);
	    }
	    else printf("\tld a%d, %d(sp)\n", argu_num, $3);
	    ++argu_num;
	  }
	  | EXPR 
	  {
	    if($1 >= 0){
		printf("\tld t0, 0(sp)\n");
		for(int r = 0; r < $1; ++r) printf("\tld t0, 0(t0)\n"); // same here
		printf("\tadd a0, t0, zero\n\taddi sp, sp, 8\n");
	    }
	    else printf("\tld a0, %d(sp)\n", $1);
	    argu_num = 1;
	  }
	  ;


ARRAY_EXPR : ARRAY_EXPR '[' EXPR ']' {}
	   | ID '[' EXPR ']' {}
	   ;


STMT : EXPR ';'
     {
	if($1 >= 0) printf("\taddi sp, sp, 8\n");
	else printf("\n");
     }
     | IF_ELSE_STMT {}
     | SWITCH '(' EXPR ')' '{' SWITCH_CASES '}' {}
     | SWITCH '(' EXPR ')' '{' '}' {}
     | WHILE '(' EXPR ')' STMT {}
     | DO STMT WHILE '(' EXPR ')' ';' {}
     | FOR '(' FOR_STMT ';' FOR_STMT ';' FOR_STMT ')' STMT {}
     | RETURN EXPR ';' {}
     | RETURN ';' {}
     | BREAK ';' {}
     | CONTINUE ';' {}
     | COMP_STMT {}
     ;


IF_ELSE_STMT : IF '(' EXPR ')' COMP_STMT %prec IFF {}
	     | IF '(' EXPR ')' COMP_STMT ELSE COMP_STMT {}
	     ;


SWITCH_CASES : SWITCH_CASES SWITCH_CASE {}
	     | SWITCH_CASE {}
	     ;


SWITCH_CASE : CASE EXPR ':' SWITCH_STMT {}
	    | CASE EXPR ':' {}
	    | DEFAULT ':' SWITCH_STMT {}
	    | DEFAULT ':' {}
	    ;


SWITCH_STMT : SWITCH_STMT STMT {}
	    | STMT {}
	    ;


FOR_STMT : EXPR {}
	 | {}
	 ;


COMP_STMT : '{' COMP_STMT_PLUM '}' {}
	  | '{' '}' {}
	  ;


COMP_STMT_PLUM : COMP_STMT_PLUM STMT { printf("\n"); }
	       | COMP_STMT_PLUM SCALAR_DEC { printf("\n"); }
	       | COMP_STMT_PLUM ARRAY_DEC { printf("\n"); }
	       | STMT { printf("\n"); }
               | SCALAR_DEC { printf("\n"); }
               | ARRAY_DEC { printf("\n"); }
	       ;

%%

int yylex();

int main(){
  init_symbol_table();
  yyparse();
  return 0;
}

int yyerror(char *msg){
  fprintf(stderr, "%s\n", msg);
  return 0;
}

