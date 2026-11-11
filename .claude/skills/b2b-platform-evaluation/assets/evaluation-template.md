# Evaluación de plataforma B2B/EDI — [Cliente]

**Fecha:** [fecha] · **Preparado por:** [autor] · **Versión:** [v]

## 1. Resumen ejecutivo

[Recomendación en dos o tres frases, con el patrón de arquitectura propuesto.]

**Recomendación:** [Opción / patrón]
**Válida bajo estos supuestos:** [los 2-3 supuestos que la sostienen]
**Qué daría vuelta esta recomendación:** [el dato o condición que cambiaría la respuesta]

## 2. Perfil del cliente

| Dato | Valor | Fuente / supuesto |
|---|---|---|
| Partners actuales / rotación anual | | |
| Volumen de mensajes/mes | | |
| Protocolos exigidos | | |
| Países con mandato de e-invoicing | | |
| Plataforma de integración actual | | |
| Equipo de integración (FTEs y skills) | | |
| Industria | | |

Los datos marcados como supuesto deben confirmarse antes de decidir.

## 3. Opciones evaluadas

[Una o dos frases por opción, incluido el patrón híbrido. Si se descartó alguna de entrada,
decir por qué.]

## 4. Matriz de evaluación

Pesos ajustados al perfil de la sección 2. Escala 1-5 (ver criterio en la nota al pie).

| Criterio | Peso | Opción A | Opción B | Opción C | Justificación |
|---|---|---|---|---|---|
| Esfuerzo de onboarding | | | | | |
| Cobertura de protocolos | | | | | |
| Estándares y mapeo | | | | | |
| Operación y reproceso | | | | | |
| Monitoreo para negocio | | | | | |
| Cumplimiento fiscal | | | | | |
| Integración con SAP | | | | | |
| TCO a 5 años | | | | | |
| Riesgo de migración | | | | | |
| **Total ponderado** | **100%** | | | | |

> Escala: 5 = de serie · 4 = configuración menor · 3 = desarrollo acotado · 2 = producto adicional o desarrollo significativo · 1 = requiere un tercero · N/A = no aplica (excluido del denominador).
> Diferencias menores a 0,3 puntos se consideran empate técnico.

## 5. TCO a 5 años

| Renglón | Opción A | Opción B | Opción C |
|---|---|---|---|
| Licencia / suscripción | | | |
| Productos complementarios | | | |
| Implementación inicial | | | |
| Migración de partners | | | |
| FTEs de operación | | | |
| FTEs de onboarding | | | |
| **Total 5 años (rango)** | | | |

Supuestos del cálculo: [días-persona por partner, costo-día, crecimiento de volumen, tipo de cambio].

## 6. Arquitectura recomendada

[Diagrama o descripción del patrón, con la frontera entre plataformas explícita.]

Decisiones de diseño a fijar antes de implementar:
1. Dónde vive la traducción EDI
2. Canónico o punto a punto
3. Dueño del monitoreo de negocio
4. Versionado de agreements
5. Archivado: dónde y por cuántos años
6. Camino de reproceso extremo a extremo

## 7. Riesgos y mitigaciones

| Riesgo | Impacto | Probabilidad | Mitigación |
|---|---|---|---|

## 8. Verificaciones pendientes con proveedores

[Cuestionario filtrado desde `vendor-questions.md`, con la prueba de onboarding cronometrado
siempre incluida.]

## 9. Próximos pasos

| # | Acción | Responsable | Fecha |
|---|---|---|---|

---

**Nota sobre fuentes.** Precios, ediciones y cobertura de mandatos fiscales citados en este
documento son hipótesis de trabajo a fecha [fecha] y deben confirmarse por escrito con cada
proveedor antes de tomar la decisión.
