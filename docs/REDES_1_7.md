# Redes prácticas, ciberdefensa y certificaciones · 1.7

La ampliación añade seis cursos de diez lecciones y sesenta ejercicios cada uno. Cada lección contiene cuatro apartados de teoría original, entre 600 y 900 palabras, dos casos resueltos, un procedimiento y seis preguntas con explicación de cada alternativa. El contenido nuevo validado reúne **39 621 palabras de teoría, 120 casos y 360 preguntas**. El recuento de teoría excluye casos, diálogos, pasos y respuestas.

## Cómo estudiar

La sexta ruta, **Redes prácticas y ciberdefensa**, propone IPv4, IPv6, switching y enrutamiento, diagnóstico, defensa y operaciones. El orden es orientativo: no bloquea cursos. Aoi presenta el concepto, comenta sus apartados y casos, ofrece pistas y analiza respuestas. Sus mensajes son fijos por contexto; el primer error recibe una reacción suave y la reincidencia, una más mordaz. Se reutilizan las dieciséis expresiones locales.

Las lecciones nuevas se aprueban con cuatro aciertos de seis. La primera aprobación de una lección otorga 50 XP; los reintentos conservan la mejor nota. Completar las diez lecciones produce el cierre de curso correspondiente. Las simulaciones y situaciones son ficticias y defensivas; no requieren conectarse a equipos externos.

## Refuerzos de los cursos anteriores

Redes desde cero, IP y DNS, Wi‑Fi doméstico, redes públicas, navegación segura y privacidad web conservan sus cuarenta microlecciones originales y añaden cuarenta ejercicios nuevos por curso. Se abren desde **Practicar refuerzos** en la ficha del curso.

Cada refuerzo corresponde al concepto de una lección anterior y plantea otro escenario. Tiene su propia nota, errores y repaso. No cambia el resultado previo de esa lección, no añade XP de lección y no es requisito para conservar la finalización del curso. La última lección de estudio continúa disponible al volver del banco. El panel de progreso muestra los refuerzos por separado y los incluye en la precisión de las preguntas que ya tienen nota.

La academia suma **31 cursos, 490 lecciones, 1290 preguntas regulares y 240 refuerzos**: 1530 ejercicios en total, además de cinco preguntas de diagnóstico. Las 430 lecciones anteriores conservan IDs y umbrales de aprobación. La ampliación contiene **4026 líneas originales de Aoi**: 2346 para los seis cursos y sus cierres, y 1680 para los refuerzos.

## Orientación de certificaciones

La guía se abre desde Inicio, Rutas o Explorar y funciona offline. Cada ficha explica destinatarios, conocimientos previos, objetivos, cursos relacionados y trabajo adicional pendiente, con enlaces oficiales que pueden copiarse para consultarlos con conexión.

| Meta | Orientación |
| --- | --- |
| Cisco CCST Networking | Entrada a redes y soporte; una opción inicial antes de profundizar hacia CCNA. |
| Cisco CCST Cybersecurity | Entrada defensiva: principios, redes, dispositivos, riesgo e incidentes. |
| ISC2 Certified in Cybersecurity (CC) | Alternativa inicial de base general. La guía usa el esquema vigente desde septiembre de 2026. |
| Cisco CCNA | Profundización en redes, con práctica adicional de configuración, servicios y automatización. |

CCST Cybersecurity e ISC2 CC pueden elegirse como alternativas según el objetivo; no se exige obtener ambas. CCST no es requisito formal de CCNA. Los indicadores cuentan lecciones superadas dentro de Aiocyb, **no preparación certificada, probabilidad de aprobar ni una credencial conseguida**. Las entidades externas administran sus procesos. La guía no copia preguntas de sus exámenes ni distribuye sus documentos de certificación.

Referencias y fecha de consulta: [CERTIFICACIONES_FUENTES_1_7.md](CERTIFICACIONES_FUENTES_1_7.md). La app incluye las referencias técnicas de IETF, NIST, Cisco, Wireshark, FIRST y documentación oficial de sistemas junto a cada lección.

## Edición y comprobación del contenido

Los originales están en `assets/network_expansion/`: una cabecera Markdown por curso y diez fragmentos en su subcarpeta. Los seis archivos `*.practice.md` contienen los 240 refuerzos. `python tool/compile_network_expansion.py` transcribe a JSON, verifica cantidades, palabras, opciones, casos, fuentes y duplicados normalizados frente a la ampliación y al banco anterior; después exporta `lib/src/data/network_expansion.g.dart`.

El compilador no genera ni rellena prosa durante el estudio. La app usa constantes locales. El reporte [NETWORK_EXPANSION_AUDIT.json](NETWORK_EXPANSION_AUDIT.json) registra los originales y sus SHA‑256. El selector de temas, favoritos, notas y errores siguen guardándose en el dispositivo con la clave existente. No se añade un servicio de sincronización ni permiso de Internet al APK release.

## Temarios

### IPv4 y subnetting con criterio

1. Leer una dirección sin adivinar la red
2. Calcular red, difusión y rango de hosts
3. /30, /31 y /32 sin fórmulas ciegas
4. Repartir un /24 con VLSM y margen real
5. Direcciones privadas, compartidas y de documentación
6. DHCP, reservas y conflictos de direcciones
7. Elegir la ruta por coincidencia de prefijo más largo
8. NAT, puertos y límites de la traducción
9. Diagnosticar máscaras y gateways con evidencia
10. Resumir rutas sin ampliar promesas

### IPv6: del prefijo al diagnóstico

1. Leer y normalizar una dirección IPv6
2. Enlace local, ULA, loopback y multicast
3. Autoconfiguración y anuncios de router
4. Separar direcciones, prefijos delegados y DNS
5. Descubrir el siguiente salto y leer la caché NDP
6. ICMPv6 y tamaño de paquetes en el camino
7. Probar IPv4 e IPv6 en una red de doble pila
8. Rutas IPv6 y siguiente salto con interfaz
9. Proteger IPv6 sin confundir dirección y confianza
10. Preparar una migración IPv6 y verificar sus límites

### VLAN, switching y enrutamiento

1. Aprender MAC y reenviar dentro de una VLAN
2. Puertos de acceso y fronteras de una VLAN
3. Transportar VLAN con IEEE 802.1Q
4. VLAN nativa y clasificación de tramas sin etiqueta
5. Puertas de enlace y comunicación entre VLAN
6. Redundancia y prevención de bucles de capa dos
7. Rutas estáticas, alcance del siguiente salto y retirada
8. Vecinos OSPF y rutas calculadas por costo
9. Listas de acceso: orden, dirección y alcance de una regla
10. Cambios de switching y rutas con recuperación comprobable

### Diagnóstico de redes basado en evidencias

1. Del síntoma a una hipótesis que pueda comprobarse
2. Estado físico, contadores y diferencias por intervalo
3. Ping, traceroute y conclusiones que sus respuestas permiten
4. Localizar la demora entre DNS, transporte e identidad TLS
5. Localizar dónde se interrumpe una asignación DHCP
6. Conexiones TCP, secuencias y evidencias de retransmisión
7. Capacidad, caudal útil, retardo y pérdida sin mezclar unidades
8. Filtros de captura y visualización en Wireshark
9. Adquirir evidencia suficiente sin recopilar de más
10. Entregar un diagnóstico que otro operador pueda verificar

### Defensa de redes y acceso controlado

1. Separar recursos y dibujar los caminos que sí necesitan existir
2. Matriz de acceso, objetos y excepciones con responsable
3. Seguimiento de conexiones, respuestas y cambios de política
4. Control de salida y resolución de nombres autorizada
5. VPN de acceso remoto, MFA y alcance del túnel
6. VPN entre sedes: pares, tráfico protegido y regreso
7. Firewall del host: proteger el último tramo
8. IDS e IPS: alertar, investigar y bloquear con criterio
9. Acceso por identidad, dispositivo y recurso
10. Validar segmentación y recuperar cambios con evidencias

### Operaciones de seguridad y respuesta

1. Inventario útil y línea base de una red
2. Registros, zonas horarias y secuencia verificable
3. Indicadores, hipótesis y falsos positivos
4. Triaje, alcance y escalado responsable
5. Priorizar vulnerabilidades con riesgo y contexto
6. Actualizaciones con prueba, despliegue y verificación
7. Contener sin confundir bloqueo y recuperación
8. Copias de configuración y recuperación comprobada
9. Aprender del incidente y comprobar las mejoras
10. Plan de práctica y orientación hacia certificaciones
