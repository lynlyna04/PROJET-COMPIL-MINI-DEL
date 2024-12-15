%{
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>
int yylex();
void yyerror(const char* msg);
extern int nb_ligne;
extern int col;
extern char* yytext;
extern int exists(char* nom);
extern void insertSymbol(const char* nom, const char* nature, const char* type, const char* valeur, int x);
extern void afficher();
%}

%union {
    int entier;
    char* str;
    float reel;
    struct {
        char* value; 
        char* type; 
    } chiffre;

    struct {
    	char* type;
    }type;
}


//terminaux
%token mc_for mc_while mc_if mc_else mc_readIn mc_writeIn mc_prog mc_integ mc_real mc_var mc_cst mc_beg mc_endp
%token <reel> nb_real <entier> nb_integer add subs multi divop aff and or neg supp inf suppeg infeg eg ineg
%token <str> idf chaine
%token po pf acco accf croo crof points pvg vg err

//associativite
%left or
%left and
%right neg
%left supp inf suppeg infeg eg ineg
%left add subs
%left multi divop


//types non-terminaux
%type <str> S
%type <str> DEC 
%type <str> ListIDF 
%type <str> TYPE
%type <str> Tableau
%type <str> Valeur
%type <chiffre> CHIFFRE
%type <str> InstAffect
%type <str> AECRIRE
%type <str> AECRIRE_PART
%type <str> additional_AECRIRE
%type <str> EXP



%%

S: mc_prog idf mc_var acco DEC accf mc_beg PGM mc_endp { printf("\n\nSyntaxe correcte\n\n"); YYACCEPT; };

DEC: TYPE ListIDF pvg DEC 
    { 
        char* id = $2; 
        if (exists(id) == 1) { 
            fprintf(stderr, "erreur: double declaration de :%s\n", id); 
        } else { 
            insertSymbol(id, "id", $1, NULL, 0); 
        } 
        $$ = $2; 
    } 
    | mc_cst idf aff CHIFFRE pvg DEC 
    { 
        char* id = $2; 
        if (exists(id) == 1) { 
            fprintf(stderr, "erreur: double declaration de :%s\n", id); 
        } else { 
            insertSymbol(id, "CONST", $4.type, $4.value, 0); 
        } 
        $$ = id; 
    } 
    | TYPE Tableau pvg DEC 
    { 
        char* id = $2; 
        if (exists(id) == 1) { 
            fprintf(stderr, "erreur: double declaration de :%s\n", id); 
        } else { 
            insertSymbol(id, "array", $1, NULL, 0); 
        } 
        $$ = id; 
    } 
    | /* vide */ 
    { 
        $$ = NULL; 
    } 
;





TYPE: mc_integ
    {
        $$ = "INTEGER";
    }
    | mc_real
    {
        $$ = "REAL";
    }
;

CHIFFRE: nb_real
    {   
        $$.value = strdup(yytext); 
        $$.type = "REAL"; 
    }
    | po subs nb_real pf 
    { 
        $$.value = strdup(yytext);
        $$.type = "REAL";
    }
    | po add nb_real pf 
    { 
        $$.value = strdup(yytext);
        $$.type = "REAL";
    }
    | nb_integer
    {
        $$.value = strdup(yytext);
        $$.type = "INTEGER"; 
    }
    | po subs nb_integer pf 
    { 
        $$.value = strdup(yytext);
        $$.type = "INTEGER";
    }
    | po add nb_integer pf 
    { 
        $$.value = strdup(yytext);
        $$.type = "INTEGER";
    }
;

ListIDF: idf vg ListIDF
    {   
    	char* id = $1;
        if (exists(id) == 1) {
            fprintf(stderr, "erreur: double declaration de :%s\n", id);
        } else {
            insertSymbol(id, "id", "I/R" , NULL, 0); 
        }
        $$ = $3;
    }
    | idf
    {
        $$ = $1;
    }
    | Tableau vg ListIDF
    {
            char* id = $1;
        if (exists(id) == 1) {
            fprintf(stderr, "erreur: double declaration de :%s\n", id);
        } else {
            insertSymbol(id, "array", "I/R", NULL, 0);
        $$ = id;}
            $$=$3;
        }
    | Tableau {$$=$1;}
;


Tableau: idf croo Valeur crof;

EXP: Valeur 
    { 
        $$ = $1; 
    }
    | EXP add EXP 
    { 
        $$ = $1;
    }
    | EXP subs EXP 
    { 
        $$ = $1;
    }
    | EXP multi EXP 
    { 
        $$ = $1; 
    }
    | EXP divop EXP 
    { 
        $$ = $1;
    }
    | po EXP pf 
    { 
        $$ = $2; 
    }
    ;


Valeur: idf
      {
          $$ = strdup($1);
      }
    | CHIFFRE
      {
          $$ = strdup($1.value);
      }
;



COND: SIMPLE_COND
    | COND OPRLogique SIMPLE_COND
    | neg SIMPLE_COND
    ;

SIMPLE_COND: po COND pf
    | EXP OPRComparaison EXP
    ;


OPRComparaison:  supp 
               | inf 
               | suppeg 
               | infeg 
               | eg 
               | ineg
;

OPRLogique: and 
           | or
;

PGM: INST_LIST;

INST_LIST: INST INST_LIST
         | /* vide */
;

INST: InstIF
    | InstFor
    | InstWhile
    | InstAffect
    | InstRead
    | InstWrite
;

InstFor: mc_for po idf points nb_integer points nb_integer points Valeur pf acco INST_LIST accf;

InstWhile: mc_while po COND pf acco INST_LIST accf;

InstIF: mc_if po COND pf acco PGM accf
      | mc_if po COND pf acco PGM accf mc_else acco PGM accf;

InstAffect: idf aff EXP pvg
          {
              if (!exists($1)) {
                  fprintf(stderr, "Erreur: Identifiant '%s' non déclaré, ligne %d, colonne %d.\n", $1, nb_ligne, col);
              } else {
              }
          }
        | Tableau aff EXP pvg
          {
              if (!exists($1)) {
                  fprintf(stderr, "Erreur: Tableau '%s' non déclaré, ligne %d, colonne %d.\n", $1, nb_ligne, col);
              } else {
              }
          }
;

InstRead: mc_readIn po idf pf pvg
         {
             if (!exists($3)) {
                 fprintf(stderr, "Erreur: Identifiant '%s' non déclaré, ligne %d, colonne %d.\n", $3, nb_ligne, col);
             }
         }
;

InstWrite: mc_writeIn po AECRIRE pf pvg
         {
         }
;

AECRIRE: AECRIRE_PART additional_AECRIRE
        {
            $$ = $1;
        }
        | { $$ = NULL; }
        ;
        
AECRIRE_PART: idf
        {
            if (exists($1) == 0) {
                fprintf(stderr, "Erreur: Identifiant '%s' non déclaré, ligne %d, colonne %d.\n", $1, nb_ligne, col);
            }
            $$ = $1;
        }
        | Tableau
        {
            if (exists($1) == 0) {
                fprintf(stderr, "Erreur: Tableau '%s' non déclaré, ligne %d, colonne %d.\n", $1, nb_ligne, col);
            }
            $$ = $1;
        }
        | chaine
        {
            $$ = $1;
        }
        ;

additional_AECRIRE: AECRIRE_PART additional_AECRIRE
        | { $$ = NULL; }
        ;


%%

void yyerror(const char* msg) {
    printf("\n\nErreur Syntaxique: %s, à la ligne %d, colonne %d, causée par l'entité '%s'\n", msg, nb_ligne, col, yytext);
}

int main() {
    yyparse();
    afficher();
    return 0;
}