/*LIBRARIES*/
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define HASH_MAP_SIZE 100

typedef struct Selector_Map_Info {
    char* selector;
    int frequency;
    int* lines;
    int num_lines;
} Selector_Map_Info;

typedef struct Selector_Map_Node {
    Selector_Map_Info* data;
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
    Property_Map_Info* data;
    struct Property_Map_Node* next;
} Property_Map_Node;

Selector_Map_Node* selectors_hash_map[HASH_MAP_SIZE];
Property_Map_Node* properties_hash_map[HASH_MAP_SIZE];

extern int yylex (void);
extern int yylineno;
void yyerror (char const *);
void removeSpaces(char* str);
void add_selector(char* selector, int line);
void add_property(char* property, int line, int total_selectors_stat, int child_of);
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
    char *string;
    /* Array de */
}
/*TOKENS*/
%token SELECTOR_START SELECTOR_END COMMA
%token <string> ELEMENT ID CLASS SUBCLASS PSEUDOCLASS PSEUDOELEMENT NESTED_ELEMENT
%token PROP_NAME VALUE_TXT VALUE_PX VALUE_PERCENTAGE VALUE_HTML_COLOR
%start css
%%
/*RULES*/
css : css style_modifier | /* vacio */

style_modifier: 
    | selectors SELECTOR_START declarations SELECTOR_END
    | SELECTOR_START declarations SELECTOR_END 
        { /* Error: Falta selector al que aplicar definiciones. */
        yyerror("Error sintactico: falta selector al que aplicar modificaciones de estilo, linea "); 
        YYABORT; }
    | selectors SELECTOR_START declarations
        { /* Error: se esperaba cierre de definiciones de selector '}'. */ 
        yyerror("Error sintactico: se esperaba final de modificaciones de estilo de un selector '}', linea "); 
        YYABORT; }
    | selectors declarations SELECTOR_END
        { /* Error: se esperaba apertura de definiciones de selector '{'. */ 
        yyerror("Error sintactico: se esperaba inicio de modificaciones de estilo de un selector '{', linea "); 
        YYABORT; }

selectors: 
      /* Selector normal. */
      selector_name
      /* Selectores múltiples. */
    | selectors COMMA selector_name
    | error 
        { /* Error: selector mal definido. */ 
        yyerror("Error sintactico: se encontro un error en la definicion del nombre/nombres de selector, linea "); 
        YYABORT; }

selector_name: 
    | ELEMENT   { /* Añadir a lista de elementos modificados */ 
        char* aux=$1;
        removeSpaces(aux);
        add_selector(aux, yylineno);
    }
    | CLASS     { /* Añadir a clases modificadas */         
        char* aux=$1;
        removeSpaces(aux);
        add_selector(aux, yylineno);
    }
    | SUBCLASS  { /* Añadir a subclases modificadas */ 
        char* aux=$1;
        removeSpaces(aux);
        add_selector(aux, yylineno);
    }
    | ID        { /* Añadir a id's modificados */ 
        char* aux=$1;
        removeSpaces(aux);
        add_selector(aux, yylineno);
    }
    | PSEUDOCLASS   { /* Añadir a pseudoclases modificadas */
        char* aux=$1;
        removeSpaces(aux);
        add_selector(aux, yylineno);
    }
    | PSEUDOELEMENT { /* Añadir a pseudoelementos modificados */
        char* aux=$1;
        removeSpaces(aux);
        add_selector(aux, yylineno);
    }
    | NESTED_ELEMENT { /* Añadir a elementos anidados modificados TENER CAUTELA CON LOS ESPACIOS*/ }

declarations: declarations property
    | /* vacio */

property: PROP_NAME property_value 
                { /*  */ }

property_value:
    | VALUE_TXT
    | VALUE_PX
    | VALUE_PERCENTAGE
    | VALUE_HTML_COLOR

%%

/* Función de hash */
unsigned int hash(char* str) {
    unsigned int hash = 5381;
    int c;

    while ((c = *str++))
        hash = ((hash << 5) + hash) + c; /* hash * 33 + c */

    return hash % HASH_MAP_SIZE;
}

/* Función para eliminar los espacios dentro de un string*/
void removeSpaces(char* str) {
    int i, j;
    for (i = 0, j = 0; str[i] != '\0'; i++) {
        if (str[i] != ' ') {
            str[j++] = str[i];
        }
    }
    str[j] = '\0';
}

/* Creador de contenedor de informacion de un nodo */
Selector_Map_Info* create_selector_info(char* selector, int line) {
    Selector_Map_Info* smi = (Selector_Map_Info*) malloc(sizeof(Selector_Map_Info));
    smi->selector = strdup(selector);
    smi->frequency = 1;
    smi->num_lines = 1;
    smi->lines = (int*) malloc(sizeof(int));
    smi->lines[0] = line;

    return smi;
}

/* Gestion de adicion de un selector al hashmap.
   1. Si no existe colision anade.
   2. Si existe colision, si es igual al almacenado aumenta la frecuencia de aparicion del selector.
   3. Si existe colision, sino es igual crea un nuevo nodo siguiente al que esta analizando. */
void add_selector(char* selector, int line) {
    unsigned int h = hash(selector);
    Selector_Map_Node* node = selectors_hash_map[h];

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

/* Creador de contenedor de informacion de un nodo de propiedades */
Property_Map_Info* create_property_info(char* property, int line, int child_of) {
    Property_Map_Info* pmi = (Property_Map_Info*) malloc(sizeof(Property_Map_Info));
    pmi->property = strdup(property);
    pmi->frequency = 1;
    pmi->num_lines = 1;
    pmi->lines = (int*) malloc(sizeof(int));
    pmi->lines[0] = line;
    pmi->child_of = child_of;

    return pmi;
}

/* Gestion de adicion de una propiedad al hashmap.
   1. Si no existe colision anade.
   2. Si existe colision, si es igual al almacenado aumenta la frecuencia de aparicion del selector.
   3. Si existe colision, sino es igual crea un nuevo nodo siguiente al que esta analizando. 
   Ademas si se da el caso de que hemos avanzado a otro selector, en caso de que haya colisiones se
   sobreescriben los datos almacenados.*/
void add_property(char* property, int line, int total_selectors_stat, int child_of) {
    unsigned int h = hash(property);
    Property_Map_Node* node = properties_hash_map[h];

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

    Property_Map_Info* pmi = create_property_info(property, line, child_of);
    node = (Property_Map_Node*) malloc(sizeof(Property_Map_Node));
    node->data = pmi;
    node->next = properties_hash_map[h];
    properties_hash_map[h] = node;
}

// Libera memoria de hash maps asociadas a los selectores
void free_selectors_hash_map(Selector_Map_Node** hash_map) {
    for (int i = 0; i < HASH_MAP_SIZE; i++) {
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

// Libera memoria de hash maps asociadas a las propiedades
void free_property_hash_map(Property_Map_Node** hash_map) {
    for (int i = 0; i < HASH_MAP_SIZE; i++) {
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

// Recorre el hashmap de selectores
void analyze_selectors_hash_map(Selector_Map_Node** hash_map) {
    for (int i = 0; i < HASH_MAP_SIZE; i++) {
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

// Recorre el hashmap de propiedades
void analyze_properties_hash_map(Property_Map_Node** hash_map) {
    for (int i = 0; i < HASH_MAP_SIZE; i++) {
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

void yyerror (char const *message) { 
    fprintf (stderr, "%s {%d}\n", message, yylineno);
}

/*CODE*/
int main(){
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