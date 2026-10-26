# Icono de Aiocyb

26 de octubre de 2026. Emblema original de un escudo con una A, un destello central y bordes cian y violeta sobre azul oscuro. Sustituye el escudo verde anterior y los iconos de plantilla de web y Windows.

![Icono final](../assets/branding/play-store-icon-512.png)

## Archivos e integración

- [Original transparente](../assets/branding/aiocyb-emblem-v1.png), conservado sin modificaciones.
- [Icono de 1024 px](../assets/branding/aiocyb-icon-1024.png) y [exportación de 512 px](../assets/branding/play-store-icon-512.png).
- Android: cinco densidades de iconos clásicos; icono adaptativo desde API 26 y capa monocromática desde API 33. El manifiesto usa `@mipmap/ic_launcher` también para el icono redondo.
- Web: favicon de 48 px y variantes normales y maskable de 192 y 512 px. El manifiesto y el tema del navegador usan `#0B1018`.
- Windows: ICO con siete tamaños, entre 16 y 256 px. No se ha compilado el ejecutable de Windows.

El primer plano adaptativo es transparente, de 432 × 432 px para un lienzo de 108 dp. El dibujo ocupa 60 dp de altura; la comprobación de píxeles con alfa superior a 16 da un radio máximo de 31,03 dp, dentro del círculo seguro de 33 dp. Las variantes web maskable tienen su propio margen. Referencia: [iconos adaptativos de Android](https://developer.android.com/develop/ui/compose/system/icon_design_adaptive).

## Regeneración

Las exportaciones se generan localmente desde el original mediante System.Drawing, sin descargar imágenes ni dependencias de Flutter:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tool/generate_icons.ps1
```

El script solo exporta tamaños, formato y fondo para cada plataforma; el original generado conserva su transparencia. No modifica la política de ejecución del sistema.

## Comprobación de la entrega

- `flutter analyze --no-pub`: sin incidencias.
- Trece PNG exportados con las dimensiones esperadas y siete tamaños válidos en el ICO.
- `flutter build apk --release --target-platform android-arm64 --no-pub`: compilación correcta; Gradle tardó 722,3 segundos.
- El manifiesto Android compilado apunta al nuevo icono normal y redondo. El APK contiene las cinco densidades clásicas, dos variantes adaptativas y la capa monocromática.
- Los píxeles visibles de los seis PNG Android empaquetados coinciden con los originales exportados, aunque la compresión de sus archivos sea diferente.
- La auditoría completa del APK vuelve a confirmar 25 cursos, 430 lecciones, 930 ejercicios, los recursos de Aoi y la ausencia del permiso de Internet. Las fuentes de las comprobaciones de interfaz de 1.6 conservan sus hashes; no se ha modificado código Dart ni repetido la prueba de interfaz para cambiar el icono.

[Auditoría del icono](ICON_AUDIT.json) · [Auditoría del APK actual](BUILD_AUDIT.json).

APK local: `build/app/outputs/flutter-apk/app-release.apk`, 69 964 302 bytes. SHA-256: `4839e8b7097221776b76ee2efc366b2ed5add9750479c252ac629a41aacb0aad`. Se conserva la versión 1.6.0+8. El instalador se genera localmente y queda fuera del repositorio de código. No se ha instalado esta compilación en un teléfono ni comprobado el icono en un lanzador físico.

## Generación original

Se aplicó la habilidad imagegen con la herramienta integrada `image_gen`, con `transparent_background: true`. No se usó la CLI ni una clave API. El resultado se copió a `assets/branding/aiocyb-emblem-v1.png` antes de generar las exportaciones.

Prompt final:

```text
Use case: logo-brand. Asset type: final Android app launcher icon source for Aiocyb, a Spanish offline cybersecurity academy whose UI uses deep navy, electric cyan and violet. Create ONE polished square icon artwork, front-facing orthographic, not a mockup or icon sheet. Subject: a bold faceted security shield forming a distinctive capital A in its negative space, with a crisp small lightning-shaped slash in the central crossbar. Material: clean dark titanium with luminous cyan bevel on the left and vibrant violet rim on the right, restrained soft neon bloom, high contrast, subtle dimensional depth. Strong simple silhouette, broad readable strokes, feels confident and playful. Center the entire emblem in the middle 58% of the square canvas so it survives circular Android adaptive masks, and leave the remaining outer area fully transparent. Transparent background, no tile, no rounded-square container, no shadow cast onto a background. Keep the interior dark navy. No typography, no wordmark, no letters beyond the geometric A built into the shield, no small circuit traces, no character, no extra objects, no watermark. 1024 by 1024 square, excellent recognition at 48 pixels.
```
