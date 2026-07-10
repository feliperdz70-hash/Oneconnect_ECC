# Bitácora de cambios — OneConnect ECC

Registro de las modificaciones realizadas sobre el repositorio y su estado de aplicación en SAP.
Cada entrada indica: qué se pidió, qué se cambió (archivo y objeto SAP), y si ya se aplicó manualmente en SAP.

---

## 2026-07-10 — Botón "Clone" en pantalla principal (ZONT_ONECM)

**Pedido**: agregar un botón en la pantalla inicial que ejecute la misma acción que la opción "Clone" del menú "Entity Actions", ubicado entre los botones Change y Delete.

**Cambio en el repo**:
- Archivo: `src/zonpg_oneconnect_cust_exe.prog.xml`
- Objeto SAP: Programa `ZONPG_ONECONNECT_CUST_EXE`, **Pantalla (Dynpro) 0100**
- Detalle: nuevo pushbutton `CLONE` (función `CLONE`, ícono `ICON_SYSTEM_COPY`, línea 8 columna 53, grupo `MOD`). Se recorrieron `DELETE` (col. 53→66) y `EXECUTE` (col. 65→78) para dejar espacio. No se tocó lógica ABAP (el function code `CLONE` ya existía en `user_command_0100 INPUT` → `call_screen603`).

**Estado**:
- ✅ Commiteado y subido a la rama `claude/powershell-install-04v2o7`
- ✅ PR creado: https://github.com/feliperdz70-hash/Oneconnect_ECC/pull/1
- ⏳ **Pendiente**: aplicar manualmente en SAP (Screen Painter de la pantalla 0100) — el import vía abapGit del `.prog.xml` no se ha confirmado como hecho por el usuario.

---

## 2026-07-10 — Saneo de caracteres especiales en JSON (ZONCL_OC_ANY_HANDLER)

**Pedido**: en el método `SEND_JSON_ANY_TABLE_LTABLES`, revisar dónde se arma el JSON y confirmar que exista una rutina (`PRETTY_JSON_ANY`) que reemplace caracteres especiales en los nombres de campo del JSON, ejemplo `/dis/field` → `_dis_field`.

**Hallazgo**:
- El JSON se serializa en `SEND_JSON_ANY_TABLE_LTABLES` (línea ~7148) vía `zoncl_ui2_cl_json=>serialize(...)`, y antes de enviarse se llama a `me->pretty_json_any(...)` (línea ~7771).
- El reemplazo `/` y `\` → `_` (+ minúsculas) **ya existe**, pero solo dentro de `SET_METADATA_NODE_ANY` (líneas 8650-8651 y 8723-8724), aplicado al bloque `METADATA` — **no** dentro de `PRETTY_JSON_ANY`, y por lo tanto **no cubre el `BODY`** del JSON.

**Propuesta de cambio** (código entregado al usuario, **aún no aplicado** al repo):
- Archivo: `src/zoncl_oc_any_handler.clas.abap`
- Objeto SAP: Clase `ZONCL_OC_ANY_HANDLER`, método `PRETTY_JSON_ANY`
- Detalle: agregar saneo de claves JSON vía regex (`FIND REGEX ... SUBMATCHES ...` + `REPLACE SECTION OFFSET ...`) que reemplaza `/` y `\` **solo dentro de los keys** del JSON (no en los valores, para no corromper datos reales que contengan `/`, ej. fechas).

**Estado**:
- ⏳ **Pendiente de confirmación del usuario** para aplicar el cambio al archivo y subirlo (aún no commiteado).

---

<!-- Nuevas entradas se agregan arriba de esta línea, con fecha y el mismo formato. -->
