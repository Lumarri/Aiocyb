# Cursos de Aiocyb 1.5

El rediseño mantiene Flutter y Android como plataforma principal. La web compilada sirve para revisar la adaptación a escritorio y móvil. Los cursos y sus identificadores permanecen iguales; las preferencias y notas usan el almacenamiento existente.

## Referencias de estructura

Se consultaron el [catálogo de seguridad de Coursera](https://www.coursera.org/browse/information-technology/security), su [ficha de Fundamentos de ciberseguridad](https://www.coursera.org/learn/foundations-of-cybersecurity), el [catálogo de Cisco Networking Academy](https://www.netacad.com/catalogs/learn?courseLang=en-US) y su [Introducción a la ciberseguridad](https://www.netacad.com/courses/introduction-to-cybersecurity). Se toman como referencia la organización por temas, la presentación de habilidades y el temario modular. Aiocyb conserva su identidad, contenido, colores configurables y tutora; las nuevas portadas son originales.

## Catálogo

- Cabecera con presentación y botones para explorar o continuar el aprendizaje.
- Cinco áreas: fundamentos, redes y Wi-Fi, malware y recuperación, desarrollo seguro y Linux y registros.
- Filtros por todos, en curso, por comenzar y completados. Un curso está completado cuando se han aprobado todas sus lecciones; los filtros usan las notas guardadas.
- Búsqueda por palabras en título, categoría, descripción, habilidades y títulos de lecciones. Ignora mayúsculas y tildes.
- Orden por ruta sugerida, menor duración o nombre. Mensaje de búsqueda vacía y restablecimiento de filtros.
- Tarjetas con portada, descripción, habilidades, duración estimada, número de lecciones y ejercicios y progreso real.
- Hasta tres columnas según el espacio disponible y la escala de texto; filtros laterales en pantallas amplias y horizontales en móvil.

## Presentación de cada curso

Los 25 cursos tienen tres objetivos y tres habilidades específicos. La ficha muestra portada, descripción, nivel, idioma y acceso sin conexión. Una barra permite saltar a Acerca del curso, Temario y Conceptos. El botón para empezar, continuar o repasar permanece al pie en móvil; el escritorio ofrece un panel de estudio.

El temario agrupa las diez lecciones en módulos de cuatro, cuatro y dos; los cursos de cuarenta microlecciones usan cuatro módulos de diez. Ninguna lección se bloquea. Los módulos muestran sus lecciones superadas y cada lección muestra su mejor nota cuando existe. Se abre inicialmente el módulo de la siguiente lección. La continuación respeta la última lección incompleta del curso; si no hay una, elige la primera pendiente.

## Conceptos y aula

Cada curso presenta tres conceptos extraídos de su primera lección, una intermedia y la última: 75 accesos a teoría ya incluida. No son resúmenes inventados ni material duplicado que deba mantenerse por separado. El lector muestra el texto completo, la lección de origen y las referencias; permite abrir la lección correspondiente. Consultar las páginas de referencia requiere Internet, estudiar su contenido incluido no.

El aula identifica el curso y la posición de la lección. Conserva las partes Inicio, Teoría, Pasos y Caso/Casos, la práctica y la tutora contextual. El botón Temario del curso abre una lista de lecciones con su estado. Elegir otra sustituye la lección actual; Atrás regresa al curso sin acumular aulas intermedias.

## Recursos locales

Cinco portadas originales en `assets/artwork/`, una por área. Sus prompts y método figuran en [PORTADAS_1_5.md](PORTADAS_1_5.md). Son ilustraciones conceptuales, sin texto ni marcas de terceros. Los diagramas educativos conservan los iconos Cisco previamente acreditados. Los 16 retratos de Aoi permanecen incluidos.

Implementación: `data/course_presentation.dart`, `screens/course_catalog.dart`, `screens/course_overview.dart`, `screens/lesson_navigation.dart`, `screens/lesson_studio.dart` y `widgets/course_visuals.dart`. Las pruebas nuevas recorren filtros, conceptos, continuación, cambio de lección y adaptación a 320 px, texto ampliado y escritorio.
