/*LIBRARIES*/
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define HASHMAP_SIZE 100

typedef struct Selector_Map_Info {
    char* selector;
    int frequency;
    int* lines;
    int num_lines;
} Selector_Map_Info;

typedef struct Selector_Map_Node {
    Selector_Info* data;
    struct Selector_Map_Node* next;
} Selector_Map_Node;

typedef struct Property_Map_Info {
    char* property;
    int frequency;
    int* lines;
    int num_lines;
    int child_of;
} Property_Map_Info;

typedef struct Property_Map_Node {
    Property_Info* data;
    struct Property_Map_Node* next;
} Property_Map_Node;

Selector_Map_Node* selectors_hash_map[HASHMAP_SIZE];
Property_Map_Node* properties_hash_map[HASHMAP_SIZE];

extern int yylex (void);
extern int yylineno;
void yyerror (char const *);
%}
%locations
%union{
    int total_selectors_stat;
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

style_modifier: 
    | selectors SELECTOR_START declarations SELECTOR_END
    | SELECTOR_START declarations SELECTOR_END 
        { /* Error: Falta selector al que aplicar definiciones. */ }
    | selectors SELECTOR_START declarations
        { /* Error: se esperaba cierre de definiciones de selector '}'. */ }
    | selectors declarations SELECTOR_END
        { /* Error: se esperaba apertura de definiciones de selector '{'. */ }

selectors: 
      /* Selector normal. */
      selector_name
      /* Selectores múltiples. */
    | selectors COMMA selector_name
    | error 
        { /* Error: selector mal definido. */ }

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
                { /*  */}

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

Selector_Map_Info* create_selector_info(char* selector, int line) {
    Selector_Map_Info* smi = (Selector_Map_Info*) malloc(sizeof(Selector_Map_Info));
    smi->selector = strdup(selector);
    smi->frequency = 1;
    smi->num_lines = 1;
    smi->lines = (int*) malloc(sizeof(int));
    smi->lines[0] = line;

    return smi;
}

void add_selector(char* selector, int line) {
    unsigned int h = hash(selector);
    Selector_Map_Node* node = hash_table[h];

    while (node != NULL) {
        // Si ya existe el mismo selector.
        if (strcmp(node->data->selector, selector) == 0) {
            node->data->frequency++;
            node->data->num_lines++;
            node->data->lines = (int*) realloc(node->data->lines, node->data->num_lines * sizeof(int));
            node->data->lines[node->data->num_lines - 1] = line;
            return;
        }
        node = node->next;
    }

    Selector_Map_Info* smi = create_selector_info(selector, line);
    node = (Selector_Map_Node*) malloc(sizeof(Selector_Map_Node));
    node->data = smi;
    node->next = selectors_hash_map[h];
    selectors_hash_map[h] = node;
}

Property_Map_Info* create_property_info(char* property, int line, int child_of) {
    Property_Map_Info* pmi = (Property_Map_Info*) malloc(sizeof(Property_Map_Info));
    pmi->selector = strdup(property);
    pmi->frequency = 1;
    pmi->num_lines = 1;
    pmi->lines = (int*) malloc(sizeof(int));
    pmi->lines[0] = line;
    pmi->child_of = child_of;

    return pmi;
}

void add_property(char* property, int line, int total_selectors_stat, int child_of) {
    unsigned int h = hash(property);
    Property_Map_Node* node = hash_table[h];

    while (node != NULL) {
        // Si ya existe el mismo property.
        if (strcmp(node->data->property, property) == 0 && total_selectors_stat==child_of) {
            node->data->frequency++;
            node->data->num_lines++;
            node->data->lines = (int*) realloc(node->data->lines, node->data->num_lines * sizeof(int));
            node->data->lines[node->data->num_lines - 1] = line;
            return;
        } else {
            node->data->frequency = 1;
            node->data->num_lines = 1;
            node->data->lines = (int*) realloc(node->data->lines, node->data->num_lines * sizeof(int));
            node->data->lines[node->data->num_lines - 1] = line;
            node->data->child_of = child_of;
            return;
        }
        node = node->next;
    }

    Property_Map_Info* pmi = create_selector_info(selector, line);
    node = (Property_Map_Node*) malloc(sizeof(Node));
    node->data = pmi;
    node->next = properties_hash_map[h];
    properties_hash_map[h] = node;
}

// Libera memoria de hash maps asociadas a los selectores
void free_hash_map(Selector_Map_Node** hash_map) {
    for (int i = 0; i < HASHMAP_SIZE; i++) {
        Selector_Map_Node* node = hash_map[i];
        while (node != NULL) {
            free(node->data->selector);
            free(node->data->lines);
            free(node->data);
            Selector_Map_Node* next_node = node->next;
            free(node);
            node = next_node;
        }
    }
    free(hash_map);
}

void free_hash_map(Property_Map_Node** hash_map) {
    for (int i = 0; i < HASHMAP_SIZE; i++) {
        Property_Map_Node* node = hash_map[i];
        while (node != NULL) {
            free(node->data->property);
            free(node->data->lines);
            free(node->data);
            Property_Map_Node* next_node = node->next;
            free(node);
            node = next_node;
        }
    }
    free(hash_map);
}

void analyze_selectors_hash_map(Selector_Map_Node** hash_map) {
    for (int i = 0; i < HASHMAP_SIZE; i++) {
        Selector_Map_Node* node = hash_map[i];
        while (node != NULL) {
            Selector_Map_Info* data = node->data;
            printf("Selector: %s\n", data->selector);
            printf("Frequency: %d\n", data->frequency);
            printf("Lines: ");
            for (int j = 0; j < data->num_lines; j++) {
                printf("%d ", data->lines[j]);
            }
            printf("\n");

            /*
            Warnings
            */

            node = node->next;
        }
    }
}

void analyze_properties_hash_map(Property_Map_Node** hash_map) {
    for (int i = 0; i < HASHMAP_SIZE; i++) {
        Property_Map_Node* node = hash_map[i];
        while (node != NULL) {
            Property_Map_Info* data = node->data;
            printf("Property: %s\n", data->property);
            printf("Frequency: %d\n", data->frequency);
            printf("Lines: ");
            for (int j = 0; j < data->num_lines; j++) {
                printf("%d ", data->lines[j]);
            }
            printf("\n");

            /*
            Warnings
            */

            node = node->next;
        }
    }
}

These functions iterate over each element in the hash map, and for each node in the chain, print the data contained in the corresponding structure. Note that these functions assume that the selector, property, and lines fields in each data structure were allocated using malloc() or a similar memory allocation function, and that the num_lines field specifies the length of the lines array. If the memory was allocated using a different method, or the lines array has a different length specification, you may need to modify the print statements accordingly.


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