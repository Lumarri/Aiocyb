# Verificación de Aiocyb 1.3.0

Este documento conserva la verificación histórica de 1.3. La versión vigente se documenta en [VERIFICACION_1_6.md](VERIFICACION_1_6.md).

24 de octubre de 2026.

## Código y contenido

- `flutter analyze --no-pub`: sin problemas detectados.
- `flutter test --no-pub --reporter expanded`: **41 pruebas aprobadas**. Incluyen los siete casos nuevos de contenido, migración, preferencias, biblioteca, laboratorios, repaso y navegación.
- Cuatro cursos nuevos, cada uno con **diez lecciones y treinta ejercicios**: Criptografía desde cero, Claves y protección de datos, Seguridad web con criterio y Programación segura desde el diseño.
- La ampliación suma **40 lecciones, 120 ejercicios, 80 casos resueltos y 27 038 palabras de teoría**. Cada lección tiene cuatro apartados que suman **634–714 palabras**, dentro del intervalo de 600–900. El recuento excluye diálogos, casos, respuestas e instrucciones.
- `python tool/compile_secure_courses.py`: cero errores; 160 apartados distintos, 120 preguntas, 360 explicaciones de respuestas y **964 intervenciones originales de Aoi**. Cada pregunta tiene su situación y feedback por opción. Informe y huellas de Markdown y JSON: [SECURE_CONTENT_AUDIT.json](SECURE_CONTENT_AUDIT.json). Temario: [SECURE_CURSOS.md](SECURE_CURSOS.md).
- Los originales Markdown se transcriben a JSON y constantes Dart conservando el texto. Los compiladores validan estructura, referencias, extensión y duplicados; no generan ni rellenan teoría.
- Las otras auditorías también pasaron: [AOI_BANK_AUDIT.json](AOI_BANK_AUDIT.json), [COURSE_CONTENT_AUDIT.json](COURSE_CONTENT_AUDIT.json), [STARTER_PRACTICE_AUDIT.json](STARTER_PRACTICE_AUDIT.json) y [MALWARE_CONTENT_AUDIT.json](MALWARE_CONTENT_AUDIT.json).
- La academia suma **19 cursos, 370 lecciones y 690 ejercicios**, además del diagnóstico de cinco preguntas. Los nuevos cursos se aprueban con 2/3; malware mantiene 3/4, redes 1/1 y los iniciales 2/3.
- Una prueba restaura notas perfectas de las **330 lecciones anteriores** y sus **16 500 XP**, manteniendo errores, alias y preferencias. Los cuatro cursos nuevos empiezan sin progreso. El orden y los IDs anteriores se conservan.

## Secciones, temas y accesibilidad

- Explorar enlaza **Rutas de aprendizaje, Laboratorio offline, Biblioteca, Repaso de errores y Logros**. Las cuatro rutas contienen todos los cursos y no imponen bloqueos.
- Biblioteca busca en títulos y teoría, filtra por curso, pagina de veinte en veinte y mantiene favoritos. Se comprobó búsqueda en el cuerpo de una lección profunda y retirada de un favorito desde el aula.
- El repaso conserva el índice real de la pregunta, su pista y explicación. Incluye cursos y diagnóstico. Resolverlo no modifica notas ni XP; otro fallo vuelve a dejarlo pendiente.
- Los cuatro laboratorios requieren acertar sus tres etapas para terminar. Las pruebas recorren los cuatro, fallan dos veces en la primera etapa y verifican reacciones suaves y mordaces, guardado y ausencia de XP de curso adicional.
- `python tool/audit_labs.py --dart <ruta-a-dart.exe>`: **4 simulaciones, 12 etapas y 52 intervenciones únicas**, cero errores. Los datos exportados corresponden a las constantes usadas por la app: [LAB_CONTENT_AUDIT.json](LAB_CONTENT_AUDIT.json).
- Temas **neón cian y violeta**, halo suave opcional, modo claro/oscuro y texto ampliado. Se comprobó aplicación de ambas paletas, guardado y conservación de favoritos y preferencias al reiniciar el progreso.
- Las pruebas abren el menú y secciones a **320 × 640** y **1024 × 480**. El menú lateral se desplaza en ventanas bajas. La barra móvil usa «Ajustes» para evitar dividir la palabra larga.
- El texto de referencia de las doce etapas tiene etiqueta semántica explícita y comprobada, manteniendo su presentación seleccionable. La revisión visual detectó esa ausencia inicial y se corrigió antes de generar el instalador final.
- Aoi mantiene sus ocho retratos y diálogos por situación. No hay controles para alternar diálogo, consultar historial o desactivar su personalidad.
- Detalle de funciones y reinicio: [INTERFAZ.md](INTERFAZ.md).

## Instalador Android

- `flutter build apk --release --target-platform android-arm64 --no-pub`: compilación final correcta, **268,9 segundos**.
- Versión **1.3.0**, código **5**, paquete `com.aiocyb.aiocyb`, Android mínimo API 24, objetivo API 36, motor ARM64.
- Archivo: `build/app/outputs/flutter-apk/app-release.apk`, **40 276 411 bytes (38,4 MiB)**.
- La auditoría verificó los **370 IDs de lección**, los cuatro laboratorios compilados, ocho retratos y seis bancos JSON iguales a sus originales. También comprobó las huellas de todas las fuentes editoriales y datos del laboratorio. No hay IDs faltantes.
- El manifiesto final **no solicita permiso de Internet**. Enseñanza, imágenes y progreso son locales. La plantilla mantiene firma de depuración para pruebas.
- Metadatos y SHA-256: [BUILD_AUDIT.json](BUILD_AUDIT.json).
- `adb devices -l` no detectó dispositivos al finalizar. El APK está listo para instalar; esta versión no se instaló ni se comprobó visualmente en un teléfono físico.

## Recorrido visual

- `flutter build web --no-web-resources-cdn --no-pub`: compilación final correcta, **57,8 segundos**. La web sirve como vista previa; el funcionamiento offline instalado se enfoca en Android.
- `tool/experience_smoke.cjs`, con Chromium y Playwright a **390 × 844**, recorrió las cinco secciones, los cuatro laboratorios y teoría y ambos casos de una lección de cada curso nuevo.
- Cambió al tema violeta, desactivó el brillo y recargó para comprobar persistencia. Se inspeccionaron capturas del cian inicial y del violeta guardado.
- Completó doce etapas, falló dos veces en una y verificó los comentarios correspondientes de Aoi. Las notas permanecieron intactas después de laboratorio y repaso.
- Buscó una frase del cuerpo teórico, guardó un favorito y lo abrió desde la biblioteca. Resolvió una pregunta de índice 2 y otra del diagnóstico, comprobando sus contextos y la retirada de los repasos pendientes.
- Con nueve lecciones aprobadas de preparación, completó la décima con **2/3** y verificó la celebración de curso de Aoi. La recarga conservó tema, brillo, favoritos, laboratorios, resolución de repaso y notas anteriores.
- Se bloquearon todas las peticiones a dominios externos: **7 solicitudes de fuentes abortadas**. El recorrido siguió funcionando y no hubo errores JavaScript. Informe: [EXPERIENCE_BROWSER_AUDIT.json](EXPERIENCE_BROWSER_AUDIT.json).
- La prueba espera la semántica de Flutter, respeta pestañas de navegación y espera la decodificación de retratos al capturar. Las interacciones de búsqueda se envían como escritura real tras enfocar el campo.
- Capturas inspeccionadas: [Explorar cian](screenshots/24-explorar-neon-cian.png), [Ajustes violeta](screenshots/25-ajustes-neon-violeta.png), [rutas](screenshots/26-rutas-aprendizaje.png), [reincidencia en laboratorio](screenshots/27-laboratorio-reincidencia.png), [biblioteca](screenshots/28-biblioteca-favoritos.png), [repaso](screenshots/29-repaso-resuelto.png), [logros](screenshots/30-logros-reales.png) y [curso completado](screenshots/31-curso-nuevo-completado.png).

Las capturas 24–31 documentan esta versión en navegador. Las anteriores corresponden a entregas previas. El servidor de vista previa se cerró al terminar.

