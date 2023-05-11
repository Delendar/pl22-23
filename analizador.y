/*LIBRARIES*/
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define HASHMAP_SIZE 100

typedef struct Selector_Info {
    char* selector;
    int frequency;
    int* lines;
} Selector_Info;

typedef struct Node {
    Selector_Info* data;
    struct Node* next;
} Node;

extern int yylex (void);
extern int yylineno;
void yyerror (char const *);
%}
%locations
%union{
    int element_stat;
    int class_stat;
    int subclass_stat;
    int id_stat;
    int pseudoclass_stat;
    int nested_stat;
    int comment_stat;
    int prop_val_txt_stat;
    int prop_val_px_stat;
    int prop_val_perc_stat;
    int prop_val_html_stat;
    int empty_selector_stat;
    /* Array de */
}
/*TOKENS*/
%token SELECTOR_START SELECTOR_END COMMA
%token ELEMENT ID CLASS SUBCLASS PSEUDOCLASS PSEUDOELEMENT NESTED_ELEMENT
%token PROP_NAME VALUE_TXT VALUE_PX VALUE_PERCENTAGE VALUE_HTML_COLOR
%start css
%%
/*RULES*/
css : css style_modifier | /* vacio */

style_modifier: selectors SELECTOR_START declarations SELECTOR_END

selectors: 
      /* Selector normal. */
      selector_name
      /* Selectores múltiples. */
    | selectors COMMA selector_name

selector_name: 
    | ELEMENT   { /* Añadir a lista de elementos modificados */ }
    | CLASS     { /* Añadir a clases modificadas */ }
    | SUBCLASS  { /* Añadir a subclases modificadas */ }
    | ID        { /* Añadir a id's modificados */ }
    | PSEUDOCLASS   { /* Añadir a pseudoclases modificadas */ }
    | PSEUDOELEMENT { /* Añadir a pseudoelementos modificados */ }
    | NESTED_ELEMENT { /* Añadir a elementos anidados modificados */ }

declarations: declarations property
    | /* vacio */

property: PROP_NAME property_value

property_value:
    | VALUE_TXT
    | VALUE_PX
    | VALUE_PERCENTAGE
    | VALUE_HTML_COLOR

%%

unsigned int hash(char* str) {
    unsigned int hash = 5381;
    int c;

    while ((c = *str++))
        hash = ((hash << 5) + hash) + c; /* hash * 33 + c */

    return hash % HASH_SIZE;
}

Selector_Info* create_selector_info(char* selector, int line) {
    Selector_Info* si = (Selector_Info*) malloc(sizeof(Selector_Info));
    si->word = strdup(selector);
    si->frequency = 1;
    si->lines = (int*) malloc(sizeof(int));
    si->lines[0] = line;

    return si;
}

void create_node(char* selector, int line) {
    unsigned int h = hash(selector);
    Node* node = hash_table[h];

    while (node != NULL) {
        // Si ya existe el mismo selector.
        if (strcmp(node->data->selector, selector) == 0) {
            node->data->frequency++;
            node->data->lines = (int*) realloc(node->data->lines, node->data->num_lines * sizeof(int));
            node->data->lines[node->data->num_lines - 1] = line;
            return;
        }
        node = node->next;
    }

    Selector_Info* si = create_selector_info(selector, line);
    node = (Node*) malloc(sizeof(Node));
    node->data = si;
    node->next = hash_table[h];
    hash_table[h] = node;
}

void add_string(char** strings, int* strings_size, const char* new_string) {
    if (*strings_size >= BASE_STORED_TAGS_SIZE) {
        strings = realloc(strings, (*strings_size + 1) *sizeof(char*));
    }
    strings[*strings_size] = malloc(strlen(new_string)+1);
    strcpy(strings[*strings_size], new_string);
    *strings_size += 1;
}

void remove_string(char*** strings, int* strings_size) {
    if (*strings_size > 0) {
        (*strings_size)--;
        free((*strings)[*strings_size]);
        (*strings)[*strings_size] = NULL;
    }
}

void free_strings(char** strings, int* strings_size) {
    for(int i=0; i < *strings_size; i++){
        free(strings[i]);
    }
    free(strings);
    free(strings_size);
}

/*CODE*/
int main(){
    yylval.linea=0;
    extern FILE *yyin;
    yyin=stdin;
    if(yyin == NULL){
        perror("fopen");
        exit(EXIT_FAILURE);
    }
    else {
        yyparse();
        fclose(yyin);
    }
    return 0;
}