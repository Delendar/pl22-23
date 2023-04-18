# Analizador de CSS
El objetivo es cerear mediante la ayuda de FLEX y BISON un analizador de CSS que permita recopilar información sobre las modificaciones que aplica el archivo CSS.

Estadísticas:
- Validador CSS.
- Número de comentarios.
- Número de elementos que se modifican.
- Número de id's que se modifican.
- Número de clases y subclases que se modifican.
- Número de atributos totales.
  - Número de veces que aparece un atributo.

```css
/* Comentario */

p { /* Elemento */ }

#id { /* ID */ }

.clase { /* Clase */ }

.clase.subclase { /* Clase y subclase */ }

div {
  color: red;
  font: arial;
  font-size: 14px;
}
```