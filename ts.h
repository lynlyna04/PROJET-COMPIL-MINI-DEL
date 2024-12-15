#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define hach_taille 100

typedef struct Symbolidc { //pour idfs et consts
    char* nom;
    char* nature;
    char* type;
    char* valeur;
    struct Symbolidc* suiv;
} Symbolidc;

typedef struct Symbol { //pour mots cles et symboles
    char* nom;
    char* nature;
    struct Symbol* suiv;
} Symbol;

Symbolidc* hashTable[hach_taille] = { NULL };
Symbol* keywords[hach_taille] = { NULL };
Symbol* symb[hach_taille] = { NULL };

//fonction de hachage
unsigned int hash(const char* str) {
    unsigned int hash = 0;
    while (*str)
        hash = (hash << 5) + *str++;
    return hash % hach_taille;
}


//recherche dans la ts
int Rechercher(const char* nom, int x) { 
    unsigned int index = hash(nom);
    switch (x) {
        case 0: { //idfs + consts
            Symbolidc* current = hashTable[index];
            while (current) {
                if (strcmp(current->nom, nom) == 0)
                    return 1;
                current = current->suiv;
            }
            break;
        }
        case 1: { //mots cles
            Symbol* current = keywords[index];
            while (current) {
                if (strcmp(current->nom, nom) == 0)
                    return 1; 
                current = current->suiv;
            }
            break;
        }
        case 2: { // Symbols
            Symbol* current = symb[index];
            while (current) {
                if (strcmp(current->nom, nom) == 0)
                    return 1;
                current = current->suiv;
            }
            break;
        }
        default:
            return 0;
    }
    return 0; 
}


// Insert a symbol
void insertSymbol(const char* nom, const char* nature, const char* type, const char* valeur, int x) {
    if (Rechercher(nom, x)) {
        return; 
    }

    unsigned int index = hash(nom);

    switch (x) {
        case 0: { //idfs et consts
            Symbolidc* newSymbol = (Symbolidc*)malloc(sizeof(Symbolidc));
            newSymbol->nom = strdup(nom);
            newSymbol->nature = strdup(nature);
            newSymbol->type = strdup(type);
            newSymbol->valeur = valeur ? strdup(valeur) : NULL;
            newSymbol->suiv = hashTable[index];
            hashTable[index] = newSymbol;
            break;
        }
        case 1: { // Keywords
            Symbol* newSymbol = (Symbol*)malloc(sizeof(Symbol));
            newSymbol->nom = strdup(nom);
            newSymbol->nature = strdup(nature);
            newSymbol->suiv = keywords[index];
            keywords[index] = newSymbol;
            break;
        }
        case 2: { // Symbols
            Symbol* newSymbol = (Symbol*)malloc(sizeof(Symbol));
            newSymbol->nom = strdup(nom);
            newSymbol->nature = strdup(nature);
            newSymbol->suiv = symb[index];
            symb[index] = newSymbol;
            break;
        }
        default:
            fprintf(stderr, "Invalid type for insertion: %d\n", x);
            break;
    }
}

//afficher la ts
void afficher() {
    printf("/*************** Table of Identifiers and Constants ***************/\n");
    printf("____________________________________________________________________\n");
    printf("\t| Nom_Entite |  Code_Entite | Type_Entite | Val_Entite\n");
    printf("____________________________________________________________________\n");

    for (int i = 0; i < hach_taille; i++) {
        Symbolidc* current = hashTable[i];
        while (current) {
            printf("\t|%10s |%15s | %12s | %12s\n",
                   current->nom,
                   current->nature,
                   current->type,
                   current->valeur ? current->valeur : "N/A");
            current = current->suiv;
        }
    }

    printf("\n/*************** Table of Keywords ***************/\n");
    printf("_____________________________________\n");
    printf("\t| NomEntite |  CodeEntite |\n");
    printf("_____________________________________\n");

    for (int i = 0; i < hach_taille; i++) {
        Symbol* current = keywords[i];
        while (current) {
            printf("\t|%10s |%15s\n", current->nom, current->nature);
            current = current->suiv;
        }
    }

    printf("\n/*************** Table of Symbols ***************/\n");
    printf("_____________________________________\n");
    printf("\t| NomEntite |  CodeEntite |\n");
    printf("_____________________________________\n");

    for (int i = 0; i < hach_taille; i++) {
        Symbol* current = symb[i];
        while (current) {
            printf("\t|%10s |%15s\n", current->nom, current->nature);
            current = current->suiv;
        }
    }
}


//fonction qui verifie lexistence dune entite dans la ts
int exists(const char* nom) {
    unsigned int index = hash(nom);
    Symbolidc* current = hashTable[index];
    
    while (current) {
        if (strcmp(current->nom, nom) == 0) {
            return 1; 
        }
        current = current->suiv;
    }
    
    return 0; 
}