# Solicitud de accesos — S4H / mandante 100

Petición a Basis / Seguridad para desbloquear el escenario 2. Reutilizable para las siguientes interfaces: basta cambiar la app y las transacciones.

**Escrita como texto de correo, sin tablas**, para que se pegue limpia en Outlook.

---

**Asunto:** Solicitud de accesos en S4H/100 — extensibilidad key user para PoC de migración de interfaces

---

Hola Omar, Ayax:

Estamos ejecutando la prueba de concepto de migración de interfaces de PI/PO a APIs, y necesitamos unos accesos acotados en **S4H, mandante 100**, para el usuario **E0FLRODRIGZ**.

El escenario consiste en agregar un campo propio al maestro de clientes y exponerlo a través de la API estándar **API_BUSINESS_PARTNER**, usando extensibilidad key user, que es la vía que SAP recomienda para este caso. No se modifica ningún objeto estándar ni se escribe código ABAP.

Necesitamos tres cosas:

**1. Un rol que contenga el business catalog de extensibilidad key user**, el que da acceso a la app Fiori **F1481 – Custom Fields**.

El nombre exacto del catálogo cambia entre releases, y la documentación pública que encontramos corresponde a S/4HANA Cloud, así que preferimos no proponer un identificador que pueda no aplicar a este sistema. Lo identificamos por la app: **F1481 – Custom Fields**. Como referencia, los candidatos que aparecen documentados son SAP_CORE_BC_EXT, SAP_BASIS_BC_EXT y SAP_UI_FLEX_KEY_USER, pero conviene confirmarlo con la ayuda de búsqueda de PFCG filtrando por *EXT*.

**2. La transacción SCFD_REGISTRY**, solo de consulta, para ver qué contextos de negocio son extensibles en este sistema.

**3. La transacción S_ATO_SETUP**, o bien que ustedes nos confirmen si el Adaptation Transport Organizer ya está configurado. Es prerrequisito técnico de todas las herramientas key user: sin él, la app devuelve "Key User Application is not Configured". Si no estuviera configurado, la nota SAP 2807979 describe el procedimiento y la 2283716 el error.

Para dar contexto de lo que **no** estamos pidiendo:

- No pedimos SAP_ALL ni perfiles amplios.
- No pedimos clave de desarrollador ni autorización de desarrollo (S_DEVELOP).
- No se modificarán objetos SAP estándar ni se crearán appends sobre tablas estándar.
- Es para el sistema de pruebas, no para productivo.

Dónde estamos: ya tenemos acceso a /IWFND/MAINT_SERVICE y verificamos que el servicio API_BUSINESS_PARTNER está activo y responde correctamente. El launchpad abre con nuestro usuario, pero sin catálogos asignados, así que la app todavía no es accesible. **Es el único punto que nos bloquea hoy.**

Si prefieren que lo tramitemos por otra vía o con algún formulario, nos dicen y lo hacemos.

Quedamos atentos. Gracias,

**Felipe Rodríguez**
Onibex
felipe.rodriguez@onibex.com
