# Verificación de Aiocyb 1.5.0

24 de octubre de 2026. Rediseño del catálogo, la presentación de cursos y la navegación del aula en Flutter.

## Resultado

- Se conservan **25 cursos, 430 lecciones y 930 ejercicios**, sus identificadores y el almacenamiento anterior.
- Catálogo visual con cinco áreas, búsqueda que ignora tildes, filtros de progreso, ordenación y tarjetas adaptables a una, dos o tres columnas.
- Cada curso tiene tres objetivos y tres habilidades propios: **75 objetivos y 75 habilidades mostradas**.
- Fichas con presentación, duración estimada, temario por módulos, notas y continuación de la última lección incompleta del curso.
- **75 accesos a conceptos**: tres extractos de teoría original por curso. El lector muestra el contenido completo, referencias y acceso a su lección.
- Cinco portadas originales de 1536 × 1024 en `assets/artwork/`, incluidas sin conexión. [Prompts y archivos](PORTADAS_1_5.md).
- El aula muestra curso y posición de la lección. Su temario permite cambiar de lección y regresar directamente al curso.
- Aoi conserva sus dieciséis expresiones y diálogos por situación. No se añaden controles de alternancia, historial ni desactivación de ironía.

[Diseño y referencias](INTERFAZ_1_5.md).

## Código y pruebas

`flutter analyze --no-pub`: sin problemas detectados.

`flutter test --no-pub --reporter expanded`: **51 pruebas aprobadas**. Las cinco nuevas pruebas cubren recursos y objetivos de todos los cursos, teoría vinculada, búsqueda sin tildes, filtros y ordenación, continuación, cambio de lección desde el aula y adaptación a móvil, escritorio, modo claro y texto ampliado. Las pruebas anteriores conservan la cobertura de contenido, migración de notas, Aoi, ejercicios, biblioteca, laboratorios y progreso.

Se actualizaron las pruebas de navegación para contemplar los módulos y el desplazamiento de la interfaz nueva. Se corrigieron desbordamientos encontrados con texto ampliado y pantallas estrechas. La flecha de los conceptos utiliza Material Icons incluido en la app.

## Versión compilada y revisión visual

`flutter build web --no-web-resources-cdn --no-pub`: compilación correcta. La web se usó como vista de revisión; no se presenta como una PWA instalable sin conexión.

`tool/course_interface_smoke.cjs` recorrió la versión compilada a **1440 × 1080, 390 × 844 y 320 × 740**. Se bloquearon todas las solicitudes HTTP a otros orígenes durante la navegación. La ejecución final bloqueó cuatro solicitudes externas de fuentes y completó el recorrido sin errores JavaScript. Las cinco portadas se cargaron desde archivos locales.

El recorrido comprobó conceptos y su teoría, entrada a la lección correspondiente, cambio desde el temario del aula, retorno al curso, búsqueda, resultados vacíos, reinicio de filtros y conservación de una nota existente tras recargar. Modo claro, neón violeta y texto ampliado también persistieron.

El [informe de navegador](COURSE_BROWSER_AUDIT_1_5.json) registra capturas, hashes de los archivos de interfaz y SHA-256 del JavaScript compilado. Se revisaron visualmente las doce capturas:

| Vista | Captura |
| --- | --- |
| Catálogo en escritorio | [42](screenshots/42-catalogo-escritorio.png) |
| Tarjetas y filtros | [43](screenshots/43-biblioteca-cursos.png) |
| Búsqueda de Linux | [44](screenshots/44-cursos-linux-escritorio.png) |
| Presentación del curso | [45](screenshots/45-presentacion-curso.png) |
| Módulos y progreso | [46](screenshots/46-modulos-curso.png) |
| Lector de conceptos | [47](screenshots/47-lector-conceptos.png) |
| Aula con Aoi | [48](screenshots/48-aula-escritorio.png) |
| Catálogo en tamaño Android | [49](screenshots/49-catalogo-android.png) |
| Presentación en móvil | [50](screenshots/50-curso-android.png) |
| Temario en móvil | [51](screenshots/51-temario-android.png) |
| Modo claro y texto ampliado a 320 px | [52](screenshots/52-catalogo-claro-320.png) |
| Concepto en modo claro a 320 px | [53](screenshots/53-concepto-claro-320.png) |

## Android

`flutter build apk --release --target-platform android-arm64 --no-pub`: compilación correcta. La ejecución final de Gradle tardó 811,5 segundos.

`tool/audit_release.py` verificó los ocho informes de contenido previos y sus hashes, los archivos actuales de interfaz, los 430 identificadores de lección compilados, los laboratorios y la igualdad de los recursos empaquetados con sus archivos locales. El APK incluye cinco portadas, dieciséis retratos y los seis bancos JSON originales de Aoi.

| Dato | Resultado |
| --- | --- |
| Versión | 1.5.0+7 |
| Paquete | `com.aiocyb.aiocyb` |
| Arquitectura | ARM64 |
| Android mínimo / objetivo | API 24 / 36 |
| Permiso de Internet | Ausente |
| Tamaño exacto | 69 699 913 bytes, aproximadamente 66,5 MiB |
| SHA-256 | `5ff41642382efc8280014d313ff8aebbf2f66e195d6d71655a287124fb608970` |

[APK final](../build/releases/aiocyb-1.5.0+7-arm64.apk) · [Auditoría del paquete](BUILD_AUDIT_1_5.json).

## Actualización del teléfono

Se actualizó el Motorola moto g24 power de **1.4.0+6 a 1.5.0+7** mediante `adb install -r`. Android devolvió `Success` y confirmó la versión nueva. El identificador de datos de la aplicación se mantuvo en `appId=10285`. No se desinstaló la app ni se borraron sus datos.

La verificación visual e interactiva de esta entrega corresponde a la web compilada y a las pruebas Flutter. No se abrió la app ni se completaron ejercicios en el teléfono; la comprobación física confirmó la instalación y la identidad de datos conservada. [Registro de instalación](ANDROID_INSTALL_1_5.json).

El informe anterior de 1.4 permanece en [VERIFICACION_1_4.md](VERIFICACION_1_4.md).
