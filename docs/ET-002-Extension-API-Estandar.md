# ET-002 — Extender una API estándar de SAP sin tocarla

> **Estado: borrador.** Las secciones marcadas con 🔎 esperan la verificación contra documentación de SAP que está en curso. El resto es estable.
>
> Documento hermano de `ET-001` y del `RUNBOOK-reconstruccion.md`. Mismo formato: pasos ejecutables y trampas señaladas en el paso donde muerden.

---

## 1. Qué demuestra este escenario, y por qué importa más que el primero

| | PoC-1 (terminado) | PoC-2 (este) |
|---|---|---|
| Pregunta que responde | *¿Sé construir una API nueva?* | *¿Sé **extender** una API estándar de SAP sin tocarla?* |
| Objeto de negocio | Propio (`ZCX_CUSTOMER`) | **Estándar** (Business Partner / Cliente) |
| Tabla | Propia (`ZCXTA_CUSTOMERS`) | **Estándar**, extendida con un campo propio |
| API | Propia (`ZAPI_CUSTOMER`, OData V4) | **Estándar** (OData V2) |
| Código ABAP | Tabla + CDS + BDEF + clase | **Ninguno** |

**Por qué el segundo vale más para Cemex:** la mayoría de las interfaces de PI/PO que hay que migrar no van contra tablas propias, van contra objetos estándar. El PoC-1 demuestra el patrón; el PoC-2 demuestra que el patrón sirve para el caso real.

Y hay un segundo argumento, el de verdad importante para la conversación de clean core: **este escenario no añade código que mantener**. Lo que se construye es configuración declarativa que sobrevive a los upgrades.

---

## 2. La corrección de partida

La idea inicial era *"crear una CDS que lea `KNA1`, añadir un campo Z a `KNA1`, y actualizarlo por la API estándar"*. Esa ruta tiene dos problemas, y conviene entenderlos antes de empezar porque explican el diseño de todo lo demás.

### 2.1 En S/4HANA, `KNA1` ya no es el maestro de clientes

El objeto líder es el **Business Partner**. `KNA1` se sigue llenando por compatibilidad con el código que la lee, pero quien manda es el BP y sus roles.

**Consecuencia:** un campo añadido a `KNA1` con un *append structure* queda fuera del alcance de la API estándar. Se podría escribir con código propio, que es exactamente lo que este PoC quiere evitar.

### 2.2 Leer `KNA1` desde una CDS propia no es clean core

`KNA1` es una tabla, no una API liberada. Lo limpio es consumir las vistas CDS liberadas.

**Y esto no hay que creérselo: se comprueba.** Si el paquete se crea con versión de lenguaje `ABAP for Cloud Development`, el compilador rechaza el acceso a lo no liberado y acepta la vista liberada. El sistema responde la pregunta de clean core por sí solo, sin depender del criterio de nadie.

> Ésta es la diferencia práctica más útil que se le puede enseñar a un cliente: **clean core deja de ser una opinión y pasa a ser un error de sintaxis.**

---

## 3. Los tres caminos 🔎

*(Pendiente de confirmar la nomenclatura oficial de los niveles de extensibilidad.)*

| Enfoque | Nivel | Clean core | Código |
|---|---|---|---|
| **A.** Campo con la app de campos propios, expuesto por la API estándar | Key user | ✅ El más limpio | Ninguno |
| **B.** CDS propia sobre vistas liberadas + objeto RAP propio | Developer extensibility | ✅ Si solo consume APIs liberadas | ABAP propio, aislado |
| **C.** Append structure sobre `KNA1` + CDS leyendo `KNA1` | Clásico | ❌ | ABAP acoplado al estándar |

El PoC-1 está en **B**. Este PoC-2 va por **A**. El camino **C** se documenta solo para poder explicar por qué se descarta.

---

## 4. 🔎 Crear el campo propio

*(Pendiente: nombre exacto de la app, contexto de negocio del cliente, prefijo del campo, y requisitos de acceso.)*

---

## 5. 🔎 Habilitar el campo en la API estándar

*(Pendiente: el paso exacto de propagación al `$metadata`. Es el punto crítico de todo el escenario.)*

---

## 6. 🔎 Activar y publicar la API estándar

*(Pendiente: transacción, patrón de URL y EntitySet.)*

---

## 7. Lo que se reaprovecha del PoC-1

Esta es la parte barata, y conviene decirlo en la presentación: **la mitad de BTP ya está montada y no se toca.**

| Componente | Estado | Qué cambia |
|---|---|---|
| Cloud Connector | ✅ Operativo | Nada. El mapeo `s4h-poc.virtual:50000` ya llega al sistema |
| Recurso en el Cloud Connector | ⚠️ Ampliar | Hay que añadir la ruta de la API estándar, que cuelga de `/sap/opu/odata` y no de `/sap/opu/odata4` |
| API Management, runtime | ✅ Operativo | Nada |
| API Provider `S4H_POC_PROVIDER` | ✅ Reutilizable | Nada: apunta al host virtual, no a una ruta concreta |
| API Proxy | ➕ Nuevo | Uno nuevo, con su propio base path |
| Colección de Postman | ➕ Ampliar | Carpeta nueva para el escenario estándar |

> **Trampa anticipada — el recurso del Cloud Connector.** La API estándar es OData **V2** y cuelga de **`/sap/opu/odata`**, mientras que el PoC-1 usa **`/sap/opu/odata4`**. El recurso declarado hoy **no cubre** la ruta nueva: hay que añadir una segunda entrada en `Resources`, también con política `Path and All Sub-Paths`. Si se omite, todas las llamadas devuelven **403** aunque el túnel esté verde — es la trampa 11 del runbook repitiéndose en una ruta distinta.

---

## 8. 🔎 Consumo desde Postman

*(Pendiente: verbo de actualización, semántica de CSRF en OData V2 y nombre del campo en el JSON.)*

Lo que **sí** se sabe ya, por el PoC-1:

- `Accept-Encoding: gzip, deflate` — el gateway de API Management **no soporta Brotli**
- El token CSRF va atado a la cookie de sesión, y Postman la mantiene sola mientras no se cambie de pestaña
- `Body → raw → JSON`, nunca `Text`, o el servicio responde **415**
- La URL del proxy se copia del campo `API Proxy URL` de su pantalla de detalle, nunca se compone a mano

> **Una diferencia que juega a favor.** El *condition string* que SAP publica para propagar el token CSRF a través de API Management cubre `POST`, `PUT` y `DELETE` pero **omite `PATCH`**. En el PoC-1 eso era una trampa, porque OData V4 actualiza con `PATCH`. Aquí, al ser OData V2, el ejemplo oficial encaja sin modificarlo — **si** se confirma que el verbo de actualización es `MERGE` o `PUT`. 🔎

---

## 9. Criterios de aceptación

El PoC-2 está demostrado cuando:

1. El campo propio aparece en el `$metadata` de la **API estándar**, sin haber escrito una línea de ABAP.
2. Un `GET` desde Postman **a través de BTP** devuelve un cliente existente con el campo nuevo.
3. Una actualización desde Postman **a través de BTP** cambia el valor del campo propio **sin tocar ningún otro dato del cliente**.
4. El cambio se verifica en el sistema, sobre el maestro estándar.
5. En ningún momento se ha modificado un objeto SAP ni se ha añadido un *append structure*.

El punto **5 es el entregable real.** Los otros cuatro demuestran que funciona; el quinto demuestra que es sostenible.

---

## 10. Riesgos conocidos antes de empezar

| Riesgo | Por qué | Cómo se comprueba antes de perder tiempo |
|---|---|---|
| El Fiori Launchpad no está operativo | La app de campos propios es Fiori; un appliance de demostración puede no traerlo configurado | Intentar abrir el launchpad antes de planificar nada 🔎 |
| El usuario no tiene el rol de extensibilidad | `BPINST` tiene autorización de desarrollo, que no es lo mismo | 🔎 |
| La API estándar no está activada | Es un paso aparte de todo lo demás | 🔎 |
| Escribir sobre un cliente existente tiene validaciones | Un `PATCH` parcial puede chocar con campos obligatorios de un rol de BP | 🔎 |
| El sistema es de pruebas y se da de baja | Ya pasó una vez en este proyecto | Exportar la configuración del Cloud Connector (`Backup`) y mantener este documento al día |
