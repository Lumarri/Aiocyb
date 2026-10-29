# Verificación de Aiocyb 1.7.0+9

29 de octubre de 2026. Android es la plataforma principal. La compilación web sirve para revisar la presentación y los recorridos de la interfaz.

## Contenido y compatibilidad

- La academia contiene 31 cursos, 490 lecciones y 1530 ejercicios: 1290 preguntas de lecciones y 240 refuerzos opcionales. El diagnóstico inicial conserva sus cinco preguntas independientes.
- La ampliación incorpora seis cursos de diez lecciones y 60 ejercicios cada uno, con 39 621 palabras de teoría y 120 casos resueltos. El contenido nuevo completo, incluidos los refuerzos, aporta 4026 líneas originales de Aoi.
- Cada lección nueva contiene entre 600 y 705 palabras de teoría, cuatro apartados, dos casos y seis preguntas. Se aprueba con cuatro aciertos.
- Las 240 microlecciones anteriores de redes conservan sus objetos, IDs y umbral de un acierto sobre una pregunta. Los refuerzos guardan notas y errores independientes, sin aportar XP ni revocar aprobaciones o cierres de curso anteriores.
- Se conservan los 25 cursos previos, la clave de almacenamiento y la mejor nota de cada evaluación. La sexta ruta es independiente. Las cuatro fichas de certificaciones orientan hacia procesos externos; su progreso solo representa lecciones estudiadas en Aiocyb.

La [auditoría editorial](NETWORK_EXPANSION_AUDIT.json) recoge cantidades, huellas de los originales y comprobaciones de duplicados. Los [temarios y fuentes de redes](REDES_1_7.md) documentan el contenido y sus referencias.

## Comprobaciones concluidas

- `flutter analyze --no-pub`: sin incidencias, en 4,7 segundos.
- `flutter test --no-pub`: 71 pruebas correctas, en 28 segundos. Cubren migración de las 430 notas anteriores y sus preferencias, favoritos y última lección; persistencia de notas y repaso de refuerzos sin XP adicionales; umbral de cuatro aciertos sobre seis; diálogos fijos y reacciones según los fallos; catálogo y guía de certificaciones.
- Tras el último ajuste editorial se regeneraron JSON y Dart. Las siete pruebas de `test/network_expansion_test.dart` se repitieron correctamente en cuatro segundos.
- Las pruebas de certificaciones comprueban navegación, enlaces oficiales copiables, progreso local y las cuatro fichas a 320 píxeles, en modo claro y con texto ampliado.
- Compilación web de producción: correcta, en 54,8 segundos. Los recursos de Flutter se sirven localmente, sin depender de una CDN.

## Recorridos en navegador y APK

Los tres recorridos terminaron correctamente, sin errores registrados y con 37 capturas: [redes, refuerzos y certificaciones](NETWORK_BROWSER_AUDIT.json), [catálogo y aula](COURSE_BROWSER_AUDIT.json) e [Inicio, rutas y progreso](DASHBOARD_BROWSER_AUDIT.json). Los informes corresponden a la misma compilación web, con SHA-256 `532f0c1855852f18d4a11d47d320fe6438ef09d61bc7c3a638ccaad6a044a2de`.

La compilación del APK Android ARM64 1.7.0+9 terminó correctamente en 864,5 segundos. La [auditoría del APK](BUILD_AUDIT.json) confirmó:

- Tamaño: 71 406 422 bytes, aproximadamente 68,1 MiB.
- SHA-256: `62d3ff2b0fa9a36b0a1e57a20bcdb93a9cfddf591d79f86c3e82055e22f56d49`.
- SDK mínimo 24 y objetivo 36, sin permiso `INTERNET` en el APK de producción.
- Contenido empaquetado: 31 cursos, 490 lecciones, 1530 ejercicios, 16 retratos de Aoi y cinco portadas locales.

## Límites y trazabilidad

No se ha confirmado instalación ni ejecución de esta versión en un teléfono físico. Las pruebas de widgets y la vista web no sustituyen esa comprobación. La vista web no incorpora un service worker para instalación offline. La auditoría del APK Android comprueba el contenido empaquetado y la ausencia del permiso de acceso a Internet.

La resolución local preexistente de dependencias contiene `jni` 1.1.1 y `shared_preferences_android` 2.5.4. Ese cambio de `pubspec.lock` se conserva localmente y no se publica: el archivo del repositorio mantiene las versiones 1.1.0 y 2.5.3, respectivamente. La compilación Android utiliza la resolución local; no se afirma que el otro archivo de bloqueo reconstruya un binario idéntico byte por byte. El [informe de compilación](BUILD_AUDIT.json) distingue ambas resoluciones y registra sus versiones y huellas para relacionar el código publicado con la compilación entregada.
