# Inicio, rutas y progreso · Aiocyb 1.6

25 de octubre de 2026. Continúa el diseño del catálogo de 1.5, con sus cinco portadas locales y las preferencias de cian/violeta y modo claro/oscuro. Los 25 cursos, 430 lecciones y 930 ejercicios permanecen incluidos.

## Inicio

La portada ofrece acceso a la última lección incompleta, con su curso, posición, duración estimada y ejercicios. Si esa lección ya está aprobada, se propone la siguiente pendiente. Cuando toda la academia está completada, ofrece repasar.

Cuatro indicadores muestran lecciones aprobadas, cursos completos, XP y ejercicios pendientes de repaso. Los accesos a Rutas, Repaso de errores, Biblioteca y Laboratorio funcionan dentro de la app. La biblioteca muestra el número de favoritos conservados.

Inicio presenta hasta tres cursos sugeridos: primero el curso que estás siguiendo, después los pendientes de esa ruta y finalmente otros cursos en el orden de la academia. Los cursos ya completados quedan fuera de las sugerencias mientras queden pendientes; al terminar todo, se ofrecen tres para repasar. El catálogo completo sigue accesible.

Aoi ofrece una intervención fija según haya repasos pendientes o esté completada la academia. La guía de estudio y el diagnóstico siguen disponibles. La cabecera usa un icono de saludo incluido en Flutter para evitar depender de una fuente de emoji.

## Rutas de aprendizaje

El directorio muestra cinco tarjetas con portada, descripción, número de cursos, ejercicios, duración estimada y avance. Permite filtrar Todas, En curso, Por comenzar y Completadas.

Cada ruta tiene una ficha propia con continuación, porcentaje de lecciones aprobadas, cursos completos y XP de esa ruta. El recorrido muestra los cursos en su orden editorial y señala el siguiente paso. Todos los cursos se pueden abrir desde el principio, incluido el último. Las portadas mantienen una proporción de 16:9.

Una ruta se completa al superar todas sus lecciones. Completar un curso de una ruta no equivale a completar la ruta completa. El logro anterior que se obtenía al terminar un curso se llama ahora «Un curso completo» para evitar esa confusión; sus condiciones y recompensas se mantienen.

## Mi progreso

La pantalla presenta el avance global, los XP, los cursos completos, las lecciones con nota y los aciertos en los mejores intentos. El porcentaje global cuenta lecciones aprobadas entre las 430 de la academia. Los porcentajes de las rutas cuentan sus propias lecciones; el global no es una media simple de las cinco barras.

La precisión usa la suma de mejores aciertos dividida entre todas las preguntas de las lecciones con nota guardada. Un resultado 0 cuenta como intento; una visita sin nota no entra en ese cálculo. Antes del primer intento se muestra `--`. El diagnóstico y los laboratorios no forman parte de esa precisión ni otorgan XP de cursos.

Los repasos pendientes incluyen preguntas de cursos y del diagnóstico que aún no se han resuelto. Un acceso permite retomarlos con su contexto original.

El detalle de notas está agrupado por curso y comienza plegado. Se puede filtrar por estado o buscar por palabras en el nombre del curso, categoría o título de una lección. La búsqueda ignora tildes y el orden de las palabras; al buscar se abren las coincidencias. Cada lección conserva su mejor nota y se puede estudiar desde su fila.

## Estados y almacenamiento

La proyección de datos está en `models/learning_overview.dart`; consultarla no escribe notas ni añade XP.

Se añade `startedCourseIds` a la misma clave de preferencias `aiocyb.academy.v1`. Entrar en una lección o guardar un intento marca su curso como comenzado. Una nota 0 o una visita sin aprobar muestran «En curso». El estado se conserva al abrir otra lección o reiniciar la app. El catálogo, las tarjetas, las fichas y los paneles usan el mismo criterio.

Al cargar datos anteriores, se conservan los inicios que se pueden demostrar por las notas y por la última lección guardada. Las visitas antiguas que nunca se registraron no se reconstruyen. Se descartan identificadores de cursos desconocidos. Alias, notas, XP derivados, favoritos, preferencias, errores y diálogos escuchados permanecen compatibles.

Reiniciar el progreso también vacía los cursos comenzados y mantiene las preferencias y favoritos, como antes. No se guardan tiempo de estudio ni rachas que no estuvieran registrados.

## Accesibilidad y adaptación

Las tarjetas de curso y ruta exponen una única acción accesible con nombre, estado y avance. Las barras incrustadas no separan el nombre del botón de abrir. La navegación lateral ocupa el alto disponible y admite desplazamiento en ventanas cortas.

Se comprueban móvil estrecho, texto ampliado y escritorio. Las tarjetas y cifras se adaptan al espacio disponible, sin fijar alturas al texto. Las imágenes se reutilizan desde `assets/artwork/`; no se agregan solicitudes de imágenes a Internet.

Implementación: `screens/learning_home.dart`, `screens/learning_routes.dart`, `screens/learning_progress.dart`, `screens/dashboard_actions.dart`, `widgets/learning_dashboard.dart`, `widgets/learning_link.dart`, `models/learning_overview.dart` y la ampliación compatible de `state/academy_store.dart`.
