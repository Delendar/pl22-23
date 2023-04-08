%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    void yyerror (char**, int*, char const *);
    void add_tag (char**, int*, const char*);
    void remove_tag(char**, int*);
    char* get_last_tag(char**, int*);
    int compare_closing_tag(char** , int*, const char*);
    void free_stored_tags (char**, int*);

%}
%union {
    float type_real;
    char * type_string;
    char type_char;
}

%parse-param {char** stored_tag_names} {int* stored_tags_size}
%token TEXT COMMENT
%token <type_string> NAME VERSION_DECL ENCODING_DECL ENCODING_ID TAG_NAME NUM_START_WORD
%token <type_real> VERSION_NUM
%token <type_char> GT LT SLASH QUEST EQ
%token end_of_file
%type <type_string> start_tag
%type <type_string> end_tag
%start xml_file

%%

xml_file: xml_header element end_of_file
|         element end_of_file 
        { yyerror(stored_tag_names, stored_tags_size, "Falta la cabecera XML."); 
        return 1; 
        }
;

xml_header: LT QUEST NAME version_info QUEST GT
|           LT QUEST NAME version_info encoding_info QUEST GT
;

version_info: VERSION_DECL EQ VERSION_NUM 

encoding_info: ENCODING_DECL EQ ENCODING_ID

element: start_tag content end_tag

start_tag: LT TAG_NAME GT 
                { add_tag(stored_tag_names, stored_tags_size, $2); }
|          LT NUM_START_WORD GT 
                { yyerror(stored_tag_names, stored_tags_size, "Los identificadores de etiquetas deben empezar por una letra.");
                return 1; }
|          LT GT 
                { yyerror(stored_tag_names, stored_tags_size, "No se encontró el identificador de la etiqueta."); 
                return 1; }

end_tag: LT SLASH NAME GT  {
        $$ = $3;
        char* end_tag_name;
        strcpy(end_tag_name, $$);
        if  (compare_closing_tag(stored_tag_names, stored_tags_size, end_tag_name) == 0) {
            remove_tag(stored_tag_names, stored_tags_size);
        }
        else {
            char* start_tag_name;
            strcpy(start_tag_name, get_last_tag(stored_tag_names, stored_tags_size));
            char result[100];

            strcpy(result, "Encontrado </");
            strcat(result, end_tag_name);
            strcat(result, " y se esperaba </");
            strcat(result, start_tag_name);
            strcat(result, ">.");
            yyerror(stored_tag_names, stored_tags_size, result);
            return 1;
        };
    };

content:    TEXT 
|           COMMENT
|           element
;

%%

void add_tag(char** tag_names, int* tag_names_size, const char* new_tag_name) {
    char* tag_names_update = realloc(tag_names, (*tag_names_size + 1) *sizeof(char*));
    tag_names_update[*tag_names_size] = malloc(strlen(new_tag_name)+1);
    strcpy(tag_names_update[*tag_names_size], new_tag_name);
    *tag_names_size += 1;
}

void remove_tag(char** tag_names, int* tag_names_size) {
    char* tag_names_update = realloc(tag_names, (*tag_names_size - 1) *sizeof(char*));
    free(tag_names[*tag_names_size]);
    *tag_names_size -= 1;
}

char* get_last_tag(char** tag_names, int* tag_names_size) {
    return tag_names[*tag_names_size -1];
}

int compare_closing_tag(char** tag_names, int* tag_names_size, const char* tag_to_compare) {
    return strcmp(get_last_tag(tag_names, tag_names_size), tag_to_compare);
}

void free_stored_tags (char** tag_names, int* tag_names_size) {
    for(int i=0; i < *tag_names_size; i++){
        free(tag_names[i]);
    }
    free(tag_names);
    free(tag_names_size);
}

int main() {
    char ** stored_tag_names;
    int * stored_tags_size;
    *stored_tags_size = 0;
    int result = yyparse(stored_tag_names, stored_tags_size);
    if (result == 0) {
        printf ("Sintaxis XML correcta.\n");
    }
    free_stored_tags(stored_tag_names, stored_tags_size);
    return 0;
}

void yyerror (char** stored_tag_names, int* stored_tags_size, char const *message) { 
    printf("Sintaxis XML incorrecta. ");
    fprintf (stderr, "%s\n", message);
    free_stored_tags(stored_tag_names, stored_tags_size); 
}