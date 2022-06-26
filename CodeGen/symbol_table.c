
/**

   This is a very simple c compiler written by Prof. Jenq Kuen Lee,
   Department of Computer Science, National Tsing-Hua Univ., Taiwan,
   Fall 1995.

   This is used in compiler class.
   This file contains Symbol Table Handling.

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//#include <error.h>
#include "symbol_table.h"

//extern FILE *f_asm;
int cur_counter = 0;
int cur_scope = 1;
char *copys();

/*

  init_symbol_table();

*/
void init_symbol_table() {

    bzero(&S_Table[0], sizeof(struct symbol_entry) * TABLE_SIZE);
}

/*
   To install a symbol in the symbol table

*/
char *install_symbol(char *s) {

    if (cur_counter >= TABLE_SIZE)
        perror("Symbol Table Full");
    else {
        S_Table[cur_counter].scope = cur_scope;
        S_Table[cur_counter].name = copys(s);
        cur_counter++;
    }
    return (s);
}

/*
   To return an integer as an index of the symbol table

*/
int look_up_symbol(char *s) {
    int i;

    if (cur_counter == 0)
        return (-1);
    for (i = cur_counter - 1; i >= 0; i--) {
        if (!strcmp(s, S_Table[i].name))
            return (i);
    }
    return (-1);
}

/*
   Pop up symbols of the given scope from the symbol table upon the
   exit of a given scope.

*/
void pop_up_symbol(int scope) {
    int i;
    if (cur_counter == 0)
        return;
    for (i = cur_counter - 1; i >= 0; i--) {
        if (S_Table[i].scope != scope)
            break;
    }
    if (i < 0)
        cur_counter = 0;
    cur_counter = i + 1;
}

/*
   Set up parameter scope and offset

*/
void set_scope_and_offset_of_param(char *s) {

    int i, j, index;
    int total_args;

    index = look_up_symbol(s);
    if (index < 0)
        perror("Error in function header");
    else {
        functor_index = index;
        S_Table[index].type = T_FUNCTION;
        total_args = cur_counter - index - 1;
        S_Table[index].total_args = total_args;
        S_Table[index].total_locals = 0;
        for (j = total_args, i = cur_counter - 1; i > index; i--, j--) {
            S_Table[i].scope = cur_scope;
            S_Table[i].offset = j;
            S_Table[i].mode = ARGUMENT_MODE;
            S_Table[i].functor_index = index;
        }
    }
}

/*
   Set up local var offset

*/
void set_local_vars(char* functor) {

    int i, j, index, index1;
    int total_locals;

    index = look_up_symbol(functor);
    index1 = index + S_Table[index].total_args;
    total_locals = cur_counter - index1 - 1;
    if (total_locals < 0)
        perror("Error in number of local variables");
    S_Table[index].total_locals = total_locals;
    for (j = total_locals, i = cur_counter - 1; j > 0; i--, j--) {
        S_Table[i].scope = cur_scope;
        S_Table[i].offset = j;
        S_Table[i].mode = LOCAL_MODE;
    }
}

void add_local_var() {
    int index = cur_counter-1;

    S_Table[index].scope = cur_scope;
    S_Table[index].offset = ++(S_Table[functor_index].total_locals);
    S_Table[index].mode = LOCAL_MODE;
    S_Table[index].functor_index = functor_index;
}

/*
  Set GLOBAL_MODE to global variables

*/

void set_global_vars(char *s) {
    int index;

    index = look_up_symbol(s);
    S_Table[index].mode = GLOBAL_MODE;
    S_Table[index].scope = 1;
}

/*

To generate house-keeping work at the beginning of the function

*/

void code_gen_func_header(char *functor) {
    printf(".global %s\n", functor);

    printf("%s:\n", functor);

    printf("\t// BEGIN PROLOGUE\n");
    printf("\taddi sp,sp,-104 \n");
    printf("\tsd sp, 96(sp) \n");
    printf("\tsd s0, 88(sp) \n");
    printf("\tsd s1, 80(sp) \n");
    printf("\tsd s2, 72(sp) \n");
    printf("\tsd s3, 64(sp) \n");
    printf("\tsd s4, 56(sp) \n");
    printf("\tsd s5, 48(sp) \n");
    printf("\tsd s6, 40(sp) \n");
    printf("\tsd s7, 32(sp) \n");
    printf("\tsd s8, 24(sp) \n");
    printf("\tsd s9, 16(sp) \n");
    printf("\tsd s10, 8(sp) \n");
    printf("\tsd s11, 0(sp) \n");
    printf("\taddi s0, sp, 104 \n");
    printf("\t// END PROLOGUE\n");

    printf("\t\t\n");
}

/*

  To generate global symbol vars

*/
// void code_gen_global_vars() {
//     int i;

//     for (i = 0; i < cur_counter; i++) {
//         if (S_Table[i].mode == GLOBAL_MODE) {
//             fprintf(f_asm, "        .type   %s,@object\n", table[i].name);
//             fprintf(f_asm, "        .comm   %s,4,4\n", table[i].name);
//         }
//     }

//     fprintf(f_asm, " \n");
//     fprintf(
//         f_asm,
//         "        .ident \"NTHU Compiler Class Code Generator for RISC-V\"\n");
//     fprintf(f_asm, "        .section \"note.stack\",\"\",@progbits\n");
// }

/*

 To geenrate house-keeping work at the end of a function

*/

void code_gen_at_end_of_function_body(char *functor) {

    printf("\t// BEGIN EPILOGUE\n");
    printf("\taddi sp, sp, %d \n", (S_Table[functor_index].total_locals+S_Table[functor_index].total_args)*8);
    printf("\tld sp, 96(sp) \n");
    printf("\tld s0, 88(sp) \n");
    printf("\tld s1, 80(sp) \n");
    printf("\tld s2, 72(sp) \n");
    printf("\tld s3, 64(sp) \n");
    printf("\tld s4, 56(sp) \n");
    printf("\tld s5, 48(sp) \n");
    printf("\tld s6, 40(sp) \n");
    printf("\tld s7, 32(sp) \n");
    printf("\tld s8, 24(sp) \n");
    printf("\tld s9, 16(sp) \n");
    printf("\tld s10, 8(sp) \n");
    printf("\tld s11, 0(sp) \n");
    printf("\taddi sp, sp, 104 \n");
    printf("\t// END EPILOGUE\n");

    printf("\t\t\n");

    printf("\tjalr zero, 0(ra) // return\n");
}

void get_two_expr(int expr1, int expr2){
    if(expr2 >= 0){
        printf("\tld t0, 0(sp)\n");
        for(int i = 0; i < expr2; i++){
            printf("\tld t0, 0(t0)\n");
        }
        printf("\taddi sp, sp, 8\n");
    } else {
        printf("\tld t0, %d(s0)\n", expr2);
    }

    if(expr1 >= 0){
        printf("\tld t1, 0(sp)\n");
        for(int i = 0; i < expr1; i++){
            printf("\tld t1, 0(t1)\n");
        }
        printf("\taddi sp, sp, 8\n");
    } else {
        printf("\tld t1, %d(s0)\n", expr1);
    }
}

/*******************Utility Functions ********************/
/*
 * copyn -- makes a copy of a string with known length
 *
 * input:
 *	  n - lenght of the string "s"
 *	  s - the string to be copied
 *
 * output:
 *	  pointer to the new string
 */

char *copyn(register int n, register char *s) {
    register char *p, *q;

    p = q = calloc(1, n);
    while (--n >= 0)
        *q++ = *s++;
    return (p);
}

/*
 * copys -- makes a copy of a string
 *
 * input:
 *	  s - string to be copied
 *
 * output:
 *	  pointer to the new string
 */
char *copys(char *s) { return (copyn(strlen(s) + 1, s)); }
