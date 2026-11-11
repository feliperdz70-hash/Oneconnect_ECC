# Matriz ponderada y modelo de TCO

## Cómo puntuar

Escala de 1 a 5 por criterio. Definila así en el entregable para que el número signifique
algo y no sea una impresión:

| Puntaje | Significado |
|---|---|
| 5 | Resuelto de serie, sin desarrollo ni producto adicional |
| 4 | Resuelto con configuración menor |
| 3 | Resuelto con desarrollo propio acotado |
| 2 | Requiere producto adicional o desarrollo significativo |
| 1 | No lo resuelve; hace falta un tercero |
| N/A | No aplica a este cliente — se excluye del denominador |

Puntaje final = Σ(puntaje × peso) / Σ(pesos de criterios aplicables).

Dos reglas que mantienen el ejercicio honesto:

1. **Todo puntaje lleva una frase de justificación.** Un número sin evidencia no sobrevive la primera pregunta del comité.
2. **Si dos plataformas quedan a menos de 0,3 puntos, el resultado es un empate técnico.** Decilo. Decidir por una diferencia de 0,1 es fabricar precisión que no existe, y en ese caso deciden factores no técnicos: relación comercial, referencias, apetito de riesgo.

## Criterios y pesos por defecto

Pesos calibrados para un cliente SAP mid-market con EDI relevante pero no crítico.
**Ajustalos al perfil y mostrá el ajuste.**

| # | Criterio | Peso | Qué se evalúa realmente |
|---|---|---|---|
| 1 | Esfuerzo de onboarding de partners | 20% | Días-persona de cero a producción para un partner nuevo típico |
| 2 | Cobertura de protocolos | 10% | ¿Cubre todo lo que exigen los partners actuales y los previstos? |
| 3 | Cobertura de estándares y mapeo | 10% | Estándares, versiones e industrias; existencia de mapas preconstruidos |
| 4 | Operación diaria y reproceso | 15% | ¿Quién resuelve un mensaje fallido un sábado, y con qué herramienta? |
| 5 | Monitoreo para negocio | 8% | ¿Puede alguien de negocio buscar por nº de pedido sin pedir ayuda a TI? |
| 6 | Cumplimiento fiscal / e-invoicing | 12% | Mandatos por país, Peppol, archivado legal, roadmap |
| 7 | Integración con el landscape SAP | 10% | IDoc, S/4, A2A, APIs, eventos; cuántas plataformas quedan en juego |
| 8 | TCO a 5 años | 10% | Licencia + productos complementarios + servicios + FTEs |
| 9 | Riesgo de migración | 5% | Re-onboarding de partners productivos, convivencia, rollback |

Ajustes típicos según perfil:

- **Automoción / retail con muchos partners:** subir #1 y #3 a 25% y 15%.
- **Operación con equipo mínimo:** subir #4 a 20% y #5 a 12%.
- **Exposición a mandatos de facturación electrónica en varios países:** subir #6 a 20%.
- **Ya hay Integration Suite y no hay presupuesto nuevo:** subir #8 a 20%.

## Modelo de TCO a 5 años

Comparar precios de licencia es el error más caro de estas evaluaciones. Calculá estos
renglones para **cada** opción, incluido el patrón híbrido.

### Costos recurrentes anuales

| Renglón | Nota |
|---|---|
| Licencia / suscripción de la plataforma | Por volumen, partners o capacity units, según modelo |
| Productos complementarios | E-invoicing, archivado, MFT, VAN. Es donde TPM pierde la ventaja aparente |
| Soporte y mantenimiento | Porcentaje sobre licencia en modelos perpetuos |
| **FTEs de operación B2B** | Monitoreo, reproceso, atención a partners. **Suele ser el renglón mayor** |
| FTEs de onboarding | Nº de partners nuevos al año × días-persona por partner × costo-día |
| Infraestructura | Solo relevante en on-premise o cloud privado |

### Costos únicos

| Renglón | Nota |
|---|---|
| Implementación inicial | Setup, conectividad, primeros flujos |
| Migración de partners existentes | **Nº de partners × días-persona.** El renglón que más se subestima |
| Formación del equipo | Nuevo skillset; mayor si se agrega un proveedor |
| Operación en paralelo | Meses de convivencia con la plataforma actual durante el corte |

### Cálculo del esfuerzo de onboarding

Es el número que decide la mayoría de los casos, así que vale la pena estimarlo explícito:

```
Esfuerzo anual = (partners nuevos/año + partners con cambios/año)
               × días-persona por partner
               × costo-día del equipo
```

Los días-persona por partner son el dato a pedirle a cada proveedor en la demo cronometrada
(ver `vendor-questions.md`). Si el proveedor no lo quiere comprometer, tomá su estimación
optimista y multiplicala por dos — es lo que muestra la experiencia de implementaciones reales.

### Presentación

Mostrá el TCO como **rango, no como punto**, con el supuesto de cada extremo. Un número único
proyecta una certeza que no existe y se vuelve en contra en cuanto el cliente pide el detalle.
