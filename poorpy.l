%{
#include <stdio.h>
#include "poorpy.tab.h"
%}

%%
"+"	            { return ADD; }
"-"	            { return MINUS; }
"*"             { return TIMES;}
"/"             { return DIV; }
"**"            { return POWER; }
"("             { return OP; }
")"             { return CP; }
[0-9]+	        { yylval.intValue = atoi(yytext); return NUMBER; }
[a-z][a-zA-Z0-9]*   { yylval.stringValue = strdup(yytext); return FUNCTION; }
","             { return COMMA; }
\n              { return EOL; }
"//".*  
[ \t]           { /* ignore white space */ }
.	            { yyerror("Mystery character %c\n", *yytext); }
%%
