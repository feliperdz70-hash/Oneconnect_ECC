# Runbook de reconstrucción — PoC API OData sobre S/4HANA

**Contexto:** el appliance S/4HANA 2025 original fue dado de baja. Este documento recoge lo que sigue en pie, lo que hay que rehacer y en qué orden, con las trampas ya identificadas señaladas en el paso donde aparecen.

Sistema destino: **SAP S/4HANA 2023**. Nada del patrón cambia respecto a 2025.

---

## 0. Punto de partida

### Lo que NO hay que repetir

| Activo | Estado |
|---|---|
| Cloud Connector instalado (Temurin 21 + sapcc 2.19.1) | ✅ Reinstalado el 2026-10-20 |
| Subcuenta `POC-CAL` registrada | ❌ No se rehace: API Management vive en el trial y POC-CAL sigue sin entitlement |
| Subcuenta `trial` registrada | ⚠️ **Rehacer**: la máquina se reseó el 2026-10-20 |
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

### Datos de la subcuenta trial

| Dato | Valor |
|---|---|
| Subdominio | `e5a2c3d7trial` |
| Subaccount ID | `1a7df9be-9f92-425c-ba24-31c438682272` |
| Proveedor / Región | AWS — `US East (VA)` |
| API Endpoint CF | `https://api.cf.us10-001.hana.ondemand.com` |
| Cockpit | `https://account.hanatrial.ondemand.com` |
| Creada | 11 de septiembre de 2026 |

> El `-001` del endpoint es la instancia de Cloud Foundry dentro de la región, no una región distinta: en el Cloud Connector la opción sigue siendo `US East (VA) - AWS`.

### Reinstalación del puesto de trabajo — 2026-10-20

La máquina se reseó y se perdió todo el lado del portátil. Nada de SAP se perdió.

| Paso | Nota |
|---|---|
| Temurin **21.0.12.1** | La carpeta real es `jdk-21.0.12.101-hotspot`, con `.101`, aunque `java -version` diga `.1` |
| `JAVA_HOME` | `setx /M` falla sin consola elevada. La vía fiable es `sysdm.cpl` → Variables de entorno → Variables del sistema |
| `sapcc-2.19.1-windows-x64.msi` | El primer intento dio *"Installation Incomplete"*; al reintentar instaló sin cambiar nada |

> **No instalar Temurin 25.** Es la LTS más reciente de Adoptium pero no está en la matriz de JVMs certificadas del Cloud Connector. El síntoma de una JVM no soportada es que el servicio instala, arranca y se cae a los pocos segundos, lo que manda a buscar el problema a la configuración de red.
>
> **Si no hubiera derechos de administrador:** el paquete `sapcc-2.19.1-windows-x64.zip` (Windows Portable) no los necesita, pero no se instala como servicio: hay que lanzar `go.bat` a mano y dejar la ventana abierta.

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

- [x] **A1.** SAP GUI → menú `Sistema` → `Status`. Release **S/4HANA 2023** (ABAP Platform 7.58).
- [x] **A2.** Transacción **`SMICM`** → `Pasar a` → `Servicios`. HTTP **50000**, HTTPS **44300**.
- [x] **A3.** Host **34.228.25.48**, mandante **100**, usuario **BPINST**, SID **S4H**. `BPINST` tiene autorización de desarrollo: creó tabla y CDS sin pedir clave de desarrollador.
- [ ] **A4.** El host está en **AWS** (rango `34.x` = EC2). Abrir el puerto de entrada en el **Security Group** de la instancia, no en un NSG de Azure.
- [ ] **A5.** Probar desde el navegador, con el protocolo explícito:

```
http://34.228.25.48:50000/sap/bc/ping?sap-client=100
```

> **Trampa 1 — el puerto.** No se asume. En el appliance anterior el HTTP era `50000` y el HTTPS `44300`, que no es el patrón habitual (`80NN` / `443NN`). Sale de `SMICM`, no de la intuición.
>
> **Trampa 2 — el cortafuegos del cloud.** El ICM puede estar escuchando y aun así no llegar desde fuera. Costó media mañana la primera vez, con un NSG de Azure. Este servidor está en **AWS**, así que el equivalente es el **Security Group** de la instancia EC2: regla de entrada para TCP 50000 (y 44300 si se usa HTTPS) desde la IP pública del puesto de trabajo.
>
> **Trampa 3 — el protocolo.** Escribir la URL sin `http://` hace que Chrome asuma HTTP contra un puerto TLS, y devuelve *"se ha restablecido la conexión"*, que parece un problema de red y no lo es.

**Datos del servidor — confirmados 2026-10-20:**

| Dato | Valor |
|---|---|
| Host / IP | `34.228.25.48` (AWS EC2, us-east-1) |
| Puerto HTTP | `50000` |
| Puerto HTTPS | `44300` |
| Mandante | `100` |
| Usuario de desarrollo | `BPINST` |
| **System ID (SID)** | `S4H` |
| Release | S/4HANA 2023 — ABAP Platform 7.58 |
| URL base OData V4 | `http://34.228.25.48:50000/sap/opu/odata4/` |

> **Trampa 3-bis — `BPINST` no es el usuario de desarrollo habitual.** En los appliances de SAP CAL, `BPINST` es el usuario de proceso de negocio y `DEVELOPER` el de desarrollo. Antes de empezar el Bloque B hay que confirmar que `BPINST` tiene **`S_DEVELOP`** y una **clave de desarrollador** registrada; si al crear el primer objeto en ADT pide clave de acceso de desarrollador o rechaza la creación, cambiar a `DEVELOPER`.
>
> **Trampa 3-ter — la IP pública de EC2 cambia al reiniciar** salvo que tenga una Elastic IP. Si mañana deja de responder, lo primero que hay que revisar es si la IP sigue siendo `34.228.25.48`, antes de tocar nada más: el mapeo del Cloud Connector (Bloque E) y el Destination (Bloque F) la llevan escrita.

---

## Bloque B — Objetos ABAP en ADT

- [x] **B1.** Proyecto ABAP en Eclipse: `S4H_100_bpinst_en_1`.

### B2. El paquete

- [x] Paquete `ZPOC_API_MIG` creado, tipo `Development`.

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

- [x] `New` → `Other ABAP Repository Object` → `Dictionary` → `Database Table` — **activa**, 6 campos verificados en SE11.

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

- [x] `New` → `Other ABAP Repository Object` → `Core Data Services` → `Data Definition` → plantilla **`defineRootViewEntity`** — **activa**.

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

- [x] Clic derecho sobre la CDS → `New Behavior Definition` → Implementation Type **`Managed`** — **activa**.

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

- [x] Cursor sobre `zbp_cx_customer` en la primera línea → `Ctrl+1` → `Create behavior implementation class` — **activa**.

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

- [x] `Ctrl+F3` sobre la clase.
- [x] Volver a la behavior definition y `Ctrl+F3`. **Activada** — *"Active object ZCX_CUSTOMER generated"*.

> Que la BDEF active es prueba indirecta de que la clase también lo está: con `authorization master ( global )`, el activador comprueba que `get_global_authorizations` existe y está implementado.

### B7. Service definition `ZAPI_CUSTOMER`

- [x] Clic derecho sobre la CDS → `New Service Definition` — **activa**.

```abap
@EndUserText.label: 'PoC - API transaccional de clientes'
define service ZAPI_CUSTOMER {
  expose ZCX_CUSTOMER as Customer;
}
```

### B8. Service binding `ZAPI_CUSTOMER_O4`

- [x] Clic derecho sobre la service definition → `New Service Binding` — **activo y publicado**.

| Campo | Valor |
|---|---|
| Name | `ZAPI_CUSTOMER_O4` |
| **Binding Type** | **`OData V4 - Web API`** |
| Service Definition | `ZAPI_CUSTOMER` |

- [x] `Ctrl+F3` para **activar** el binding.

### B8-bis. Publicar el grupo de servicios — `/IWFND/V4_ADMIN`

> **Trampa 14 — activar no es publicar, y el botón `Publish` de ADT no sirve en on-premise.**
>
> Son dos cosas distintas: activar registra el grupo de servicios, **publicar** es lo que lo hace alcanzable por HTTP. En S/4HANA on-premise el botón `Publish` del editor de Service Binding normalmente **no funciona** — el propio material de SAP (ejercicio RAP610) dice literalmente *"Publishing the local service endpoint of your service binding in on premise systems does not work from within ADT"* y manda usar la transacción.
>
> Síntoma si se omite este paso: **404** en todas las llamadas, con el binding en verde y la URL bien escrita. En `/IWFND/ERROR_LOG` aparece *"Service group '<nombre>' is not published"*.

- [ ] Transacción **`/n/IWFND/V4_ADMIN`** (o `Alt+F8` sobre el binding desde ADT).
- [ ] Botón **`Publish Service Groups`**.

| Campo | Valor |
|---|---|
| System Alias | **`LOCAL`** |
| Service Group ID | `ZAPI_CUSTOMER_O4` |

- [ ] Botón **`Get Service Groups`**.
- [ ] Marcar **solo** la fila `ZAPI_CUSTOMER_O4` — no las entradas default de soporte — y pulsar **`Publish Service Groups`**.
- [ ] Asignar una orden de **Customizing** (no de Workbench). Confirmar y `Enter`.
- [ ] Volver a ADT, clic derecho sobre el binding → `Refresh`. Debe figurar como **Published** y mostrar la Service URL.

> **Trampa 14-bis — el mandante de Customizing.** Si ADT rechaza el publish con *"Publishing of ZAPI_CUSTOMER_O4 in Customizing Client Not Allowed"*, es que el mandante 100 está marcado como mandante de Customizing en `SCC4` (**nota SAP 3101976**). La solución es la misma: publicar desde `/IWFND/V4_ADMIN`.
>
> **Trampa 14-ter — la publicación no viaja en la orden de Workbench** y es específica de sistema y mandante. Cuando esto se replique a QA y productivo, hay que repetir el paso en cada uno.
>
> **503 justo después de publicar:** caché de alias desactualizada. Es transitorio, reintentar.

- [x] **B9.** Entity Set `Customer` visible en el editor del binding.

> Si solo aparece *Read*, el binding se publicó antes de activar la behavior definition. Repetir la publicación.

- [x] **B10.** Service URL confirmada.

**URL real — confirmada contra el navegador, devuelve EDMX 4.0:**

```
http://34.228.25.48:50000/sap/opu/odata4/sap/zapi_customer_o4/srvd_a2x/sap/zapi_customer/0001/
```

> **La trampa 14 NO se produjo en S4H.** El botón `Publish` del editor de Service Binding funcionó directamente y el endpoint pasó a `Published` sin pasar por `/IWFND/V4_ADMIN`. Se deja documentada porque es un modo de fallo real y frecuente en on-premise, pero en este sistema no hizo falta.
>
> **El mandante no hace falta en la URL.** El `$metadata` respondió sin `?sap-client=100`, así que el mandante 100 es el predeterminado del nodo ICF. La KBA de la trampa 8-bis no afecta a este sistema; la cabecera `sap-client` se mantiene como seguro, no como requisito.

---

## Bloque C — ICF

- [ ] **C1.** Transacción **`SICF`** → *Hierarchy Type* `SERVICE` → `F8` → navegar a `default_host` → `sap` → `opu` → **`odata4`**.
- [x] Verificar que está **activo** (negro, no gris). Si no: clic derecho → `Activar servicio`, incluyendo subnodos.

> **Resuelto sin entrar en SICF.** Que el `$metadata` devuelva EDMX desde el navegador prueba que el nodo está activo. Esta transacción solo hace falta si la URL devuelve 403.

> Sin este nodo activo, todo devuelve **404** aunque el binding esté publicado.

---

## Bloque D — Validación F2: Postman contra el backend directo

Sea `BASE` la Service URL del paso B10.

- [ ] **D1.** Postman → `Settings` → `General` → **`SSL certificate verification` → OFF**.

> Solo necesario si se va por HTTPS. El certificado del appliance es autofirmado y Postman lo rechaza sin dar un motivo claro.

- [ ] **D2.** Metadatos

```http
GET {BASE}/$metadata?sap-client=100
Authorization: Basic <BPINST:contraseña en base64 — en Postman, pestaña Authorization → Basic Auth>
```

Esperado: **200** + EDMX con la entidad `Customer` y los cinco campos.

> **Trampa 8-bis — el mandante por parámetro de URL.** Hay una KBA de SAP que dice que el runtime de OData **V4 ignora `sap-client` cuando viene como parámetro de consulta** (NetWeaver 7.5+ y S/4HANA 1610+). En la práctica muchos sistemas on-premise sí lo resuelven, porque lo procesa el logon de ICF antes que Gateway, pero no está garantizado. Como seguro barato, mandar **además** la cabecera `sap-client: 100`. Si el nodo ICF ya apunta al mandante 100 — lo más probable en este appliance — no hace falta nada, pero conviene no jugarse un ciclo.

- [ ] **D3.** Token CSRF

```http
GET {BASE}/?sap-client=100
Authorization: Basic <BPINST:contraseña en base64 — en Postman, pestaña Authorization → Basic Auth>
X-CSRF-Token: Fetch
```

De la respuesta, pestaña **`Headers`**, copiar **`X-CSRF-Token`**.

> **Trampa 9-quater — las cookies, no solo la cabecera.** El token va atado a la sesión. Hay que devolver en la escritura **todas** las cookies que entregó este GET (`SAP_SESSIONID_S4H_100`, `sap-XSRF_S4H_100`, `sap-usercontext`), sin filtrar por nombre — SAP lo indica expresamente, porque el nombre de la cookie XSRF puede cambiar. **Postman lo hace solo** con su cookie jar si las dos peticiones van al mismo host. En cuanto esto se traslade a `curl`, a un iFlow de CPI o a un script, el POST empieza a devolver **403 "CSRF token validation failed"** con un token que parece correcto: ahí es que faltan las cookies.
>
> Pedir el token contra la **raíz del servicio**, con el mismo usuario y el mismo mandante que la escritura. Cambiar de usuario o de mandante entre las dos llamadas invalida el token.

> **Trampa 8-ter — `raw → Text` en vez de `raw → JSON`.** En Postman, si el cuerpo se elige como `Text`, se envía `text/plain` y el servicio responde **415 Unsupported Media Type**. Tiene que ser `Body → raw → JSON`.
>
> En un `DELETE` no se manda ni `Content-Type` ni cuerpo.

- [ ] **D4.** Alta

```http
POST {BASE}/Customer?sap-client=100
Authorization: Basic <BPINST:contraseña en base64 — en Postman, pestaña Authorization → Basic Auth>
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
GET {BASE}/Customer?sap-client=100
```

- [ ] **D6.** **Actualización — el paso que quedó pendiente**

```http
PATCH {BASE}/Customer('0000001000')?sap-client=100
Authorization: Basic <BPINST:contraseña en base64 — en Postman, pestaña Authorization → Basic Auth>
X-CSRF-Token: <token de D3>
Content-Type: application/json

{ "PolicyNumber": "POL9999999" }
```

Esperado: **200** o **204 No Content**.

> **Trampa 9-bis — el `If-Match`.** Si el PATCH devuelve **428 Precondition Required** o **412 Precondition Failed**, añadir la cabecera **`If-Match: *`**. Pasa cuando Gateway considera que la entidad tiene control optimista de concurrencia. El BDEF de este PoC no declara ningún campo `etag`, así que no debería hacer falta, pero es el primer intento ante esos dos códigos.
>
> **Trampa 9-ter — PATCH, no PUT.** OData V4 de RAP acepta `PATCH` (actualización parcial) y rechaza `PUT`. Enviar solo los campos que cambian; mandar la entidad entera con `PUT` devuelve error de método no soportado.

- [ ] **D7.** Verificar en SAP: **`SE16N`** sobre `ZCXTA_CUSTOMERS`. El campo `poliza` debe mostrar el valor nuevo.

> **Trampa 9 — el token CSRF.** Va ligado a la cookie de sesión. D3 y D4 deben ejecutarse seguidos y en la misma pestaña de Postman. Si pasa mucho tiempo, repetir D3.
>
> **Trampa 10 — la conversión ALPHA.** `KUNNR` es CHAR(10) y se graba literalmente lo que se envía. Mandar `"1000"` crea un registro distinto de `"0000001000"`. En las lecturas por clave hay que usar el formato interno, con ceros a la izquierda.

**Con D7 verificado, la parte SAP está demostrada: lectura, alta y actualización.**

---

## Bloque E — Cloud Connector

- [x] **E1.** `BTP-Trial-PoC` en **`Connected`**, certificado de subcuenta `Valid`, túnel contra `cf.us10.hana.ondemand.com`.

> El servicio arranca con Windows, pero tarda. Si está caído, todo lo de abajo falla y parece error de configuración.

- [x] **E2.** Seleccionar **`BTP-Trial-PoC`** → `Cloud to On-Premises` → `ACCESS CONTROL`.
- [x] Mapeo creado: `s4h-poc.virtual:50000` → `34.228.25.48:50000`, **Reachable**.

| Pantalla | Campo | Valor |
|---|---|---|
| 1 | Back-End Type | `ABAP System` |
| 2 | Protocol | `HTTP` — **sin** marcar `Use TLS` |
| 3 | Internal Host / Port | `34.228.25.48` / `50000` |
| 4 | Virtual Host / Port | `s4h-poc.virtual` / `50000` |
| 5 | Principal Type | `None` |
| 6 | System ID | `S4H` |
| 7 | Host in Request Header | `Use Virtual Host` |

> Se va por HTTP/50000 deliberadamente, igual que en el servidor anterior: evita por completo la trampa 13 (certificado autofirmado del appliance). El tramo Cloud Connector → BTP sigue cifrado por el túnel; el tramo sin cifrar es solo Cloud Connector → S/4HANA. Queda anotado como **desviación consciente del PoC**: en productivo este salto va por HTTPS con certificado de una CA reconocida.

- [x] **E3.** Recurso `/sap/opu/odata4` con política `Path and All Sub-Paths`.

| Campo | Valor |
|---|---|
| URL Path | `/sap/opu/odata4` |
| **Access Policy** | **`Path and All Sub-Paths`** |

> **Trampa 11-bis — el dígito del puerto.** En el primer intento se tecleó `5000` en lugar de `50000`, en el host interno y en el virtual. El síntoma es `Not Reachable`, idéntico al de un cortafuegos cerrado o un certificado rechazado, así que lo primero que hay que mirar ante un `Not Reachable` es si el puerto está bien escrito, antes de sospechar de la red.
>
> **Trampa 11 — el recurso.** Es el olvido número uno. Con `Resources (0)` toda petición devuelve **403** aunque el túnel esté verde y el mapeo sea perfecto.
>
> **Trampa 12 — la política.** El diálogo propone **`Path Only (Sub-Paths Are Excluded)`**, que bloquea toda la ruta real del servicio. Tiene que ser `Path and All Sub-Paths`.

- [x] **E4.** `Reachable` confirmado el 2026-10-20.

> **Trampa 13 — el certificado.** Si se va por HTTPS y sale `Not Reachable`: exportar el certificado del servidor desde el navegador y subirlo en `Configuration` → pestaña **`ON-PREMISES`** → sección **`Back-End Trust Store`** → `Allowlist` → `+`.
>
> **No es** la sección `CA Certificate` que hay justo debajo: esa es la CA propia del conector para propagación de identidad, y rechaza el fichero.

---

## Bloque F — Destination

- [x] **F1.** Destination `S4H_POC_CUSTOMER` creado de cero en la subcuenta `trial`.

| Campo | Valor |
|---|---|
| URL | `http://s4h-poc.virtual:50000` |
| Proxy Type | **`OnPremise`** |
| Authentication | `BasicAuthentication` |
| User | `BPINST` |
| Password | *(la del usuario)* |
| `sap-client` | `100` |

- [x] **F2.** **`Check Connection`** → *"Backend is reachable from the Cloud Connector"* — 2026-10-20.

> **El Destination no es un requisito de API Management.** El API Provider del bloque G habla con el Cloud Connector por su cuenta, sin pasar por aquí. Este paso se mantiene porque es el **punto de control**: demuestra en dos minutos que la cadena BTP → Cloud Connector → S/4HANA funciona desde el lado de la nube. Si el bloque G falla después, el túnel queda descartado como causa.

> **Un `401` también es un buen resultado** en esta comprobación: significa que la petición llegó al ICM y pidió credenciales. Lo que se prueba aquí es conectividad, no autenticación. Solo un timeout o un 403 serían fallos reales.

---

## Bloque G — API Management (trial)

- [ ] **G0. Limpiar el usuario fantasma.** Subcuenta `trial` → `Seguridad` → `Usuarios`. Si existe una fila cuyo *User Name* es literalmente **`Proveedor de identidad`**, borrarla: es la etiqueta del campo tecleada dentro del campo del ID. Es la que provoca el *"Failed to save role collection: internal error"*.

- [ ] **G1. Dar de alta el runtime de API Management.** Integration Suite → **`Settings`** → **`Runtimes`** → pestaña **`Configure`**:

| Campo | Valor |
|---|---|
| **Account Type** | **`Non-Production`** — ⚠️ **no se puede cambiar después** |
| Virtual Host → Host Alias | Un alias corto, p.ej. `cemex-poc` |
| Notification Contact | El correo del responsable |

→ **`Activate`** → **`Confirm`**. Después, cerrar sesión y volver a entrar.

> ### Trampa 15 — activar la capacidad no es dar de alta el runtime
>
> **Esta es la causa real del bloqueo que nos paró dos veces**, y es la trampa más cara de todo el documento porque no produce ningún error.
>
> La tarjeta **`Manage APIs`** no responde al pulsarla: no navega, no parpadea, no avisa. El motivo es que **no hay nada que abrir**. Activar la capacidad en `Manage Capabilities` solo registra la suscripción; el alta del runtime es un paso aparte que crea el virtual host y el API Portal. Sin él no existe destino.
>
> **Lectura equivocada que nos despistó:** en el diálogo de capacidades, la capacidad padre se llama **`Manage APIs`**. `API Modelling` es una casilla hija, marcada por defecto, y `Developer Hub` una hermana opcional. Ver esas dos en `Active` **no prueba** que el runtime esté dado de alta — y es exactamente lo que vimos antes de perder dos sesiones buscando el problema en los roles y en el navegador.
>
> **El Host Alias no es cosmético:** forma la URL base pública de las APIs (`https://<alias>.apimanagement.hana.ondemand.com`). Es la URL que consumirá Postman en el bloque H, o sea, el entregable del PoC.
>
> **Vía alternativa en trial:** si bajo `Settings` no aparece `Runtimes` sino **`APIs`**, seleccionar esa entrada dispara la activación automática con un virtual host por defecto. Al terminar, la opción desaparece del menú y **la sesión se cierra sola**: hay que volver a entrar. Ese logout va **después** del alta, no en lugar de ella.
>
> **Lo que NO era, pese a lo que parecía:**
> - **No era el bloqueador de ventanas emergentes.** Se descartó al reproducir el mismo comportamiento en Edge y en Chrome.
> - **No era el triángulo amarillo de las role collections.** No existe documentación de SAP que diga que ese icono signifique asignación inefectiva; el único rastro apunta a que BTP marca *autorizaciones críticas*, con las asignaciones intactas.
> - **No era el aprovisionamiento de la capacidad.** `Manage Capabilities` mostraba `Active` desde semanas antes.
> - **Un token sin scopes no produce "no pasa nada"**, produce un 403 o un *"You are not authorized"*. Una tarjeta que no navega en absoluto significa que no hay URL destino.

- [ ] **G1-bis.** Comprobar la role collection **`Integration_Provisioner`** en la **subcuenta** (no en la cuenta global): la documentación la lista como prerrequisito de la suscripción y no estaba asignada.

> **Trampa 15-bis — cuenta global y subcuenta tienen listas de usuarios y de role collections distintas, y se ven idénticas.** Las role collections de API Management viven en la **subcuenta**. Se comprueba en el breadcrumb: `Trial Home / e5a2c3d7trial / trial` — si falta el tercer segmento, se está en la cuenta global y se está mirando la lista equivocada.

- [ ] **G2.** `Configure` → `APIs` → pestaña `API Providers` → `Create`

| Campo | Valor |
|---|---|
| Name | `S4H_POC_PROVIDER` — ✅ creado |
| Type | `On-Premise` |
| **Use Cloud Connector** | ✅ |
| Host / Port | `s4h-poc.virtual` / `50000` |
| Use SSL | **Desmarcado** — el backend va por HTTP |

> **El host del provider es el VIRTUAL del Cloud Connector, no la IP del servidor.** API Management habla con `s4h-poc.virtual:50000` y el Cloud Connector traduce a `34.228.25.48:50000`. Poner la IP real no funciona: no hay ruta directa de BTP al servidor.

### Host público de API Management — confirmado 2026-10-20

```
https://e5a2c3d7trial-trial.integrationsuitetrial-apim.us10.hana.ondemand.com
```

**URL pública real del proxy — la que consume Postman en el bloque H:**

```
https://e5a2c3d7trial-trial.integrationsuitetrial-apim.us10.hana.ondemand.com/e5a2c3d7trial/100/poc/customer/v1
```

> ### Trampa 18 — el base path publicado no es el que se teclea
>
> Se creó el proxy con `API Base Path = /poc/customer/v1` y API Management lo publicó como **`/100/poc/customer/v1`**, anteponiendo además el subdominio del tenant: la ruta real es **`/e5a2c3d7trial/100/poc/customer/v1`**.
>
> Es la causa real del `ApplicationNotFound` de la trampa 17: el proxy estaba desplegado, pero se estaba llamando a una ruta que no existía.
>
> **Nunca componer la URL a mano.** Se copia del campo **`API Proxy URL`** de la pantalla de detalle del proxy, que es el único sitio donde figura la ruta tal como quedó publicada. El `:443` que muestra se puede omitir.

> ### Trampa 19 — `Unsupported Encoding "br"`
>
> ```json
> {"fault":{"faultstring":"Unsupported Encoding \"br\"","detail":{"errorcode":"protocol.http.UnsupportedEncoding"}}}
> ```
>
> El gateway de API Management **no soporta Brotli**. Los navegadores modernos envían `Accept-Encoding: gzip, deflate, br, zstd` y la petición se rechaza antes de procesarse. **Es un problema del cliente, no del proxy:** verlo significa que el enrutado ya funciona.
>
> **En Postman:** añadir explícitamente el header `Accept-Encoding: gzip, deflate`. Postman también añade `br` por su cuenta, así que hay que sobrescribirlo — conviene desplegar los *hidden headers* y comprobar que no quede.
>
> **Arreglo definitivo**, para que también funcione desde el navegador en una demo: una policy `AssignMessage` en el **`ProxyEndpoint` → `PreFlow` → `Request`** que elimine la cabecera.
>
> ```xml
> <AssignMessage async="false" continueOnError="false" enabled="true" name="Normalize-Accept-Encoding">
>     <DisplayName>Normalize-Accept-Encoding</DisplayName>
>     <Remove>
>         <Headers>
>             <Header name="Accept-Encoding"/>
>         </Headers>
>     </Remove>
>     <AssignTo createNew="false" transport="http" type="request"/>
> </AssignMessage>
> ```
>
> No es bloqueante para el PoC, cuyo consumidor es Postman. Sí conviene tenerlo antes de enseñárselo al cliente, por si alguien abre la URL en Chrome.

- [ ] **G3.** Key Value Map `poc_backend_creds`, **cifrado**, con `username` y `password`.
- [x] **G4.** API Proxy `PoC_Customer_v1`, base path `/poc/customer/v1`, sobre el provider. Creado como `PoC_Customer_v1_1_0_0` — API Management le añade la versión al nombre interno, no afecta a la URL.

| Campo | Valor usado |
|---|---|
| Select | `API Provider` |
| API Provider | `S4H_POC_PROVIDER` |
| URL | `/sap/opu/odata4/sap/zapi_customer_o4/srvd_a2x/sap/zapi_customer/0001` |
| API Base Path | `/poc/customer/v1` |
| **Service Type** | **`REST`** |

> **Trampa 16 — `Service Type: ODATA` no sirve aquí.** Ese tipo hace que API Management intente descubrir el catálogo de servicios, pensado para OData **V2**. Con un servicio **V4 A2X** como este, el descubrimiento falla. Con `REST` el proxy pasa las peticiones tal cual, que es lo que se quiere en un escenario de migración de interfaces.

> **El campo `URL` del proxy lleva solo la ruta**, sin host: el host lo aporta el API Provider.

- [ ] **G4-bis. Desplegar el proxy.** Recién creado queda en **`Not Deployed`**. Abrir el proxy por su nombre (la acción vive en la pantalla de detalle, no en el menú `...` de la lista) y pulsar **`Deploy`**.

> ### Trampa 17 — `ApplicationNotFound`
>
> Un proxy creado pero **no desplegado** devuelve esto, y conviene saber leerlo porque dice exactamente lo que pasa:
>
> ```json
> {"fault":{"faultstring":"Unable to identify proxy for host: default and url: /poc/customer/v1/$metadata",
>  "detail":{"errorcode":"messaging.adaptors.http.flow.ApplicationNotFound"}}}
> ```
>
> Significa: *la petición llegó al gateway correcto, pero ningún proxy desplegado atiende esa ruta*. Es **buena señal**, no mala: prueba que el host público resuelve, que el TLS funciona y que API Management está vivo. Solo falta el despliegue, o el `API Base Path` no coincide con el que se está llamando.
>
> **No confundirlo con el error de Postman** *"Could not get any response"*, que es su mensaje comodín para cualquier fallo de conexión y no distingue entre DNS, TLS, proxy corporativo y host inexistente. **Ante ese mensaje, probar siempre la URL en el navegador primero:** devuelve el error real en una línea, como este `ApplicationNotFound`, en lugar de cuatro hipótesis genéricas.
- [ ] **G5.** Policies: `Key Value Map Operations` + `Basic Authentication` en el target, `Verify API Key` en el proxy, restricción de verbos, y **propagación del token CSRF y la cookie**.
- [ ] **G6.** Product `PoC_Migracion_Interfaces` → publicar → Application en el Developer Hub → **copiar la API key**.

> Detalle completo de policies y del flujo CSRF a través del proxy: **§10.5 del ET-001**.

---

## Bloque H — Validación F4: Postman vía BTP

**URL base, confirmada en funcionamiento el 2026-10-20:**

```
https://e5a2c3d7trial-trial.integrationsuitetrial-apim.us10.hana.ondemand.com/e5a2c3d7trial/100/poc/customer/v1
```

> ### Hito — cadena completa demostrada
>
> La primera respuesta que llegó desde Postman a través de BTP fue un **406** emitido por el propio S/4HANA:
>
> ```json
> "ComponentId": "BC-ESI-ESF-GW", "ServiceRepository": "SRVD_A2X",
> "ServiceId": "ZAPI_CUSTOMER", "ServiceVersion": "0001"
> ```
>
> Un error de negociación de contenido emitido por el Gateway prueba dos cosas de una vez: que la petición atravesó **Postman → API Management → Cloud Connector → S/4HANA** hasta el servicio, y que la **autenticación funcionó** — de lo contrario habría devuelto 401 antes de mirar las cabeceras.

> ### Trampa 20 — `$metadata` solo existe en XML
>
> Pedir `$metadata` con `Accept: application/json` devuelve **406 Not Acceptable** con el código `/IWCOR/CX_OD_NOT_ACCEPTABLE`. En OData V4 el documento de metadatos es EDMX, es decir XML.
>
> - Para `$metadata` → **`Accept: application/xml`**
> - Para los datos (`/Customer`) → **`Accept: application/json`**
>
> Es un error del cliente, no del servicio: verlo significa que la cadena entera ya funciona.

> ### Trampa 21 — Postman en portátil corporativo
>
> *"Could not get any response"* mientras el **navegador sí llega** a la misma URL apunta a Postman, no a la red. En un equipo con inspección TLS corporativa, el navegador confía en la CA de la empresa porque está en el almacén de Windows, pero Postman usa el suyo propio y rechaza la conexión.
>
> Ajustes (`Ctrl` + `,`, **no** el engranaje de la lista de entornos, que abre *Manage Environments*):
>
> | Pestaña | Ajuste | Valor |
> |---|---|---|
> | `General` | `SSL certificate verification` | OFF |
> | `General` | `Request timeout in ms` | `0` |
> | `Proxy` | `Use the system proxy` | ON |
>
> **Trampa 21-bis — el método pegado en la URL.** Copiar una línea del tipo `GET  https://...` mete el texto `GET` dentro del campo de la URL. Postman intenta conectar a `GET%20%20https://...` y devuelve el mismo *"Could not get any response"*, que no distingue entre una URL mal formada, un fallo de DNS y un cortafuegos.



- [ ] **H1.** Importar `docs/postman/ET-001-PoC-S4H-Customer-API.postman_collection.json` y su entorno.
- [ ] **H2.** Rellenar `api_key` y `sap_password`. El resto de variables ya vienen con los valores reales.
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
| A — Servidor | ✅ | 2026-10-20 | `34.228.25.48:50000`, SID `S4H`, mandante 100, `BPINST`, AWS |
| B — Objetos ABAP | ✅ | 2026-10-20 | Los 7 objetos activos. `strict(2)` sin cambios en 7.58 |
| C — ICF | ✅ | 2026-10-20 | Resuelto sin SICF: el `$metadata` responde |
| D — F2 Postman directo | ⏳ | | Baseline de aislamiento de fallos, no es el entregable |
| E — Cloud Connector | ✅ | 2026-10-20 | `Reachable` + `Resources (1)`. Tras reinstalar el puesto |
| F — Destination | ✅ | 2026-10-20 | `S4H_POC_CUSTOMER` → *Backend is reachable* |
| G — API Management | ⏳ | | Causa del bloqueo identificada: falta el alta del runtime (trampa 15) |
| H — F4 Postman vía BTP | ⏳ | | **El entregable. El PoC no está demostrado sin esto.** |

> **El criterio de aceptación es H, no D.** El requisito del cliente es que la prueba se ejecute **a través de BTP**. La validación contra el backend directo (bloque D) es un paso de diagnóstico: sirve para que, si algo falla en los bloques F a H, se sepa que la causa no está en SAP. No sustituye a H bajo ninguna circunstancia.
