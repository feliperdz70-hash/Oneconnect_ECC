# Incidencia para Basis — semáforo huérfano en S4H

Texto listo para enviar. Diagnóstico ya hecho; a Basis solo le queda confirmar y actuar.

---

**Asunto:** S4H — semáforo huérfano en LMSEMAPHORE bloquea la extensibilidad key user (todos los mandantes)

---

Hola Omar, Ayax:

Hemos localizado un bloqueo en **S4H** que afecta a **todos los mandantes** y que lleva activo desde noviembre de 2025. Les paso el diagnóstico completo porque creemos que la acción es de su lado.

## El síntoma

La app Fiori **Custom Fields** (`F1481`) no permite publicar ningún campo propio. Devuelve:

> Publishing not possible. Upgrade preparation is running.

Mensaje `CFD_DE_HANDLER026`, KBA **3216699**. **No hay ningún upgrade en curso.**

## La causa

Rastreando el código estándar, la comprobación acaba en la tabla **`LMSEMAPHORE`**:

```
CL_CFD_MANAGE_JOB->ENSURE_NO_JOB_RUNNING
  → IS_UPGRADE_PREPARATION_RUNNING
    → CL_ATO_SERVICE_FACTORY=>GET_ATO_CHECK( )
      → CL_ATO_OBJECT_CHECKS->CHECK_UPGRADE_LOCK_IS_PREPARED
        → CL_ATO_LM_SEMAPHORE->CHECK_UPGRADE_SEMAPHORE_EXISTS
          → SELECT ... FROM LMSEMAPHORE WHERE system_name = sy-sysid
```

En `SE16N` sobre `LMSEMAPHORE` hay **una fila**:

| Campo | Valor |
|---|---|
| SYSTEM_NAME | S4H |
| CLIENT_RANGE | `*` (todos los mandantes) |
| PROCESS_TYPE | ABAP_OCS_IMPORT |
| PROCESS_ID | SAINT_S4HID_INITIAL_20251127084229 |
| TOOL_NAME | SAINT |
| STATUS | R (Running) |
| START_TIMESTAMP | 27/11/2025 08:42:29 |

El `PROCESS_ID` incluye `INITIAL` y la herramienta es `SAINT`, así que **parece un residuo de la instalación inicial del sistema**. El estado `R` lleva once meses, lo que descarta que el proceso siga vivo.

Mientras ese semáforo exista, **ningún key user puede publicar campos propios en ningún mandante**. No lo habíamos detectado antes porque hasta ahora nadie había intentado publicar uno.

## Lo que les pedimos

1. Confirmar en **`SAINT`** y **`SPAM`** que no hay ninguna cola pendiente ni sin confirmar.
2. Si está todo limpio, valorar la retirada de esa entrada. La nota **2751168** contempla borrarla cuando no hay ningún proceso en curso y la entrada no se necesita; la **2824291** documenta un caso del mismo semáforo bloqueando otra operación.
3. Si hay cualquier duda sobre el estado de la cola, abrir incidente a SAP en el componente **`BC-UPG-OCS-SPA`**.

**No hemos tocado nada**, y no vamos a hacerlo. Sabemos que circula como workaround editar `LMSEMAPHORE` con `SE16` en modo debug, y nos parece que el mantenimiento de esa tabla está restringido por algo. Tampoco proponemos resetear la cola de SPAM/SAINT sin mirar antes en qué fase quedó, porque después de `DDIC_IMPORT` eso puede dejar el sistema inconsistente.

## Contexto

Es para la prueba de concepto de migración de interfaces de PI/PO a APIs. El campo ya está creado y solo falta publicarlo, así que en cuanto se libere el semáforo seguimos sin rehacer nada.

Quedamos atentos. Gracias,

**Felipe Rodríguez**
Onibex
felipe.rodriguez@onibex.com
