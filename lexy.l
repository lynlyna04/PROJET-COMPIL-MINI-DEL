%{
#include <stdio.h>
#include "synta.tab.h"
#include "ts.h"
#include <string.h>
int col=1;
int nb_ligne = 1;
extern YYSTYPE yylval;
%}
%x COMMENT
%x CHAINE

idf [A-Za-z][a-z0-9_]{0,6}
integer \([+-]?[0-9]+\)|[0-9]+
real \([+-]?[0-9]+\.[0-9]+\)|[0-9]+\.[0-9]+

%%
"/*"         { BEGIN(COMMENT); } 
<COMMENT>"*/" { BEGIN(INITIAL); }
<COMMENT>.|\n { /* Ignorer */ }
<COMMENT><<EOF>> {
    fprintf(stderr, "Error: Unterminated comment at line %d\n", nb_ligne);
    exit(1);  
}

"'"          { BEGIN(CHAINE); ECHO; } 
<CHAINE>"'"  { 
    BEGIN(INITIAL); 
    ECHO; 
    return chaine;
}
<CHAINE>.|\n { ECHO; /* Ignorer*/ }
<CHAINE><<EOF>> {
    fprintf(stderr, "Error: Unterminated string at line %d\n", nb_ligne);
    exit(1);
}

"for"       { insertSymbol(yytext, "mot cle", "none", NULL, 1); col=col + strlen(yytext); ECHO; return mc_for; }
"while"     { insertSymbol(yytext, "mot cle", "none", NULL, 1); col=col + strlen(yytext); ECHO; return mc_while; }
"if"        { insertSymbol(yytext, "mot cle", "none", NULL, 1); col=col + strlen(yytext); ECHO; return mc_if; }
"else"      { insertSymbol(yytext, "mot cle", "none", NULL, 1); col=col + strlen(yytext); ECHO; return mc_else; }
"readIn"    { insertSymbol(yytext, "mot cle", "none", NULL, 1); col=col + strlen(yytext); ECHO; return mc_readIn; }
"writeIn"   { insertSymbol(yytext, "mot cle", "none", NULL, 1); col=col + strlen(yytext); ECHO; return mc_writeIn; }

"PROGRAMME" { insertSymbol(yytext, "mot cle", "none", NULL, 1); col=col + strlen(yytext); ECHO; return mc_prog; }
"INTEGER"   { insertSymbol(yytext, "mot cle", "none", NULL, 1); col=col + strlen(yytext); ECHO; return mc_integ; }
"REAL"      { insertSymbol(yytext, "mot cle", "none", NULL, 1); col=col + strlen(yytext); ECHO; return mc_real; }
"VAR"       { insertSymbol(yytext, "mot cle", "none", NULL, 1); col=col + strlen(yytext); ECHO; return mc_var; }
"CONST"     { insertSymbol(yytext, "mot cle", "none", NULL, 1); col=col + strlen(yytext); ECHO; return mc_cst; }
"BEGIN"     { insertSymbol(yytext, "mot cle", "none", NULL, 1); col=col + strlen(yytext); ECHO; return mc_beg; }
"END."      { insertSymbol(yytext, "mot cle", "none", NULL, 1); col=col + strlen(yytext); ECHO; return mc_endp; }

{real}      { yylval.reel=atoi(yytext);col=col + strlen(yytext); ECHO; return nb_real; }
{integer}   { yylval.entier=atoi(yytext); col=col + strlen(yytext); ECHO; return nb_integer; }
{idf}       { yylval.str = strdup(yytext);col = col + strlen(yytext); ECHO; return idf;}

"+"         { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return add; }
"-"         { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return subs; }
"*"         { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return multi; }
"/"         { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return divop; }
"="         { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return aff; }

"&&"        { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return and; }
"||"        { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return or; }
"!"         { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return neg; }

"//".*      { /* Ignore single-line comments */ }
"/\\*([^*]|\\*+[^*/])*\\*+/" { /* Ignore multi-line comments */ }

">"         { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return supp; }
"<"         { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return inf; }
">="        { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return suppeg; }
"<="        { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return infeg; }
"=="        { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return eg; }
"!="        { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return ineg; }

"("         { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return po; }
")"         { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return pf; }
"{"         { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return acco; }
"}"         { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return accf; }
"["         { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return croo; }
"]"         { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return crof; }
":"         { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return points; }
";"         { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return pvg; }
","         { insertSymbol(yytext, "symbole", "none", NULL, 2); col=col + strlen(yytext); ECHO; return vg; }

[ \t]       { ECHO; /* Ignorer espaces*/ }
\n          {nb_ligne++; printf("\n"); }
.           { printf("Erreur lexicale Ã  la ligne %d\n", nb_ligne); return err; }

%%
