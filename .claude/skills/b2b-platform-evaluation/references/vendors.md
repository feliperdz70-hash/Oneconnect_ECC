# Capacidades y límites por plataforma

> **Vigencia.** Ediciones, precios y cobertura de mandatos fiscales cambian al menos una vez
> al año. Usá este archivo como hipótesis de trabajo y confirmá con el proveedor todo lo que
> vaya a aparecer en un entregable con número o compromiso. Revisado: noviembre 2026.

## Índice

1. SAP Integration Suite — Trading Partner Management (TPM)
2. SEEBURGER Business Integration Suite (BIS)
3. Otras opciones del mercado
4. Tabla comparativa rápida
5. Qué hay que comprar aparte en cada caso

---

## 1. SAP Integration Suite — Trading Partner Management (TPM)

**Qué es.** La capacidad B2B dentro del iPaaS de SAP en BTP. Sucesor funcional del B2B
Add-on de PI/PO.

**Modelo.** Trading Partner Profile + Trading Partner Agreement almacenados en el Partner
Directory. Los iFlows son **genéricos y parametrizados por agreement**: no se construye un
iFlow por partner, lo que es su mayor acierto de diseño y lo que lo diferencia de PI/PO.

**Mapeo.** Integration Advisor, con librería de tipos (EDIFACT, ANSI X12, ODETTE, VDA,
TRADACOMS, UN/CEFACT, IDoc) y propuestas de mapeo asistidas por ML a partir de MIG/MAG.
Genuinamente bueno para construir desde cero; no reemplaza una librería de mapas ya hechos
por partner.

**Protocolos.** AS2, AS4, SFTP, HTTPS, OFTP2. **Sin X.400 ni conectividad VAN nativa.**

**Fortalezas**
- Delta de costo bajo si el cliente ya paga Integration Suite para A2A.
- Un solo proveedor, un solo skillset (CPI), un solo plano de monitoreo con el resto de la integración.
- Camino natural desde PI/PO: existen utilidades de migración de perfiles, agreements y mapeos.
- Integración nativa con IDoc, S/4HANA, eventos y APIs sobre la misma plataforma.

**Límites conocidos**
- **Onboarding artesanal.** No hay librería de mapas por retailer/OEM; cada partner nuevo es desarrollo.
- **Reproceso limitado.** Reenviar o corregir un mensaje fallido suele implicar reenvío desde el origen o construir un datastore/JMS propio. Es la queja operativa más repetida.
- **Retención corta.** El payload vive días en los logs de CPI; archivado de largo plazo requiere solución externa.
- **Monitoreo de perfil técnico.** Buscar por número de pedido o factura, no por ID de mensaje, no es inmediato para un usuario de negocio.
- **AS2 con partners que no autentican a nivel de transporte** ha generado fricción en implementaciones reales.
- **Sin e-invoicing.** Los mandatos fiscales se cubren con SAP Document and Reporting Compliance (DRC), producto y licencia aparte.
- **Solo SaaS.** No hay opción on-premise ni servicio gestionado por el proveedor.

**Licenciamiento.** Requiere edición Premium (o Enterprise con B2B). Consumo por capacity
units / mensajes, habitualmente bajo CPEA/BTPEA. Confirmar el tramo con el volumen real.

---

## 2. SEEBURGER Business Integration Suite (BIS)

**Qué es.** Plataforma B2B/EDI/MFT/e-invoicing con más de tres décadas en el mercado.
Muchos clientes SAP la conocen por sus adaptadores para PI.

**Fortalezas**
- **Librería de mapas y plantillas preconstruidas** por partner, retailer, OEM e industria (automoción, retail, logística, banca). Esto es lo que realmente comprime el tiempo de onboarding.
- **Amplitud de protocolos**: AS2, AS4, OFTP/OFTP2, X.400, SFTP/FTPS, EDIINT, conectividad VAN, Peppol Access Point, MFT completo.
- **Operación pensada para negocio**: Message Tracking con búsqueda por documento de negocio, reproceso, reenvío y corrección de mensajes de serie.
- **E-invoicing y mandatos país a país** dentro de la misma suite, con archivado y auditoría.
- **Flexibilidad de despliegue**: on-premise, cloud privado, SaaS, híbrido.
- **Servicio gestionado**: se puede externalizar el onboarding y la operación diaria. Para muchos clientes este es el argumento que decide, no las features.

**Límites conocidos**
- Proveedor adicional, contrato adicional, skillset adicional; solapamiento si ya hay Integration Suite para A2A.
- UI de administración percibida como anticuada, en particular para dar de alta partners y agreements.
- Dependencia del proveedor para cambios bajo el modelo gestionado.
- Sentimiento mixto sobre soporte en reseñas públicas — pedir referencias de clientes de tamaño y región similares.
- Licencia más cara en términos absolutos que el delta de TPM.

**Licenciamiento.** Suscripción (o perpetua on-premise) por conexiones/partners/volumen,
más servicios de implementación y, opcionalmente, de operación.

---

## 3. Otras opciones del mercado

Mencionalas cuando el perfil las justifique; no infles la comparación con proveedores que
no encajan.

| Opción | Cuándo entra en la conversación |
|---|---|
| **OpenText Business Network / Trading Grid** | Partners legacy sobre VAN, alcance global, preferencia por modelo totalmente gestionado |
| **Cleo Integration Cloud** | Mid-market con foco en logística y supply chain; buena relación costo/visibilidad de negocio |
| **SPS Commerce** | Retail norteamericano; modelo full-service con red de partners ya onboardeados |
| **Boomi / MuleSoft / Workato** | Ya son el estándar de integración del cliente; B2B/EDI es un módulo, no su fortaleza — mismo patrón de límites que TPM |
| **VAN pura (Comdata, Sterling, etc.)** | Pocos partners, sin apetito por operar nada internamente |
| **IBM Sterling B2B Integrator** | Volumen muy alto, sector financiero o retail grande, equipo propio con ese skillset |

---

## 4. Tabla comparativa rápida

| Dimensión | SAP TPM | SEEBURGER BIS |
|---|---|---|
| Origen | iPaaS con módulo B2B | Plataforma B2B que también integra |
| Modelo de partner | Profile + Agreement, iFlows genéricos | Perfiles granulares, versionado, plantillas por industria |
| Mapeo | Integration Advisor (MIG/MAG, asistido por ML) | Mapping Designer + librería preconstruida |
| Protocolos | AS2, AS4, SFTP, HTTPS, OFTP2 | + X.400, VAN, EDIINT, Peppol, MFT |
| Reproceso | Limitado | Maduro, de serie |
| Retención/archivado | Días; archivado externo | Largo plazo incluido |
| Monitoreo | Técnico | Técnico y de negocio |
| E-invoicing | No (requiere SAP DRC) | Incluido, país a país |
| Despliegue | Solo SaaS en BTP | On-prem, privado, SaaS, híbrido |
| Operación gestionada | No | Sí |
| Costo de licencia | Incremental si ya hay Integration Suite | Mayor en absoluto |

---

## 5. Qué hay que comprar aparte en cada caso

Esta sección es la que evita la comparación tramposa. Llevala al TCO.

**Si se elige TPM, falta presupuestar:**
- SAP DRC u otro producto de facturación electrónica, si hay mandatos.
- Solución de archivado de largo plazo y auditoría.
- MFT, si hay transferencias de archivos fuera del alcance de los adaptadores.
- Conectividad VAN o X.400 vía tercero, si algún partner la exige.
- **FTEs de onboarding y soporte de partners** — normalmente el renglón más grande y el más olvidado.

**Si se elige SEEBURGER, falta presupuestar:**
- Integration Suite igualmente, si hay escenarios A2A y de API que el broker no cubre bien.
- Servicios de implementación inicial y migración de los partners existentes.
- Costo de coordinación entre dos proveedores cuando un incidente cruza la frontera.
