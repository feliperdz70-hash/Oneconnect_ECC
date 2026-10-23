# Solicitud de accesos — S4H / mandante 100

Plantilla de la petición a Basis / Seguridad. Reutilizable para las siguientes interfaces del proyecto: basta cambiar la app y las transacciones.

---

**Asunto:** Solicitud de accesos en S4H/100 — extensibilidad key user para PoC de migración de interfaces

---

Hola [Nombre]:

Estamos ejecutando una prueba de concepto de migración de interfaces de PI/PO a APIs, y necesitamos unos accesos acotados en **S4H, mandante 100**, para el usuario **`E0FLRODRIGZ`**.

El escenario consiste en añadir un campo propio al maestro de clientes y exponerlo a través de la API estándar `API_BUSINESS_PARTNER`, usando **extensibilidad key user**, que es la vía que SAP recomienda para esto. **No se modifica ningún objeto estándar ni se crea código ABAP.**

## Lo que necesitamos

| # | Qué | Para qué |
|---|---|---|
| 1 | Rol con el **business catalog de extensibilidad key user**, el que da acceso a la app Fiori **`F1481` – Custom Fields** | Crear el campo propio y habilitarlo en la API |
| 2 | Transacción **`SCFD_REGISTRY`** (solo consulta) | Ver qué contextos de negocio son extensibles en este sistema |
| 3 | Transacción **`S_ATO_SETUP`**, o bien que ustedes confirmen si el **Adaptation Transport Organizer** ya está configurado | Es prerrequisito técnico de todas las herramientas key user. Sin él, la app devuelve *"Key User Application is not Configured"* |

Sobre el punto 1: el nombre exacto del catálogo varía entre releases y la documentación pública que encontramos es de S/4HANA Cloud, así que **preferimos no proponer un identificador que pueda no corresponder a este sistema**. Lo identificamos por la app: **`F1481` – Custom Fields**. Si les sirve de pista, los candidatos que aparecen en la documentación son `SAP_CORE_BC_EXT`, `SAP_BASIS_BC_EXT` y `SAP_UI_FLEX_KEY_USER`, pero conviene confirmarlo con la ayuda de búsqueda de `PFCG` filtrando por `*EXT*`.

Sobre el punto 3: si el ATO no estuviera configurado, la nota **2807979** describe el procedimiento y la **2283716** el error que aparece cuando falta.

## Lo que NO estamos pidiendo

- No pedimos `SAP_ALL` ni perfiles amplios.
- No pedimos clave de desarrollador ni autorización de desarrollo (`S_DEVELOP`).
- No se van a modificar objetos SAP estándar ni crear appends sobre tablas estándar.
- Los accesos son para el sistema de pruebas, no para productivo.

## Estado actual

Ya tenemos acceso a `/IWFND/MAINT_SERVICE` y hemos verificado que el servicio `API_BUSINESS_PARTNER` está activo y responde correctamente. El launchpad abre con nuestro usuario, pero sin catálogos asignados, por lo que la app no es accesible todavía. **Es el único punto que nos bloquea.**

Si necesitan que lo tramitemos por otra vía o con un formulario concreto, indíquennoslo y lo hacemos.

Gracias,

**Felipe Rodríguez**
Onibex
felipe.rodriguez@onibex.com
