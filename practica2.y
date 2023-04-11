%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #define BASE_STORED_TAGS_SIZE 100
    #define MAX_TAG_NAME_LENGTH 20

    int mallocs = 0;
    int frees = 0;

    void yyerror (char**, int*, int*, char const *);
    void add_tag(char**, int*, const char*);
    void remove_tag(char***, int*);
    char* get_last_tag(char**, int*);
    int compare_closing_tag(char**, int*, const char*);
    void remove_xml_notation(char*);
%}

%union {
    char* type_string;
    char* current_tag;
    char* current_text;
}

%token <type_string> CDATA WS
%token <type_string> XML_HEADER
%token <type_string> OPEN_TAG CLOSE_TAG
%token <type_string> COMMENT
%token <type_string> GT LT EOL
%type <type_string> start_tag
%start xml_file
%parse-param {char** stored_tags} {int* stored_tags_size} {int* line_number}

%%

/* Define la estructura del archivo. */
xml_file: XML_HEADER body
|         body 
                // Error. No hay XML Header
                { char error_msg[] = "Cabecera XML inexistente.";
                yyerror(stored_tags, stored_tags_size, line_number, error_msg); 
                YYABORT; }
|         error
                // Error. XML Header mal construido
                { char error_msg[] = "Cabecera XML mal construída.";
                yyerror(stored_tags, stored_tags_size, line_number, error_msg); 
                YYABORT; }
;

body: body element | /* vacio */ | error 
                { char error_msg[] = "Error en la construccion del archivo.";
                yyerror(stored_tags, stored_tags_size, line_number, error_msg); 
                YYABORT;  };

/* Define la estructura de una etiqueta o comentario */
element: ws start_tag content end_tag ws
|        ws COMMENT
|        error { char error_msg[] = "Error en la construccion del archivo.";
                yyerror(stored_tags, stored_tags_size, line_number, error_msg); 
                YYABORT;  };
;

start_tag: OPEN_TAG
                { char* tag_name = malloc(strlen(yyval.current_tag) * sizeof(char));
                strcpy(tag_name, yyval.current_tag);
                remove_xml_notation(tag_name);
                add_tag(stored_tags, stored_tags_size, tag_name);
                free(tag_name); }
|          LT GT 
                //ERROR NO HAY IDENTIFICADOR DE ETIQUETA
                { char error_msg[] = "No se encontró identificador de la etiqueta.";
                yyerror(stored_tags, stored_tags_size, line_number, error_msg); 
                YYABORT; }
|          error 
                //ERROR IDENTIFICADOR DE ETIQUETA MAL CONSTRUIDO
                { char error_msg[] = "Identificador de etiqueta mal construído.";
                yyerror(stored_tags, stored_tags_size, line_number, error_msg); 
                YYABORT; }
;

end_tag: CLOSE_TAG 
                //ERROR SI LA ETIQUETA DE CIERRE NO CORRESPONDE CON LA QUE ESTA ABIERTA ACTUALMENTE
                { char* tag_name = malloc(strlen(yyval.current_tag) * sizeof(char));
                strcpy(tag_name, yyval.current_tag);
                remove_xml_notation(tag_name);
                if (compare_closing_tag(stored_tags, stored_tags_size, tag_name) != 0){
                    char* error_msg = malloc(300 * sizeof(char));
                    sprintf(error_msg, "Se esperaba </%s> y se encontró </%s>",
                        get_last_tag(stored_tags, stored_tags_size), tag_name);
                    yyerror(stored_tags, stored_tags_size, line_number, error_msg);
                    free(error_msg);
                    free(tag_name);
                    YYABORT; 
                } else {
                    remove_tag(&stored_tags, stored_tags_size);
                    free(tag_name);
                }}
|        LT CDATA GT 
                //ERROR FALTA IDENTIFIADOR
                { char error_msg[] = "No se encontró identificador de la etiqueta.";
                yyerror(stored_tags, stored_tags_size, line_number, error_msg); 
                YYABORT; }
|        LT GT 
                //ERROR FALTA CIERRE Y IDENTIFICADOR
                { char error_msg[] = "Se esperaba cierre te etiqueta xml y no se encontró.";
                yyerror(stored_tags, stored_tags_size, line_number, error_msg); 
                YYABORT; }
|        OPEN_TAG 
                //ERROR NO ES CIERRE DE TAG
                { char error_msg[] = "Se esperaba cierre te etiqueta xml y se encontró etiqueta de apertura.";
                yyerror(stored_tags, stored_tags_size, line_number, error_msg);  
                YYABORT;}
|        error 
                { char error_msg[] = "Cierre de etiqueta mal construído.";
                yyerror(stored_tags, stored_tags_size, line_number, error_msg);  
                YYABORT;}
;

// Acepta cualquier combinacion de " " "\t" "\n"
ws: ws1 ws | /* vacio */;

ws1: WS EOL 
                { *line_number = *line_number + 1; } 
| EOL WS
                { *line_number = *line_number + 1; } 
| EOL 
                { *line_number = *line_number + 1; } 
| WS
| error
                { char error_msg[] = "Error en la construccion del archivo.";
                yyerror(stored_tags, stored_tags_size, line_number, error_msg); 
                YYABORT;  };

// Acepta cualquier combinacion de CDATA y " " "\t" "\n"
tag_content: cdata tag_content | ;

cdata: CDATA
| ws1 tag_content
                { *line_number = *line_number + 1; }
| CDATA cdata
| error
                { char error_msg[] = "Error en la construccion del archivo.";
                yyerror(stored_tags, stored_tags_size, line_number, error_msg); 
                YYABORT;  } ;

content:    cdata
|           element content
|           ws
;

%%

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
        stored_tags = realloc(stored_tags, (*stored_tags_size + 1) *sizeof(char*));
    }
    stored_tags[*stored_tags_size] = malloc(strlen(new_tag)+1);
    strcpy(stored_tags[*stored_tags_size], new_tag);
    *stored_tags_size += 1;
}

/* Elimina el último string añadido al array.
   Elimina la última etiqueta añadida a la pila de etiquetas. */
void remove_tag(char*** stored_tags, int* stored_tags_size) {
    if (*stored_tags_size > 0) {
        (*stored_tags_size)--;
        free((*stored_tags)[*stored_tags_size]);
        (*stored_tags)[*stored_tags_size] = NULL;
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

/* Libera la memoria de la pila de etiquetas y el contador de número de etiquetas añadidas. */
void free_stored_tags (char** stored_tags, int* stored_tags_size) {
    for(int i=0; i < *stored_tags_size; i++){
        free(stored_tags[i]);
    }
    free(stored_tags);
    free(stored_tags_size);
}

int main() {
    char** stored_tags = malloc(BASE_STORED_TAGS_SIZE * sizeof(char*));
    int* stored_tags_size = malloc(sizeof(int));
    *stored_tags_size = 0;
    int* line_number = malloc(sizeof(int));
    *line_number = 1;
    int result = yyparse(stored_tags, stored_tags_size, line_number);
    if (result != 1) {
        printf ("Sintaxis XML correcta.\n");
    }
    free_stored_tags(stored_tags, stored_tags_size);
    return 0;
}

void yyerror (char** stored_tags, int* stored_tags_size, int* line_number,char const *message) { 
    printf("\nSintaxis XML incorrecta. Error en linea %d. %s\n", *line_number, message);
}