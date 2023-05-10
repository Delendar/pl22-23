/*LIBRARIES*/
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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

unsigned long hash_code(const char *str) {
    unsigned long hash = 5381;
    int c;

    while ((c = *str++)) {
        hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
    }

    return hash;
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