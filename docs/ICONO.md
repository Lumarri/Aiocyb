# Icono de Aiocyb 1.7.1

29 de octubre de 2026. Diseño vectorial original definido con coordenadas SVG: una A geométrica azul oscuro `#081820` sobre cian `#22D3EE`. El fondo ocupa todo el cuadrado; la forma usa dos polígonos con relleno par e impar, sin tipografías, texturas, brillo ni bisel.

![Icono plano de Aiocyb](../assets/branding/play-store-icon-512.png)

## Fuente y exportaciones

La fuente editable es [aiocyb-simple.svg](../assets/branding/aiocyb-simple.svg), con lienzo de 108 × 108. El [generador local](../tool/generate_icons.ps1) lee sus colores y coordenadas para producir los PNG, el ICO y los vectores Android. No descarga imágenes ni requiere nuevas dependencias de Flutter.

- Doce PNG opacos: originales de 1024 y 512 px; cinco densidades Android de 48, 72, 96, 144 y 192 px; favicon de 48 px; iconos web normales y maskable de 192 y 512 px.
- Android: iconos clásicos para API 24–25, primer plano vectorial y fondo de color desde API 26, y vector monocromático de la misma A desde API 33. El manifiesto usa `@mipmap/ic_launcher` para los iconos normal y redondo.
- Windows: ICO con siete cuadros PNG reales de 16, 24, 32, 48, 64, 128 y 256 px. No se ha compilado el ejecutable de Windows.

En los adaptativos, el símbolo alcanza un radio máximo de 32,52691 dp respecto del centro `(54,54)`, dentro del círculo seguro de 33 dp. El fondo cubre los 108 dp completos. Las exportaciones clásicas amplían la A con un radio geométrico del 46% del lienzo; las web maskable utilizan el 38,5%, dejando margen para el suavizado dentro del radio seguro del 40%. Los doce PNG mantienen alfa 255 y el color cian exacto en todos los píxeles de sus bordes.

## Regeneración y auditoría

Desde la raíz del proyecto, en Windows PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tool/generate_icons.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tool/audit_icons.ps1
```

El segundo comando comprueba fuente, colores, geometría, contraste, tamaños, opacidad y bordes de los doce PNG, contenido de los siete cuadros ICO y correspondencia entre SVG, vectores y referencias adaptativas. En los cuadros ICO más pequeños puede haber suavizado hasta el borde; la comprobación estricta del fondo en todos los bordes corresponde a los doce PNG independientes. La inspección visual de 512 y 48 px confirma que la A sigue siendo reconocible; las comprobaciones de píxeles complementan esa revisión.

Para comprobar además el APK compilado:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tool/audit_icons.ps1 `
  -Apk build/app/outputs/flutter-apk/app-release.apk `
  -Aapt D:/DevTools/Android/sdk/build-tools/36.1.0/aapt.exe
```

Con `-Apk`, el auditor verifica identidad y versión frente a `pubspec.yaml`, las referencias de icono normal y redondo, las cinco densidades PNG empaquetadas por comparación de píxeles decodificados, los colores y trazados vectoriales compilados y las variantes adaptativas API 26 y 33. Utiliza `aapt`, `ZipArchive` y `System.Drawing`; no instala bibliotecas. Los nombres de recursos optimizados se obtienen del APK, sin depender de nombres internos de una compilación anterior.

El resultado se escribe en [ICON_AUDIT.json](ICON_AUDIT.json). `scope: source_only` y `apk_verified: false` indican que se comprobaron únicamente fuentes y exportaciones; `scope: source_and_packaged_apk` y `apk_verified: true` requieren que también finalice la comprobación del APK indicado. Una comprobación fallida queda registrada con su error y devuelve código de salida 1.

## Estado y límites

La compilación Android ARM64 1.7.1+10 terminó correctamente en 791,6 segundos. La auditoría de fuentes y del APK terminó sin errores: doce PNG, siete tamaños ICO, cinco densidades Android empaquetadas con cero diferencias de píxeles, dos variantes adaptativas y una capa monocromática con los vectores correctos.

APK: `build/app/outputs/flutter-apk/app-release.apk`, 71 287 226 bytes. SHA-256: `368a344c9ef39e89c282959d222995e4b42422474b4a54f2613a438b99d7c149`. La auditoría general vuelve a comprobar el contenido real del paquete: 31 cursos, 490 lecciones, 1530 ejercicios y ausencia del permiso de Internet.

La evidencia de interfaz procede del commit verificado de 1.7.0; los recorridos no se repitieron para este cambio de icono. El auditor comprueba que los 44 archivos de `lib/` y los recursos de la interfaz conservan sus bytes, permitiendo únicamente el valor de versión en `app_info.dart` y `pubspec.yaml`. El informe distingue las huellas actuales y las comprobadas en el navegador. La auditoría general de este cambio se reproduce con:

```powershell
python tool/audit_release.py `
  --aapt D:/DevTools/Android/sdk/build-tools/36.1.0/aapt.exe `
  --browser-baseline-ref eb367e987b09b975a1d2e512de2f3c1a58752798
```

No se ha comprobado el icono en un lanzador de teléfono físico. Las máscaras y el tratamiento de los iconos temáticos dependen del sistema y del lanzador. La [auditoría general de compilación](BUILD_AUDIT.json) documenta el contenido y las limitaciones del APK entregado.

El informe del emblema anterior se conserva intacto en [ICON_AUDIT_1_6.json](ICON_AUDIT_1_6.json), con su versión, recursos y huella originales.
