# Criptografía, web y programación segura

Cuatro cursos, diez lecciones y treinta ejercicios por curso. Cada lección incluye 600–900 palabras de teoría, dos casos resueltos y tres ejercicios. Se aprueba con dos aciertos. Los originales Markdown se transcriben a JSON y constantes Dart sin generar ni rellenar contenido.

## Criptografía desde cero

Entiende qué protegen el cifrado, los resúmenes y las firmas antes de elegir una herramienta.

| Lección | Tema | Palabras de teoría | Casos resueltos | Ejercicios |
| ---: | --- | ---: | ---: | ---: |
| 1 | Primero decide qué quieres proteger | 634 | 2 | 3 |
| 2 | Codificar no significa ocultar | 635 | 2 | 3 |
| 3 | Un resumen necesita una referencia confiable | 645 | 2 | 3 |
| 4 | Cifrado simétrico y acceso compartido | 653 | 2 | 3 |
| 5 | Cifrar y detectar modificaciones | 643 | 2 | 3 |
| 6 | Claves públicas y privadas | 648 | 2 | 3 |
| 7 | Qué demuestra una firma digital | 651 | 2 | 3 |
| 8 | Certificados y confianza en una conexión | 653 | 2 | 3 |
| 9 | Azar, claves y valores que no deben repetirse | 658 | 2 | 3 |
| 10 | Elegir mecanismos sin promesas mágicas | 654 | 2 | 3 |

## Claves y protección de datos

Organiza secretos, protege contraseñas y prepara cambios y recuperación sin perder el control de tus datos.

| Lección | Tema | Palabras de teoría | Casos resueltos | Ejercicios |
| ---: | --- | ---: | ---: | ---: |
| 1 | No todos los valores son secretos | 667 | 2 | 3 |
| 2 | Dónde conservar un secreto | 673 | 2 | 3 |
| 3 | Verificar contraseñas sin conservarlas en claro | 662 | 2 | 3 |
| 4 | Cifrar datos que sí necesitas recuperar | 676 | 2 | 3 |
| 5 | Entregar acceso sin repartirlo de más | 660 | 2 | 3 |
| 6 | Cambiar secretos sin perder continuidad | 677 | 2 | 3 |
| 7 | Un secreto salió al repositorio | 674 | 2 | 3 |
| 8 | Registros, portapapeles y copias discretas | 670 | 2 | 3 |
| 9 | Conservar claves para una recuperación legítima | 683 | 2 | 3 |
| 10 | Un plan pequeño para secretos y datos | 681 | 2 | 3 |

## Seguridad web con criterio

Comprende peticiones, orígenes, sesiones y permisos para reconocer dónde debe protegerse una aplicación web.

| Lección | Tema | Palabras de teoría | Casos resueltos | Ejercicios |
| ---: | --- | ---: | ---: | ---: |
| 1 | Del clic a una decisión del servidor | 676 | 2 | 3 |
| 2 | Origen, sitio y fronteras del navegador | 681 | 2 | 3 |
| 3 | Cookies y atributos con propósito | 686 | 2 | 3 |
| 4 | La vida de una sesión | 697 | 2 | 3 |
| 5 | Autorizar cada recurso y cada acción | 684 | 2 | 3 |
| 6 | Proteger acciones que cambian estado | 692 | 2 | 3 |
| 7 | Mantener el contenido en su papel de dato | 700 | 2 | 3 |
| 8 | HTTPS a lo largo del flujo web | 683 | 2 | 3 |
| 9 | Políticas del navegador como defensa adicional | 675 | 2 | 3 |
| 10 | Cerrar el flujo de archivos del portal | 670 | 2 | 3 |

## Programación segura desde el diseño

Aprende a revisar entradas, consultas, archivos, dependencias y fallos con contratos claros y ejemplos ilustrativos.

| Lección | Tema | Palabras de teoría | Casos resueltos | Ejercicios |
| ---: | --- | ---: | ---: | ---: |
| 1 | Un programa necesita límites explicables | 703 | 2 | 3 |
| 2 | Tipos, límites y reglas del negocio | 686 | 2 | 3 |
| 3 | Separar valores y estructura en SQL | 695 | 2 | 3 |
| 4 | Archivos, nombres y ubicaciones permitidas | 709 | 2 | 3 |
| 5 | Configuración y secretos fuera de los ejemplos | 686 | 2 | 3 |
| 6 | Dependencias que puedas conocer y mantener | 692 | 2 | 3 |
| 7 | Fallar de una forma controlada | 709 | 2 | 3 |
| 8 | Dos operaciones pueden coincidir | 696 | 2 | 3 |
| 9 | Probar propiedades que importan | 714 | 2 | 3 |
| 10 | Revisar una función antes de compartirla | 707 | 2 | 3 |

## Auditoría

Total: 27,038 palabras de teoría original, 80 casos explicados, 120 ejercicios, 360 explicaciones de respuesta y 964 intervenciones editoriales de Aoi. Los mensajes se seleccionan por situación, sin alternancia manual.

Originales: assets/secure/*.md (originales) y *.json (transcripcion estructurada). Validación y compilación: python tool/compile_secure_courses.py. Informe por lección y huellas: [SECURE_CONTENT_AUDIT.json](SECURE_CONTENT_AUDIT.json).
