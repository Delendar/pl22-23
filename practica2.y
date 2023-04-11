%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #define BASE_STORED_TAGS_SIZE 100
    #define MAX_TAG_NAME_LENGTH 20

    void yyerror (char**, int*, char const *);
    void add_tag(char**, int*, const char*);
    void remove_tag(char***, int*);
    char* get_last_tag(char**, int*);
    int compare_closing_tag(char**, int*, const char*);
    void remove_xml_notation(char*);
    void printStrings(char**, int);
%}
%union {
    float type_real;
    char* type_string;
    char* current_tag;
}

%token <type_string> CDATA VF
%token <type_string> XML_HEADER HEADER_START HEADER_CLOSE VERSION_INFO ENCODING_INFO
%token <type_string> OPEN_TAG CLOSE_TAG
%token <type_string> COMMENT
%token <type_string> GT LT
%type <type_string> start_tag
%start xml_file
%parse-param {char** stored_tags} {int* stored_tags_size}

%%

xml_file: XML_HEADER element { printf("{xml_file}\n");}
|         element //ERROR NO HAY XML HEADER
                { char error_msg[] = "Sintaxis XML incorrecta, cabecera XML mal construída.";
                yyerror(stored_tags, stored_tags_size, error_msg); 
                YYABORT; }
|         '(' error ')' 
                { char error_msg[] = "Sintaxis XML incorrecta, XML mal construído.";
                yyerror(stored_tags, stored_tags_size, error_msg); 
                YYABORT; }
;
/*
xml_header: HEADER_START VERSION_INFO HEADER_CLOSE 
|           HEADER_START VERSION_INFO ENCODING_INFO HEADER_CLOSE
|           LT GT  //ERROR NO HAY XML HEADER
                { char error_msg[] = "Sintaxis XML incorrecta, la cabecera XML está vacía.";
                yyerror(stored_tags, stored_tags_size, error_msg); 
                YYABORT; }
|           '(' error ')' //ERROR XML HEADER MAL CONSTRUIDO
                { char error_msg[] = "Sintaxis XML incorrecta, la cabecera XML está mal construída.";
                yyerror(stored_tags, stored_tags_size, error_msg); 
                YYABORT; }
;*/

element: vf start_tag content end_tag vf 
|        vf COMMENT element
;

start_tag: OPEN_TAG
                { char* tag_name = malloc(strlen(yyval.current_tag) * sizeof(char)); 
        //printf("\n\t\t\t\t\t\t\t\t\t\t +Malloc tag name\n");
                strcpy(tag_name, yyval.current_tag);
                remove_xml_notation(tag_name);
                printf("\topen_tag3\n");
                add_tag(stored_tags, stored_tags_size, tag_name); 
                printf("\topen_tag4\n");
        //printf("\n\t\t\t\t\t\t\t\t\t\t -Free tag name\n");
                free(tag_name); }
|          LT GT //ERROR NO HAY IDENTIFICADOR DE ETIQUETA
                { char error_msg[] = "Sintaxis XML incorrecta, no se encontró identificador de la etiqueta.";
                yyerror(stored_tags, stored_tags_size, error_msg); 
                YYABORT; }
|          '(' error ')' //ERROR IDENTIFICADOR DE ETIQUETA MAL CONSTRUIDO
                { char error_msg[] = "Sintaxis XML incorrecta, identificador de etiqueta mal construído.";
                yyerror(stored_tags, stored_tags_size, error_msg); 
                YYABORT; }
;

end_tag: CLOSE_TAG //ERROR SI LA ETIQUETA DE CIERRE NO CORRESPONDE CON LA QUE ESTA ABIERTA ACTUALMENTE
                { char* tag_name = malloc(strlen(yyval.current_tag) * sizeof(char));
                printf("\tclose_tag1\n");
                strcpy(tag_name, yyval.current_tag);
                remove_xml_notation(tag_name);
                if (compare_closing_tag(stored_tags, stored_tags_size, tag_name) != 0){
                    char* error_msg = malloc(300 * sizeof(char));
                    sprintf(error_msg, 
                        "Sintaxis incorrecta. Se esperaba </%s> y se encontró </%s>", 
                        get_last_tag(stored_tags, stored_tags_size), tag_name);
                    yyerror(stored_tags, stored_tags_size, error_msg);
                    free(error_msg); 
                    free(tag_name);
                    YYABORT; 
                } else {
                    remove_tag(&stored_tags, stored_tags_size);
                    free(tag_name);
                    printf("\tclose_tag2\n");
                }}
/* |       CLOSE_TAG element
                { char* tag_name = malloc(strlen(yyval.current_tag) * sizeof(char));
                strcpy(tag_name, yyval.current_tag);
                remove_xml_notation(tag_name);
                if (compare_closing_tag(stored_tags, stored_tags_size, tag_name) != 0){
                    char* error_msg = malloc(300 * sizeof(char));
                    sprintf(error_msg, 
                        "Sintaxis incorrecta. Se esperaba </%s> y se encontró </%s>", 
                        get_last_tag(stored_tags, stored_tags_size), tag_name);
                    yyerror(stored_tags, stored_tags_size, error_msg);
                    free(error_msg); 
                    free(tag_name);
                    YYABORT; 
                } else {
                    remove_tag(&stored_tags, stored_tags_size);
                    free(tag_name);
                }} */
|        LT '/' GT //ERROR FALTA IDENTIFIADOR
                { char error_msg[] = "Sintaxis XML incorrecta, no se encontró identificador de la etiqueta.";
                yyerror(stored_tags, stored_tags_size, error_msg); 
                YYABORT; }
|        LT GT //ERROR FALTA CIERRE Y IDENTIFICADOR
                { char error_msg[] = "Sintaxis XML incorrecta, se esperaba cierre te etiqueta xml y no se encontró.";
                yyerror(stored_tags, stored_tags_size, error_msg); 
                YYABORT; }
|        OPEN_TAG //ERROR NO ES CIERRE DE TAG
                { char error_msg[] = "Sintaxis XML incorrecta, se esperaba cierre te etiqueta xml y se encontró etiqueta de apertura.";
                yyerror(stored_tags, stored_tags_size, error_msg);  
                YYABORT;}
|        '(' error ')' 
                { char error_msg[] = "Sintaxis XML incorrecta, cierre de etiqueta mal construído.";
                yyerror(stored_tags, stored_tags_size, error_msg);  
                YYABORT;}
;

vf: VF | /* vacio */;

content:    CDATA 
|           element content
|           vf /* vacio */
;

%%
/* Cosas que no se tienen en cuenta: 
 - Comentarios mal construidos (2 o más guiones consecutivos dentro de un comentario
 sin ser estos los de finalización de comentario). 
 
 - Solo reconoce xmls con 1 tag padre. */

/* Elimina los caracteres '<' '>' y '/' de las tags XML para poder almacenarlas y compararlas. */
void remove_xml_notation(char* xml_tag_notation) {
    int pos = 0;

    while (xml_tag_notation[pos] != '\0') {
        if (xml_tag_notation[pos] == '<' ||
            xml_tag_notation[pos] == '>' ||
            xml_tag_notation[pos] == '/') {
            
            int newpos = pos;
            while (xml_tag_notation[newpos] != '\0') {
                xml_tag_notation[newpos] = xml_tag_notation[newpos+1];
                newpos++;
            }
        } 
        else pos++;
    }
}

/* Añade un string a un array de strings. 
   Añade una etiqueta a la pila de etiquetas. */
void add_tag(char** stored_tags, int* stored_tags_size, const char* new_tag) {
    if (*stored_tags_size >= BASE_STORED_TAGS_SIZE) {
        printf("\n\t\t\t\t\t\t\t\t\t\t +Realloc array");
        stored_tags = realloc(stored_tags, (*stored_tags_size + 1) *sizeof(char*));
    }
    printf("\t\tadd_tag\n");
    stored_tags[*stored_tags_size] = malloc(strlen(new_tag)+1);
    printf("\t\tadd_tag2\n");
    strcpy(stored_tags[*stored_tags_size], new_tag);
    //printStrings(stored_tags, *stored_tags_size);
    *stored_tags_size += 1;
}

/* Elimina el último string añadido al array.
   Elimina la última etiqueta añadida a la pila de etiquetas. */
void remove_tag(char*** stored_tags, int* stored_tags_size) {
    if (*stored_tags_size > 0) {
        (*stored_tags_size)--;
        free((*stored_tags)[*stored_tags_size]);
        (*stored_tags)[*stored_tags_size] = NULL;
        //*stored_tags = realloc(*stored_tags, (*stored_tags_size) * sizeof(char *));
    }
}

/* Recupera el último string añadido a un array de strings.
   Recupera la última etiqueta añadida a la pila. */
char* get_last_tag(char** stored_tags, int* stored_tags_size) {
    return stored_tags[*stored_tags_size -1];
}

/* Devuelve 0 si el string pasado por parámtero es igual último string del array. 
   Devuelve 0 si la etiqueta cierra correctamente la etiqueta abierta actualmente. */
int compare_closing_tag(char** stored_tags, int* stored_tags_size, const char* tag_to_compare) {
    int closes = strcmp(get_last_tag(stored_tags, stored_tags_size), tag_to_compare);
    return closes;
}

void printStrings(char **stringArray, int numStrings) {
    for (int i = 0; i < numStrings; i++) {
        printf(" %s : ", stringArray[i]);
    }
}

/* Libera la memoria de la pila de etiquetas y el contador de número de etiquetas añadidas. */
void free_stored_tags (char** stored_tags, int* stored_tags_size) {
    for(int i=0; i < *stored_tags_size; i++){
        //printf("\n\t\t\t\t\t\t\t\t\t\t +Free post parser\n");
        free(stored_tags[i]);
    }
    //printf("\n\t\t\t\t\t\t\t\t\t\t +Free post parser\n");
    free(stored_tags_size);
}

int main() {
    //printf("\n\t\t\t\t\t\t\t\t\t\t +Malloc pre parser \n");
    char** stored_tags = malloc(BASE_STORED_TAGS_SIZE * sizeof(char*));
    //printf("\n\t\t\t\t\t\t\t\t\t\t +Malloc pre parser\n");
    int* stored_tags_size = malloc(sizeof(int));
    *stored_tags_size = 0; 
    int result = yyparse(stored_tags, stored_tags_size);
    if (result != 1) {
        printf ("Sintaxis XML correcta.\n");
    }
    free_stored_tags(stored_tags, stored_tags_size);
    return 0;
}

void yyerror (char** stored_tags, int* stored_tags_size, char const *message) { 
    printf("\nSintaxis XML incorrecta. %d . %s\n", *stored_tags_size, message);
    //fprintf (stderr, "%s\n", message);
}