# ET-002 — Extender una API estándar de SAP sin tocarla

**Segundo escenario del PoC de migración de interfaces PI/PO.**
Documento hermano de `ET-001` y del `RUNBOOK-reconstruccion.md`. Mismo formato: pasos ejecutables y trampas señaladas en el paso donde muerden.

> Verificado contra documentación de SAP con 30 agentes y refutación independiente de cada hallazgo. Lo que no se pudo confirmar está marcado como tal en la sección 14 — **no se presenta nada sin respaldo como si lo tuviera**.

---

## 0. Sistema destino

**A partir del 2026-10-23 este escenario se ejecuta contra el S/4HANA on-premise de Cemex.** No contra el appliance de AWS del PoC-1.

| Dato | Valor |
|---|---|
| Host | `10.222.55.7` — **IP privada, red interna de Cemex** |
| Protocolo / puerto en uso | `HTTPS` / `443` (navegador) · **`HTTP` / `50000` disponible** |
| Puerto HTTP | ✅ **`50000`** — confirmado 2026-10-23 |
| Mandante | `100` |
| Release | S/4HANA **2025** — ⏳ nivel exacto pendiente (`Sistema` → `Status`) |
| SID | ✅ **`S4H`** |
| Usuario | **`E0FLRODRIGZ`** — usuario nominal de Cemex |
| Hostname interno | `vhcals4hci.dummy.nodomain` |
| Tipo | On-premise de Cemex. El hostname y el SID siguen el patrón de appliance de SAP, así que lo más probable es un appliance desplegado en la infraestructura del cliente |
| URL del launchpad | `https://10.222.55.7/sap/bc/ui2/flp?sap-client=100&sap-language=EN` |

> **Cómo se obtuvieron estos datos, sin salir de SAP GUI.** El SID y el mandante salen de la barra de título (`S4H (5) 100`). El hostname interno y el **puerto HTTP** salen del atributo `xml:base` de la respuesta de `/IWFND/GW_CLIENT` — el service document lo trae escrito. Es más rápido que `SMICM` y no hace falta autorización para la transacción de administración del ICM.

> **Por qué el cambio es una mejora.** Un on-premise real del cliente es mucho más representativo que un appliance, y **2025 trae el check de ATC `Allowed Enhancement Technologies`**, introducido en agosto de 2025, que es justamente el que marca los append structures. En 2023 no existía. Es decir: en este sistema el enfoque C de la sección 4 se puede **demostrar como inaceptable con una herramienta de SAP**, en vez de argumentarlo.

> ### ⚠️ Lo que deja de ser cierto respecto al PoC-1
>
> | PoC-1 (appliance AWS) | Aquí |
> |---|---|
> | `34.228.25.48`, IP pública | `10.222.55.7`, privada — **el Cloud Connector solo llega con la VPN de Cemex levantada** |
> | HTTP `50000`, que esquivaba el certificado | HTTPS `443` — **la trampa 13 vuelve** salvo que exista puerto HTTP |
> | `BPINST`, usuario del appliance con amplios permisos | `E0FLRODRIGZ`, usuario nominal — **los permisos los controla Seguridad de Cemex** |
> | Sistema de laboratorio, se toca sin pedir permiso | **Sistema del cliente**: toda asignación de rol pasa por su proceso |

---

## 1. Veredicto

**El escenario es posible y es el camino limpio.** La ruta confirmada es:

```
Campo creado con la app Custom Fields  →  habilitado para API_BUSINESS_PARTNER
   →  publicado  →  aparece en el $metadata  →  PATCH desde BTP
```

**Cero líneas de ABAP. Cero modificaciones. Cero objetos propios.**

Pero la forma en que se planteó al principio —*"CDS Z que lea `KNA1`, campo Z en `KNA1`, actualizar por la API estándar"*— **no sirve**, y conviene entender por qué antes de empezar.

---

## 1.1 Alcance acordado — 2026-10-22

Decisiones tomadas con el cliente antes de empezar. Fijan qué se construye y, sobre todo, **qué no**.

| Punto | Decisión |
|---|---|
| Nombre del campo | `policy_number` — es el identificador que se teclea. **El nombre real se lee del `$metadata`** (trampa 31) |
| Tipo | Texto libre |
| **Validación del campo propio** | **Ninguna.** Es un dato de origen externo: no existe catálogo de valores válidos contra el que comprobarlo |
| Validaciones del resto | Solo las que ya trae la API estándar |
| Código ABAP | **Cero.** Ni en ADT ni en la app `Custom Logic` |
| API de mantenimiento | `API_BUSINESS_PARTNER` — la API OData V2 estándar de Business Partner |

**Consecuencia:** al no validar la póliza, el escenario se queda íntegramente en `Custom Fields` + `Enable Usage`. No hace falta la app `Custom Logic` (`F6957`) ni ningún BAdI key user, que habrían metido ABAP —aunque restringido— en un PoC cuyo argumento central es que no hay ninguno.

### Qué valida el estándar sin programar nada

Es entregable del PoC aunque no lo construyamos nosotros, y conviene enseñarlo explícitamente:

| Caso | Respuesta de la API estándar |
|---|---|
| Cliente / BP inexistente | **404** sobre la clave de la URL |
| Código de país inexistente | Error del estándar, contra la tabla de check `T005` |
| Código de región inexistente para ese país | Error del estándar, contra `T005S` |
| Campo *read-only* enviado en el `PATCH` | Error **aunque el valor no cambie** — nota 3569467, trampa 34 |
| `policy_number` | Se graba tal cual. Sin validación, por diseño |

> **Pendiente de resolver en el sistema, y condiciona el diseño:** dónde se mantienen `Country` y `Region`. En S/4HANA la dirección cuelga del Business Partner, no del cliente (trampa 36), así que es probable que en `A_Customer` sean **read-only** y que el mantenimiento real vaya por `A_BusinessPartnerAddress`. Si es así, "actualizar póliza + región + país" son **dos `PATCH` contra entidades distintas**, no uno. Se confirma leyendo `sap:updatable` en el `$metadata`.

## 2. Por qué la idea inicial no funciona

Tres motivos independientes. Cualquiera de ellos basta.

### 2.1 El argumento fuerte: no cumple el objetivo

`API_BUSINESS_PARTNER` **no lee `KNA1`**. Expone un modelo propio —`A_BusinessPartner`, `A_Customer`, `A_Supplier`…— construido sobre vistas CDS y el objeto de negocio del BP.

Un *append structure* añade una columna a la tabla física, pero **no añade nada al modelo**. El campo no aparece en el `$metadata`, no se puede leer y no se puede escribir por la API.

> Éste es el argumento que hay que dar primero. "No es clean core" es el argumento débil y discutible; **"no funciona"** no se discute.

### 2.2 La CDS Z sobra, y además contradice el objetivo

Una vista CDS propia genera **un servicio nuevo** — que es exactamente el PoC-1, ya demostrado. Presentarlo como *"extensión de la estándar"* es el escenario 1 disfrazado, y un cliente técnico lo detecta.

**Para extender `API_BUSINESS_PARTNER` no se escribe ninguna CDS.**

### 2.3 Escribir en `KNA1` rompe la sincronización

En S/4HANA el Business Partner es el **único punto de entrada** para crear y mantener clientes (SAP Note 2265093, *The Business Partner Approach*). `KNA1` no desaparece: se rellena por detrás mediante **CVI** (Customer/Vendor Integration) cada vez que se graba el BP.

Escribir directo en `KNA1` salta CVI y deja el maestro descuadrado.

---

## 3. ⚠️ El vocabulario cambió: ya no se dice "tiers"

**Corrección importante respecto a lo que se venía diciendo en este proyecto.**

En la actualización de **agosto de 2025**, SAP jubiló el *3-Tier Extensibility Model* y lo sustituyó por los **clean core levels A, B, C y D**.

| Lo que sigue vigente | Lo que está jubilado |
|---|---|
| **Key User Extensibility** (antes *In-App*) | ~~Tier 1~~ |
| **Developer Extensibility** (on-stack, ABAP Cloud) | ~~Tier 2~~ |
| **Side-by-Side Extensibility** (en SAP BTP) | ~~Tier 3~~ |

**Nivel A** = solo APIs y puntos de extensión liberados, tanto on-stack con ABAP Cloud como side-by-side en BTP. Es el objetivo.

> Decir "Tier 1" delante de un cliente al día lo fecha a uno. Decir "Nivel A" y "Key User Extensibility" es lo correcto hoy.

---

## 4. Dónde encaja cada enfoque

| Enfoque | Opción de extensibilidad | Nivel | Código |
|---|---|---|---|
| **A.** Campo con Custom Fields expuesto por la API estándar | Key User | **Nivel A**, sin matices | Ninguno |
| **B.** CDS propia sobre vistas liberadas + RAP propio *(el PoC-1)* | Developer | Nivel A **solo si** se cumplen dos condiciones | ABAP aislado |
| **C.** Append sobre `KNA1` + CDS leyendo `KNA1` | Clásica | **Nunca Nivel A** | ABAP acoplado |

### 4.1 La verdad incómoda sobre el PoC-1

El enfoque **B** es Nivel A **solo si se cumplen las dos cosas a la vez**:

1. Que consuma exclusivamente objetos liberados, **y**
2. Que el paquete esté en versión de lenguaje **`ABAP for Cloud Development`**

**El PoC-1 está en `Standard ABAP`.** Eso significa que el objeto RAP construido **no es ABAP Cloud**: compila contra todo el repositorio clásico, y nada impide que mañana alguien le añada un `SELECT` sobre una tabla no liberada sin que nadie se entere.

> **Qué decir y qué no decir del PoC-1.** Es un PoC válido y el patrón es correcto. Pero **no se puede presentar como "clean core Nivel A"** mientras el paquete siga en `Standard ABAP`. La frase honesta es: *"el patrón es el correcto; la versión de lenguaje quedó en estándar para no bloquear la prueba, y migrarla es una decisión consciente que está documentada"*.
>
> Si alguien del cliente pregunta, esa respuesta gana. La otra se cae en cuanto miren las propiedades del paquete.

---

## 5. La prueba de 30 segundos

Esta es la pieza de evidencia más fuerte del documento, y es verificable **en vivo, delante del cliente**.

SAP publica en GitHub la lista completa y legible por máquina de objetos liberados y no liberados, con sus sucesores: el **Cloudification Repository** (`SAP/abap-atc-cr-cv-s4hc`), que es lo que consume el check de ATC *Usage of Released APIs*.

El fichero correcto para este caso es el de la línea **PCE** (Private Cloud Edition / on-premise), no el de Public Cloud:

- `objectReleaseInfo_PCE2023_3.json` — 40.413 objetos, 39.128 liberados
- `objectReleaseInfo_PCE2025_0.json` — 43.400 objetos, 42.483 liberados

**La entrada de `KNA1` dice literalmente:**

| Campo | Valor |
|---|---|
| Objeto | `KNA1` |
| Componente | `S4CORE` / `LO-MD-BP-CM` |
| **Estado** | **`notToBeReleased`** |
| **Sucesor designado** | **`I_CUSTOMER`** (marcada `released`) |

Y lo mismo con el resto del maestro:

```
BUT000  →  I_BUSINESSPARTNER
KNVV    →  I_CUSTOMERSALESAREA
KNB1    →  I_CUSTOMERCOMPANY
```

> **Por qué esto gana cualquier discusión.** El razonamiento del upgrade es **contractual, no intuitivo**: "released" significa que SAP se compromete a mantener la compatibilidad. Sobre `notToBeReleased` no hay compromiso ninguno. No es una opinión de arquitectura, es lo que SAP publica.

---

## 6. 🔴 Prerrequisitos bloqueantes

**Hay que comprobarlos antes de prometerle nada al cliente.** Cualquiera de los cuatro detiene el escenario en seco.

### 6.1 El Adaptation Transport Organizer (ATO)

> ### Trampa 23 — en on-premise, la extensibilidad key user viene apagada
>
> El ATO es **prerrequisito duro de todas las herramientas key user**. Sin él, la app devuelve **`Key User Application is not Configured`** y no deja crear ni publicar nada.
>
> Se configura con la transacción **`S_ATO_SETUP`**: se define un paquete local para los objetos de extensión, asignado al componente de software `Local` (el ejemplo de SAP es `$YATO_KEY_USER_LOCAL`), y se elige entre prefijo o namespace.
>
> - **Nota SAP 2807979** — cómo configurar ATO vía `S_ATO_SETUP`
> - **Nota SAP 2283716** — el error *"Key User Application is not configured"*
>
> Una fuente indica que ATO solo hace falta en el sistema de desarrollo, no en QA ni producción.

#### ✅ Verificado en S4H — 2026-10-27: el ATO ya está configurado

No hizo falta ejecutar `S_ATO_SETUP` ni preguntar a Basis. **La prueba es indirecta pero concluyente:** la app `Custom Fields` abre sin el error `Key User Application is not Configured`, y su lista ya contiene campos creados antes por otras personas (`ZZ1_CustomFieldH…`, `ZZ1_Customerregio…`, `ZZ1_CutomZRegio…`). Si el ATO no estuviera configurado, ninguno de esos campos existiría.

> **Atajo reutilizable:** antes de tramitar `S_ATO_SETUP` con Basis, mirar si la app ya lista campos `ZZ1_`. Si los hay, el ATO está hecho y la petición sobra.

### 6.2 El servicio estándar no está activo de serie

`API_BUSINESS_PARTNER` **no responde** hasta registrarlo en el hub de Gateway:

`/IWFND/MAINT_SERVICE` → `Add Service` → System Alias **`LOCAL`** (Gateway embebido, lo normal en S/4HANA) → nombre técnico `API_BUSINESS_PARTNER` → asignar paquete.

**Comprobación rápida:** pedir su `$metadata`. Si responde, está registrado.

#### ✅ Verificado en S4H — 2026-10-23: el servicio YA está activo

No hizo falta registrar nada. Desde **`/IWFND/GW_CLIENT`**, con `Protocol: HTTP`:

```
GET /sap/opu/odata/sap/API_BUSINESS_PARTNER/?$format=xml
```

→ **`200 OK`**, con el service document listando las colecciones (`A_AddressEmailAddress`, `A_AddressFaxNumber`, `A_AddressHomePageURL`, `A_AddressPhoneNumber`, …).

> **`/IWFND/GW_CLIENT` es la forma más barata de comprobar esto**, y mejor que el navegador: se ejecuta dentro del sistema, así que aísla el servicio de cualquier problema de red, proxy o certificado. Si responde 200 aquí y falla desde fuera, el problema no es el servicio.

> ### Trampa 24 — SAP_COM_0008 y los communication arrangements son de Cloud
>
> Si un tutorial pide crear un **Communication Arrangement** sobre el escenario **`SAP_COM_0008`**, o muestra una URL del tipo `<host>-api.s4hana.ondemand.com`, **está leyendo documentación de S/4HANA Cloud Public Edition**. En on-premise eso no existe: se activa el servicio en `/IWFND/MAINT_SERVICE` y se asignan permisos por PFCG.
>
> Es la fuente de confusión número uno de este escenario, porque casi todos los tutoriales indexados son de Cloud.

### 6.3 Launchpad y rol

Para **crear** un campo propio hace falta la app Fiori, y por tanto un launchpad operativo. **No existe transacción de SAP GUI que cree campos key user.**

| Transacción | Para qué sirve | Ojo |
|---|---|---|
| `SCFD_REGISTRY` | Consultar el Extensibility Registry: qué contextos y vistas son extensibles | Solo consulta |
| `SCFD_EUI` | *Enable Fields for Custom Field App*: habilitar campos **ya existentes** | **No crea campos** |
| `S_ATO_SETUP` | Configurar el ATO | Prerrequisito |

El rol necesario lleva el catálogo de herramientas key user. Las fuentes se contradicen sobre el identificador exacto (`SAP_CORE_BC_EXT`, `SAP_BASIS_BC_EXT`, `SAP_UI_FLEX_KEY_USER`): **hay que mirarlo en el sistema**, no citarlo de memoria.

> ### Trampa 37 — la búsqueda del launchpad NO sirve para saber si tienes una app
>
> La lupa de la cabecera del launchpad (intent `#Action-search`) consulta el índice de **Enterprise Search**, que en los appliances no suele estar configurado. Devuelve `Results (0)` para cualquier término, **aunque el usuario tenga la app perfectamente asignada**. No prueba absolutamente nada, y es el primer sitio donde todo el mundo mira.
>
> La pantalla correcta es el **App Finder**: avatar de usuario → `App Finder`, o directamente el intent **`#Shell-appfinder`**. Y dentro de él, la pestaña **`Catalog`** — no `SAP Menu`, que lista transacciones del menú clásico y devuelve señuelos como `Define Custom Functions`, `Define Custom Hints` o `Define Custom Message Texts`, que no tienen ninguna relación con la extensibilidad key user.
>
> **Cómo se lee el resultado de `Catalog`:**
>
> | Lo que ves | Qué significa |
> |---|---|
> | Catálogos en el panel izquierdo, pero sin `Custom Fields` | Falta el catálogo de Extensibility en el rol |
> | Panel izquierdo solo con `All`, y `No apps to display` | **El usuario no tiene NINGÚN catálogo Fiori asignado** |

#### Resultado verificado — 2026-10-23

🔴 **El prerrequisito 6.3 FALLA con `E0FLRODRIGZ`.**

| Comprobación | Resultado |
|---|---|
| El launchpad abre | ✅ Sí — luego Fiori está desplegado y los nodos ICF de UI2 están activos |
| `E0FLRODRIGZ` entra | ✅ Sí — el usuario no está bloqueado. **La trampa 25 no aplica aquí**: no es un appliance ni un usuario demo |
| Home del launchpad | ❌ Vacía, sin tiles |
| App Finder → `Catalog` | ❌ `No apps to display`, con el panel de catálogos vacío |

**Diagnóstico:** no es que falte el catálogo de extensibilidad — es que `E0FLRODRIGZ` **no tiene ningún catálogo Fiori asignado**. Es lo normal en un usuario nominal de un sistema corporativo: se le dan los roles de lo que hace, y la extensibilidad key user no es uno de ellos.

**El contenido Fiori está bien.** Que el launchpad abra y el App Finder responda prueba que los nodos ICF de UI2 están activos y que hay contenido desplegado. Lo único que falta es el rol.

> ### 🔴 Trampa 38 — en el sistema del cliente, el rol no te lo das tú
>
> En el appliance bastaba con entrar en `PFCG` y asignarse lo que hiciera falta. **En el on-premise de Cemex no.** La asignación de roles la controla el equipo de Seguridad / Basis del cliente, y un usuario nominal normalmente **no tiene `PFCG` ni `SU01`**.
>
> Esto convierte un paso de dos minutos en un **trámite con plazo**, y es el tipo de cosa que descarrila una demo con fecha. Hay que pedirlo **ya**, en paralelo con el resto del trabajo, no cuando toque.
>
> **Qué pedir exactamente, para que no haya idas y venidas:** un rol que contenga el **business catalog de extensibilidad key user**, el que da acceso a la app **`Custom Fields`** (`F1481`). El identificador hay que sacarlo del sistema con la **F4 de `PFCG`** filtrando por `*EXT*` — los candidatos `SAP_CORE_BC_EXT`, `SAP_BASIS_BC_EXT` y `SAP_UI_FLEX_KEY_USER` provienen de documentación de Cloud y **ninguno está confirmado para on-premise 2025**.
>
> Conviene pedir en la misma petición el acceso a **`/IWFND/MAINT_SERVICE`**, que hará falta para el prerrequisito 6.2, y a **`SCFD_REGISTRY`** para resolver el business context de la sección 14.

> ### 🔴 Cambio de sistema destino — 2026-10-23
>
> Esta comprobación **no** se hizo sobre el appliance `S4H` de AWS (`34.228.25.48`) del PoC-1, sino sobre un **servidor on-premise de Cemex, release 2025**, alcanzable en `https://10.222.55.7`, mandante `100`. **Ese es el sistema de pruebas de aquí en adelante.**
>
> Es una mejora de fondo —un on-premise real del cliente es más representativo que un appliance de SAP CAL, y 2025 trae la extensibilidad más madura que 2023—, pero **invalida tres supuestos del bloque C**. Ver sección 9.

### 6.4 🔴 El usuario `BPINST` puede estar bloqueado

> ### Trampa 25 — los usuarios demo del appliance vienen bloqueados
>
> El *SAP S/4HANA Fully-Activated Appliance* **sí** trae el launchpad y el contenido Fiori activados — es su argumento frente a una instalación estándar. Pero en las entregas recientes **SAP bloquea por seguridad los usuarios demo iniciales, incluidos los `S4H_*` y `BPINST`**.
>
> El acceso de arranque es con **`DDIC`** o **`SAP*`** y la *master password* elegida en la consola de SAP CAL. Desde ahí se desbloquean en `SU01` los usuarios de diálogo.
>
> **Relevante para este proyecto:** todo el PoC-1 se hizo con `BPINST` por SAP GUI y ADT, que funcionó. Pero el acceso Fiori puede comportarse distinto. Conviene probar el launchpad con `BPINST` **antes** de planificar nada.

---

## 7. Bloque A — Crear el campo propio

- [ ] **A1.** Abrir el launchpad y buscar la app **`Custom Fields`**.

> ### Trampa 26 — el nombre de la app cambió
>
> Hasta S/4HANA 2020 el tile se llamaba **`Custom Fields and Logic`** (app `F1481`). **Desde S/4HANA 2021 está partida en dos**: `Custom Fields` (`F1481`) y `Custom Logic` (`F6957`).
>
> Existe una KBA específica, la **3136810**: *"The Custom Fields and Logic tile shows Deprecated in SAP S/4HANA 2021 and higher"*. Si en el sistema aparece el tile antiguo marcado como *Deprecated*, **no es un fallo**: es el comportamiento esperado. Hay que usar `Custom Fields`.

- [ ] **A2.** `Create` → elegir el **business context**.

> ### Trampa 27 — el business context decide todo y elegir mal es caro
>
> El contexto determina **en qué tabla aterriza el campo, en qué entidad OData aparece y qué usos se ofrecen después**. Y para Business Partner hay varios que se parecen peligrosamente:
>
> | Contexto | Tabla | Entidad OData |
> |---|---|---|
> | *Business Partner Core View* | `BUT000` | `A_BusinessPartner` |
> | Vista de cliente | `KNA1` / `INCL_EEW_KNA1` | `A_Customer` |
> | *Master Data: Business Partner* | — | Distinto de los anteriores |
>
> Que son contextos **distintos con capacidades distintas** lo demuestra la **KBA 3084335**: el uso para la SOAP API de replicación de BP *"solo está disponible para campos creados bajo el business context Master Data: Business Partner"*.
>
> **Antes de crear nada, abrir `SCFD_REGISTRY`** y ver qué contextos existen en ESE sistema y cómo se llaman. Los códigos que aparecen en la documentación de Cloud (por ejemplo `BP_CUSTVEND1`) **no están confirmados para on-premise 2023**: no citarlos delante del cliente sin comprobarlos.

- [ ] **A3.** Rellenar etiqueta y tipo. `Create and Publish`, o `Save` y después `Publish`.

> **`Publish` es obligatorio.** Un campo guardado pero no publicado **no entra en el `$metadata` ni en la base de datos**. La documentación de SAP es literal: *"Once the extended field has been successfully published, it'll be part of the metadata of the OData service and the corresponding database"*.

> ### 🔴 Trampa 40 — `Publishing not possible. Upgrade preparation is running.`
>
> **Ocurrido en S4H el 2026-10-27.** El campo se crea y se guarda sin problema, aparece en la lista, y **el `Publish` falla** con:
>
> ```
> ❌ Publishing not possible. Upgrade preparation is running.
> ✅ Please check custom field log (transaction SCFD_LOG) for further messages
> ```
>
> - Mensaje: **`CFD_DE_HANDLER026`**
> - KBA específica: **3216699** — *"Custom Fields app error when publishing a field: Publishing not possible. Upgrade preparation is running."*
>
> **Qué es.** Un bloqueo **de sistema, no de usuario ni de permisos**. Mientras el sistema está marcado como en preparación de upgrade, la extensibilidad key user impide publicar, para no generar objetos que el upgrade no controle. No se arregla con roles, ni reintentando, ni cambiando de contexto.
>
> **Por qué despista.** Los dos pasos del bloque A se parecen pero son independientes: **crear el campo funciona y publicar no**. Como el campo queda visible en la lista, es fácil creer que salió bien y seguir al bloque B — donde `Enable Usage` tampoco servirá de nada, porque sin publicación el campo no llega ni a la base de datos ni al `$metadata`.
>
> **Qué hacer:**
>
> 1. **`SCFD_LOG`** — el log de custom fields, que es lo que pide el propio mensaje. Ahí está el detalle.
> 2. Abrir la **KBA 3216699** con un S-user.
> 3. Preguntar a Basis si hay un **SUM / preparación de upgrade realmente en curso** en S4H, o si quedó un **flag residual** de una preparación abortada. Son dos situaciones muy distintas: la primera se espera, la segunda se limpia.
>
> **Impacto en la planificación.** Si el upgrade está de verdad en marcha, **el escenario queda bloqueado hasta que termine**, y eso no depende del proyecto. Conviene tener identificado un sistema alternativo antes de comprometer una fecha de demo.
>
> #### Lo que dice `SCFD_LOG`, y por qué el mensaje engaña
>
> El log da el stack completo:
>
> | Campo | Valor |
> |---|---|
> | Exception Class | **`CX_CFD_GENERATION_HANDLER`** |
> | Class | **`CL_CFD_MANAGE_JOB`** |
> | Method | **`ENSURE_NO_JOB_RUNNING`** |
> | Field Name | `ZZ1_POLICYNUMBER` |
> | Host ID | `vhcals4hci` · Client `100` |
>
> **El texto del mensaje habla de un upgrade, pero el código comprueba otra cosa.** La clase gestiona el *job* de generación de campos propios y el método se llama, literalmente, *"asegúrate de que no haya un job en ejecución"*. `Upgrade preparation is running` es la etiqueta del mensaje, no necesariamente lo que ocurre.
>
> **Eso abre un escenario mucho mejor que esperar a un upgrade:** que haya un **job colgado** que nunca terminó y dejó el candado puesto. Se limpia en minutos en vez de en semanas.
>
> **Cómo distinguirlo:**
>
> 1. **`SE24`** → `CL_CFD_MANAGE_JOB` → método `ENSURE_NO_JOB_RUNNING`. Leer qué comprueba exactamente: el nombre del job o la tabla de control. Es **lectura de código estándar para diagnosticar** — no tiene nada que ver con el compromiso de no escribir ABAP, que se refiere a no crear código propio.
> 2. **`SM37`** → buscar jobs en estado `Activo` o `Liberado`, de cualquier usuario, filtrando por `*CFD*` y por nombres relacionados con extensibilidad o upgrade. Un job activo desde hace días es un zombie, no un upgrade.
>
> Con el nombre exacto del job en la mano, Basis sabe qué cancelar sin tener que adivinar.
>
> #### `SM37` descarta el job real — 2026-10-27
>
> Búsqueda con `Job Name: *`, `User Name: *`, estado **`Active`**, desde el 01.01.2026: **`No job matches the selection criteria`**. **No hay ni un solo job activo en el sistema.**
>
> Luego el bloqueo **no lo causa un job en ejecución**, sino un **estado persistido** que marca el sistema como en preparación de upgrade y que nadie retiró. Es la hipótesis buena: un flag se limpia, un upgrade se espera.
>
> **Pistas sobre dónde mirar** (de un índice de terceros de clases SAP, **a confirmar en `SE24`**):
>
> | Dato | Valor |
> |---|---|
> | Job que gestiona `CL_CFD_MANAGE_JOB` | **`CFD_FIELD_GENERATION`** |
> | Report de adaptación de campos propios | **`CFD_REGENERATE_IN_ONPREMISE`** — SAP recomienda ejecutarlo **antes** de un upgrade |
> | KBAs relacionadas | **3441040** (fallo de regeneración tras upgrade), **2400599** (programas para regenerar campos tras upgrade o patch), **3137922** (publicación bloqueada por dependencias) |
>
> **Siguientes comprobaciones, por orden de valor:**
>
> 1. **`SE24`** → `CL_CFD_MANAGE_JOB` → `ENSURE_NO_JOB_RUNNING`. Es lo único que da la respuesta exacta.
> 2. **`SM37`** con `CFD*` y **todos los estados**, no solo `Active`: un `CFD_FIELD_GENERATION` cancelado o a medias explicaría el candado.
> 3. **KBA 3216699** con un S-user. Tiene la resolución oficial.
>
> > ### ⚠️ Lo que NO se debe hacer
> >
> > **No modificar a mano la tabla de control** para quitar el flag, por tentador que resulte. Es el sistema del cliente, no hay documentación pública de cuál es esa tabla ni de qué más depende de ella, y un PoC cuyo argumento es *"no tocamos nada del estándar"* no puede empezar editando una tabla de control de SAP. Si la KBA no da un remedio limpio, esto va a Basis o a un incidente con SAP.

> ### ✅ Trampa 31 confirmada — el prefijo es `ZZ1_`
>
> Verificado en S4H el 2026-10-27: los campos aparecen como **`ZZ1_…`**, tal como anticipaba la documentación para on-premise. **Todos los tutoriales que muestran `YY1_` son de Cloud** y no aplican aquí.
>
> El campo de este PoC se creó como **`ZZ1_PolicyNumber…`** — el nombre completo, con el sufijo del contexto, **sigue pendiente de leer del `$metadata`**, que es la única fuente válida.

---

## 8. Bloque B — Habilitar el campo en la API estándar

**Éste es el paso crítico de todo el escenario.**

- [ ] **B1.** Abrir el campo recién creado → pestaña **`UIs and Reports`**.
- [ ] **B2.** Localizar la fila **`API_BUSINESS_PARTNER 0001`**.
- [ ] **B3.** Pulsar **`Enable Usage`**.
- [ ] **B4.** **`Publish`** otra vez.

> ### Trampa 28 — el servicio NO está en la pestaña "OData APIs"
>
> La app tiene una pestaña llamada **`OData APIs`**, y todo el mundo va ahí primero. **Para `API_BUSINESS_PARTNER` es el sitio equivocado.**
>
> SAP tiene una KBA cuyo título es literalmente: **"For the Business Context Master Data: Business Partner, the OData Service API_BUSINESS_PARTNER is not available in the tab OData APIs"** — **KBA 3233361**. El caso descrito es exactamente éste: el usuario no lo encuentra bajo `OData APIs` aunque sí aparece bajo **`UIs and Reports`**.
>
> Las pestañas reales son: `UIs and Reports`, `Email Templates`, `Form Templates`, `Business Scenarios`, `OData APIs`, `SOAP APIs`, `BAPIs` e `IDocs`. **No existe ninguna pestaña llamada "Service Integration"**, pese a lo que digan algunos tutoriales.

> ### Trampa 29 — el campo no se expone solo, y el fallo es SILENCIOSO
>
> Crear y publicar el campo lo lleva a la base de datos y a la UI, **pero no al contrato de la API**. La exposición es una decisión explícita, **campo por campo y servicio por servicio**.
>
> Es por diseño: SAP no quiere que cada campo que cree un key user cambie sin querer el contrato de una API que ya están consumiendo terceros.
>
> **Lo peligroso es cómo falla.** Si el campo está creado y publicado pero **no habilitado**, no hay ningún error:
>
> | Operación | Resultado |
> |---|---|
> | `GET` | **200 OK**, pero la entidad llega **sin esa propiedad** |
> | `PATCH` con esa propiedad | **204 No Content**, y **no escribe nada** |
>
> OData V2 **descarta sin protestar** las propiedades desconocidas del payload. No hay 400, no hay 404, no hay mensaje en el log.
>
> **Consecuencia:** el modo de fallo de "no habilitado" es **indistinguible a simple vista** del de "nombre mal escrito" y del de "falta el segundo Publish". Por eso el orden de diagnóstico de la sección 11 hay que tenerlo preparado **antes** de la demo.

---

## 9. Bloque C — Ampliar BTP

> ### 🔴 Revisión obligatoria tras el cambio de servidor — 2026-10-23
>
> La tabla de abajo se escribió suponiendo el appliance de AWS. Con el on-premise de Cemex (`10.222.55.7`), **tres cosas dejan de ser ciertas** y hay que rehacerlas antes de dar nada por reaprovechado:
>
> | Supuesto del PoC-1 | Qué pasa ahora |
> |---|---|
> | El mapeo del Cloud Connector apunta a `34.228.25.48:50000` | ❌ **Hay que remapearlo** al servidor nuevo. El host virtual `s4h-poc.virtual` puede conservarse, pero el destino interno cambia |
> | Se va por **HTTP/50000**, lo que evitaba la trampa 13 | ✅ **Resuelto el 2026-10-23: el servidor nuevo también expone HTTP en `50000`.** Se mantiene el mismo planteamiento que el PoC-1 y **la trampa 13 no llega a aplicar**. Queda por comprobar que ese puerto sea alcanzable desde donde corre el Cloud Connector |
> | El backend es alcanzable desde la red del puesto sin más | ⚠️ `10.222.55.7` es una **dirección privada de la red de Cemex**. El Cloud Connector solo llega si el puesto está en esa red o con la VPN levantada. Es la trampa 22 agravada: aquí no basta con reconectar el túnel, hace falta además la VPN |
>
> **Lo que sí sigue valiendo tal cual:** el runtime de API Management, las role collections, el Developer Hub y la colección de Postman. El API Provider `S4H_POC_PROVIDER` también, **siempre que se conserve el host virtual** y solo cambie el mapeo interno.

Buena noticia: **casi todo se reaprovecha**.

| Componente | Estado | Qué cambia |
|---|---|---|
| Cloud Connector | ✅ Operativo | Solo el recurso |
| API Provider `S4H_POC_PROVIDER` | ✅ Reutilizable | Nada: apunta al host virtual, no a una ruta |
| Runtime de API Management | ✅ Operativo | Nada |
| **Recurso del Cloud Connector** | ➕ **Añadir** | Ver trampa 30 |
| API Proxy | ➕ Nuevo | Base path propio |

- [ ] **C1.** Cloud Connector → `Cloud to On-Premises` → `Resources` → `+`

| Campo | Valor |
|---|---|
| URL Path | **`/sap/opu/odata`** |
| Access Policy | **`Path and All Sub-Paths`** |

> ### Trampa 30 — el recurso actual no cubre la API estándar
>
> La API estándar es OData **V2** y cuelga de **`/sap/opu/odata`**. El PoC-1 usa **`/sap/opu/odata4`**. **Son rutas distintas y el recurso declarado hoy no cubre la nueva.**
>
> Si se omite: **403 en todo**, con el túnel verde y el mapeo `Reachable`. Es la trampa 11 del runbook repitiéndose en otra ruta — y cuesta encontrarla precisamente porque "eso ya estaba configurado".

- [ ] **C2.** API Management → nuevo API Proxy sobre `S4H_POC_PROVIDER`

| Campo | Valor |
|---|---|
| URL (ruta en el backend) | `/sap/opu/odata/sap/API_BUSINESS_PARTNER` |
| API Base Path | `/poc/bp/v1` |
| Service Type | `REST` |

> ### Trampa 39 — OData V2 devuelve URLs absolutas con el host interno
>
> El service document de este sistema viene con:
>
> ```xml
> xml:base="http://vhcals4hci.dummy.nodomain:50000/sap/opu/odata/sap/API_BUSINESS_PARTNER/"
> ```
>
> OData **V2** incrusta **URLs absolutas** en las respuestas (`xml:base`, y el `__metadata.uri` de cada entidad), construidas con el host que el ICM cree tener. A través de API Management, el cliente recibirá enlaces que apuntan a **`vhcals4hci.dummy.nodomain:50000`** — un hostname que **no resuelve fuera del servidor**.
>
> **Qué rompe y qué no.** El `GET` y el `PATCH` que hagamos por URL propia funcionan igual: no rompe el PoC. Lo que queda inservible es **navegar siguiendo los enlaces de la respuesta**, y cualquier cliente que lo haga automáticamente.
>
> El PoC-1 no se topó con esto porque OData **V4** usa referencias relativas.
>
> **Si hiciera falta arreglarlo:** una policy de API Management que reescriba el host en el cuerpo de la respuesta. No es necesario para los criterios de aceptación de la sección 12 — queda anotado para que, si alguien lo ve en la demo, se sepa qué es y no parezca un fallo del montaje.

- [ ] **C3.** **`Deploy`**, y copiar la URL del campo `API Proxy URL` — **nunca componerla a mano** (trampa 18).

---

## 10. Bloque D — Consumo desde Postman

### 10.1 Lo que cambia respecto al PoC-1

| | PoC-1 | PoC-2 |
|---|---|---|
| Versión OData | V4 | **V2** |
| Ruta | `/sap/opu/odata4/...` | `/sap/opu/odata/sap/API_BUSINESS_PARTNER` |
| EntitySet | `Customer` | `A_BusinessPartner`, `A_Customer` |
| Verbo de update | `PATCH` | `PATCH` (o `MERGE`) |
| **`If-Match`** | **No hacía falta** | **🔴 OBLIGATORIO** |

### 10.2 La secuencia

- [ ] **D1.** `GET {base}/$metadata` → buscar el campo nuevo. **Leer su nombre exacto de ahí.**
- [ ] **D2.** `GET {base}/` con `X-CSRF-Token: Fetch` → copiar token y conservar cookies.
- [ ] **D3.** `GET {base}/A_BusinessPartner('<id>')` → leer el cliente y su `ETag`.
- [ ] **D4.** `PATCH {base}/A_BusinessPartner('<id>')` con el campo nuevo → **204 No Content**.
- [ ] **D5.** Verificar con un `GET`.

> ### Trampa 31 — el nombre del campo NO es el que escribiste
>
> Dos transformaciones, y las dos despistan:
>
> **Prefijo.** SAP documenta que *"en la mayoría de sistemas on-premise el namespace de cliente está configurado como `ZZ1`, mientras que en el landscape cloud está configurado como `YY1`"*. Como casi todos los tutoriales son de Cloud, **todos muestran `YY1_` y en este sistema será `ZZ1_`**.
>
> **Sufijo.** Al nombre se le añade un sufijo derivado del contexto de negocio. Un ejemplo real documentado en esta API: el consultor escribió `TEST_EXT_DEMO` y la propiedad que aparece es **`YY1_TEST_EXT_DEMO_bus`**.
>
> **Regla:** el nombre se **lee del `$metadata`**, nunca se supone. Buscar en el `$metadata` el nombre que uno escribió lleva directo a concluir, erróneamente, que el campo "no salió".
>
> *Ojo adicional:* el setup del ATO distingue el prefijo transportable (`ZZ1_`) del de sandbox (`ZZ9_`). **Los objetos `ZZ9_` no se transportan.**

> ### Trampa 32 — `If-Match` pasa de opcional a obligatorio
>
> En el PoC-1 no hacía falta porque la behavior definition no declaraba `etag`. **Aquí sí hace falta.**
>
> El framework **SADL** devuelve **428 Precondition Required** con el mensaje `SADL_ENTITY_RUNTIME/006` — *"Precondition required for action in entity … (If-Match missing)"* — si se omite.
>
> Se puede enviar el ETag real obtenido de un `GET` previo, o **`If-Match: *`** como comodín, que salta el control de concurrencia. Para el PoC, `*` basta; en productivo se usa el ETag real.

> ### Trampa 33 — el condition string del CSRF vuelve a morder
>
> El update de esta API es **`PATCH`**, igual que en el PoC-1. Así que **el condition string que publica SAP, que cubre `POST`, `PUT` y `DELETE` pero omite `PATCH`, vuelve a aplicar tal cual**.
>
> Si se añaden policies de CSRF al proxy, el condition string debe ser:
>
> ```
> (request.verb = "POST" OR request.verb = "PUT" OR request.verb = "PATCH" OR request.verb = "DELETE")
> ```
>
> El fallo es traicionero: **la lectura funciona, el alta funciona, y solo falla la actualización.**

### 10.3 Lo que ya se sabe del PoC-1 y aplica igual

- `Accept-Encoding: gzip, deflate` — el gateway **no soporta Brotli**
- El token CSRF va atado a la cookie de sesión; Postman la mantiene sola
- `Body → raw → JSON`, nunca `Text`, o devuelve **415**

> ### Trampa 34 — roles de BP y campos de solo lectura
>
> Para que existan datos de cliente, el BP debe tener el rol asignado: **`FLCU00`** (Cliente FI, datos de sociedad) y **`FLCU01`** (Cliente, parte de ventas). Sin `FLCU01`, `A_CustomerSalesArea` no tiene registros y cualquier escritura ahí falla. Los roles se asignan con un `POST` a `A_BusinessPartnerRole`.
>
> Y la **Nota SAP 3569467**: si una tabla no forma parte del dataset de Business Partner, no puede actualizarse por esta API. Los campos marcados como *read-only* **provocan error si se envían en el `PATCH` aunque no cambien de valor**.

---

## 11. Orden de diagnóstico: "el campo no aparece en el `$metadata`"

Es el fallo más común del escenario y **delante del cliente es donde se pierde la demo**. Hay que recorrerlo en este orden:

| # | Comprobar | Cómo |
|---|---|---|
| 1 | ¿Estás buscando el nombre correcto? | `ZZ1_...` + sufijo. No el que escribiste |
| 2 | ¿El campo está **publicado**? | Estado en la app `Custom Fields` |
| 3 | ¿`Enable Usage` está marcado sobre `API_BUSINESS_PARTNER 0001`? | Pestaña `UIs and Reports` |
| 4 | ¿Se publicó **otra vez** después de habilitarlo? | Son dos publicaciones distintas |
| 5 | ¿El business context es el que corresponde a la entidad que consultas? | `SCFD_REGISTRY` |
| 6 | Caché de metadatos de Gateway | Ver abajo |

**Sobre la caché:** `/IWFND/CACHE_CLEANUP` limpia la capa frontend y `/IWBEP/CACHE_CLEANUP` la del backend. Desde `/IWFND/GW_CLIENT`, el menú `Metadata` ofrece limpiar en ambos a la vez.

> **Pero la caché es el último paso, no el primero.** No está documentada como parte del procedimiento oficial — el procedimiento termina en `Publish`. Aparece en hilos de comunidad como remedio. Y la **KBA 2830565** documenta un caso donde se probaron ambos *cache cleanup* sin éxito: **si falla, el problema está antes**, en los pasos 1 a 5.

---

## 12. Criterios de aceptación

El PoC-2 está demostrado cuando:

1. El campo propio aparece en el `$metadata` de la **API estándar**, sin una línea de ABAP.
2. Un `GET` desde Postman **a través de BTP** devuelve un cliente existente con el campo nuevo.
3. Un `PATCH` desde Postman **a través de BTP** cambia su valor **sin tocar ningún otro dato**.
4. El cambio se verifica en el sistema, sobre el maestro estándar.
5. **No se ha modificado ningún objeto SAP ni se ha creado ningún append structure.**

El punto **5 es el entregable real**. Los otros cuatro demuestran que funciona; el quinto, que es sostenible.

---

## 13. Cómo puede el cliente MEDIR su clean core

Al cliente le interesa poder ponerle un número. Existen cuatro capas, de más técnica a más ejecutiva:

| Herramienta | Qué da |
|---|---|
| **ATC** con variante clean core | Los checks `Usage of APIs` y `Allowed Enhancement Technologies` |
| **ATC** con `ABAP_CLOUD_READINESS` | Distancia a ABAP Cloud |
| **Cloudification Repository Viewer** | Estado objeto por objeto y su sucesor |
| **Custom Code Migration** | Analiza el código propio |
| **Readiness Check** | Vista ejecutiva |

> En on-premise / Cloud ERP Private la variante correcta es **la de clean core**, no la de cloud readiness.
>
> El check **`Allowed Enhancement Technologies`** se introdujo en **agosto de 2025** y es justamente el que señala los append structures. Dicho de otro modo: **SAP ya tiene un check automático que marca el enfoque C**.

---

## 14. Lo que NO se pudo verificar

Honestidad sobre los límites de esta especificación. Hay que comprobarlo en el sistema antes de darlo por bueno:

| Punto | Por qué no se confirmó |
|---|---|
| El nombre y código exactos del business context para cliente/BP en **on-premise 2023** | Los códigos documentados son de Cloud. **Abrir `SCFD_REGISTRY`** |
| Que los contextos de BP/Cliente estén **liberados para key user** en ese release | No se encontró una página que lo confirme para 2023 on-premise |
| El identificador exacto del catálogo/rol de extensibilidad | **Sigue sin confirmar.** Existe la familia `SAP_CORE_BC_EXT` con subcatálogos `_CBO`, `_CCE` y `_TST` (este último SAP dice expresamente que no se asigne fuera de un tenant de test), pero **toda la documentación localizable es de Cloud**. Un ejemplo de SAP para on-premise usa `SAP_BASIS_BC_EXT` + grupo `SAP_BASIS_BCG_EXT`. Se resuelve con la **F4 de `PFCG`** sobre el catálogo, filtrando por `*EXT*` |
| El nombre completo del campo generado | Depende del sufijo del contexto. **Se lee del `$metadata`** |
| Que `API_BUSINESS_PARTNER` sea V2 | Muy probable por la ruta, pero **confirmarlo leyendo la versión en el `$metadata`** |
| El síntoma exacto de "campo no habilitado" | Razonado desde el contrato OData, sin fuente directa |

> **Nota de método:** el proxy de salida del entorno de verificación bloquea los dominios de SAP (`help.sap.com`, `community.sap.com`). Los hallazgos se obtuvieron del contenido indexado y del espejo oficial de la documentación en GitHub (`SAP-docs`, `SAP-samples`, `SAP/abap-atc-cr-cv-s4hc`). El Cloudification Repository **sí** se descargó y consultó directamente.

---

## 15. Si el cliente ya tiene campos Z heredados de ECC

Es muy probable, y SAP ha documentado la ruta de reconversión. **El orden importa y hay riesgo de pérdida de datos.**

- [ ] Si el campo está implementado en CVI y en BP: **borrarlo primero** de la estructura `CVIS_EI_EXTERN`, en sus subestructuras `DATA` **y** `DATAX`.
- [ ] Volver a crearlo con la app `Custom Fields`.
- [ ] Alternativa para campos de `KNA1`: moverlos a la estructura de ampliación estándar **`INCL_EEW_KNA1`** y habilitarlos con **`SCFD_EUI`**.

> ### 🔴 Trampa 35 — riesgo de pérdida de datos en la reconversión
>
> El borrado del append y el alta en el include **deben activarse en UNA SOLA activación masiva**, o hay **pérdida de datos** — **SAP Note 3104595**.
>
> Un campo que siga en un Z-append aparecerá en `SCFD_EUI` como **`Preparation Required`**.
>
> **No es "mover y/o habilitar": es mover primero, habilitar después.** Y no se hace en el sistema de un cliente sin planificarlo.

---

## 16. Riesgos de ciclo de vida que conviene decir ANTES

Son advertencias de SAP sobre campos key user en on-premise. Quedan mucho mejor dichas por iniciativa propia que respondidas a la defensiva:

1. Los campos propios se desarrollan y editan **en un solo sistema de desarrollo**, nunca en varios: los nombres de artefactos generados pueden colisionar.
2. **Borrar un campo propio puede dejar el sistema inconsistente** si existen objetos generados solo en local.
3. En on-premise hay un paso extra de **registro para transporte** que en Cloud no existe.

---

## Anexo — Vistas CDS liberadas para cliente y dirección

Verificadas contra el Cloudification Repository (ficheros PCE 2023 FPS3 y 2025):

| Vista | Sustituye a | Componente |
|---|---|---|
| `I_Customer` | `KNA1` | `S4CORE` |
| `I_CustomerCompany` | `KNB1` | `S4CORE` |
| `I_CustomerSalesArea` | `KNVV` | `S4CORE` |
| `I_BusinessPartner` | `BUT000` | `SAP_ABA` |
| `I_BusinessPartnerCustomer` | Puente BP ↔ cliente | `SAP_ABA` |
| `I_BusPartAddress` | — | `SAP_ABA` |
| `I_Address_2` | `ADRC` | `SAP_BASIS` |

> ### Trampa 36 — la dirección no cuelga del cliente
>
> **`I_Customer` no tiene los datos de dirección.** La dirección cuelga del **Business Partner**.
>
> El patrón documentado por SAP: desde el cliente/BP se obtiene el **`AddressID`** (el antiguo `KNA1-ADRNR`) mediante **`I_BusPartAddress`**, y con ese ID se leen los datos postales en **`I_Address_2`**, y la comunicación en `I_AddressEmailAddress_2`, `I_AddressPhoneNumber_2`, `I_AddressFaxNumber_2`.
>
> La **KBA 2810992** lo dice explícitamente para el email: `I_Customer` tiene fax pero **no** tiene email, y la solución es pasar por `I_BusPartAddress`.

**Cómo comprobar si algo está liberado, desde ADT:**

- **Por objeto:** abrir el objeto → vista `Properties` → pestaña **`API State`**. Muestra el estado, el contrato y, si no está liberado, **el sucesor que SAP recomienda**.
- **Por catálogo:** en el Project Explorer, crear un *ABAP Repository Tree* con el criterio **`Released Objects`** y filtrar por contrato.

Contratos: **C0** = *Extend* · **C1** = *Use* (el que importa aquí) · **C2** = *Implement*.
