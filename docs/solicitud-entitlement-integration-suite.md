# Solicitud de entitlement — Integration Suite en POC-CAL

Texto listo para enviar a Ayax. Sin tablas, para que se pegue limpio en Outlook.

---

**Asunto:** POC-CAL — falta el entitlement de Integration Suite para cerrar la PoC de migración de interfaces

---

Hola Ayax:

Te escribo por el entitlement de **Integration Suite** en la subcuenta **POC-CAL**, que quedó pendiente desde septiembre. Ya es lo único que nos bloquea.

**Dónde estamos**

La prueba de concepto de migración de interfaces de PI/PO a APIs está terminada por el lado de SAP y por el lado de la conectividad:

- Creamos un campo propio en el maestro de Business Partner con extensibilidad key user, sin una sola línea de ABAP.
- El campo ya se lee y se escribe a través de la API estándar `API_BUSINESS_PARTNER`.
- El Cloud Connector está configurado contra POC-CAL, con el túnel conectado y el mapeo al servidor S/4HANA en estado **Reachable**.

Lo único que falta es **publicar esa API en API Management**, que es el entregable que pide el cliente: que la llamada se haga a través de BTP, con API key y control de acceso, y no directamente contra el servidor.

**Qué necesitamos**

Que se asigne cuota de **Integration Suite** a la subcuenta **POC-CAL** (subaccount ID `f2685d1b-ccac-43a3-b9a4-3772bfc774f6`, región US East (VA) - Azure).

Hoy la subcuenta tiene 34 entitlements, entre ellos `connectivity`, `destination` y `cloudfoundry`, pero **ninguno de API Management**.

**La pregunta concreta**

¿La global account de Cemex Operaciones México tiene cuota de Integration Suite disponible para asignar?

- **Si la tiene:** con asignarla a POC-CAL desde Entitlements nos desbloqueas, y seguimos el mismo día.
- **Si no la tiene:** entonces no es una asignación sino una licencia que habría que adquirir, y necesitamos saberlo cuanto antes para replantear los tiempos del PoC con el cliente.

Esa distinción es la que más nos ayuda ahora mismo, aunque la respuesta sea la segunda.

**Mientras tanto**

Tenemos el escenario completo y funcionando en una subcuenta trial, así que podemos demostrarlo si hiciera falta. Pero es un trial, caduca, y no es el entorno de Cemex: para cerrar la PoC como corresponde necesitamos POC-CAL.

Si te sirve que lo veamos juntos en una llamada corta, dime y lo montamos.

Gracias,

**Felipe Rodríguez**
Onibex
felipe.rodriguez@onibex.com
