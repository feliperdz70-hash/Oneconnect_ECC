# Due diligence: qué preguntar y qué exigir en la demo

La documentación y la demo guiada muestran el camino feliz. Estas preguntas existen para
salir de él. Entregá al cliente la lista filtrada a su caso — no las 40 preguntas enteras,
porque una lista inmanejable no se usa.

## La prueba que más importa

**Onboarding cronometrado de un partner nuevo, de cero a producción, delante del cliente.**

Pedí que lo hagan con un partner realista del sector del cliente, no con el ejemplo de la
demo. Cronometrá y observá:

- ¿Cuántas personas distintas hacen falta y con qué perfil?
- ¿Cuánto es configuración y cuánto es desarrollo?
- ¿Existe un mapa preconstruido para ese partner o se arma desde cero?
- ¿Cómo se prueba contra el partner antes de ir a producción?
- ¿Qué pasa cuando el partner cambia una versión de mensaje seis meses después?

Ningún documento comercial distingue las plataformas tan bien como este ejercicio.

## Operación

1. Una factura se rechaza un sábado por la noche. Mostrame el camino completo: alerta, diagnóstico, corrección, reenvío. ¿Quién de mi organización puede hacerlo?
2. ¿Puede un usuario de negocio buscar por número de pedido o factura sin involucrar a TI?
3. ¿Se puede reprocesar un mensaje corrigiendo el payload, o hay que reenviar desde el sistema origen?
4. ¿Cómo se detecta un acuse (997/CONTRL/MDN) que nunca llegó? ¿Hay escalado automático?
5. ¿Qué pasa si un partner envía un lote duplicado? ¿Hay detección de duplicados?
6. ¿Cómo se gestionan los certificados por vencer de AS2/OFTP? ¿Avisa el sistema?

## Datos y cumplimiento

7. ¿Cuántos días se conserva el payload completo y qué cuesta extenderlo?
8. ¿El archivado cumple requisitos de auditoría fiscal en los países del cliente?
9. ¿Qué mandatos de facturación electrónica están cubiertos hoy, exactamente, por país? Pedí el roadmap por escrito con fechas.
10. ¿Peppol Access Point propio o vía tercero?
11. ¿Dónde residen los datos y qué certificaciones tiene la plataforma?

## Comercial

12. ¿Qué edición exacta hace falta y qué queda fuera de ella?
13. ¿Qué pasa con el costo si el volumen se duplica? Pedí el escalón siguiente por escrito.
14. ¿El precio es por partner, por conexión, por mensaje o por capacity unit? ¿Qué cuenta como uno?
15. ¿Qué incluye el soporte y cuáles son los SLA reales por severidad? ¿Hay cobertura 24/7 en la zona horaria del cliente?
16. ¿Qué cuesta salir? Exportabilidad de mapas, perfiles y configuración al terminar el contrato.
17. ¿Hay costos de servicios profesionales obligatorios además de la licencia?

## Migración

18. ¿Cuántos de los partners actuales requieren re-onboarding completo y cuántos migran con configuración?
19. ¿Se puede correr en paralelo con la plataforma actual durante el corte? ¿Cómo se divide el tráfico?
20. ¿Hay utilidades de migración desde la plataforma de origen (PI/PO, broker actual) y qué cubren realmente?
21. ¿Cuál es el plan de rollback si el corte falla con partners productivos?

## Referencias

22. Dos clientes de tamaño, industria y región similares, con contacto directo — no un caso de éxito escrito.
23. Preguntales a esas referencias: ¿cuánto tardó el onboarding real contra lo prometido, y cómo responde el soporte cuando hay un incidente con un partner grande?

## Señales de alerta

- El proveedor no quiere cronometrar el onboarding con un partner realista.
- "Eso lo cubrimos" sin mostrarlo en pantalla.
- El roadmap de mandatos fiscales se entrega solo verbalmente.
- No hay referencias del tamaño y la región del cliente.
- El precio solo se sostiene con un volumen que el cliente todavía no tiene.
