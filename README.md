# Analizador de CSS
El objetivo es cerear mediante la ayuda de FLEX y BISON un analizador de CSS que permita recopilar información sobre las modificaciones que aplica el archivo CSS.

Estadísticas:
- [ ] Validador CSS.
- [ ] Número de comentarios.
- [ ] Número de elementos que se modifican.
- [ ] Número de id's que se modifican.
- [ ] Número de clases y subclases que se modifican.
- [ ] Número de atributos totales.
  - [ ] Número de veces que aparece un atributo.
  - [ ] Número de valores en pixeles.
  - [ ] Número de valores en porcentajes.
  - [ ] Número de color en formato HTML.
  - [ ] Numero de atributos !important.
- [ ] ¿Número de llamadas a funciones?

```css
/* Comentario */

p { /* Elemento */ }

#id { /* ID */ }

.clase { /* Clase */ }

.clase.subclase { /* Subclase */ }

element:pseudoclass { /* Pseudo clases */ }

element::pseudoelement { /* Pseudo elemento */ }

p .sub-elemento { }

.clase .sub-elemento { }

.clase.subclase .sub-elemento {  }

p, h1, h2, .clase, .clase.subclase { /* Multiples selectores. */ }

div {
  color: red;
  font: arial;
  font-size: 14px;
}
```

```html
<div class="clase">
  <div class="elemento">
  </div>
</div>
<div class="elemento">
</div>
```

## A tener en cuenta en la gramática:

OPKEY -> {      CLKEY -> }

Elemento: NOMBRE OPKEY ATRIBUTOS CLKEY

Identificador: ASTERISCO NOMBRE OPKEY ATRIBUTOS CLKEY

Clase: DOT NOMBRE OPKEY ATRIBUTOS CLKEY

Subclase: DOT nombre DOT nombre OPKEY ATRIBUTOS CLKEY

## Regexps:

```
/.*/ -> coment
{ -> atributos open
} -> atributos close
[a-zA-Z-_]*: -> nombre atributo
[a-zA-z0-9-_]*; -> valor atributo (MIRAR ESTO)
[0-9]*px; -> valor atributo (MIRAR ESTO)
 -> color html
"." -> clase
 \t -> space
\n -> eol
; -> eos
!important -> importante
```