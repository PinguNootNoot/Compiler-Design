%{

#include <stdio.h>
#include <stdlib.h>
#define MAX_LENGTH 299

int srcFlag = 1;

int tokFlag = 1;

int ifComment = 0;

%}

prasrc_on ^[ ]*[#](pragma)[ ]+(source)[ ]+(on)

prasrc_off ^[ ]*[#](pragma)[ ]+(source)[ ]+(off)

pratok_on ^[ ]*[#](pragma)[ ]+(token)[ ]+(on)

pratok_off ^[ ]*[#](pragma)[ ]+(token)[ ]+(off)

key	for|while|break|continue|if|else|do|return|struct|switch|case|default|void|int|char|float|double|unsigned|signed|long|short|const

macro	NULL|__COUNTER__|__LINE__|MAX|MIN|INT_MAX|INT_MIN|CHAR_MAX|CHAR_MIN

id	[a-zA-Z_][a-zA-Z0-9_]*

op	[+]|[\-]|[*]|[/]|%|=|&|[|]|!|<|>|"++"|"--"|"=="|"!="|"<="|">="|"&&"|"||"

punc	:|;|,|[.]|\(|\)|\[|\]|\{|\}

char	['](.|(\\n)|(\\t))[']

integer	[\-|+]?[0-9]+

float	[\-|+]?[0-9]+[.][0-9]+

string	["][^"]*["]

comment1 "//".*

comment2 [/][*][^"*/"]*[*][/]

comment2_begin [*]?[/][*]

comment2_end [*][/]

space	[ ]+

newline	\n

%%

{prasrc_on} {srcFlag = 1;}

{prasrc_off} {srcFlag = 0;}

{pratok_on} {tokFlag = 1;}

{pratok_off} {tokFlag = 0;}

{space} { }

{newline} { }

{string} {if(tokFlag && !ifComment) printf("#string:%s\n", yytext);}

{key}	{if(tokFlag && !ifComment) printf("#key:%s\n", yytext);}

{macro}	{if(tokFlag && !ifComment) printf("#macro:%s\n", yytext);}

{op}    {if(tokFlag && !ifComment) printf("#op:%s\n", yytext);}

{punc}	{if(tokFlag && !ifComment) printf("#punc:%s\n", yytext);}

{char}	{if(tokFlag && !ifComment) printf("#char:%s\n", yytext);}

{id}	{if(tokFlag && !ifComment) printf("#id:%s\n", yytext);}

{integer} {if(tokFlag && !ifComment) printf("#integer:%s\n", yytext);}

{float}	{if(tokFlag && !ifComment) printf("#float:%s\n", yytext);}

{comment1} { }

{comment2} { }

{comment2_begin} {if(yytext[2]) { if(!ifComment) ifComment = 1; else ifComment = 0; printf("#op:*\n");} else ifComment = 1;}

{comment2_end} {if(!ifComment) printf("#op:*\n#op:/\n"); ifComment = 0;}

%%

int main(int argc, char* argv[]){
  char inputLine[MAX_LENGTH];
  int lineCount = 0;
  YY_BUFFER_STATE buffer;

  if(argv[1]){
    FILE *FilePtr;

    FilePtr = fopen(argv[1],"r");
    if(!FilePtr){
      printf("Error! Could not open file: %s\n", argv[1]);
      exit(1);
    } 
    while(fgets(inputLine, MAX_LENGTH, FilePtr)){
      buffer = yy_scan_string(inputLine);
      ++lineCount;
      yylex();
      if(srcFlag) printf("%d:%s", lineCount, inputLine);
      yy_delete_buffer(buffer);
    }
    fclose(FilePtr);
  } else {
    while(fgets(inputLine, MAX_LENGTH, stdin)){
      buffer = yy_scan_string(inputLine);
      ++lineCount;
      yylex();
      if(srcFlag) printf("%d:%s", lineCount, inputLine);
      yy_delete_buffer(buffer);
    }
  }
  return 0;
}

