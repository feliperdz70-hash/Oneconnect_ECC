---
name: b2b-platform-evaluation
description: Marco de evaluación y selección de plataformas B2B/EDI para clientes SAP — SAP Integration Suite Trading Partner Management (TPM), SEEBURGER BIS, OpenText, Cleo, Boomi, VANs y brokers equivalentes. Úsala siempre que aparezca una comparación, selección, RFP, business case, estimación de TCO o migración de plataforma B2B/EDI/e-invoicing, y también ante keywords como TPM, Trading Partner Management, SEEBURGER, EDI, EDIFACT, X12, AS2, OFTP, Peppol, VAN, broker B2B, Integration Advisor o migración desde PI/PO — incluso si el usuario solo pide "una comparación rápida", no nombra una plataforma concreta, o pregunta por una sola de ellas. Produce scoring ponderado, TCO a 3-5 años, preguntas de due diligence al proveedor y recomendación de arquitectura.
---

# Evaluación de plataformas B2B/EDI

## Por qué existe esta skill

Las comparaciones de plataformas B2B casi siempre se deciden mal por la misma razón:
se compara **precio de licencia contra precio de licencia**, cuando el costo real está en
quién opera el EDI todos los días y en qué capacidades hay que comprar aparte para llegar
a paridad funcional.

El trabajo acá no es listar features de cada proveedor — eso lo hace cualquier página de
marketing. Es **convertir el perfil operativo del cliente en una recomendación defendible**,
con los supuestos explícitos y los puntos que el cliente debe verificar antes de firmar.

## Regla que ordena todo el análisis

Ninguna de estas plataformas es "mejor". Se diferencian en dónde ponen el costo:

- **SAP TPM** mueve el costo a **tu equipo** (onboarding artesanal de cada partner, operación diaria con herramientas de perfil técnico) a cambio de una licencia incremental barata si ya hay Integration Suite.
- **SEEBURGER y los brokers B2B especializados** mueven el costo a **licencia y servicios** a cambio de absorber la operación, el onboarding y el cumplimiento fiscal.

Por eso la pregunta que decide la evaluación no es técnica sino organizacional:
**¿el cliente quiere construir un equipo B2B o quiere comprar uno?** Si la conversación no
toca ese punto, la recomendación todavía no está lista.

## Flujo de trabajo

### 1. Levantar el perfil antes de opinar

Sin estos datos cualquier recomendación es adivinanza. Pedilos de entrada, y si el usuario
no los tiene, seguí igual pero **declará el supuesto que estás usando** en el entregable.

| Dato | Por qué cambia la respuesta |
|---|---|
| Nº de partners y rotación anual | Es el driver #1 del esfuerzo de onboarding |
| Volumen de mensajes/mes | Define el tramo de licencia y descarta opciones por costo |
| Protocolos exigidos por los partners | X.400/VAN/OFTP descartan a TPM como solución única |
| Países con mandato de facturación electrónica | TPM no lo cubre; exige DRC u otro producto aparte |
| ¿Ya tienen SAP Integration Suite? ¿Qué edición? | Cambia el delta de costo de TPM de "alto" a "incremental" |
| Tamaño y skills del equipo de integración | Decide si la operación interna es viable |
| Plataforma actual (PI/PO, broker, VAN, nada) | Define costo de migración y el mapa de partners a re-onboardear |
| Industria | Retail/automoción implica mapas específicos y ventanas de penalización |

### 2. Puntuar con la matriz ponderada

Leé `references/scoring-matrix.md` y usala tal cual. Los pesos por defecto están calibrados
para un cliente SAP mid-market; ajustalos al perfil del paso 1 y **mostrá los pesos usados**,
porque el peso es donde se esconde el sesgo de quien evalúa.

Puntuá solo criterios que afecten a este cliente. Un criterio que no aplica se marca N/A y
se saca del denominador — rellenarlo con un 3 "neutro" distorsiona el resultado.

### 3. Calcular TCO, no licencia

Leé `references/scoring-matrix.md` (sección TCO). Lo que casi siempre falta en el cálculo:
el producto de e-invoicing comprado aparte, el archivado de largo plazo, el MFT, la
conectividad VAN, y sobre todo las horas/FTE de onboarding y soporte de partners.

### 4. Contrastar con las capacidades reales

Leé `references/vendors.md` para el detalle de cada plataforma: fortalezas, límites
conocidos y qué hay que comprar por separado en cada caso.

Advertencia importante sobre este archivo: **precios, ediciones y cobertura de mandatos
fiscales cambian cada año**. Tratá el contenido como hipótesis a confirmar, no como dato
duro, y decile eso al cliente explícitamente. Si el entregable afirma un precio, tiene que
venir con fecha y fuente.

### 5. Recomendar arquitectura, no solo producto

Leé `references/architecture-patterns.md`. El resultado más frecuente de una evaluación
honesta no es "A gana a B" sino un **patrón híbrido**: broker especializado en la frontera
externa hacia partners, Integration Suite hacia los backends SAP. Si descartás el híbrido,
decí por qué.

### 6. Cerrar con preguntas al proveedor

Leé `references/vendor-questions.md` y entregá el cuestionario filtrado al caso. Esto es lo
que más valor le da al cliente: lo protege de comprar sobre la base de una demo guiada.
Insistí en la prueba cronometrada de onboarding de un partner nuevo de punta a punta — es
el único ejercicio que expone la diferencia real entre las plataformas.

## Formato de salida

Usá `assets/evaluation-template.md` como estructura del entregable. Para un pedido corto
("¿cuál conviene?") respondé en chat con las secciones de recomendación, criterio de
decisión y riesgos; reservá el documento completo para cuando haya que presentarlo a un
comité o acompañar un RFP.

Sea cual sea el largo, el entregable siempre dice **bajo qué supuestos** se recomienda y
**qué dato daría vuelta la recomendación**. Una recomendación sin esa condición es una
opinión, y el cliente no está pagando por opiniones.

## Anti-patrones

- **Declarar un ganador absoluto.** Siempre es "gana X *para este perfil*, y cambia si Y".
- **Comparar licencia contra licencia.** Ver la regla de arriba.
- **Citar precios sin fecha ni fuente.** Se desactualizan en meses y queman credibilidad.
- **Puntuar criterios que no aplican** solo para llenar la matriz.
- **Ignorar el costo de migración** de los partners ya productivos: re-onboardear 200
  partners puede costar más que la licencia de cualquiera de las dos opciones.
- **Presentar features sin traducirlas a riesgo operativo.** "No tiene reproceso nativo"
  no significa nada; "cuando una factura se rechaza un sábado, alguien de TI tiene que
  reenviarla desde el origen" sí.

## Archivos de referencia

| Archivo | Cuándo leerlo |
|---|---|
| `references/vendors.md` | Paso 4: capacidades, límites y qué se compra aparte por plataforma |
| `references/scoring-matrix.md` | Pasos 2 y 3: criterios, pesos, escala y modelo de TCO |
| `references/vendor-questions.md` | Paso 6: due diligence y pruebas a exigir en la demo |
| `references/architecture-patterns.md` | Paso 5: patrones de despliegue y árbol de decisión |
| `assets/evaluation-template.md` | Estructura del entregable final |
