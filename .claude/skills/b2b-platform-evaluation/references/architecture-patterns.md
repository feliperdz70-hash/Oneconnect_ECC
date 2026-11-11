# Patrones de arquitectura y árbol de decisión

## Árbol de decisión

Recorrelo en orden. La primera condición que se cumple suele determinar el patrón; las
siguientes afinan.

```
¿Algún partner exige X.400, VAN o conectividad legacy equivalente?
├── Sí → TPM no puede ser la solución única. Patrón B o C.
└── No → seguir

¿Hay mandatos de facturación electrónica en varios países, con roadmap activo?
├── Sí → sumar al TCO el producto fiscal aparte (DRC u otro) o ir a Patrón B/C
└── No → seguir

¿El cliente quiere construir y sostener un equipo B2B propio?
├── No → Patrón C (gestionado) o Patrón B con operación delegada
└── Sí → seguir

¿Cuántos partners y con qué rotación anual?
├── Alta (decenas de altas/cambios al año) → Patrón B: la librería de mapas se paga sola
└── Baja y estable → seguir

¿Ya pagan SAP Integration Suite para A2A?
├── Sí → Patrón A es el camino de menor costo y menor fricción organizativa
└── No → comparar TCO completo; el delta de TPM deja de ser incremental
```

## Patrón A — Todo en SAP Integration Suite

```
Partners ──AS2/SFTP/OFTP2──> Integration Suite (TPM) ──IDoc/OData──> S/4HANA · ECC
```

**Cuándo.** Volumen moderado, partners estables y pocos, equipo CPI propio, Integration
Suite ya en casa, sin exposición fiscal compleja.

**Ventajas.** Una plataforma, un skillset, un plano de monitoreo, costo incremental.

**Riesgos a declarar.** Todo el peso operativo del EDI queda en el equipo interno. El
onboarding no escala por sí solo: si los partners crecen, crece el equipo. Reproceso y
archivado requieren construcción propia.

## Patrón B — Híbrido (el resultado más frecuente)

```
Partners ──todos los protocolos──> Broker B2B (SEEBURGER u otro)
                                         │
                                    canal único
                                         ▼
                              Integration Suite (A2A/API)
                                         │
                                         ▼
                                   S/4HANA · ECC · resto
```

**Cuándo.** Ecosistema de partners grande o heterogéneo, protocolos legacy, mandatos
fiscales, y a la vez necesidad de A2A/APIs modernas hacia el landscape SAP.

**Por qué funciona.** Cada plataforma hace lo que hace bien: el broker absorbe la diversidad
y la operación del mundo exterior; Integration Suite maneja el mundo SAP. Evita re-onboardear
un ecosistema de partners que ya funciona.

**Riesgos a declarar.** Dos proveedores y dos contratos. Definir desde el día uno **dónde
vive la traducción** (EDI↔canónico) y **quién es dueño del troubleshooting cuando el
incidente cruza la frontera** — sin esa definición, cada incidente se convierte en una
discusión entre proveedores.

## Patrón C — B2B totalmente gestionado

```
Partners ──> Servicio gestionado del proveedor ──canal único──> SAP
```

**Cuándo.** Sin equipo B2B ni intención de construirlo; EDI es un requisito del negocio, no
una capacidad diferencial.

**Ventajas.** Costo predecible, onboarding delegado, sin dependencia de personas clave internas.

**Riesgos a declarar.** Menor control y menor velocidad ante cambios; dependencia fuerte del
proveedor; el costo de salida es real — verificar exportabilidad de mapas y configuración
antes de firmar.

## Decisiones de diseño que hay que fijar, sea cual sea el patrón

Estas preguntas no las resuelve el producto y, si no se deciden al inicio, se pagan después:

1. **¿Dónde vive la traducción EDI?** En el broker, en Integration Suite, o partida. Partida es la opción que más dolor genera a mediano plazo.
2. **¿Formato canónico o punto a punto?** Canónico cuesta más al inicio y se paga a partir del tercer o cuarto partner.
3. **¿Quién es dueño del número de orden/factura en el monitoreo?** Define si negocio puede autoservirse.
4. **¿Cómo se versiona un agreement?** Qué pasa cuando un partner cambia de versión de mensaje y conviven ambas.
5. **¿Dónde se archiva y por cuántos años?** Es un requisito legal, no una preferencia técnica.
6. **¿Cuál es el camino de reproceso extremo a extremo?** Documentarlo con nombres de roles, no de herramientas.

## Migración desde PI/PO

Si el punto de partida es PI/PO, la evaluación tiene una dimensión extra: el fin de
mantenimiento fuerza el movimiento, pero **no obliga a quedarse en SAP**. Es el momento
natural para revisar si el B2B debe seguir en la misma plataforma que el A2A.

- Existen utilidades para migrar perfiles, agreements y mapeos de PI/PO a TPM; confirmá qué cubren en la versión actual y qué queda manual.
- Los mapeos complejos con lógica custom rara vez migran limpios: presupuestalos como desarrollo nuevo.
- La migración de partners productivos es el renglón de riesgo más alto del proyecto. Planificá convivencia por olas y rollback por partner, nunca un corte global.
