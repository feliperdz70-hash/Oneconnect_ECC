# Runbook de reconstrucción — PoC API OData sobre S/4HANA

**Contexto:** el appliance S/4HANA 2025 original fue dado de baja. Este documento recoge lo que sigue en pie, lo que hay que rehacer y en qué orden, con las trampas ya identificadas señaladas en el paso donde aparecen.

Sistema destino: **SAP S/4HANA 2023**. Nada del patrón cambia respecto a 2025.

---

## 0. Punto de partida

### Lo que NO hay que repetir

| Activo | Estado |
|---|---|
| Cloud Connector instalado (Temurin 21 + sapcc 2.19.1) | ✅ En el portátil |
| Subcuenta `POC-CAL` registrada | ✅ `US East (VA) - Azure` → `cf.us21` |
| Subcuenta `trial` registrada | ✅ `US East (VA) - AWS` → `cf.us10` |
| Trial: Integration Suite suscrito | ✅ Plan `trial` |
| Trial: API Management activo | ✅ `API Modelling` + `Developer Hub` en `Active` |
| Trial: role collections asignados | ✅ `APIPortal.Administrator`, `APIManagement.SelfService.Administrator`, `AuthGroup.API.Admin` |
| Colección de Postman | ✅ `docs/postman/` — solo cambia `backend_url` |
| Especificación ET-001 | ✅ `docs/ET-001-PoC-CDS-RAP-BTP-Postman.md` |

### Lo que depende de terceros

| Pendiente | De quién |
|---|---|
| Entitlement de Integration Suite en `POC-CAL` | Ayax Morales |

La PoC avanza por el **trial** mientras tanto. Replicar en `POC-CAL` después es mecánico.

### Nombres de objetos

| Objeto | Nombre |
|---|---|
| Paquete | `Z001` *(o el que se decida en el sistema nuevo)* |
| Tabla | `ZCXTA_CUSTOMERS` |
| CDS raíz | `ZCX_CUSTOMER` |
| Behavior definition | `ZCX_CUSTOMER` |
| Clase de comportamiento | `ZBP_CX_CUSTOMER` |
| Service definition | `ZAPI_CUSTOMER` |
| Service binding | `ZAPI_CUSTOMER_O4` |
| Entity set expuesto | `Customer` |

---

## Bloque A — Reconocer el servidor nuevo

- [ ] **A1.** SAP GUI → menú `Sistema` → `Status`. Anotar release y SP.
- [ ] **A2.** Transacción **`SMICM`** → `Pasar a` → `Servicios`. **Anotar los puertos HTTP y HTTPS reales.**
- [ ] **A3.** Anotar host o IP, mandante y usuario de desarrollo.
- [ ] **A4.** Si está en Azure: **abrir el puerto en el Network Security Group**.
- [ ] **A5.** Probar desde el navegador, con el protocolo explícito:

```
http://<host>:<puerto_http>/sap/bc/ping?sap-client=<mandante>
```

> **Trampa 1 — el puerto.** No se asume. En el appliance anterior el HTTP era `50000` y el HTTPS `44300`, que no es el patrón habitual (`80NN` / `443NN`). Sale de `SMICM`, no de la intuición.
>
> **Trampa 2 — el NSG de Azure.** El ICM puede estar escuchando y aun así no llegar desde fuera. Costó media mañana la primera vez.
>
> **Trampa 3 — el protocolo.** Escribir la URL sin `http://` hace que Chrome asuma HTTP contra un puerto TLS, y devuelve *"se ha restablecido la conexión"*, que parece un problema de red y no lo es.

**Datos a rellenar antes de seguir:**

| Dato | Valor |
|---|---|
| Host / IP | |
| Puerto HTTP | |
| Puerto HTTPS | |
| Mandante | |
| Usuario de desarrollo | |

---

## Bloque B — Objetos ABAP en ADT

- [ ] **B1.** Crear el proyecto ABAP en Eclipse contra el servidor nuevo.

### B2. El paquete

- [ ] Crear paquete de desarrollo.

| Campo | Valor |
|---|---|
| Name | `ZPOC_API_MIG` |
| Description | `PoC migración interfaces PI/PO a APIs` |
| **Package Type** | **`Development`** |
| **Superpackage** | **vacío** |
| Software Component | `HOME` |
| Transport Layer | La de cliente del sistema, **no `SAP`** |
| ABAP Language Version | `Standard ABAP` *(ver nota)* |

> **Trampa 4 — el tipo de paquete.** El asistente de ADT y el de SE21 crean **`Structure Package`** por defecto, y el tipo **no se puede cambiar después**. Un paquete de estructura no admite objetos: la vista CDS fallará con *"Structure packages cannot contain development objects"*, y el error no menciona el paquete.
>
> En el asistente de SE21 el campo está en la **tercera pantalla** (`Additional properties`), no en la primera.
>
> **Trampa 5 — el superpaquete.** Debe quedar vacío. Un paquete sin padre solo puede ser de estructura en algunos sistemas; si el desplegable sale en gris fijado en `Structure`, hay que crear la jerarquía `estructura → principal → desarrollo`, o usar un paquete de desarrollo existente.

> **Nota sobre clean core.** Poner `ABAP for Cloud Development` haría que el compilador rechace cualquier objeto no liberado — es lo correcto para un blueprint. Pero hay que decidirlo **al crear el paquete**: cambiarlo después obliga a recompilar todo. Si se quiere avanzar sin riesgo, `Standard ABAP` y se migra luego, asumiendo que hasta entonces el desarrollo queda en extensibilidad clásica.

### B3. Tabla `ZCXTA_CUSTOMERS`

- [ ] `New` → `Other ABAP Repository Object` → `Dictionary` → `Database Table`

```abap
@EndUserText.label : 'PoC - Clientes cargados vía API'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zcxta_customers {
  key mandt : mandt not null;
  key kunnr : kunnr not null;
  ort01     : ort01;
  regio     : regio;
  land1     : land1;
  poliza    : abap.char(10);
}
```

`Ctrl+F3`.

### B4. CDS `ZCX_CUSTOMER`

- [ ] `New` → `Other ABAP Repository Object` → `Core Data Services` → `Data Definition` → plantilla **`defineRootViewEntity`**

```abap
@EndUserText.label: 'PoC - Clientes cargados vía API'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZCX_CUSTOMER
  as select from zcxta_customers
{
      @EndUserText.label: 'Número de cliente'
  key kunnr as Customer,

      @EndUserText.label: 'Ciudad'
      ort01 as CityName,

      @EndUserText.label: 'Región / Estado'
      regio as Region,

      @EndUserText.label: 'País'
      land1 as Country,

      @EndUserText.label: 'Póliza'
      poliza as PolicyNumber
}
```

`Ctrl+F3`. Luego `Data Preview`: debe abrir **sin registros y sin error**. Vacío es el resultado correcto.

> **Trampa 6 — falta `root`.** La plantilla por defecto es `defineViewEntity`, que genera `define view entity` **sin** `root`. Sin esa palabra, la behavior definition del paso siguiente no activa nunca. Si ya se creó sin ella, se añade a mano y se reactiva.
>
> **Trampa 7 — la projection view.** No se crea. El documento expone la vista base directamente. Crear una *projection view* sin su *behavior projection* da el error *"Transactional Projection View must be part of a business object"*, que despista mucho.

### B5. Behavior definition `ZCX_CUSTOMER`

- [ ] Clic derecho sobre la CDS → `New Behavior Definition` → Implementation Type **`Managed`**

```abap
managed implementation in class zbp_cx_customer unique;
strict ( 2 );

define behavior for ZCX_CUSTOMER alias Customer
persistent table zcxta_customers
lock master
authorization master ( global )
{
  create;
  update;
  delete;

  field ( mandatory : create ) Customer;
  field ( readonly : update )  Customer;

  mapping for zcxta_customers
    {
      Customer     = kunnr;
      CityName     = ort01;
      Region       = regio;
      Country      = land1;
      PolicyNumber = poliza;
    }
}
```

`Ctrl+F3` → **dará error de clase inexistente. Es lo esperado.**

> Si `strict ( 2 )` diera problema en este release, bajar a `strict ( 1 )`.

### B6. Clase `ZBP_CX_CUSTOMER`

- [ ] Cursor sobre `zbp_cx_customer` en la primera línea → `Ctrl+1` → `Create behavior implementation class`

> **Trampa 8 — `Ctrl+1` no hace nada.** El quick fix solo aparece sobre un error ya marcado. Hay que **guardar (`Ctrl+S`) e intentar activar (`Ctrl+F3`) primero**; si `Problems` muestra `0 items`, no hay nada que corregir y por eso no ofrece opciones.
>
> **Alternativa que siempre funciona:** crear la clase a mano con `New` → `ABAP Class` y pegar el código de abajo.

**Clase global** — se deja así:

```abap
CLASS zbp_cx_customer DEFINITION PUBLIC ABSTRACT FINAL
  FOR BEHAVIOR OF zcx_customer.
ENDCLASS.

CLASS zbp_cx_customer IMPLEMENTATION.
ENDCLASS.
```

**Pestaña `Local Types`** — aquí va la lógica:

```abap
CLASS lhc_customer DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Customer
      RESULT result.
ENDCLASS.

CLASS lhc_customer IMPLEMENTATION.
  METHOD get_global_authorizations.
    " PoC: se conceden todas las operaciones al usuario del servicio.
    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.
    IF requested_authorizations-%update = if_abap_behv=>mk-on.
      result-%update = if_abap_behv=>auth-allowed.
    ENDIF.
    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      result-%delete = if_abap_behv=>auth-allowed.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
```

- [ ] `Ctrl+F3` sobre la clase.
- [ ] Volver a la behavior definition y `Ctrl+F3`. **Ahora sí debe activar.**

### B7. Service definition `ZAPI_CUSTOMER`

- [ ] Clic derecho sobre la CDS → `New Service Definition`

```abap
@EndUserText.label: 'PoC - API transaccional de clientes'
define service ZAPI_CUSTOMER {
  expose ZCX_CUSTOMER as Customer;
}
```

### B8. Service binding `ZAPI_CUSTOMER_O4`

- [ ] Clic derecho sobre la service definition → `New Service Binding`

| Campo | Valor |
|---|---|
| Name | `ZAPI_CUSTOMER_O4` |
| **Binding Type** | **`OData V4 - Web API`** |
| Service Definition | `ZAPI_CUSTOMER` |

- [ ] `Ctrl+F3` y botón **`Publish`**.
- [ ] **B9.** Desplegar la entidad `Customer` en el árbol del editor. Deben aparecer **Create, Update y Delete**.

> Si solo aparece *Read*, el binding se publicó antes de activar la behavior definition. Volver a pulsar `Publish`.

- [ ] **B10.** Copiar la **`Service URL`** que muestra el editor.

**URL a rellenar:**

```
________________________________________________________
```

---

## Bloque C — ICF

- [ ] **C1.** Transacción **`SICF`** → *Hierarchy Type* `SERVICE` → `F8` → navegar a `default_host` → `sap` → `opu` → **`odata4`**.
- [ ] Verificar que está **activo** (negro, no gris). Si no: clic derecho → `Activar servicio`, incluyendo subnodos.

> Sin este nodo activo, todo devuelve **404** aunque el binding esté publicado.

---

## Bloque D — Validación F2: Postman contra el backend directo

Sea `BASE` la Service URL del paso B10.

- [ ] **D1.** Postman → `Settings` → `General` → **`SSL certificate verification` → OFF**.

> Solo necesario si se va por HTTPS. El certificado del appliance es autofirmado y Postman lo rechaza sin dar un motivo claro.

- [ ] **D2.** Metadatos

```http
GET {BASE}/$metadata?sap-client=<mandante>
Authorization: Basic <usuario:contraseña>
```

Esperado: **200** + EDMX con la entidad `Customer` y los cinco campos.

- [ ] **D3.** Token CSRF

```http
GET {BASE}/?sap-client=<mandante>
Authorization: Basic <usuario:contraseña>
X-CSRF-Token: Fetch
```

De la respuesta, pestaña **`Headers`**, copiar **`X-CSRF-Token`**.

- [ ] **D4.** Alta

```http
POST {BASE}/Customer?sap-client=<mandante>
Authorization: Basic <usuario:contraseña>
X-CSRF-Token: <token de D3>
Content-Type: application/json

{
  "Customer": "0000001000",
  "CityName": "Monterrey",
  "Region": "NLE",
  "Country": "MX",
  "PolicyNumber": "POL0000001"
}
```

Esperado: **201 Created**.

- [ ] **D5.** Consulta

```http
GET {BASE}/Customer?sap-client=<mandante>
```

- [ ] **D6.** **Actualización — el paso que quedó pendiente**

```http
PATCH {BASE}/Customer('0000001000')?sap-client=<mandante>
Authorization: Basic <usuario:contraseña>
X-CSRF-Token: <token de D3>
Content-Type: application/json

{ "PolicyNumber": "POL9999999" }
```

Esperado: **200** o **204 No Content**.

- [ ] **D7.** Verificar en SAP: **`SE16N`** sobre `ZCXTA_CUSTOMERS`. El campo `poliza` debe mostrar el valor nuevo.

> **Trampa 9 — el token CSRF.** Va ligado a la cookie de sesión. D3 y D4 deben ejecutarse seguidos y en la misma pestaña de Postman. Si pasa mucho tiempo, repetir D3.
>
> **Trampa 10 — la conversión ALPHA.** `KUNNR` es CHAR(10) y se graba literalmente lo que se envía. Mandar `"1000"` crea un registro distinto de `"0000001000"`. En las lecturas por clave hay que usar el formato interno, con ceros a la izquierda.

**Con D7 verificado, la parte SAP está demostrada: lectura, alta y actualización.**

---

## Bloque E — Cloud Connector

- [ ] **E1.** Abrir `https://localhost:8443`. Verificar que `S4H-PoC-API` y `BTP-Trial-PoC` están en **`Connected`**.

> El servicio arranca con Windows, pero tarda. Si está caído, todo lo de abajo falla y parece error de configuración.

- [ ] **E2.** Seleccionar **`BTP-Trial-PoC`** → `Cloud to On-Premises` → `ACCESS CONTROL`.
- [ ] Borrar el mapeo antiguo que apunta a `20.237.117.22` y crear uno nuevo:

| Pantalla | Campo | Valor |
|---|---|---|
| 1 | Back-End Type | `ABAP System` |
| 2 | Protocol | `HTTP` + `Use TLS` solo si se va por HTTPS |
| 3 | Internal Host / Port | *(host y puerto del bloque A)* |
| 4 | Virtual Host / Port | `s4h-poc.virtual` / *(mismo puerto)* |
| 5 | Principal Type | `None` |
| 6 | System ID | *(SID del sistema nuevo)* |
| 7 | Host in Request Header | `Use Virtual Host` |

- [ ] **E3.** Con la fila seleccionada, panel **`Resources`** → `+`

| Campo | Valor |
|---|---|
| URL Path | `/sap/opu/odata4` |
| **Access Policy** | **`Path and All Sub-Paths`** |

> **Trampa 11 — el recurso.** Es el olvido número uno. Con `Resources (0)` toda petición devuelve **403** aunque el túnel esté verde y el mapeo sea perfecto.
>
> **Trampa 12 — la política.** El diálogo propone **`Path Only (Sub-Paths Are Excluded)`**, que bloquea toda la ruta real del servicio. Tiene que ser `Path and All Sub-Paths`.

- [ ] **E4.** Icono de comprobación en `Actions` → **`Reachable`**.

> **Trampa 13 — el certificado.** Si se va por HTTPS y sale `Not Reachable`: exportar el certificado del servidor desde el navegador y subirlo en `Configuration` → pestaña **`ON-PREMISES`** → sección **`Back-End Trust Store`** → `Allowlist` → `+`.
>
> **No es** la sección `CA Certificate` que hay justo debajo: esa es la CA propia del conector para propagación de identidad, y rechaza el fichero.

---

## Bloque F — Destination

- [ ] **F1.** BTP Cockpit → subcuenta **`trial`** → `Conectividad` → `Destinations` → editar `S4H_POC_CUSTOMER`.

| Campo | Valor |
|---|---|
| URL | `http://s4h-poc.virtual:<puerto>` |
| Proxy Type | **`OnPremise`** |
| Authentication | `BasicAuthentication` |
| User / Password | *(usuario del bloque A)* |
| `sap-client` | *(mandante)* |

- [ ] **F2.** **`Check Connection`** → *"Se puede acceder al back end desde el conector de la nube"*.

---

## Bloque G — API Management (trial)

- [ ] **G1.** `Instancias y suscripciones` → `Integration Suite` → `Ir a la aplicación` → tarjeta **`Manage APIs`**.

> **Aquí nos quedamos la última vez.** Si la tarjeta no responde: comprobar el bloqueador de ventanas emergentes, probar clic derecho → abrir en pestaña nueva, recargar con `Ctrl+Shift+R`, y cerrar sesión y navegador antes de reintentar.

- [ ] **G2.** `Configure` → `APIs` → pestaña `API Providers` → `Create`

| Campo | Valor |
|---|---|
| Name | `S4H_POC_PROVIDER` |
| Type | `On-Premise` |
| **Use Cloud Connector** | ✅ |
| Host / Port | `s4h-poc.virtual` / *(puerto)* |
| Use SSL | Según protocolo |

- [ ] **G3.** Key Value Map `poc_backend_creds`, **cifrado**, con `username` y `password`.
- [ ] **G4.** API Proxy `PoC_Customer_v1`, base path `/poc/customer/v1`, sobre el provider.
- [ ] **G5.** Policies: `Key Value Map Operations` + `Basic Authentication` en el target, `Verify API Key` en el proxy, restricción de verbos, y **propagación del token CSRF y la cookie**.
- [ ] **G6.** Product `PoC_Migracion_Interfaces` → publicar → Application en el Developer Hub → **copiar la API key**.

> Detalle completo de policies y del flujo CSRF a través del proxy: **§10.5 del ET-001**.

---

## Bloque H — Validación F4: Postman vía BTP

- [ ] **H1.** Importar `docs/postman/ET-001-PoC-S4H-Customer-API.postman_collection.json` y su entorno.
- [ ] **H2.** Rellenar `apim_host`, `api_key`, `backend_url`, `sap_client`, `sap_user`, `sap_password`.
- [ ] **H3.** Ejecutar las carpetas `00` a `05` en orden.
- [ ] **H4.** Confirmar el registro en `SE16N`.

**Con H4, la cadena completa queda demostrada y el requisito del cliente cumplido.**

---

## Pendiente de terceros

- [ ] Entitlement de **Integration Suite** en `POC-CAL` → Ayax Morales
- [ ] Al llegar: replicar los bloques F, G y H en `POC-CAL`

---

## Registro de avance

| Bloque | Estado | Fecha | Notas |
|---|---|---|---|
| A — Servidor | | | |
| B — Objetos ABAP | | | |
| C — ICF | | | |
| D — F2 Postman directo | | | |
| E — Cloud Connector | | | |
| F — Destination | | | |
| G — API Management | | | |
| H — F4 Postman vía BTP | | | |
