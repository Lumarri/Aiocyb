# Secciones y temas de Aiocyb

El catálogo, las fichas y el aula se rediseñaron en la versión 1.5. Véase [INTERFAZ_1_5.md](INTERFAZ_1_5.md).

Inicio, Rutas y Mi progreso se ampliaron en 1.6. Véase [INTERFAZ_1_6.md](INTERFAZ_1_6.md).

La navegación principal conserva Inicio, Cursos y Mi progreso, y añade Explorar. La configuración se llama Ajustes en la barra del móvil y Configuración en el menú amplio. El menú lateral admite desplazamiento en ventanas de poca altura.

## Explorar

- **Rutas de aprendizaje:** cinco recorridos que agrupan los veinticinco cursos. La ruta de Linux reúne sus seis cursos en orden orientativo. Muestran lecciones superadas y acceso directo sin bloquear contenidos.
- **Laboratorio offline:** cuatro simulaciones de tres etapas sobre protección de información, sesiones web, revisión de código y ciclo de claves. Cada decisión tiene feedback propio; solo se avanza al acertar. El primer error recibe una reacción suave y los posteriores, otra más mordaz. Se conservan errores y finalizaciones sin modificar notas ni XP de cursos. El texto de referencia de las etapas tiene etiqueta accesible.
- **Biblioteca:** búsqueda en títulos y teoría, filtro por curso, favoritos y páginas de veinte resultados. El marcador también se cambia desde el aula y permanece al reiniciar el progreso.
- **Repaso de errores:** incluye preguntas de cursos y diagnóstico. Recupera el índice original para que Aoi dé la pista y explicación correspondientes. Acertar resuelve el repaso y conserva nota y XP. Un error posterior vuelve a abrirlo.
- **Logros:** ocho objetivos calculados a partir del progreso, cursos, simulaciones y repasos. Repetir una actividad no concede XP adicional por esta sección.

## Apariencia

Los temas neón cian y violeta cambian los acentos de la aplicación. Las cabeceras pueden mostrar un halo suave, sin parpadeos. Tema, brillo, modo claro/oscuro y texto ampliado se guardan en este dispositivo.

La migración conserva el modo y progreso anteriores; los campos nuevos tienen valores iniciales compatibles. Los diálogos de Aoi siguen seleccionándose por situación y no incluyen controles de alternancia o historial.

El reinicio solicita confirmación y borra notas, XP, diagnóstico, errores, repasos y simulaciones completadas. Conserva alias, preferencias y favoritos, tal como explica su diálogo.

Implementación: `lib/src/screens/explore_screens.dart`, `data/learning_paths.dart`, `data/offline_labs.dart`, `theme.dart` y `state/academy_store.dart`. Las pruebas de contenido, migración e interacción están en `test/expanded_experience_test.dart`.
