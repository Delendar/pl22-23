%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    void yyerror (int*, char const *);

%}
%union {
    float type_real;
    char * type_string;
    char type_char;
}

%token <type_string> TEXT END_OF_FILE
%token <type_string> HEADER_START HEADER_CLOSE VERSION_INFO ENCODING_INFO
%token <type_string> OPEN_TAG CLOSE_TAG
%token <type_string> COMMENT
%token <type_char> GT LT
%start xml_file
%parse-param {int* size}

%%

xml_file: xml_header element
|         element {  }//ERROR NO HAY XML HEADER
|         '(' error ')' 
;

xml_header: HEADER_START VERSION_INFO HEADER_CLOSE 
|           HEADER_START VERSION_INFO ENCODING_INFO HEADER_CLOSE
|           LT GT //ERROR NO HAY XML HEADER
|           '(' error ')' //ERROR XML HEADER MAL CONSTRUIDO
;

element: start_tag content end_tag
|        COMMENT element
;

start_tag: OPEN_TAG 
|          LT GT //ERROR NO HAY IDENTIFICADOR DE ETIQUETA
|          '(' error ')' //ERROR IDENTIFICADOR DE ETIQUETA MAL CONSTRUIDO
;

end_tag: CLOSE_TAG //ERROR SI LA ETIQUETA DE CIERRE NO CORRESPONDE CON
                           // LA QUE ESTA ABIERTA ACTUALMENTE
|        LT '/' GT  //ERROR FALTA IDENTIFIADOR
|        LT GT //ERROR FALTA CIERRE Y IDENTIFICADOR
|        OPEN_TAG //ERROR NO ES CIERRE DE TAG
|        '(' error ')' 
;

content:    TEXT 
|           element content
|           /* vacio */ 
;

%%
/* Cosas que no se tienen en cuenta: 
 - Comentarios mal construidos (2 o más guiones consecutivos dentro de un comentario
 sin ser estos los de finalización de comentario). */

void remove_xml_notation(char* xml_tag_notation) {
    int pos = 0;

    while (xml_tag_notation[pos] != '\0') 
    {
        if (xml_tag_notation[pos] == '<' ||
            xml_tag_notation[pos] == '>' ||
            xml_tag_notation[pos] == '/') 
        {
            
            int newpos = pos;
            while (xml_tag_notation[newpos] != '\0') {
                xml_tag_notation[newpos] = xml_tag_notation[newpos+1];
                newpos++;
            }
        } 
        else pos++;
    }
}

void add_tag(char** stored_tags, int* tags_stored, const char* new_tag) {
    char* stored_tags_update = realloc(stored_tags, (*tags_stored + 1) *sizeof(char*));
    stored_tags_update[*tags_stored] = malloc(strlen(new_tag)+1);
    strcpy(stored_tags_update[*tags_stored], new_tag);
    *tags_stored += 1;
}

void remove_tag(char** stored_tags, int* tags_stored) {
    char* stored_tags_update = realloc(stored_tags, (*tags_stored - 1) *sizeof(char*));
    free(stored_tags[*tags_stored]);
    *tags_stored -= 1;
}

char* get_last_tag(char** stored_tags, int* tags_stored) {
    return stored_tags[*tags_stored -1];
}

int compare_closing_tag(char** stored_tags, int* tags_stored, const char* tag_to_compare) {
    return strcmp(get_last_tag(stored_tags, tags_stored), tag_to_compare);
}

void free_stored_tags (char** stored_tags, int* tags_stored) {
    for(int i=0; i < *tags_stored; i++){
        free(stored_tags[i]);
    }
    free(stored_tags);
    free(tags_stored);
}

void test_tag(char** stored_tags, int* tags_stored) {
    add_tag(stored_tags, tags_stored, "tag1");
    //printf("%d \n",*tags_stored);
}

int main() {
    char** stored_tags;
    printf("RIP");
    int* tags_stored = malloc(sizeof(int));
    *tags_stored = 0; 
    test_tag(stored_tags, tags_stored);
    printf("%s\n", get_last_tag(stored_tags, tags_stored));
    yyparse(tags_stored);
    free_stored_tags(stored_tags, tags_stored);
    //printf ("Sintaxis XML correcta.\n");
    return 0;
}

void yyerror (int* size, char const *message) { 
    printf("\nSintaxis XML incorrecta. %d . %s\n", *size, message);
    //fprintf (stderr, "%s\n", message);
}