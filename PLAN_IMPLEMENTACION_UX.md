# Plan de Implementación — Mejoras UX del Data Modeler

> Documento técnico que detalla el **cómo** de cada mejora propuesta en el análisis de UX
> (`ANALISIS_UX_DATA_MODELER.md`). Para cada ítem: objetos afectados, cambio concreto,
> pasos, riesgo y validación. Los tiempos estimados están en el documento ejecutivo (Word).

## Convenciones

- **Rama de trabajo:** `claude/data-modeler-ux-analysis-h0cqt0`
- **Despliegue a SAP:** vía abapGit (pull sobre el paquete Z correspondiente).
- **Orden recomendado:** completar toda la Fase 1 antes de arrancar la Fase 2.
- Cada ítem debería ir en su propia **orden de transporte (TR)** para poder transportar
  de forma independiente a QA/PRD.

---

# FASE 1 — Quick wins

## Ítem 1 — Corregir el mensaje "Cancelled" mal formado

**Problema:** al cancelar los popups 0100/0300/0400/0500 de `ZONFG_OC_CNTRL`, se dispara
`MESSAGE e017(zon_cl_oc) WITH 'Cancelled'`, cuyo texto es el placeholder `&1 &2 &3 &4`.
El usuario ve un popup de error con la palabra suelta "Cancelled".

**Objetos afectados:**
- `zonfg_oc_cntrl.fugr.*` — módulos PAI de los popups (buscar `MESSAGE e017`).
- (Verificar) `zon_cl_oc.msag.xml` — mensaje 017.

**Cambio concreto:**
1. Localizar cada `MESSAGE e017(zon_cl_oc) WITH 'Cancelled'` en el function group.
2. Reemplazar por una salida limpia del popup sin mensaje de error:
   - Sustituir por `LEAVE TO SCREEN 0.` (o `SET SCREEN 0. LEAVE SCREEN.`) según el flujo,
     eliminando el `MESSAGE`.
   - Si se requiere señalizar la cancelación al llamador, usar la excepción `cancelled`
     que ya está comentada arriba de cada llamada (`RAISE cancelled`) en vez de un mensaje.

**Riesgo:** Bajo. Cambio local en el manejo de `CANCEL`.

**Validación:** abrir cada popup (add table, search, propose join, scale) y pulsar Cancelar;
confirmar que el diálogo se cierra sin popup de error.

---

## Ítem 2 — Unificar mensajes hardcodeados en la clase `ZON_CL_OC`

**Problema:** hay literales de texto embebidos en el código, inconsistentes con la clase de
mensajes y no traducibles.

**Ubicaciones confirmadas (`zonpg_oneconnect_cust_exe_f01.prog.abap`):**
- Línea 8595: `MESSAGE 'Select the table for which you want to find the desired field.' TYPE 'I'.`
- Línea 8618: `MESSAGE 'Field not found in tree' TYPE 'I'.`
- Línea 9822: `MESSAGE 'Target entity already exists' TYPE 'E'.`
- Línea 9846: `MESSAGE 'Entity copied successfully' TYPE 'S'.`
- Línea 8533 (comentada): `MESSAGE 'An error occurred during search.' TYPE 'E'.`

**Cambio concreto:**
1. En `ZON_CL_OC` (SE91 / `zon_cl_oc.msag.xml`) crear nuevos números de mensaje, p.ej.:
   - `050` "Select the table for which you want to find the desired field."
   - `051` "Field not found in tree."
   - `052` "Target entity already exists."  (nota: ya existe `124` con texto similar — reutilizar si aplica)
   - `053` "Entity copied successfully."
2. Reemplazar cada literal por `MESSAGE i050(zon_cl_oc).` / `e052(zon_cl_oc).` / etc.
3. Cargar las traducciones (ES/EN) de los nuevos mensajes vía SE91 → Goto → Translation.

**Riesgo:** Bajo. Solo cambia el origen del texto, no la lógica.

**Validación:** disparar cada mensaje (búsqueda de campo sin selección, copiar clase con
entidad existente, etc.) y verificar el texto y que aparece en el idioma de logon.

---

## Ítem 3 — Corregir bugs de copy-paste en el motor de joins (ALTO)

**Problema:** dos asignaciones incorrectas heredadas de duplicar FMs estándar; pueden
descartar cambios del usuario sin aviso.

**Ubicaciones confirmadas:**
- `zonfg_aqjd.fugr.zonfm_rsaq_dj_define_aliastab.abap:57`
  → `dbft[] = dbpa_input[].`  (copia la tabla equivocada como fuente)
- `zonfg_aqjd.fugr.zonfm_rsaq_dj_define_join.abap:100`
  → `clogsg_input[] = clogsg_input[].`  (auto-asignación / no-op; no devuelve `clogsg[]`)

**Cambio concreto:**
1. En `zonfm_rsaq_dj_define_aliastab.abap:57`, revisar la interfaz del FM:
   - Si existe un parámetro `dbft_input`, corregir a `dbft[] = dbft_input[].`
   - Si NO existe `dbft_input`, comparar contra el FM estándar `RSAQ_DJ_DEFINE_ALIASTAB`
     de SAP para determinar el origen correcto de `dbft[]`.
2. En `zonfm_rsaq_dj_define_join.abap:100`, cambiar la asignación de retorno a:
   - `clogsg_input[] = clogsg[].`  (devolver la tabla de trabajo al parámetro de salida,
     igual que las líneas vecinas `dbpa_input[] = dbpa[].`).

> **IMPORTANTE:** comparar ambos FM contra sus equivalentes estándar de SAP (`SAPLAQJD`)
> antes de modificar, para confirmar el patrón correcto de marshalling de tablas.

**Riesgo:** Medio (toca el motor de joins). Mitigar con pruebas de regresión en self-joins
y joins con condición manual.

**Validación:** crear una entidad con self-join (alias table), definir condiciones de join
manualmente, guardar, reabrir y confirmar que las condiciones/alias persisten.

---

## Ítem 4 — Mensaje de error al introducir una tabla inexistente

**Problema:** si el nombre de tabla en el popup 0300 no existe en `DD03L`, la rutina de
validación termina en silencio y el usuario no recibe feedback.

**Ubicación:** `zonfg_table_ctrl.fugr.lzonfg_table_ctrlf01.abap:397-411`
(rutina `check_for_table_addition_0300`).

**Cambio concreto:**
1. En el `SELECT SINGLE tabname FROM dd03l ... WHERE tabname = g_dyn_0300-tname`, agregar
   el manejo del caso `sy-subrc <> 0`:
   ```abap
   IF sy-subrc <> 0.
     MESSAGE e0NN(zon_cl_oc) WITH g_dyn_0300-tname.  " "Table &1 does not exist."
     RETURN.  " o mantener el foco en el campo
   ENDIF.
   ```
2. Crear el mensaje correspondiente en `ZON_CL_OC` (ej. "La tabla &1 no existe en el
   diccionario.").

**Riesgo:** Bajo.

**Validación:** en "agregar tabla", escribir un nombre inexistente (ej. `ZZZNOEXISTE`) y
confirmar que aparece el mensaje de error en vez de "no pasa nada".

---

## Ítem 5 — Enganchar o eliminar la copia personalizada de `ZONFG_SSEL`

**Problema:** el botón "Filtros" (`FILTERS` → `call_filters_screen` →
`show_filter_options_new`) llama directamente a la FM estándar `FREE_SELECTIONS_DIALOG`
de SAP, dejando la copia propia `ZONFG_SSEL` como código muerto o migración a medias. El
usuario ve un diálogo estándar de SAP (con textos en alemán) inconsistente con el resto.

**Objetos afectados:**
- `zoncl_oc_customizing.clas.abap` — método `show_filter_options_new` (llamada a
  `FREE_SELECTIONS_DIALOG`, ~líneas 2723 y 3134).
- `zonfg_ssel.fugr.*` — la copia personalizada.

**Decisión previa (requiere negocio/arquitectura):**
- **Opción A — Eliminar:** si nunca se usará la copia, borrar `ZONFG_SSEL` del repo/paquete
  y documentar que el filtro usa el diálogo estándar. Menor esfuerzo, menor consistencia.
- **Opción B — Enganchar (recomendada para consistencia):** redirigir `show_filter_options_new`
  para que llame a la función propia de `ZONFG_SSEL` en vez de `FREE_SELECTIONS_DIALOG`, y
  traducir/rebrandear sus textos (quitar los alemanes).

**Cambio concreto (Opción B):**
1. Identificar en `ZONFG_SSEL` la FM equivalente a `FREE_SELECTIONS_DIALOG`.
2. Cambiar la llamada en `zoncl_oc_customizing.clas.abap` para invocar esa FM.
3. Traducir los textos de pantalla (0888/2000/2001/2002/3000) de alemán a ES/EN.
4. Verificar que los parámetros de entrada/salida (`RSDS_TWHERE`/`RSDS_TRANGE`) se mapean igual.

**Riesgo:** Medio. Cambia el motor del diálogo de filtros. Requiere decisión de negocio.

**Validación:** definir filtros en una entidad, guardar en `ZONTA_OC_FRANGES`/`ZONTA_OC_FILTERS`,
reabrir y confirmar que se conservan; confirmar que la UI está en el idioma correcto.

---

# FASE 2 — Cambios estructurales

## Ítem 6 — Sustituir las 13 pantallas "tab-simuladas" por un TABSTRIP real

**Problema:** el editor de entidad usa 13 combinaciones de subscreens (0300…0380) elegidas
con flags booleanos y `decide_screen`/`CALL SCREEN`, en vez de un control TABSTRIP.

**Objetos afectados:**
- `zonpg_oneconnect_cust_exe.prog.screen_0300..0380.abap` (flow logic).
- `zonpg_oneconnect_cust_exe_pai.prog.abap:191-218` (`decide_screen`, toggles
  `gv_mains/gv_tabless/gv_columnss`).
- `zonpg_oneconnect_cust_exe_pbo.prog.abap` (status PF300/PF380).

**Cambio concreto:**
1. Crear **una** pantalla contenedora (ej. 0390) con un control `TABSTRIP` de 3 pestañas:
   Main / Tables / Columns.
2. Reutilizar los subscreens existentes 0301 (Main), 0302 (Tables ALV), 0303 (Columns ALV)
   como áreas de subscreen dentro de cada pestaña del tabstrip.
3. Manejar el cambio de pestaña con el mecanismo estándar de tabstrip
   (`sy-ucomm` = código de pestaña + `g_tab-activetab`), eliminando `decide_screen` y los
   flags booleanos.
4. Migrar el GUI status (PF300/PF380) a la nueva pantalla.
5. Repuntar todas las navegaciones que hacían `CALL SCREEN 0300/0310/.../0380` hacia 0390.
6. Deprecar (dejar sin uso) las pantallas 0300..0380 tras validar.

**Riesgo:** Alto. Rediseño de la pantalla principal del editor. Requiere pruebas completas de
crear/cambiar/mostrar entidad en todos los modos (display/change, tipo relations/class).

**Validación:** recorrer crear, editar y mostrar una entidad completa, alternando pestañas;
confirmar que ALVs de tablas/columnas y el guardado siguen funcionando.

---

## Ítem 7 — Capa de alias de negocio sobre nombres técnicos

**Problema:** el usuario ve nombres de tabla/campo/dominio ABAP crudos; falta una capa de
nombres de negocio.

**Objetos afectados:**
- Popups de `ZONFG_OC_CNTRL` (add table 0300, search 0400, propose join 0500).
- `ZONFG_TABLE_CTRL` (búsqueda de campos).
- Nueva tabla Z de mapeo técnico → negocio.

**Cambio concreto:**
1. Crear tabla Z (ej. `ZONTA_OC_ALIAS`) con: nombre técnico (tabla/campo), alias de negocio,
   descripción, idioma.
2. En los popups, mostrar el alias/descripcion junto al nombre técnico (columna adicional o
   texto descriptivo debajo del campo). Aprovechar los textos DDIC (`DD02T`, `DD03T`) como
   default cuando no haya alias configurado.
3. En las ayudas F4, enriquecer la lista con la descripción de negocio.
4. (Opcional) Pantalla de mantenimiento del catálogo de alias (SM30/vista de tabla).

**Riesgo:** Alto (transversal a varios popups). Empezar por mostrar descripciones DDIC
(quick win dentro del ítem) antes del catálogo de alias personalizado.

**Validación:** en add table / search fields, confirmar que se muestran descripciones legibles
junto a los nombres técnicos.

---

## Ítem 8 — Función de "vista previa / probar entidad" antes de guardar

**Problema:** no hay forma de previsualizar el resultado de un modelo sin ejecutarlo completo.

**Objetos afectados:**
- `zonpg_oneconnect_cust_exe_f01.prog.abap` (lógica de ejecución/JSON, clase `go_json`).
- Nueva pantalla/popup de preview.

**Cambio concreto:**
1. Agregar un botón "Vista previa" (ej. `PREVIEW`) al GUI status del editor.
2. Al pulsarlo, ejecutar la consulta del modelo con un **límite de filas** (`UP TO n ROWS`,
   ej. 50) sin enviar a endpoint ni escribir logs.
3. Mostrar el resultado en un ALV o en el visor JSON existente
   (`ZONFG_JSON_VIEWER` / `ZONFM_OC_JSON_DISPLAY`).
4. Reutilizar `go_json->get_relation` en un modo "dry-run" (sin `iv_dest`, sin commit).

**Riesgo:** Alto (toca la ruta de ejecución). Aislar el modo preview para que nunca envíe
datos a un endpoint real.

**Validación:** modelar una entidad, pulsar Vista previa, confirmar que muestra una muestra
de datos/JSON sin generar log ni enviar al endpoint.

---

## Ítem 9 — Resolver la funcionalidad "prioridades"

**Problema:** el tabstrip `priorities_tab` (pantalla 0200 de `ZONFG_TABLE_CTRL`) permite
editar en memoria (`MODIFY gt_dd07t FROM gs_dd07t`) pero no persiste; función incompleta.

**Objetos afectados:**
- `zonfg_table_ctrl.fugr.lzonfg_table_ctrlf02.abap:15-19` (carga desde `DD07T`, idioma fijo `EN`).
- `zonfg_table_ctrl.fugr.lzonfg_table_ctrli06.abap:9-16` (`modify_table_control`).

**Decisión previa (requiere negocio):** ¿la función debe existir?
- **Si NO:** eliminar el table control y su lógica (limpieza).
- **Si SÍ:** implementar la persistencia y corregir el idioma fijo.

**Cambio concreto (si se conserva):**
1. Reemplazar el `SELECT ... ddlanguage = 'EN'` por `sy-langu`.
2. Agregar guardado real de los valores editados a una tabla Z (no a `DD07T`, que es estándar).
3. Cargar los valores guardados al abrir la pantalla.

**Riesgo:** Bajo.

**Validación:** editar prioridades, guardar, reabrir y confirmar persistencia; o confirmar
que la sección desapareció si se elige eliminar.

---

## Ítem 10 — Colapsar el flujo de agregar tabla + join + campos

**Problema:** agregar una tabla al modelo encadena hasta 4-5 popups modales
(0300 add table → 0500 propose join → 0400 search fields → 0069 alias). Incluye también
el paso extra de la pantalla 1000 (Guardar Variante/Ejecutar) detectado en revisión.

**Objetos afectados:**
- `ZONFG_OC_CNTRL` (popups 0300/0400/0500).
- `zonpg_oneconnect_cust_exe_pai.prog.abap` (pantalla 1000 y navegación de ejecución).

**Cambio concreto:**
1. **Sub-tarea 10a (rápida):** fusionar la pantalla 1000 en la pantalla 0400. Mover los
   comandos `SAVE` (Guardar Variante → `PERFORM save_variant`) y `EXECUTE` al GUI status de
   0400, y enrutar `EXECUTE` directo a la selección front/back/preview, eliminando el salto
   por 1000. (Ninguna acción de la 1000 depende de un campo exclusivo — verificado.)
2. **Sub-tarea 10b (mayor):** rediseñar el flujo de "agregar tabla" para que en un solo panel
   se pueda: elegir tabla, ver/ajustar la propuesta automática de join y seleccionar campos,
   en vez de tres popups secuenciales. Apoyarse en el canvas gráfico existente (0200) con
   paneles laterales en lugar de popups `STARTING AT`.

**Riesgo:** Alto (10b). La sub-tarea 10a es de bajo riesgo y puede adelantarse como quick win.

**Validación:** agregar una tabla nueva a una entidad con el flujo reducido; confirmar que la
propuesta de join y la selección de campos siguen funcionando; para 10a, confirmar que Guardar
Variante y Ejecutar funcionan desde la pantalla 0400.

---

# Resumen de dependencias y orden sugerido

1. **Fase 1 primero** (ítems 1→5), en este orden: 3 (bug de datos, prioridad), luego 1, 4, 2, 5.
2. **Fase 2** tras aprobar alcance:
   - Adelantar **10a** (fusionar pantalla 1000) como quick win temprano.
   - 9 (decisión rápida).
   - 6 (TABSTRIP) y 8 (preview) en paralelo si hay 2 desarrolladores.
   - 7 (alias) y 10b (flujo agregar tabla) al final, por ser los más transversales.

# Consideraciones transversales

- **Transportes:** un TR por ítem para transporte independiente a QA/PRD.
- **Traducciones:** todo texto nuevo debe traducirse (mínimo ES/EN) en SE91/SE63.
- **Pruebas de regresión:** priorizar el motor de joins (ítem 3) y la ruta de ejecución (ítem 8).
- **Despliegue:** los cambios llegan a SAP vía abapGit (pull sobre el paquete Z del proyecto).
