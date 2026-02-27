
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
char *yyerror = NULL;

 /* functions to update line and column numbers */
void updateCol();
void countLines();

 /* function to process a string literal */
int processString();

%}

newline         \n
whitespace      [ \t\r]+
integer         0|[1-9][0-9]*
integerlead0    0[0-9]+
character       \'[^\'\n]\'

 /* String can contain any characters between the double quotes */
 /* other than a newline or unescaped doublequotes */
string       \"([^"\n\\]|\\[^\n])*\"



 /* If the end quote is not found in the same line the string is unterminated */
untermstring \"([^"\n\\]|\\[^\n])*\n

comment         \/\/.*
multlncomment   \/\*([^*]|\*+[^*/])*\*+\/
untermcomment   \/\*([^*]|\*+[^*/])*


identifier      [A-Za-z][A-Za-z0-9]*
illidentifier   [0-9]+[A-Za-z][A-Za-z0-9]*


%%

 /* rules */

 /* Keywords */
if          { updateCol(); return KWD_IF; }
else        { updateCol(); return KWD_ELSE; }
while       { updateCol(); return KWD_WHILE; }
int         { updateCol(); return KWD_INT; }
string      { updateCol(); return KWD_STRING; }
char        { updateCol(); return KWD_CHAR; }
return      { updateCol(); return KWD_RETURN; }
void        { updateCol(); return KWD_VOID; }

 /* Operators */
 /* Two character operators */
"++"        { updateCol(); return OPER_INC; }
"--"        { updateCol(); return OPER_DEC; }
"<="        { updateCol(); return OPER_LTE; }
">="        { updateCol(); return OPER_GTE; }
"=="        { updateCol(); return OPER_EQ; }
"!="        { updateCol(); return OPER_NEQ; }
"&&"        { updateCol(); return OPER_AND; }
"||"        { updateCol(); return OPER_OR; }

 /* One character operators */
"+"         { updateCol(); return OPER_ADD; }
"-"         { updateCol(); return OPER_SUB; }
"*"         { updateCol(); return OPER_MUL; }
"/"         { updateCol(); return OPER_DIV; }
"%"         { updateCol(); return OPER_MOD; }
"<"         { updateCol(); return OPER_LT; }
">"         { updateCol(); return OPER_GT; }
"="         { updateCol(); return OPER_ASGN; }
"!"         { updateCol(); return OPER_NOT; }
"@"         { updateCol(); return OPER_AT; }
 /* Brackets and punctuation */
"["         { updateCol(); return LSQ_BRKT; }
"]"         { updateCol(); return RSQ_BRKT; }
"{"         { updateCol(); return LCRLY_BRKT; }
"}"         { updateCol(); return RCRLY_BRKT; }
"("         { updateCol(); return LPAREN; }
")"         { updateCol(); return RPAREN; }
","         { updateCol(); return COMMA; }
";"         { updateCol(); return SEMICLN; }

 /* Identifiers */
{identifier} {
  updateCol();
  return ID;
}
{illidentifier} {
  updateCol();
  yyerror = "Illegal token";
  return ERROR;
}

 /* Constants */
{integerlead0} {
  updateCol();
  yyerror = "Illegal token";
  return ERROR;
}
{integer} {
  updateCol();
  return INTCONST;
}
{character}     { updateCol(); return CHARCONST; }
{string}        {updateCol(); return processString();}
{untermstring}  {updateCol(); countLines(); yyerror = "String spans multiple lines"; return ERROR;}

 /* Comments */
{comment}       { updateCol(); }

{multlncomment} {
    updateCol();
    for(int i = 0; i < yyleng; i++){
        if(yytext[i] == '\n'){
            countLines();
        }
    }
}

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
    yylineno = scanlineno;
    yycol = scancol;
    scancol += yyleng;
}

/*
Implement this function to keep track of line numbers
*/
void countLines(){
    scanlineno += 1;
    scancol = 1;
}


/*
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
