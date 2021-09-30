%{
#include <stdio.h>
#include <string.h>
#include <Python.h>

yyerror(char *s)
{
    fprintf(stderr, "error: %s\n", s);
}

int yywrap()
{
	return 1;
}

PyObject *pBuiltins;

main()
{
    printf("**************************************\n");
    printf("--- Simple calculator Python-based ---\n");
    printf("**************************************\n");
    Py_Initialize();
    pBuiltins = PyImport_AddModule("builtins");
    printf("> "); 
    yyparse();
    Py_FinalizeEx();
}

%}


%union
{
    long intValue;
    char *stringValue;
}

/* declare tokens */
%token<intValue> NUMBER
%token ADD MINUS TIMES DIV POWER OP CP
%token EOL COMMA
%token<stringValue> FUNCTION 

%type<intValue> exp factor inside func parenthesized argument

%%

calclist:
 | calclist exp EOL { printf("%d\n> ", $2); }
 | calclist EOL { printf("> "); }
 ;


exp: factor 
    | exp ADD exp       
    {
        PyObject *addendum1 = PyLong_FromLong($1);
        PyObject *addendum2 = PyLong_FromLong($3);
        PyObject *fun = PyUnicode_DecodeLocale("__add__", NULL);
        PyObject *summa = PyObject_CallMethodOneArg(addendum1, fun, addendum2);
        long value = PyLong_AsLong(summa);
        $$ = value;
    }
    | exp MINUS exp     
    {
        PyObject *addendum1 = PyLong_FromLong($1);
        PyObject *addendum2 = PyLong_FromLong($3);
        PyObject *fun = PyUnicode_DecodeLocale("__sub__", NULL);
        PyObject *summa = PyObject_CallMethodOneArg(addendum1, fun, addendum2);
        long value = PyLong_AsLong(summa);
        $$ = value;
    }
    ;

factor: inside
    | factor TIMES factor 
    {
        PyObject *addendum1 = PyLong_FromLong($1);
        PyObject *addendum2 = PyLong_FromLong($3);
        PyObject *fun = PyUnicode_DecodeLocale("__mul__", NULL);
        PyObject *summa = PyObject_CallMethodOneArg(addendum1, fun, addendum2);
        long value = PyLong_AsLong(summa);
        $$ = value;    
    }
    | factor DIV factor   
    { 
        PyObject *addendum1 = PyLong_FromLong($1);
        PyObject *addendum2 = PyLong_FromLong($3);
        PyObject *fun = PyUnicode_DecodeLocale("__truediv__", NULL);
        PyObject *summa = PyObject_CallMethodOneArg(addendum1, fun, addendum2);
        long value = PyLong_AsLong(summa);
        $$ = value;    
    }
    ;

inside: parenthesized  
    | func
    | exp POWER exp
    {
        PyObject *addendum1 = PyLong_FromLong($1);
        PyObject *addendum2 = PyLong_FromLong($3);
        PyObject *fun = PyUnicode_DecodeLocale("__pow__", NULL);
        PyObject *summa = PyObject_CallMethodOneArg(addendum1, fun, addendum2);
        long value = PyLong_AsLong(summa);
        $$ = value;      
    }
    ;

func:   
    FUNCTION OP argument CP
    {
        
        //PyObject *fun = PyUnicode_DecodeLocale($1, NULL);
        PyObject *arg1 = PyLong_FromLong($3);
        PyObject *fun = PyObject_GetAttrString(pBuiltins, $1);
        PyObject *pArgs = PyTuple_New(1);
        PyTuple_SetItem(pArgs, 0, arg1);
    
        //printf("%d", PyLong_AsLong(arg1));

        if (PyCallable_Check(fun)) {
            PyObject *summa = PyObject_CallObject(fun, pArgs);
            long value = PyLong_AsLong(summa);
            $$ = value;
        } else {
            printf("La stringa non è chiamabile");
            $$ = 0;
        }

        Py_DECREF(pArgs);    
    }
    | FUNCTION OP MINUS argument CP 
    {
        
        //PyObject *fun = PyUnicode_DecodeLocale($1, NULL);
        PyObject *arg1 = PyLong_FromLong(-$4);
        PyObject *fun = PyObject_GetAttrString(pBuiltins, $1);
        PyObject *pArgs = PyTuple_New(1);
        PyTuple_SetItem(pArgs, 0, arg1);
    
        //printf("%d", PyLong_AsLong(arg1));

        if (PyCallable_Check(fun)) {
            PyObject *summa = PyObject_CallObject(fun, pArgs);
            long value = PyLong_AsLong(summa);
            $$ = value;
        } else {
            printf("La stringa non è chiamabile");
            $$ = 0;
        }

        Py_DECREF(pArgs);    
    }
    ;

argument: exp        { $$ = $1; } 
    | argument COMMA exp { $$ = $3; }
    ;

parenthesized: NUMBER   { $$ = $1 } 
    | OP exp CP           { $$ = $2; }
    ;

%%
