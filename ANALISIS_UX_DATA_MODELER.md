# Análisis de User Experience — Data Modeler de OneConnect ECC

## 1. Qué es el "Data Modeler"

El "Data Modeler" es la herramienta con la que un consultor define **entidades**: modelos de datos que exponen tablas SAP (y sus joins/campos) como interfaces/API de OneConnect. No es una aplicación nueva construida desde cero: es una capa de personalización (`Z*`) montada **encima del motor interno de SAP Query / InfoSet** (SQ02/SQVI). Prácticamente toda la lógica de joins, propuesta de campos y selecciones libres es una copia renombrada de function groups estándar de SAP (`SAPLAQJD`, `SAPLAQJD_CNTRL`, mensajes de clase `AQQIS_CNTRL`, estructuras `RS38Q`, `DBSA/DBOB/DBOS/DBJT/DBZT/EXDBFI`, clases `CL_QUERY_JOIN_DATA` / `CL_QUERY_JOIN_PERS`).

Puntos de entrada principales:

| Transacción | Programa | Función |
|---|---|---|
| `ZONT_ONECM` / `ZONT_VARIANT` | `ZONPG_ONECONNECT_CUST_EXE` | Transacción principal ("One Connect Main transaction") |
| (interno) | `ZONFG_OC_CNTRL` | Editor gráfico de joins de tablas (canvas de la entidad) |
| (interno) | `ZONFG_TABLE_CTRL` / `ZONFG_AQJD` | Selección de tablas/joins/campos (motor AQ subyacente) |
| (interno) | `ZONFG_SSEL` | Diálogo de "Filtros" (selecciones libres) |

## 2. Mapa de navegación

```
ZONT_ONECM
 └─ 0100  Lista de entidades / launchpad (CREATE, CHANGE, DELETE, EXECUTE, CLONE, UPLOAD, DOWNLOAD, TRANSPORT, SYNCH…)
     ├─ 0200  Popup "Create business process" (OK/CANCEL)
     ├─ 0300…0380  Editor de entidad (13 pantallas casi duplicadas que simulan un tabstrip:
     │              Main | Tables | Columns, combinadas a mano según botones PB_M/PB_T/PB_C)
     │     ├─ JOIN/COLUMNS → 0500  Selector de joins/columnas (árbol izquierda/derecha)
     │     │        └─ ZONFG_OC_CNTRL 0200  Canvas gráfico de joins (drag&drop)
     │     │              ├─ 0100  Zoom
     │     │              ├─ 0300  Agregar tabla
     │     │              ├─ 0400  Buscar campos
     │     │              └─ 0500  Proponer condiciones de join
     │     │                    (fallback no gráfico: ZONFG_AQJD 0060 / 0069 alias de tabla)
     │     ├─ FILTERS → call_filters_screen → FREE_SELECTIONS_DIALOG (estándar SAP; ZONFG_SSEL 0888/2000 existe pero no está enganchado)
     │     ├─ CODE → 0900  Popup de clase/código ABAP
     │     └─ AUTH_VAL → 0800  Valores de objeto de autorización
     ├─ 0400  Popup de ejecución (síncrona/background)
     ├─ 0600/0602  Upload/Download Excel
     ├─ 0603  Clonar entidad
     ├─ 0700  Selector de columnas (dominio "ANY")
     └─ 1000  Mantenimiento de variantes → 0283 → 0284 → 0285 (atributos anidados 3 niveles)
```

Solo para el módulo principal se cuentan **17 GUI status distintos** (`PF100, PF200, PF283, PF284, PF0285, PF300, PF380, PF400, PF500, PF600, PF601, PF602, PF603, PF700, PF800, PF900, PF1000`), y el editor de una sola entidad ya encadena hasta 4-5 popups modales para una sola acción ("agregar tabla al join" pasa por 0300 → 0500 → 0400 → posible 0069).

## 3. Hallazgos de UX (con evidencia)

### 3.1 Explosión de pantallas en vez de una UI cohesionada
El editor de entidad (pantallas 0300/0310/0320/0330/0340/0350/0360/0370/0380) es, en la práctica, **un tabstrip simulado a mano**: en vez de un único screen con un control TABSTRIP real, hay 13 combinaciones casi idénticas de 3 subscreens (Main=0301, Tables=0302, Columns=0303), elegidas dinámicamente con flags booleanos (`gv_mains/gv_tabless/gv_columnss`) y `PERFORM decide_screen. CALL SCREEN gv_screen.` (`zonpg_oneconnect_cust_exe_pai.prog.abap:191-218`). Esto es frágil (cualquier combinación nueva de pestañas exige otra pantalla dynpro) y da al consultor la sensación de saltar entre "pantallas distintas" en lugar de pestañas de una misma vista.

Un patrón similar se repite en `ZONFG_OC_CNTRL`/`ZONFG_TABLE_CTRL`: desde el canvas único de la pantalla 0200 se abren hasta cuatro popups modales anidados (zoom, agregar tabla, buscar campo, proponer join), cada uno con `CALL SCREEN ... STARTING AT`, típico de herramientas dynpro de los años 90 y con alta carga cognitiva para quien lo percibe como "constructor de entidades/API" y no como el editor técnico de InfoSets que realmente es.

### 3.2 Exposición de conceptos técnicos de bajo nivel al usuario
- Los popups de "agregar tabla" y "proponer join" piden **nombres de tabla ABAP crudos** (`g_dyn_0300-tname`, `RS38Q-DBJOLTAB/DBJORTAB`) con ayuda F4 de diccionario, sin ninguna capa de nombres de negocio.
- La pantalla de búsqueda de campos (0400) expone directamente **dominio, tipo de dato ABAP, longitud de carácter y decimales** como criterios de filtro — vocabulario de diccionario de datos, no de "campos de la entidad".
- El diálogo de "Filtros" (Free Selections) muestra un árbol de campos por tabla/nodo técnico con rangos low/high/sign/option — la misma UX que "Más selecciones" en SE16/SQVI.
- El self-join requiere definir una "alias table" (`RS38Q-DDICTAB/ALIASTAB`) — un concepto de SQL, no de modelado de datos de negocio.

En conjunto, un usuario funcional necesita conocimiento profundo de diccionario ABAP (tablas, dominios, foreign keys) para operar la herramienta.

### 3.3 Feedback y validación inconsistentes
- La validación ocurre casi siempre **al confirmar (PAI), no en línea** mientras el usuario escribe.
- Mensajes de error mezclan tres fuentes distintas: la clase de mensajes propia `ZON_CL_OC` (bien estructurada, con textos como *"Please select an Entity."*, *"You do not have authorization to change/delete."*), la clase estándar `AQQIS_CNTRL` heredada del motor de Query, y **literales hardcodeados** (`MESSAGE 'Target entity already exists' TYPE 'E'.`, `'Field not found in tree'`) que rompen la consistencia y dificultan la traducción.
- En los popups 0100/0300/0400/0500 de `ZONFG_OC_CNTRL`, cancelar dispara `MESSAGE e017(zon_cl_oc) WITH 'Cancelled'`, cuyo texto de clase es literalmente el placeholder sin resolver `&1 &2 &3 &4` — el usuario ve un popup de tipo error con la palabra suelta "Cancelled" en vez de simplemente cerrarse el diálogo.
- Hay un caso de **fallo silencioso**: si el nombre de tabla introducido en "agregar tabla" (0300) no existe en `DD03L`, la rutina de validación simplemente termina sin mensaje (`lzonfg_table_ctrlf01.abap:397-411`) — el usuario no sabe por qué "no pasó nada".
- Un tabstrip de "prioridades" (`priorities_tab`) en la pantalla 0200 de `ZONFG_TABLE_CTRL` permite editar valores en memoria (`MODIFY gt_dd07t FROM gs_dd07t`) pero **no existe ningún guardado real** — parece una función incompleta o abandonada que da la ilusión de edición persistente.
- Se detectaron dos bugs de copy-paste típicos de duplicar function modules estándar sin adaptarlos (`dbft[] = dbpa_input[].` en vez de `dbft_input[]`; `clogsg_input[] = clogsg_input[].` como no-op), que pueden hacer que cambios del usuario no se reflejen sin ningún aviso.

### 3.4 Inconsistencia de marca / idioma
El único punto realmente "re-brandeado" en todo el flujo de joins es el popup de confirmación de salida (*"OneConnect Customizing Tables" / "Finish the customizing of tables?"*); el resto de la experiencia (textos de menú, mensajes de error, incluso el pool de textos multi-idioma) sigue hablando el lenguaje genérico de "InfoSet"/"Query" de SAP, incluyendo **descripciones de pantalla en alemán** en los metadatos de `ZONFG_SSEL` ("Subscreen für Freie Abgrenzungen", "Dummysubscreen ohne freie Abgrenzungen"). Además, el botón "Filtros" del editor de entidad llama directamente a la función estándar `FREE_SELECTIONS_DIALOG` de SAP en lugar de la copia personalizada `ZONFG_SSEL` que existe en el repo — es decir, hay código muerto o una migración a medias, y el usuario final ve el diálogo estándar de SAP sin ninguna adaptación a "OneConnect".

### 3.5 Falta de vista previa / prueba del modelo
En ningún punto del flujo (canvas de joins, selector de columnas, filtros) existe una función de "vista previa" o "probar la entidad" antes de guardar/generar. El único mecanismo de retroalimentación indirecta es ejecutar la entidad completa desde la pantalla 0400 (popup de ejecución), lo cual mezcla "modelar" con "ejecutar en productivo/test" en el mismo flujo.

### 3.6 Aspectos positivos a preservar
- **Auto-propuesta de condiciones de join** a partir de foreign keys y dominios compartidos del diccionario (`ZONFM_RSAQ_CNTRL_SET_STAND_CON` / `DD_TBFK_GET`) — reduce trabajo manual cuando el modelo de datos está bien definido en el diccionario.
- **Confirmaciones de pérdida de datos** al cancelar el canvas de joins en modo edición (`POPUP_TO_CONFIRM_LOSS_OF_DATA`) — único mecanismo real de "red de seguridad" ante cambios no guardados.
- **Control de whitelist** (`ZONFM_RSCHECK_WHITELISTTAB`) que restringe qué tablas/campos pueden exponerse vía el diálogo de selecciones libres — buen control de seguridad, aunque invisible para el usuario (no hay mensaje explicando por qué una tabla no aparece).
- Ayuda F4 en casi todos los campos técnicos (nombre de tabla, dominio, variante), y documentación de campo bajo demanda (menú "Extras → Field documentation", `RSAQWFD_SHOW_FIELD_DOCU`).
- Separación de modo "solo lectura" vs "sistema" en la pantalla 0100 (oculta CREATE/CHANGE/DELETE/GENERATE/UPLOAD para usuarios sin ese rol).

## 4. Recomendaciones priorizadas

**Quick wins (bajo esfuerzo, alto impacto en percepción):**
1. Reemplazar el mensaje `e017(zon_cl_oc) WITH 'Cancelled'` por un simple `LEAVE`/cierre de popup sin mensaje de error.
2. Unificar todos los mensajes hardcodeados (`'Target entity already exists'`, `'Field not found in tree'`, etc.) en la clase de mensajes `ZON_CL_OC`, para consistencia y soporte de traducción.
3. Corregir los dos bugs de copy-paste (`dbft_input[]`, `clogsg_input[] = clogsg[]`) que descartan silenciosamente cambios del usuario.
4. Añadir mensaje explícito cuando una tabla introducida en "agregar tabla" no existe en el diccionario, en vez de fallar en silencio.
5. Enganchar (o eliminar) el `ZONFG_SSEL` personalizado: actualmente el botón "Filtros" llama al diálogo estándar de SAP, dejando una experiencia visualmente inconsistente con el resto de la herramienta.

**Cambios estructurales (mayor esfuerzo, mejoran la experiencia de fondo):**
6. Sustituir las 13 pantallas "tab-simuladas" (0300…0380) por una única pantalla con un control `TABSTRIP` real, reduciendo la duplicación y el riesgo de mantenimiento.
7. Añadir una capa de nombres de negocio (alias) sobre los nombres técnicos de tabla/campo/dominio que ve el usuario en los popups de joins y búsqueda de campos.
8. Incorporar una función de "vista previa"/"probar entidad" (mostrar una muestra de datos resultante del join+filtros) antes de guardar, para dar feedback inmediato sobre si el modelo es correcto.
9. Revisar si la funcionalidad de "prioridades" (`priorities_tab`) en `ZONFG_TABLE_CTRL` debe completarse (persistir cambios) o eliminarse si está abandonada.
10. Evaluar si el flujo de "agregar tabla al join" puede colapsarse (agregar tabla + proponer join + elegir campos en un solo panel) en vez de encadenar 3-5 popups modales por tabla añadida.

## 5. Conclusión

El Data Modeler de OneConnect es funcionalmente potente porque hereda directamente el motor maduro de SAP Query/InfoSet (joins, propuesta automática de condiciones, selecciones libres), pero su UX sufre por ser una superposición cosmética sobre esa herramienta genérica en vez de un rediseño orientado al caso de uso "modelar una entidad de integración". Los mayores frenos a la experiencia son: (a) la fragmentación en decenas de pantallas y popups modales encadenados, (b) la exposición de vocabulario técnico de diccionario ABAP a usuarios funcionales, y (c) la inconsistencia de mensajes/feedback (mezcla de clases de mensaje, literales hardcodeados, fallos silenciosos). Ninguno de estos problemas requiere rehacer el motor subyacente; son ajustables de forma incremental empezando por los "quick wins" de la sección 4.
