# Verificación de Aiocyb 1.6.0

25 de octubre de 2026. Mejora de Inicio, Rutas de aprendizaje y Mi progreso, con compatibilidad de las notas y preferencias existentes.

Este documento conserva la entrega anterior al cambio de icono del 26 de octubre. El icono y su integración se describen en [ICONO.md](ICONO.md); la auditoría del APK actual está en [BUILD_AUDIT.json](BUILD_AUDIT.json).

## Entrega

- Inicio muestra la última lección incompleta, cuatro indicadores, accesos de estudio y hasta tres cursos sugeridos.
- Las cinco rutas tienen directorio visual, filtros y una ficha con continuación, estadísticas y cursos en su orden editorial. El último curso sigue disponible desde el principio.
- Mi progreso distingue avance global, cursos completos, lecciones con nota y precisión de mejores intentos. Las notas se consultan por curso, con búsqueda por palabras y filtros.
- Los cursos comenzados se guardan en `startedCourseIds`, dentro de la misma clave de preferencias. La migración deriva los inicios conocidos por notas y última lección; conserva alias, favoritos, preferencias, errores y notas.
- Entrar en una lección o visitar un panel no aprueba lecciones ni añade XP. La precisión cuenta solo las preguntas de las lecciones con nota; los repasos incluyen también el diagnóstico.
- Las tarjetas de navegación exponen una única acción accesible con nombre, estado y avance. El saludo usa un icono incluido en Flutter.
- Se mantienen **25 cursos, 430 lecciones, 930 ejercicios, cinco portadas locales y dieciséis retratos de Aoi**. No se añadieron cursos ni se modificó su teoría en esta entrega.

[Descripción del diseño y los cálculos](INTERFAZ_1_6.md).

## Pruebas de código

`flutter analyze --no-pub`: sin problemas detectados.

`flutter test --no-pub --reporter expanded`: **60 pruebas aprobadas**. Las nueve pruebas nuevas cubren:

1. Cálculos a partir de notas reales, porcentajes por lección, precisión ponderada y repasos de diagnóstico, sin escrituras al consultar el panel.
2. Estados inicial, nota cero y academia completada: 25 cursos, cinco rutas, 930 preguntas con nota y 21 500 XP en el último caso.
3. Migración de cursos comenzados y conservación al abrir otro curso y recargar. Identificadores desconocidos se descartan; el reinicio conserva favoritos y preferencias.
4. Recomendaciones limitadas a tres cursos y continuación de la última lección incompleta.
5. Acceso a las cinco rutas y al último curso de Linux, filtros y estado vacío.
6. Búsqueda de notas con palabras reordenadas, conservación de la nota original y acceso a su lección.
7. Acceso a las preguntas originales del repaso sin alterar notas ni XP.
8. Navegación por etiquetas accesibles con estado y avance reales.
9. Inicio, Progreso, Rutas y su ficha en móvil estrecho, texto ampliado y escritorio.

Las 51 pruebas anteriores siguen cubriendo contenido, migración de las 370 notas previas, Aoi, ejercicios, cursos, biblioteca, laboratorios y preferencias.

## Comprobación de la versión compilada

`flutter build web --no-web-resources-cdn --no-pub`: compilación correcta. La web se usa para revisar la interfaz; no se presenta como una PWA offline instalable.

Se ejecutaron dos recorridos sobre el mismo JavaScript compilado, con todas las conexiones HTTP externas bloqueadas:

- [DASHBOARD_BROWSER_AUDIT.json](DASHBOARD_BROWSER_AUDIT.json): Inicio, las cinco rutas y Progreso a **1440 × 1080, 390 × 844 y 320 × 740**. La ejecución final registró cero solicitudes externas y cero errores JavaScript.
- [COURSE_BROWSER_AUDIT.json](COURSE_BROWSER_AUDIT.json): regresión del catálogo, fichas, conceptos, aula, navegación entre lecciones, temas y búsqueda. Las cinco portadas se cargaron localmente; cero solicitudes externas y cero errores JavaScript.

El escenario de los paneles utiliza datos de prueba: diez lecciones aprobadas de Fundamentos, una nota 1/3 en Identidad, la última lección en Linux, un favorito y dos ejercicios por repasar. Se verifican **500 XP, 11 lecciones con nota, 31/33 aciertos y 10/430 lecciones aprobadas**. La ruta de Fundamentos muestra 10/30 y el global 10/430, sin promediar porcentajes de rutas. Esos valores son del escenario de prueba y no describen los datos del teléfono.

Abrir otra lección y recargar conserva las once notas, el diagnóstico, el favorito, el tema y los cursos comenzados. La consulta de búsqueda se verifica completa en el campo antes de comprobar las notas. Ambos informes registran los hashes de los archivos relevantes y del JavaScript revisado.

Se revisaron las catorce capturas de los paneles:

| Vista | Captura |
| --- | --- |
| Inicio en escritorio | [54](screenshots/54-inicio-escritorio.png) |
| Directorio de rutas | [55](screenshots/55-rutas-escritorio.png) |
| Ficha de la ruta de Linux | [56](screenshots/56-ruta-linux-detalle.png) |
| Recorrido por los cursos | [57](screenshots/57-recorrido-cursos.png) |
| Progreso global | [58](screenshots/58-progreso-escritorio.png) |
| Notas por curso | [59](screenshots/59-notas-por-curso.png) |
| Filtro de cursos completados | [60](screenshots/60-cursos-completados.png) |
| Inicio en tamaño Android | [61](screenshots/61-inicio-android.png) |
| Rutas en tamaño Android | [62](screenshots/62-rutas-android.png) |
| Ficha de ruta en móvil | [63](screenshots/63-ruta-android.png) |
| Progreso en móvil | [64](screenshots/64-progreso-android.png) |
| Inicio claro y ampliado a 320 px | [65](screenshots/65-inicio-claro-320.png) |
| Ruta clara y ampliada a 320 px | [66](screenshots/66-ruta-clara-320.png) |
| Progreso claro y ampliado a 320 px | [67](screenshots/67-progreso-claro-320.png) |

El recorrido de cursos guarda doce capturas adicionales en `docs/screenshots/1.6-courses/`, conservando las capturas originales de 1.5.

## Android

`flutter build apk --release --target-platform android-arm64 --no-pub`: compilación correcta. Gradle tardó 564,1 segundos en la ejecución final.

`tool/audit_release.py` validó los ocho informes de contenido previos, los dos recorridos de interfaz y sus hashes actuales. Confirmó los 430 identificadores de lección compilados y los laboratorios. Las cinco portadas, los dieciséis retratos y los bancos JSON de Aoi empaquetados coinciden con sus archivos locales.

| Dato | Resultado |
| --- | --- |
| Versión | 1.6.0+8 |
| Paquete | `com.aiocyb.aiocyb` |
| Arquitectura | ARM64 |
| Android mínimo / objetivo | API 24 / 36 |
| Permiso de Internet | Ausente |
| Tamaño | 69 831 313 bytes, aproximadamente 66,6 MiB |
| SHA-256 | `873090ca2695e58cd2580816083c9cfe131acfbd61d4720ae283071b9bf3106a` |

[APK de esta comprobación](../build/releases/aiocyb-1.6.0+8-before-icon-arm64.apk) · [Auditoría de esta comprobación](BUILD_AUDIT_1_6_BEFORE_ICON.json).

Al finalizar, `adb devices -l` no detectó ningún teléfono conectado. La versión 1.6 **no se instaló ni se revisó visualmente en un teléfono físico**; se entrega el APK y la comprobación interactiva de la web compilada. La última instalación confirmada corresponde a 1.5, el 24 de octubre. [Estado de instalación de 1.6](ANDROID_INSTALL_1_6.json).

El APK, las capturas y los informes anteriores de 1.5 se conservan como antecedente: [VERIFICACION_1_5.md](VERIFICACION_1_5.md).
