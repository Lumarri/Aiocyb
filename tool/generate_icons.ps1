param([string]$Source = 'assets/branding/aiocyb-simple.svg')
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$projectRootPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))

function Get-ProjectPath {
    param([string]$RelativePath)
    $resolvedPath = [System.IO.Path]::GetFullPath((Join-Path $projectRootPath $RelativePath))
    if (-not $resolvedPath.StartsWith($projectRootPath + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
        throw 'Icon files must stay inside the project.'
    }
    return $resolvedPath
}

# The editable vector is the source for every export: no font, raster or effects.
[xml]$svg = [System.IO.File]::ReadAllText((Get-ProjectPath $Source))
if ($svg.svg.viewBox -ne '0 0 108 108') { throw 'Expected a 108 by 108 SVG viewport.' }
$backgroundHex = [string]$svg.svg.rect.fill
$foregroundHex = [string]$svg.svg.path.fill
$pathData = [string]$svg.svg.path.d
$backgroundColor = [System.Drawing.ColorTranslator]::FromHtml($backgroundHex)
$foregroundColor = [System.Drawing.ColorTranslator]::FromHtml($foregroundHex)
$shape = [System.Drawing.Drawing2D.GraphicsPath]::new([System.Drawing.Drawing2D.FillMode]::Alternate)
$points = [System.Collections.Generic.List[System.Drawing.PointF]]::new()
$maximumRadius = 0.0
foreach ($token in [regex]::Matches($pathData, '([ML])\s*([\d.]+)[,\s]+([\d.]+)|(Z)')) {
    if ($token.Groups[4].Success) {
        $shape.AddPolygon($points.ToArray())
        $points.Clear()
    } else {
        $pointX = [float]::Parse($token.Groups[2].Value, [System.Globalization.CultureInfo]::InvariantCulture)
        $pointY = [float]::Parse($token.Groups[3].Value, [System.Globalization.CultureInfo]::InvariantCulture)
        $points.Add([System.Drawing.PointF]::new($pointX, $pointY))
        $maximumRadius = [Math]::Max($maximumRadius, [Math]::Sqrt([Math]::Pow($pointX - 54, 2) + [Math]::Pow($pointY - 54, 2)))
    }
}
if ($points.Count -ne 0 -or $shape.PointCount -lt 3) { throw 'Expected closed M/L/Z polygons.' }
if ($maximumRadius -gt 33) { throw 'The adaptive symbol exceeds the Android safe circle.' }

function New-IconBitmap {
    param([int]$Size, [double]$RadiusFraction = 0.46)
    $renderSize = $Size * 4
    $render = [System.Drawing.Bitmap]::new($renderSize, $renderSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($render)
    $drawing = $shape.Clone()
    $brush = [System.Drawing.SolidBrush]::new($foregroundColor)
    $scale = [float]($renderSize * $RadiusFraction / $maximumRadius)
    $transform = [System.Drawing.Drawing2D.Matrix]::new($scale, 0, 0, $scale, ($renderSize / 2 - 54 * $scale), ($renderSize / 2 - 54 * $scale))
    try {
        # Full opaque background: no inset tile or pre-rounded corners.
        $graphics.Clear($backgroundColor)
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $drawing.Transform($transform)
        $graphics.FillPath($brush, $drawing)
    } finally {
        $graphics.Dispose(); $drawing.Dispose(); $brush.Dispose(); $transform.Dispose()
    }
    $bitmap = [System.Drawing.Bitmap]::new($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $output = [System.Drawing.Graphics]::FromImage($bitmap)
    $attributes = [System.Drawing.Imaging.ImageAttributes]::new()
    try {
        $output.Clear($backgroundColor)
        $output.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $attributes.SetWrapMode([System.Drawing.Drawing2D.WrapMode]::TileFlipXY)
        $output.DrawImage($render, [System.Drawing.Rectangle]::new(0, 0, $Size, $Size), 0, 0, $renderSize, $renderSize, [System.Drawing.GraphicsUnit]::Pixel, $attributes)
    } finally {
        $attributes.Dispose(); $output.Dispose(); $render.Dispose()
    }
    return ,$bitmap
}

function Save-IconPng {
    param([string]$RelativePath, [int]$Size, [double]$RadiusFraction = 0.46)
    $outputPath = Get-ProjectPath $RelativePath
    [System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($outputPath)) | Out-Null
    $bitmap = New-IconBitmap $Size $RadiusFraction
    try { $bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png) }
    finally { $bitmap.Dispose() }
    Write-Output "$RelativePath ($Size x $Size)"
}

try {
    Save-IconPng 'assets/branding/aiocyb-icon-1024.png' 1024
    Save-IconPng 'assets/branding/play-store-icon-512.png' 512
    foreach ($density in @(@('mdpi', 48), @('hdpi', 72), @('xhdpi', 96), @('xxhdpi', 144), @('xxxhdpi', 192))) {
        Save-IconPng "android/app/src/main/res/mipmap-$($density[0])/ic_launcher.png" $density[1]
    }
    Save-IconPng 'web/favicon.png' 48
    foreach ($size in @(192, 512)) {
        Save-IconPng "web/icons/Icon-$size.png" $size
        # The web maskable safe radius is 40% of the canvas.
        Save-IconPng "web/icons/Icon-maskable-$size.png" $size 0.385
    }

    $utf8 = [System.Text.UTF8Encoding]::new($false)
    foreach ($variant in @(@('aiocyb_icon_foreground', $foregroundHex), @('aiocyb_icon_monochrome', '#FFFFFF'))) {
        $vector = @"
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="$($variant[1])" android:fillType="evenOdd"
        android:pathData="$pathData" />
</vector>
"@
        [System.IO.File]::WriteAllText((Get-ProjectPath "android/app/src/main/res/drawable/$($variant[0]).xml"), $vector + [Environment]::NewLine, $utf8)
    }
    $colors = '<?xml version="1.0" encoding="utf-8"?>' + [Environment]::NewLine +
        '<resources>' + [Environment]::NewLine +
        '    <color name="aiocyb_icon_background">' + $backgroundHex + '</color>' + [Environment]::NewLine +
        '</resources>' + [Environment]::NewLine
    [System.IO.File]::WriteAllText((Get-ProjectPath 'android/app/src/main/res/values/icon_colors.xml'), $colors, $utf8)

    $frames = [System.Collections.Generic.List[byte[]]]::new()
    $sizes = @(16, 24, 32, 48, 64, 128, 256)
    foreach ($size in $sizes) {
        $bitmap = New-IconBitmap $size
        $stream = [System.IO.MemoryStream]::new()
        try {
            $bitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
            $frames.Add($stream.ToArray())
        } finally { $stream.Dispose(); $bitmap.Dispose() }
    }
    $icoStream = [System.IO.File]::Create((Get-ProjectPath 'windows/runner/resources/app_icon.ico'))
    $writer = [System.IO.BinaryWriter]::new($icoStream)
    try {
        $writer.Write([uint16]0); $writer.Write([uint16]1); $writer.Write([uint16]$frames.Count)
        $offset = 6 + 16 * $frames.Count
        for ($i = 0; $i -lt $frames.Count; $i++) {
            $writer.Write([byte]($sizes[$i] % 256)); $writer.Write([byte]($sizes[$i] % 256))
            $writer.Write([byte]0); $writer.Write([byte]0)
            $writer.Write([uint16]1); $writer.Write([uint16]32)
            $writer.Write([uint32]$frames[$i].Length); $writer.Write([uint32]$offset)
            $offset += $frames[$i].Length
        }
        foreach ($frame in $frames) { $writer.Write([byte[]]$frame) }
    } finally { $writer.Dispose(); $icoStream.Dispose() }
    Write-Output "Windows ICO: 7 sizes. Adaptive safe radius: $([Math]::Round($maximumRadius, 3)) dp."
} finally { $shape.Dispose() }
