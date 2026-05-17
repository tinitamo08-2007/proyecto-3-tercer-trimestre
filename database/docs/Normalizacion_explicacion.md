# Proceso de Normalización – Granja Digital

Este documento explica paso a paso cómo se ha pasado de una tabla "todo en uno"
hasta el modelo final del proyecto, que está en **3ª Forma Normal (3FN)**.

Acompaña al diagrama visual `diagrama_normalizacion.png` / `.svg`.

---

## Punto de partida: tabla sin normalizar

Imagina que recogemos toda la información del día en una sola hoja de cálculo
con columnas como:

```
id_actividad | fecha | hora | tipo | descripción
nombre_empleado | rol | telefono
LISTA_DE_ANIMALES   (varios aretes en la misma celda)
especie | raza | estado_salud | ubicación
```

Una fila de ejemplo sería:

```
7 ; 2026-05-10 ; 06:30 ; ORDENIE ; "matutino" ;
"Juan Pérez" ; peón ; 655234567 ;
"ARETE-001, ARETE-002" ;
vaca ; Holstein ; buena ; Corral 1
```

**Problemas evidentes:**

-  La columna `LISTA_DE_ANIMALES` mete varios valores en una sola celda
  (grupo repetitivo). Eso ya rompe la 1FN.
-  Los datos del empleado y del animal se repiten en cada actividad
  → redundancia y riesgo de inconsistencias (si cambia un teléfono hay que
  cambiarlo en muchas filas).

---

## Paso 1 · Primera Forma Normal (1FN)

> **Regla 1FN:** todos los atributos deben ser **atómicos**. No se admiten
> listas, conjuntos ni grupos repetitivos dentro de una misma celda. Además,
> cada fila debe poder identificarse de forma única.

**Qué hacemos:**

Separamos la lista de animales en filas individuales. Una fila por cada
animal en cada actividad.

```
id_act | fecha       | hora  | tipo    | empleado    | rol  | id_animal | especie | raza      | salud
   7   | 2026-05-10  | 06:30 | ORDENIE | Juan Pérez  | peón |     1     | vaca    | Holstein  | buena
   7   | 2026-05-10  | 06:30 | ORDENIE | Juan Pérez  | peón |     2     | vaca    | Pirenaica | buena
   8   | 2026-05-10  | 08:00 | ALIMENT | Juan Pérez  | peón |     1     | vaca    | Holstein  | buena
```

**Qué hemos ganado:**

- Cada celda contiene un único valor.
- Ya se puede definir una clave primaria: `(id_act, id_animal)`.

**Qué problemas siguen ahí:**

-  "Juan Pérez" y "peón" se repiten en cada animal de cada actividad.
-  "Holstein" se repite por cada actividad en la que aparece la vaca 1.

---

## Paso 2 · Segunda Forma Normal (2FN)

> **Regla 2FN:** estando ya en 1FN, todos los atributos **no clave** deben
> depender de la **PK completa**, no solo de una parte de ella.

**El análisis:**

La PK de la tabla anterior es `(id_act, id_animal)`. Pero:

- `especie`, `raza`, `salud` dependen **solo de `id_animal`** (la vaca 1 es
  Holstein, sin importar la actividad).
- `fecha`, `hora`, `tipo`, `empleado` dependen **solo de `id_act`** (la
  actividad 7 ocurrió a las 06:30, sin importar el animal).

Eso es **dependencia parcial** y rompe la 2FN.

**Qué hacemos:**

Dividimos en tres tablas:

```
actividad (id, fecha, hora, tipo, descripción, nombre_empleado, rol)
   - aún tiene los datos del empleado mezclados, lo arreglamos en el paso 3

animal (id, especie, raza, identificador, estado_salud, ubicación, estado)

actividad_animal (id_actividad, id_animal)
   - solo claves, materializa la relación N:M
```

**Qué hemos ganado:**

-  El animal vive en su propia tabla; ya no se repiten sus datos.
-  La tabla intermedia resuelve elegantemente la relación N:M.

**Qué sigue mal:**

-  Los datos del empleado (`nombre_empleado`, `rol`) siguen mezclados
  dentro de `actividad`. Si Juan Pérez cambia de rol hay que actualizar
  todas sus actividades.

---

## Paso 3 · Tercera Forma Normal (3FN)

> **Regla 3FN:** estando ya en 2FN, ningún atributo **no clave** puede
> depender **transitivamente** de la PK. Es decir, no puede pasar que
> `PK → atributo_no_clave_A → atributo_no_clave_B`.

**El análisis:**

En la tabla `actividad`, el `nombre_empleado` y el `rol` no dependen de
`id_actividad`. Dependen del propio empleado (`id_empleado → nombre, rol`).
Hay dependencia transitiva → viola la 3FN.

**Qué hacemos:**

Extraemos los datos del empleado a su propia tabla y dejamos solo la FK
en `actividad`:

```
empleado (id, nombre, rol, telefono, fecha_contratación)

actividad (id, fecha, hora, tipo, descripción, id_empleado)
   - ahora id_empleado es FK a empleado.id

animal           → sin cambios (ya estaba bien desde 2FN)
actividad_animal → sin cambios
```

**Resultado final:**

-  4 tablas independientes.
-  Cada dato vive en un único sitio.
-  Sin redundancias.
-  Cambiar un teléfono o un rol se hace en una sola fila.

Este es el modelo definitivo del proyecto, el que se ve en el diagrama
relacional y en el script SQL de creación.

---

## ¿Por qué pararse en 3FN y no seguir a BCNF/4FN?

Para un dominio tan pequeño como este (4 tablas) la 3FN ya elimina todas
las redundancias importantes. Llegar a BCNF, 4FN o 5FN tendría sentido
en modelos con dependencias funcionales o multivaluadas complicadas
que aquí no aparecen. Subir de nivel sin necesidad **dispara el número
de tablas** y obliga a hacer más JOINs en cada consulta, lo cual penaliza
el rendimiento sin aportar nada.

## Resumen visual del proceso

| Estado            | Tablas resultantes                                                  | Forma alcanzada |
|-------------------|---------------------------------------------------------------------|-----------------|
| Tabla "todo en uno" | 1 tabla con listas y datos repetidos                              | 0FN             |
| Paso 1            | 1 tabla con valores atómicos                                        | 1FN             |
| Paso 2            | actividad · animal · actividad_animal                               | 2FN             |
| Paso 3 (final)    | empleado · actividad · animal · actividad_animal                    | **3FN ✓**       |
