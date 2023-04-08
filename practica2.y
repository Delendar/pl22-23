%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #define BASE_STORED_TAGS_SIZE 10
    #define MAX_TAG_NAME_LENGTH 20

    void yyerror (char**, int*, char const *);
    void add_tag(char**, int*, const char*);
    void remove_tag(char**, int*);
    char* get_last_tag(char**, int*);
    int compare_closing_tag(char**, int*, const char*);
    void remove_xml_notation(char*);
%}
%union {
    float type_real;
    char* type_string;
    char* current_tag;
}

%token <type_string> TEXT
%token <type_string> HEADER_START HEADER_CLOSE VERSION_INFO ENCODING_INFO
%token <type_string> OPEN_TAG CLOSE_TAG
%token <type_string> COMMENT
%token <type_string> GT LT
%type <type_string> start_tag
%start xml_file
%parse-param {char** stored_tags} {int* tags_stored}

%%

xml_file: xml_header element
|         element //ERROR NO HAY XML HEADER
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
                    { char* tag_name = malloc(strlen(yyval.current_tag) * sizeof(char)); 
                      strcpy(tag_name, yyval.current_tag);
                      remove_xml_notation(tag_name);
                      add_tag(stored_tags, tags_stored, tag_name); 
                      free(tag_name);}
|          LT GT //ERROR NO HAY IDENTIFICADOR DE ETIQUETA
|          '(' error ')' //ERROR IDENTIFICADOR DE ETIQUETA MAL CONSTRUIDO
;

end_tag: CLOSE_TAG { char* tag_name = malloc(strlen(yyval.current_tag) * sizeof(char));
                     strcpy(tag_name, yyval.current_tag);
                     remove_xml_notation(tag_name);
                     printf("PreCOmpare\n");
                     if (compare_closing_tag(stored_tags, tags_stored, tag_name) == 1){
                        printf("PostCOmpare\n");
                        char* error_msg = malloc(300 * sizeof(char));
                        printf("PostMalloc\n");
                        strcpy(error_msg, "Sintaxis incorrecta. Se esperaba </");
                        strcat(error_msg, get_last_tag(stored_tags,tags_stored));
                        strcat(error_msg, "> y se encontro </");
                        strcat(error_msg, tag_name);
                        strcat(error_msg, ">");
                        yyerror(stored_tags, tags_stored, error_msg);
                        free(error_msg);
                     }
                     free(tag_name);}
                    //ERROR SI LA ETIQUETA DE CIERRE NO CORRESPONDE CON
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
    if (*tags_stored >= BASE_STORED_TAGS_SIZE) {
        stored_tags = realloc(stored_tags, (*tags_stored + 1) *sizeof(char*));
    } 
    stored_tags[*tags_stored] = malloc(strlen(new_tag)+1);
    strcpy(stored_tags[*tags_stored], new_tag);
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

// Devuelve 0 si la etiqueta cierra correctamente la etiqueta abierta actualmente
int compare_closing_tag(char** stored_tags, int* tags_stored, const char* tag_to_compare) {
    return strcmp(get_last_tag(stored_tags, tags_stored), tag_to_compare);
}

void free_stored_tags (char** stored_tags, int* tags_stored) {
    printf("PreLoop\n");
    for(int i=0; i < *tags_stored; i++){
        free(stored_tags[i]);
    }
    printf("POSTLoop\n");
    free(stored_tags);
    printf("POSTListp\n");
    free(tags_stored);
}

void test_tag(char** stored_tags, int* tags_stored) {
    add_tag(stored_tags, tags_stored, "tag1");
    printf("%d \n",*tags_stored);
    printf("%s \n", get_last_tag(stored_tags, tags_stored));
    printf("IS SAME %d \n", compare_closing_tag(stored_tags, tags_stored, "tag1"));
    add_tag(stored_tags, tags_stored, "tag2");
    printf("%d \n",*tags_stored);
    printf("%s \n", get_last_tag(stored_tags, tags_stored));
    printf("IS SAME %d \n", compare_closing_tag(stored_tags, tags_stored, "tag1"));
    remove_tag(stored_tags, tags_stored);
    printf("%d \n",*tags_stored);
    printf("%s \n", get_last_tag(stored_tags, tags_stored));
    printf("IS SAME %d \n", compare_closing_tag(stored_tags, tags_stored, "tag1"));
}

int main() {
    char** stored_tags = malloc(BASE_STORED_TAGS_SIZE * sizeof(char*));
    int* tags_stored = malloc(sizeof(int));
    *tags_stored = 0; 
    //test_tag(stored_tags, tags_stored);
    yyparse(stored_tags, tags_stored);
    free_stored_tags(stored_tags, tags_stored);
    //printf ("Sintaxis XML correcta.\n");
    return 0;
}

void yyerror (char** stored_tags, int* tags_stored, char const *message) { 
    printf("\nSintaxis XML incorrecta. %d . %s\n", *tags_stored, message);
    //fprintf (stderr, "%s\n", message);
}