
/* definitions */

%{
#include <stdio.h>
#include <stdlib.h>
#include "tokendef.h"

 /* integers to track line and column numbers */
int scancol = 1;
int yycol = 1;
int scanlineno = 1;

 /* char pointer to pass error messages to driver.c */
char *yyerror;

 /* TODO: functions to update line and column numbers */
void updateCol();
void countLines();

 /* TODO: function to process a string literal */
int processString();

%}

newline         \n
whitespace      [ \t\r]+
integer         //TODO
character       //TODO

 /* String can contain any characters between the double quotes */
 /* other than a newline or unescaped doublequotes */
string       \"([^"\n\\]|\\[nt\"\\])*\"


 /* If the end quote is not found in the same line the string is unterminated */
untermstring \"([^"\n\\]|\\[nt\"\\])*\n

comment         \/\/.*
multlncomment   \/\*([^*]|\*+[^*/])*\*+\/
untermcomment   \/\*(.|\n)*

identifier      //TODO
illidentifier   //TODO: regular expression for an illegal identifier

yylineno = 1;

%%

 /* rules */

 /* Keywords */
 /* TODO: Support all keywords in mC */

 /* Operators */
 /* TODO: Support all operators in mC */

 /* Identifiers */;
{identifier}    //TODO
{illidentifier} //TODO

 /* Constants */;
{integer}       //TODO
{integerlead0}  //TODO: "Integers may not have leading zeros"
{character}     //TODO
{string}        {updateCol(); return processString();}
{untermstring}  {updateCol(); countLines(); yyerror = "String spans multiple lines"; return ERROR;}

 /* Comments */
{comment}       { updateCol(); }

{untermcomment} {
    updateCol();
    for(int i = 0; i < yyleng; i++){
        if(yytext[i] == '\n'){
            countLines();
        }
    }
    yyerror = "Unterminated comment";
    return ERROR;
}

{multlncomment} {
    updateCol();
    for(int i = 0; i < yyleng; i++){
        if(yytext[i] == '\n'){
            countLines();
        }
    }
}

 /* Other */
{newline}       { countLines(); }
{whitespace}    { updateCol(); }
.               {return ILLEGAL_TOK;}

%%

/* user routines */

/*
Implement this function to keep track of column numbers
*/
void updateCol(){
    yycol = scancol;
    scancol += yyleng;
}

/*
Implement this function to keep track of line numbers
*/
void countLines(){
    scanlineno += 1;
    yylineno = scanlineno;
    scancol = 1;
}


/* TODO:
Implement this function to
check for illegal escape sequences in string literals
and
convert valid escape sequences into escaped characters
(string[0] == '\\' and string[1] == 'n', then string[0] should be '\n')
*/
int processString(){
    char buffer[1024];
    int i = 1;
    int j = 0;

    while(yytext[i] != '"'){
        if(yytext[i] == '\\'){
            i++;
            if(yytext[i] == 'n')       buffer[j] = '\n';
            else if(yytext[i] == 't')  buffer[j] = '\t';
            else if(yytext[i] == '"')  buffer[j] = '"';
            else if(yytext[i] == '\\') buffer[j] = '\\';
            else {
                yyerror = "Unrecognized escape character in String";
                return ERROR;
            }
        } else {
            buffer[j] = yytext[i];
        }
        i++;
        j++;
    }
    buffer[j] = '\0';
    strcpy(yytext, buffer);
    return STRCONST;
}
