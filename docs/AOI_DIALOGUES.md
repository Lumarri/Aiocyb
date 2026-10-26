# Aula acompañada por Aoi Bite

La versión 1.4 añade **1 746 intervenciones únicas de Linux**, 29 por cada una de sus 60 lecciones y seis cierres de curso. Cada pregunta aporta explicación, pista, acierto, primer error y reincidencia propios. Las 240 preguntas tienen 720 explicaciones de respuesta y la teoría incluye 120 casos resueltos. Auditoría: [LINUX_CONTENT_AUDIT.json](LINUX_CONTENT_AUDIT.json).

Las ocho expresiones nuevas se seleccionan por situación: curiosidad al presentar, concentración al explicar y dar pistas, reto juguetón al comprobar límites, sorpresa en el primer caso, alivio al acertar, puchero en el primer fallo, rubor al aprobar y celebración en la primera finalización del curso. La reincidencia usa exasperación mordaz. Los cursos anteriores conservan sus gestos y diálogos; no hay alternancia, historial ni opción para desactivar ironía. Archivos y prompts: [AOI_EXPRESIONES_1_4.md](AOI_EXPRESIONES_1_4.md).

El banco editorial inicial contiene **585 intervenciones y 585 explicaciones distintas**: 91 por cada una de las seis lecciones iniciales y 39 para el diagnóstico. Incluye seis celebraciones de curso y diez reacciones adicionales para errores repetidos en el diagnóstico. La auditoría comprueba su unicidad normalizando acentos, mayúsculas y puntuación.

Las seis rutas nuevas contienen **240 microlecciones y 1920 mensajes de Aoi redactados individualmente**: ocho por microlección. Sus fuentes editoriales son los JSON de `assets/courses/`. Cada lección aporta teoría, instrucciones, un caso, una pregunta y feedback específico para sus dos distractores. Estos textos se compilan a constantes Dart, sin generar lenguaje durante el uso de la app.

Los tres cursos iniciales tienen **30 ejercicios cada uno**. Sus ocho lecciones de refuerzo por curso suman 72 preguntas nuevas, 216 explicaciones de respuesta y 456 líneas propias de Aoi. Cada pregunta incorpora un caso independiente y cinco intervenciones: presentación, pista, acierto, primer fallo y reincidencia. La lección aporta otras cuatro para introducción, teoría, aprobación y repaso. Los originales están en `assets/practice/`; el compilador comprueba su unicidad también frente a los bancos anteriores.

La ruta de malware contiene **60 lecciones profundas, 240 ejercicios y 120 casos resueltos**. Suma 1746 líneas editoriales: nueve por lección (introducción, cuatro conceptos, dos casos, aprobación y repaso), cinco por pregunta y seis cierres de curso. La teoría de 600–900 palabras aparece en cuatro apartados, con un comentario distinto de Aoi en cada uno. La tutora no repite íntegro el apartado en su panel. Los dos casos tienen situaciones y razonamientos propios, y cambiar de caso selecciona automáticamente su intervención fija.

## Diálogos fijos según la situación

La ruta de criptografía, web y programación segura añade **40 lecciones, 120 ejercicios, 80 casos resueltos y 964 intervenciones editoriales**: nueve por lección, cinco por pregunta y cuatro cierres de curso. Los originales Markdown de `assets/secure/` se transcriben a JSON y constantes Dart sin generar ni rellenar teoría. Cada apartado y cada caso conservan su contexto fijo. Los cuatro laboratorios incluyen otras 52 líneas fijas propias: cuatro por etapa y un cierre por simulación.

El repaso abre la lección y el índice originales de cada pregunta, también para el diagnóstico, de modo que la pista y el feedback siguen correspondiendo al ejercicio real. Resolver un repaso no cambia la mejor nota ni concede XP; conserva un registro de resolución hasta que se vuelva a fallar esa pregunta. Los laboratorios mantienen contadores separados por etapa y sus logros no sustituyen las notas de los cursos.

El panel no incluye botones para cambiar diálogo, elegir otra explicación o consultar un historial. La presentación también tiene un mensaje fijo. Al volver a un concepto, Aoi mantiene la misma intervención; reconstruir una pantalla o reiniciar la app no hace rotar variantes. Las alternativas del banco inicial se conservan como material editorial, pero no se ofrecen para alternar manualmente.

El contexto incluye la lección, la etapa, el concepto o pregunta y la opción comprobada. Antes de responder no se muestra el razonamiento de la solución. La pista de un ejercicio es fija y solo puede pedirse una vez en cada intento; no es un selector de diálogos. El caso práctico cambia automáticamente al elegir esa etapa y no tiene botón de rotación.

Ante el primer error de un ejercicio, Aoi usa la reacción suave y el retrato `disappointed`. Si vuelves a fallar ese ejercicio, usa una reacción fija más mordaz y `exasperated`, aunque hayas elegido otro distractor. El contador se guarda por lección y pregunta, también si abandonas un intento. No altera las notas ni los XP. Reiniciar el progreso borra esos contadores.

Un acierto o una lección superada muestra `delighted`; una pista, `thinking`; la primera aprobación que completa todas las lecciones de un curso, `proud`. Las lecciones pueden cursarse en cualquier orden. Una práctica posterior de un curso ya terminado usa el cierre de lección y no vuelve a conceder el logro de finalización.

## Presencia y contenido

Aoi permanece junto al contenido en una columna lateral amplia o en un panel inferior fijo en el teléfono. Su retrato queda al lado del texto y la explicación admite desplazamiento. La composición se adapta al modo horizontal y al texto ampliado. Las ocho imágenes están incluidas localmente.

Los guiones de las microlecciones presentan el texto docente del contexto: teoría, paso, caso o justificación de la opción. Una instrucción o pregunta breve no se repite en un segundo párrafo para rellenar el panel. Los cierres retoman el razonamiento aprendido. Esta reutilización docente no se contabiliza como nuevos diálogos editoriales ni infla el conteo de mensajes únicos. La explicación de cada distractor es distinta y se consulta después de comprobar la respuesta.

## Archivos y comprobación

- `assets/dialogues/`: banco inicial, reacciones de diagnóstico y celebraciones.
- `assets/courses/`: seis cursos originales de cuarenta microlecciones cada uno.
- `assets/practice/`: veinticuatro lecciones de refuerzo con tres ejercicios y casos independientes por lección.
- `assets/malware/`: seis cursos con teoría profunda, dos casos resueltos y cuatro ejercicios por lección.
- `assets/secure/`: cuatro originales Markdown, JSON estructurados y tres ejercicios por lección profunda.
- `lib/src/data/offline_labs.dart`: cuatro simulaciones de tres etapas y sus guiones situacionales fijos.
- `tool/compile_courses.py`: valida los archivos originales y exporta constantes a `lib/src/data/extended_curriculum.g.dart`.
- `tool/compile_practice.py`: valida los refuerzos y exporta `lib/src/data/starter_practice.g.dart`.
- `tool/compile_malware.py`: valida las 600–900 palabras por lección y exporta `lib/src/data/malware_curriculum.g.dart`.
- `tool/compile_secure_courses.py`: valida los cuatro cursos y exporta `lib/src/data/secure_curriculum.g.dart`; `secure_editorial.py` conserva los textos al transcribir sus registros.
- `lib/src/data/micro_lesson_dialogues.dart`: relaciona los textos docentes escritos con sus situaciones y emociones.
- `lib/src/data/aoi_library.dart`: carga local y selección fija por contexto.
- `lib/src/widgets/aoi_classroom.dart`: panel de Aoi sin alternancia ni historial.
- `lib/src/state/academy_store.dart`: notas, preferencias y memoria de errores por ejercicio.

```powershell
python tool/audit_aoi.py
python tool/compile_courses.py
python tool/compile_practice.py
python tool/compile_malware.py
flutter analyze --no-pub
flutter test --no-pub
```

La auditoría del banco se guarda en [AOI_BANK_AUDIT.json](AOI_BANK_AUDIT.json). La de cursos, con conteos y huellas de los originales, en [COURSE_CONTENT_AUDIT.json](COURSE_CONTENT_AUDIT.json), y la de refuerzos en [STARTER_PRACTICE_AUDIT.json](STARTER_PRACTICE_AUDIT.json). Los temarios se pueden revisar en [CURSOS.md](CURSOS.md) y [PRACTICAS_INICIALES.md](PRACTICAS_INICIALES.md).
