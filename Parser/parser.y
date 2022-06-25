%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

%}

%union{
  int intVal;
  double dVal;
  char *strVal;
}

%type<strVal> SCALAR_DEC ARRAY_DEC FUNC_DEC FUNC_DEF idents ident id EXPR SIGN_EXPR CONST_EXPR ARRAY_EXPR TYPE ARRAYS ARRAY ARRAY_CONT FUNC_PARA FUNC_ARGU STMT IF_ELSE_STMT SWITCH_CASES SWITCH_CASE SWITCH_STMT FOR_STMT COMP_STMT COMP_STMT_PLUM

%token FOR WHILE DO CONTINUE BREAK IF SWITCH CASE RETURN DEFAULT ZERO STRUCT CONST INT FLOAT DOUBLE CHAR VOID LONG SHORT SIGNED UNSIGNED INTEGER_MAX INTEGER_MIN
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

GLOBAL_DEC : GLOBAL_DEC SCALAR_DEC { }
	   | GLOBAL_DEC ARRAY_DEC { }
	   | GLOBAL_DEC FUNC_DEC { }
	   | GLOBAL_DEC FUNC_DEF { }
	   |
	   ;


CONST_EXPR : CONST { }
	   | { }
	   ;


SIGN_EXPR : SIGNED { }
	  | UNSIGNED { }
	  | { }
	  ;


TYPE : CONST_EXPR SIGN_EXPR LONG LONG INT
     {
     	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($2)));
     	sprintf($$, "%s%slonglongint", $1, $2); free($1); free($2);
     }
     | CONST_EXPR SIGN_EXPR LONG INT
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($2)));
	sprintf($$, "%s%slongint", $1, $2); free($1); free($2);
     }
     | CONST_EXPR SIGN_EXPR INT
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($2)));
	sprintf($$, "%s%sint", $1, $2); free($1); free($2);
     }
     | CONST_EXPR SIGN_EXPR SHORT INT
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($2)));
	sprintf($$, "%s%sshortint", $1, $2); free($1); free($2);
     }
     | CONST_EXPR SIGN_EXPR CHAR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($2)));
	sprintf($$, "%s%schar", $1, $2); free($1); free($2);
     }
     | CONST_EXPR FLOAT
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1)));
	sprintf($$, "%sfloat", $1); free($1);
     }
     | CONST_EXPR DOUBLE
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1)));
	sprintf($$, "%sdouble", $1); free($1);
     }
     | CONST_EXPR VOID
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1)));
	sprintf($$, "%svoid", $1); free($1);
     }
     | CONST_EXPR SIGN_EXPR LONG LONG
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($2)));
	sprintf($$, "%s%slonglong", $1, $2); free($1); free($2);
     }
     | CONST_EXPR SIGN_EXPR LONG
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($2)));
	sprintf($$, "%s%slong", $1, $2); free($2);
     }
     | CONST_EXPR SIGN_EXPR SHORT
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($2)));
	sprintf($$, "%s%sshort", $1, $2); free($1); free($2);
     }
     | CONST_EXPR UNSIGNED
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1)));
	sprintf($$, "%sunsigned", $1); free($1);
     }
     | CONST_EXPR SIGNED
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1)));
	sprintf($$, "%ssigned", $1); free($1);
     }
     | CONST { $$ = malloc(sizeof(char) * (30)); sprintf($$, "const"); }
     ;


FUNC_DEC : TYPE id '(' FUNC_PARA ')' ';'
	 {
             $$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($2) + strlen($4)));
	     sprintf($$, "<func_decl>%s%s(%s);</func_decl>", $1, $2, $4); free($1); free($2); free($4);
	 }
	 | TYPE id '(' ')' ';'
	 {
	     $$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($2)));
	     sprintf($$, "<func_decl>%s%s();</func_decl>", $1, $2); free($1); free($2);
	 }
	 ;


FUNC_DEF : TYPE id '(' FUNC_PARA ')' COMP_STMT
	 {
	     $$ = malloc(sizeof(char) * (50 + strlen($1) + strlen($2) + strlen($4) + strlen($6)));
	     sprintf($$, "<func_def>%s%s(%s)%s</func_def>", $1, $2, $4, $6); free($1); free($2); free($4); free($6);
	 }
	 | TYPE id '(' ')' COMP_STMT
	 {
	     $$ = malloc(sizeof(char) * (50 + strlen($1) + strlen($2) + strlen($5)));
	     sprintf($$, "<func_def>%s%s()%s</func_def>", $1, $2, $5); free($1); free($2); free($5);
	 }
	 ;


FUNC_PARA : FUNC_PARA ',' TYPE id
	  {
	      $$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3) + strlen($4)));
	      sprintf($$, "%s,%s%s", $1, $3, $4); free($1); free($3); free($4);
	  }
	  | TYPE id
	  {
	      $$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($2)));
	      sprintf($$, "%s%s", $1, $2); free($1); free($2);
	  }
	  ;


SCALAR_DEC : TYPE idents ';'
	   {
	       $$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($2)));
	       sprintf($$, "<scalar_decl>%s%s;</scalar_decl>", $1, $2); free($1); free($2);
	   }
           ;


idents : idents ',' ident
       {
	 $$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	 sprintf($$, "%s,%s", $1, $3); free($1); free($3);
       }
       | ident { $$ = malloc(sizeof(char) * (30 + strlen($1))); sprintf($$, "%s", $1);  free($1); }
       ;


ident : id '=' EXPR
      {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	sprintf($$, "%s=%s", $1, $3); free($1); free($3);
      }
      | id { $$ = malloc(sizeof(char) * (30 + strlen($1))); sprintf($$, "%s", $1); free($1); }
      ;


id : ID { $$ = malloc(sizeof(char) * (30 + strlen($1))); sprintf($$, "%s", $1); free($1); }
   | '*' ID { $$ = malloc(sizeof(char) * (30 + strlen($2))); sprintf($$, "*%s", $2); free($2); }
   ;


ARRAY_DEC : TYPE ARRAYS ';'
	  {
	      $$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($2)));
	      sprintf($$, "<array_decl>%s%s;</array_decl>", $1, $2); free($1); free($2);
	  }
	  ;


ARRAYS : ARRAYS ',' ARRAY '=' '{' ARRAY_CONT '}'
       {
	   $$ = malloc(sizeof(char) * (50 + strlen($1) + strlen($3) + strlen($6)));
	   sprintf($$, "%s,%s={%s}", $1, $3, $6); free($1); free($3); free($6);
       }
       | ARRAYS ',' ARRAY
       {
	   $$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	   sprintf($$, "%s,%s", $1, $3); free($1); free($3);
       }
       | ARRAY '=' '{' ARRAY_CONT '}'
       {
	   $$ = malloc(sizeof(char) * (50 + strlen($1) + strlen($4)));
	   sprintf($$, "%s={%s}", $1, $4); free($1); free($4);
       }
       | ARRAY { $$ = malloc(sizeof(char) * (30 + strlen($1))); sprintf($$, "%s", $1); free($1); }
       ;


ARRAY : ARRAY '[' EXPR ']'
      {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	sprintf($$, "%s[%s]", $1, $3); free($1); free($3);
      }
      | id '[' EXPR ']'
      {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	sprintf($$, "%s[%s]", $1, $3); free($1); free($3);
      }
      ;


ARRAY_CONT : ARRAY_CONT ',' '{' ARRAY_CONT '}'
	   {
		$$ = malloc(sizeof(char) * (50 + strlen($1) + strlen($4)));
		sprintf($$, "%s,{%s}", $1, $4); free($1); free($4);
	   }
	   | ARRAY_CONT ',' EXPR
	   {
		$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
		sprintf($$, "%s,%s", $1, $3); free($1); free($3);
	   }
	   | '{' ARRAY_CONT '}'
	   {
		$$ = malloc(sizeof(char) * (30 + strlen($2)));
		sprintf($$, "{%s}", $2); free($2);
	   }
	   | EXPR { $$ = malloc(sizeof(char) * (30 + strlen($1))); sprintf($$, "%s", $1); free($1); }
	   ;


EXPR : EXPR '+' EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	sprintf($$, "<expr>%s+%s</expr>", $1, $3); free($1); free($3);
     }
     | EXPR '-' EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	sprintf($$, "<expr>%s-%s</expr>", $1, $3); free($1); free($3);
     }
     | EXPR '*' EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	sprintf($$, "<expr>%s*%s</expr>", $1, $3); free($1); free($3);
     }
     | EXPR '/' EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3))); if($3 == 0) yyerror("Divisor cannot be 0"); else { sprintf($$, "<expr>%s/%s</expr>", $1, $3); free($1); free($3); }
	 }
     | EXPR '%' EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3))); if($3 == 0) yyerror("Divisor cannot be 0"); else { sprintf($$, "<expr>%s%c%s</expr>", $1, 37, $3); free($1); free($3); }
	 }
     | EXPR '^' EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	sprintf($$, "<expr>%s^%s</expr>", $1, $3); free($1); free($3);
     }
     | PLUSONE EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($2)));
	sprintf($$, "<expr>++%s</expr>", $2); free($2);
     }
     | MINUSONE EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($2)));
	sprintf($$, "<expr>--%s</expr>", $2); free($2);
     }
     | EXPR PLUSONE %prec RIGHT_PLUSONE
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1)));
	sprintf($$, "<expr>%s++</expr>", $1); free($1);
     }
     | EXPR MINUSONE %prec RIGHT_MINUSONE
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1)));
	sprintf($$, "<expr>%s--</expr>", $1); free($1);
     }
     | EXPR '=' EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	sprintf($$, "<expr>%s=%s</expr>", $1, $3); free($1); free($3);
     }
     | EXPR '>' EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	sprintf($$, "<expr>%s>%s</expr>", $1, $3); free($1); free($3);
     }
     | EXPR '<' EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	sprintf($$, "<expr>%s<%s</expr>", $1, $3); free($1); free($3);
     }
     | EXPR EQUAL EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	sprintf($$, "<expr>%s==%s</expr>", $1, $3); free($1); free($3);
     }
     | EXPR NEQUAL EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	sprintf($$, "<expr>%s!=%s</expr>", $1, $3); free($1); free($3);
     }
     | EXPR GEQUAL EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	sprintf($$, "<expr>%s>=%s</expr>", $1, $3); free($1); free($3);
     }
     | EXPR SEQUAL EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	sprintf($$, "<expr>%s<=%s</expr>", $1, $3); free($1); free($3);
     }
     | EXPR '&' EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	sprintf($$, "<expr>%s&%s</expr>", $1, $3); free($1); free($3);
     }
     | EXPR '|' EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	sprintf($$, "<expr>%s|%s</expr>", $1, $3); free($1); free($3);
     }
     | EXPR CONDI_AND EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	sprintf($$, "<expr>%s&&%s</expr>", $1, $3); free($1); free($3);
     }
     | EXPR CONDI_OR EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	sprintf($$, "<expr>%s||%s</expr>", $1, $3); free($1); free($3);
     }
     | EXPR SHIFT_LEFT EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	sprintf($$, "<expr>%s<<%s</expr>", $1, $3); free($1); free($3);
     }
     | EXPR SHIFT_RIGHT EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	sprintf($$, "<expr>%s>>%s</expr>", $1, $3); free($1); free($3);
     }
     | EXPR '(' FUNC_ARGU ')'
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	sprintf($$, "<expr>%s(%s)</expr>", $1, $3); free($1); free($3);
     }
     | EXPR '(' ')'
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1)));
	sprintf($$, "<expr>%s()</expr>", $1); free($1);
     }
     | '(' EXPR ')'
     {
	$$ = malloc(sizeof(char) * (30 + strlen($2)));
	sprintf($$, "<expr>(%s)</expr>", $2); free($2);
     }
     | '!' EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($2)));
	sprintf($$, "<expr>!%s</expr>", $2); free($2);
     }
     | '+' EXPR %prec UNIPLUS
     {
	$$ = malloc(sizeof(char) * (30 + strlen($2)));
	sprintf($$, "<expr>+%s</expr>", $2); free($2);
     }
     | '-' EXPR %prec UNIMINUS
     {
	$$ = malloc(sizeof(char) * (30 + strlen($2)));
	sprintf($$, "<expr>-%s</expr>", $2); free($2);
     }
     | '*' EXPR %prec DEREFER
     {
	$$ = malloc(sizeof(char) * (30 + strlen($2)));
	sprintf($$, "<expr>*%s</expr>", $2); free($2);
     }
     | '&' EXPR %prec ADDR_REFER
     {
	$$ = malloc(sizeof(char) * (30 + strlen($2)));
	sprintf($$, "<expr>&%s</expr>", $2); free($2);
     }
     | '(' TYPE ')' EXPR %prec TYPE_TRANS
     {
	$$ = malloc(sizeof(char) * (50 + strlen($2) + strlen($4)));
	sprintf($$, "<expr>(%s)%s</expr>", $2, $4); free($2); free($4);
     }
     | '(' TYPE '*' ')' EXPR %prec TYPE_TRANS
     {
	$$ = malloc(sizeof(char) * (50 + strlen($2) + strlen($5)));
	sprintf($$, "<expr>(%s*)%s</expr>", $2, $5); free($2); free($5);
     }
     | ARRAY_EXPR
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1)));
	sprintf($$, "<expr>%s</expr>", $1); free($1);
     }
     | STRING
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1)));
	sprintf($$, "<expr>%s</expr>", $1);
     }
     | ID
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1)));
	sprintf($$, "<expr>%s</expr>", $1);
     }
     | CH
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1)));
	sprintf($$, "<expr>%s</expr>", $1);
     }
     | NUM
     {
	$$ = malloc(sizeof(char) * (50 + strlen($1)));
	sprintf($$, "<expr>%d</expr>", atoi($1));
     }
     | DOUB
     {
	$$ = malloc(sizeof(char) * (50 + strlen($1)));
	sprintf($$, "<expr>%f</expr>", atof($1));
     }
     | ZERO
     {
	$$ = malloc(sizeof(char) * (30));
	sprintf($$, "<expr>NULL</expr>");
     }
     ;


FUNC_ARGU : FUNC_ARGU ',' EXPR
	  {
	      $$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
	      sprintf($$, "%s,%s", $1, $3); free($1); free($3);
	  }
	  | EXPR { $$ = malloc(sizeof(char) * (30 + strlen($1))); sprintf($$, "%s", $1); free($1); }
	  ;


ARRAY_EXPR : ARRAY_EXPR '[' EXPR ']'
	   {
		$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
		sprintf($$, "%s[%s]", $1, $3); free($1); free($3);
	   }
	   | ID '[' EXPR ']'
	   {
		$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($3)));
		sprintf($$, "%s[%s]", $1, $3); free($1); free($3);
	   }
	   ;


STMT : EXPR ';'
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1)));
	sprintf($$, "<stmt>%s;</stmt>", $1); free($1);
     }
     | IF_ELSE_STMT
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1)));
	sprintf($$, "<stmt>%s</stmt>", $1); free($1);
     }
     | SWITCH '(' EXPR ')' '{' SWITCH_CASES '}'
     {
	$$ = malloc(sizeof(char) * (50 + strlen($3) + strlen($6)));
	sprintf($$, "<stmt>switch(%s){%s}</stmt>", $3, $6); free($3); free($6);
     }
     | SWITCH '(' EXPR ')' '{' '}'
     {
	$$ = malloc(sizeof(char) * (50 + strlen($3)));
	sprintf($$, "<stmt>switch(%s){}</stmt>", $3); free($3);
     }
     | WHILE '(' EXPR ')' STMT
     {
	$$ = malloc(sizeof(char) * (50 + strlen($3) + strlen($5)));
	sprintf($$, "<stmt>while(%s)%s</stmt>", $3, $5); free($3); free($5);
     }
     | DO STMT WHILE '(' EXPR ')' ';'
     {
	$$ = malloc(sizeof(char) * (50 + strlen($2) + strlen($5)));
	sprintf($$, "<stmt>do%swhile(%s);</stmt>", $2, $5); free($2); free($5);
     }
     | FOR '(' FOR_STMT ';' FOR_STMT ';' FOR_STMT ')' STMT
     {
	$$ = malloc(sizeof(char) * (50 + strlen($3) + strlen($5) + strlen($7) + strlen($9)));
	sprintf($$, "<stmt>for(%s;%s;%s)%s</stmt>", $3, $5, $7, $9); free($3); free($5); free($7); free($9);
     }
     | RETURN EXPR ';'
     {
	$$ = malloc(sizeof(char) * (30 + strlen($2)));
	sprintf($$, "<stmt>return%s;</stmt>", $2); free($2);
     }
     | RETURN ';'
     {
	$$ = malloc(sizeof(char) * (30));
	sprintf($$, "<stmt>return;</stmt>");
     }
     | BREAK ';'
     {
	$$ = malloc(sizeof(char) * (30));
	sprintf($$, "<stmt>break;</stmt>");
     }
     | CONTINUE ';'
     {
	$$ = malloc(sizeof(char) * (30));
	sprintf($$, "<stmt>continue;</stmt>");
     }
     | COMP_STMT
     {
	$$ = malloc(sizeof(char) * (30 + strlen($1)));
	sprintf($$, "<stmt>%s</stmt>", $1); free($1);
     }
     ;


IF_ELSE_STMT : IF '(' EXPR ')' COMP_STMT %prec IFF
	     {
		$$ = malloc(sizeof(char) * (50 + strlen($3) + strlen($5)));
		sprintf($$, "if(%s)%s", $3, $5); free($3); free($5);
	     }
	     | IF '(' EXPR ')' COMP_STMT ELSE COMP_STMT
	     {
		$$ = malloc(sizeof(char) * (50 + strlen($3) + strlen($5) + strlen($7)));
		sprintf($$, "if(%s)%selse%s", $3, $5, $7); free($3); free($5); free($7);
	     }
	     ;


SWITCH_CASES : SWITCH_CASES SWITCH_CASE
	     {
		$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($2)));
		sprintf($$, "%s%s", $1, $2); free($1); free($2);
	     }
	     | SWITCH_CASE
	     {
		$$ = malloc(sizeof(char) * (30 + strlen($1)));
		sprintf($$, "%s", $1); ; free($1);
	     }
	     ;


SWITCH_CASE : CASE EXPR ':' SWITCH_STMT
	    {
		$$ = malloc(sizeof(char) * (30 + strlen($2) + strlen($4)));
		sprintf($$, "case%s:%s", $2, $4); free($2); free($4);
	    }
	    | CASE EXPR ':'
	    {
		$$ = malloc(sizeof(char) * (30 + strlen($2)));
		sprintf($$, "case%s:", $2); free($2);
	    }
	    | DEFAULT ':' SWITCH_STMT
	    {
		$$ = malloc(sizeof(char) * (30 + strlen($3)));
		sprintf($$, "default:%s", $3); free($3);
	    }
	    | DEFAULT ':' { $$ = malloc(sizeof(char) * 30); sprintf($$, "default:"); }
	    ;


SWITCH_STMT : SWITCH_STMT STMT
	    {
		$$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($2)));
		sprintf($$, "%s%s", $1, $2); free($1); free($2);
	    }
	    | STMT { $$ = malloc(sizeof(char) * (30 + strlen($1))); sprintf($$, "%s", $1); free($1); }
	    ;


FOR_STMT : EXPR { $$ = malloc(sizeof(char) * (30 + strlen($1))); sprintf($$, "%s", $1); free($1); }
	 | { $$ = malloc(sizeof(char) * (30)); sprintf($$, "%s", ""); }
	 ;


COMP_STMT : '{' COMP_STMT_PLUM '}'
	  {
	      $$ = malloc(sizeof(char) * (30 + strlen($2)));
	      sprintf($$, "{%s}", $2); free($2);
	  }
	  | '{' '}' { $$ = malloc(sizeof(char) * (30)); sprintf($$, "{}"); }
	  ;


COMP_STMT_PLUM : COMP_STMT_PLUM STMT
	       {
		 $$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($2)));
		 sprintf($$, "%s%s", $1, $2); free($1); free($2);
	       }
	       | COMP_STMT_PLUM SCALAR_DEC 
	       {
		 $$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($2)));
		 sprintf($$, "%s%s", $1, $2); free($1); free($2);
	       }
	       | COMP_STMT_PLUM ARRAY_DEC
	       {
		 $$ = malloc(sizeof(char) * (30 + strlen($1) + strlen($2)));
		 sprintf($$, "%s%s", $1, $2); free($1); free($2);
	       }
	       | STMT { $$ = malloc(sizeof(char) * (30 + strlen($1))); sprintf($$, "%s", $1); free($1); }
               | SCALAR_DEC { $$ = malloc(sizeof(char) * (30 + strlen($1))); sprintf($$, "%s", $1); free($1); }
               | ARRAY_DEC { $$ = malloc(sizeof(char) * (30 + strlen($1))); sprintf($$, "%s", $1); free($1); }
	       ;

%%

int yylex();

int main(){
  yyparse();
  return 0;
}

int yyerror(char *msg){
  fprintf(stderr, "%s\n", msg);
  return 0;
}

