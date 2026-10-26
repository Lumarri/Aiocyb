# Verificación de Aiocyb 1.4.0

24 de octubre de 2026. Plataforma principal: Android; aplicación educativa offline en español.

## Contenido completo

- Academia: **25 cursos, 430 lecciones y 930 ejercicios**, más cinco preguntas de diagnóstico.
- Ampliación: **seis cursos**, cada uno con diez lecciones y cuarenta ejercicios. Temario completo: [LINUX_CURSOS.md](LINUX_CURSOS.md).
- **40 097 palabras de teoría original**, cuatro apartados por lección y **623–711 palabras por lección**, excluyendo diálogos, casos, instrucciones y respuestas.
- **120 casos resueltos, 240 preguntas y 720 explicaciones de respuesta**. Cada pregunta tiene su escenario y justificaciones específicas para acierto y ambos distractores.
- **1 746 intervenciones únicas de Aoi**: 29 por lección y seis cierres de curso. Superan el mínimo elegido de 25 por lección. Se comprueban duplicados normalizando acentos, mayúsculas y puntuación, también frente al contenido anterior.
- Los originales `assets/linux/*.md` se transcriben a JSON y constantes Dart. El parser y el compilador no generan ni rellenan prosa. El ajuste editorial de posiciones mueve cada opción junto con su feedback; no altera el orden durante la ejecución de la app.
- Auditoría, conteo por lección y huellas de Markdown/JSON: [LINUX_CONTENT_AUDIT.json](LINUX_CONTENT_AUDIT.json).
- Las referencias primarias de GNU, Linux, Debian, systemd, OpenSSH, nginx, OWASP y NIST se registran en `lib/src/data/linux_sources.dart`. Su consulta externa es opcional; la enseñanza y los ejercicios ya están incluidos localmente.

## Aoi y navegación

- Se conservan los ocho retratos anteriores y se añaden ocho PNG distintos con transparencia real: curiosidad, concentración, sorpresa, alivio, reto juguetón, puchero, rubor pícaro y celebración final.
- Archivos, prompts completos y herramienta integrada imagegen: [AOI_EXPRESIONES_1_4.md](AOI_EXPRESIONES_1_4.md). Metadatos, alpha y huellas: [AOI_VISUAL_AUDIT.json](AOI_VISUAL_AUDIT.json).
- Los retratos se vinculan a contexto y resultado. Ante el primer error aparece puchero con reacción suave; la reincidencia utiliza exasperación y un texto más mordaz. Acertar muestra alivio, aprobar rubor y la primera finalización del curso celebración.
- `gaplessPlayback` conserva el retrato anterior mientras se decodifica la siguiente expresión local, evitando un hueco visible durante el cambio. Los ocho originales conservan sus bytes.
- Sin alternancia manual, historial de diálogos ni interruptor para desactivar ironía. No se ha producido voz o audio.
- La quinta ruta, **Linux: observa, comprende e investiga**, reúne los seis cursos. La biblioteca, favoritos, repaso, logros y búsqueda incluyen el contenido mediante el catálogo existente.
- Los escenarios son ficticios: la app no ejecuta órdenes de Linux ni sondeos de red sobre el dispositivo.

## Pruebas de código y migración

- `flutter analyze --no-pub`: sin problemas detectados.
- `flutter test --no-pub --reporter expanded`: **46 pruebas**. Las cinco nuevas cubren fidelidad de las constantes a las fuentes, profundidad y cantidad, expresiones y contextos fijos, migración, aula y evaluación completa.
- La migración conserva **370 notas anteriores, 18 500 XP, alias, diagnóstico, errores, repasos resueltos, favoritos, laboratorios y preferencias**. Las sesenta lecciones nuevas comienzan sin completar. Se mantienen IDs y orden anteriores.
- Linux requiere **tres aciertos de cuatro**. Los reintentos conservan la mejor nota, no duplican XP y solo celebran la primera finalización del curso.
- El aula se verifica a **320 × 640** y **1024 × 480**, con teoría y dos casos, Aoi presente y ausencia de controles para cambiar su diálogo.
- Las auditorías previas de banco inicial, redes, refuerzos, malware, criptografía y laboratorios se mantienen sin errores.

## Reproducir las comprobaciones

```powershell
python tool/audit_aoi.py
python tool/audit_aoi_visuals.py
python tool/compile_courses.py
python tool/compile_practice.py
python tool/compile_malware.py
python tool/compile_secure_courses.py
python tool/compile_linux_courses.py
flutter analyze --no-pub
flutter test --no-pub --reporter expanded
```

La verificación de una APK mediante `tool/audit_release.py` comprueba versión, archivos locales y huellas, presencia de los 430 IDs compilados, laboratorios y ausencia de permiso de Internet. Sus resultados se guardan en [BUILD_AUDIT.json](BUILD_AUDIT.json).

## Recorrido visual de la versión final

- `flutter build web --no-web-resources-cdn --no-pub`: correcto en **145,1 segundos**, después del ajuste de continuidad del retrato. La web es una vista previa; la instalación offline está enfocada en Android.
- `tool/linux_smoke.cjs`, Chromium y Playwright a **390 × 844**, abrió los seis cursos, comprobó sus cuarenta ejercicios y leyó teoría y los dos casos de una lección de cada uno.
- Se preparó un perfil de prueba con las 370 notas anteriores y nueve lecciones del primer curso nuevo para comprobar su primera finalización. Realizó intentos de **2/4, 3/4 y 4/4** en la décima; verificó reacción suave, reincidencia, acierto, celebración única y aprobación posterior sin repetirla.
- Las ocho expresiones nuevas aparecieron en sus contextos. Se revisaron visualmente las diez capturas finales, incluidos los retratos durante las transiciones. No hay controles para cambiar diálogo, consultar historial o desactivar personalidad.
- La recarga conservó las 370 notas anteriores, mejor nota nueva de 4/4, errores de los ejercicios, favorito nuevo y tema violeta. Ningún resultado de preparación modifica datos de un teléfono real: el navegador utiliza un perfil aislado.
- **18 solicitudes externas bloqueadas**; la ruta siguió funcionando sin errores JavaScript. Fuentes, imágenes y contenido del curso se sirvieron localmente. Informe: [LINUX_BROWSER_AUDIT.json](LINUX_BROWSER_AUDIT.json).
- Capturas: [ruta](screenshots/32-ruta-linux.png), [curiosidad](screenshots/33-aoi-curiosidad.png), [concentración](screenshots/34-aoi-concentracion.png), [reto](screenshots/35-aoi-reto.png), [sorpresa](screenshots/36-aoi-sorpresa.png), [primer fallo](screenshots/37-aoi-primer-fallo.png), [alivio](screenshots/38-aoi-alivio.png), [reincidencia](screenshots/39-aoi-reincidencia.png), [celebración](screenshots/40-aoi-celebracion-linux.png) y [rubor](screenshots/41-aoi-rubor.png).

El recorrido esperó la preparación del servidor, las transiciones de navegación y la decodificación de imágenes. Los primeros intentos del automatismo detectaron una carrera de inicio y un tiempo de espera insuficiente al volver entre pantallas; el recorrido final corrigió ambos y terminó completo. La revisión también motivó conservar el retrato anterior durante cambios de expresión en la app.

## APK Android definitivo

- `flutter build apk --release --target-platform android-arm64 --no-pub`: compilación final correcta en **335,6 segundos**, después del ajuste del retrato continuo. La primera compilación, anterior a ese ajuste, no es el instalador final auditado.
- Versión **1.4.0**, código **6**, paquete `com.aiocyb.aiocyb`, ARM64, Android mínimo API 24 y objetivo API 36.
- [Instalador](../build/app/outputs/flutter-apk/app-release.apk): **59 499 231 bytes, 56,7 MiB**.
- SHA-256: `a15f0f4441a8a37521084d1364dc4d4dde048b2cf23edcd2e9d72602f9210592`.
- `tool/audit_release.py` verificó ocho informes de contenido y gráficos con sus huellas, los **430 IDs de lección** y los cuatro laboratorios compilados, **16 retratos** y los seis bancos JSON originales. No faltan lecciones ni assets auditados.
- El APK final **no solicita permiso de Internet**. La enseñanza, imágenes, diálogos, ejercicios y progreso son locales. Los enlaces de referencia se consultan opcionalmente fuera del estudio offline.
- La plantilla conserva firma de desarrollo; no se ha publicado en una tienda.
- `adb devices -l`: sin dispositivos conectados al finalizar. El instalador está preparado, pero **no se instaló ni se validó esta versión en un teléfono físico**.
- El servidor local de la vista previa se cerró después de las capturas.

Metadatos completos: [BUILD_AUDIT.json](BUILD_AUDIT.json). Pruebas del navegador: [LINUX_BROWSER_AUDIT.json](LINUX_BROWSER_AUDIT.json). Contenido por lección: [LINUX_CONTENT_AUDIT.json](LINUX_CONTENT_AUDIT.json).
