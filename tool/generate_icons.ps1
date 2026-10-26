param(
    [string]$Source = 'assets/branding/aiocyb-emblem-v1.png'
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$projectRootPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$sourcePath = [System.IO.Path]::GetFullPath((Join-Path $projectRootPath $Source))
if (-not $sourcePath.StartsWith($projectRootPath + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'The source image must be inside the project.'
}
$sourceImage = [System.Drawing.Bitmap]::FromFile($sourcePath)

try {
    # Ignore almost invisible bloom when measuring the transparent artwork.
    $left = $sourceImage.Width
    $top = $sourceImage.Height
    $right = -1
    $bottom = -1
    for ($y = 0; $y -lt $sourceImage.Height; $y++) {
        for ($x = 0; $x -lt $sourceImage.Width; $x++) {
            if ($sourceImage.GetPixel($x, $y).A -gt 8) {
                $left = [Math]::Min($left, $x)
                $top = [Math]::Min($top, $y)
                $right = [Math]::Max($right, $x)
                $bottom = [Math]::Max($bottom, $y)
            }
        }
    }
    if ($right -lt $left) { throw 'The source image is empty.' }
    $sourceBounds = [System.Drawing.Rectangle]::new($left, $top, $right - $left + 1, $bottom - $top + 1)

    function New-IconBitmap {
        param([int]$Size, [double]$Fraction, [bool]$Transparent = $false)
        $bitmap = [System.Drawing.Bitmap]::new($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        try {
            $graphics.Clear([System.Drawing.Color]::Transparent)
            if (-not $Transparent) { $graphics.Clear([System.Drawing.ColorTranslator]::FromHtml('#0B1018')) }
            $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $scale = ($Size * $Fraction) / [Math]::Max($sourceBounds.Width, $sourceBounds.Height)
            $width = $sourceBounds.Width * $scale
            $height = $sourceBounds.Height * $scale
            $target = [System.Drawing.RectangleF]::new(($Size - $width) / 2, ($Size - $height) / 2, $width, $height)
            $graphics.DrawImage($sourceImage, $target, $sourceBounds, [System.Drawing.GraphicsUnit]::Pixel)
        } finally {
            $graphics.Dispose()
        }
        return ,$bitmap
    }

    function Save-IconPng {
        param([string]$RelativePath, [int]$Size, [double]$Fraction, [bool]$Transparent = $false)
        $outputPath = [System.IO.Path]::GetFullPath((Join-Path $projectRootPath $RelativePath))
        if (-not $outputPath.StartsWith($projectRootPath + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
            throw 'The output image must stay inside the project.'
        }
        [System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($outputPath)) | Out-Null
        $bitmap = New-IconBitmap -Size $Size -Fraction $Fraction -Transparent $Transparent
        try { $bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png) }
        finally { $bitmap.Dispose() }
        Write-Output "$RelativePath ($Size x $Size)"
    }

    Save-IconPng 'assets/branding/aiocyb-icon-1024.png' 1024 0.82
    Save-IconPng 'assets/branding/play-store-icon-512.png' 512 0.82

    # Android 108 dp adaptive foreground: emblem height 60 dp, inside the safe circle.
    Save-IconPng 'android/app/src/main/res/drawable-nodpi/aiocyb_emblem_foreground.png' 432 (60.0 / 108) $true
    foreach ($density in @(@('mdpi', 48), @('hdpi', 72), @('xhdpi', 96), @('xxhdpi', 144), @('xxxhdpi', 192))) {
        Save-IconPng "android/app/src/main/res/mipmap-$($density[0])/ic_launcher.png" $density[1] 0.82
    }

    Save-IconPng 'web/favicon.png' 48 0.88
    foreach ($size in @(192, 512)) {
        Save-IconPng "web/icons/Icon-$size.png" $size 0.82
        Save-IconPng "web/icons/Icon-maskable-$size.png" $size 0.72
    }

    # ICO embeds real PNG frames, including a 256 px high-DPI frame.
    $frames = [System.Collections.Generic.List[byte[]]]::new()
    $sizes = @(16, 24, 32, 48, 64, 128, 256)
    foreach ($size in $sizes) {
        $bitmap = New-IconBitmap -Size $size -Fraction 0.88
        $stream = [System.IO.MemoryStream]::new()
        try {
            $bitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
            $frames.Add($stream.ToArray())
        } finally {
            $stream.Dispose()
            $bitmap.Dispose()
        }
    }
    $icoPath = Join-Path $projectRootPath 'windows/runner/resources/app_icon.ico'
    $icoStream = [System.IO.File]::Create($icoPath)
    $writer = [System.IO.BinaryWriter]::new($icoStream)
    try {
        $writer.Write([uint16]0)
        $writer.Write([uint16]1)
        $writer.Write([uint16]$frames.Count)
        $offset = 6 + 16 * $frames.Count
        for ($i = 0; $i -lt $frames.Count; $i++) {
            $dimension = $sizes[$i] % 256
            $writer.Write([byte]$dimension)
            $writer.Write([byte]$dimension)
            $writer.Write([byte]0)
            $writer.Write([byte]0)
            $writer.Write([uint16]1)
            $writer.Write([uint16]32)
            $writer.Write([uint32]$frames[$i].Length)
            $writer.Write([uint32]$offset)
            $offset += $frames[$i].Length
        }
        foreach ($frame in $frames) { $writer.Write([byte[]]$frame) }
    } finally {
        $writer.Dispose()
        $icoStream.Dispose()
    }
    Write-Output 'windows/runner/resources/app_icon.ico (7 frames)'
} finally {
    $sourceImage.Dispose()
}
