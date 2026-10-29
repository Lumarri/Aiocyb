param(
    [string]$Apk = '',
    [string]$Aapt = 'aapt'
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$projectRootPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$androidNamespace = 'http://schemas.android.com/apk/res/android'
$reportPath = Join-Path $projectRootPath 'docs/ICON_AUDIT.json'
$utf8 = [System.Text.UTF8Encoding]::new($false)

# Read-only pixel inspection. C# keeps the full-image checks fast on Windows
# PowerShell 5 without installing Pillow or another image dependency.
if (-not ('AiocybIconPixels' -as [type])) {
    Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
public sealed class AiocybIconStats {
    public int Width, Height, NonOpaque, WrongEdge, SymbolPixels, CorePixels, InkPixels;
    public int Left, Top, Right, Bottom;
    public double MaximumRadiusFraction;
}
public static class AiocybIconPixels {
    public static AiocybIconStats Inspect(Bitmap image, int background, int foreground) {
        var result = new AiocybIconStats {
            Width = image.Width, Height = image.Height,
            Left = image.Width, Top = image.Height, Right = -1, Bottom = -1
        };
        Color backgroundColor = Color.FromArgb(background), foregroundColor = Color.FromArgb(foreground);
        int inkThreshold = Math.Max(Math.Abs(foregroundColor.R - backgroundColor.R),
            Math.Max(Math.Abs(foregroundColor.G - backgroundColor.G), Math.Abs(foregroundColor.B - backgroundColor.B))) / 2;
        for (int y = 0; y < image.Height; y++) {
            for (int x = 0; x < image.Width; x++) {
                Color pixel = image.GetPixel(x, y);
                int value = pixel.ToArgb();
                if (pixel.A != 255) result.NonOpaque++;
                if ((x == 0 || y == 0 || x == image.Width - 1 || y == image.Height - 1)
                        && value != background) result.WrongEdge++;
                if (value == foreground) result.CorePixels++;
                int colorDifference = Math.Max(Math.Abs(pixel.R - backgroundColor.R),
                    Math.Max(Math.Abs(pixel.G - backgroundColor.G), Math.Abs(pixel.B - backgroundColor.B)));
                if (colorDifference >= inkThreshold) result.InkPixels++;
                if (value == background) continue;
                result.SymbolPixels++;
                result.Left = Math.Min(result.Left, x); result.Top = Math.Min(result.Top, y);
                result.Right = Math.Max(result.Right, x); result.Bottom = Math.Max(result.Bottom, y);
                double dx = (x + 0.5 - image.Width / 2.0) / image.Width;
                double dy = (y + 0.5 - image.Height / 2.0) / image.Height;
                result.MaximumRadiusFraction = Math.Max(result.MaximumRadiusFraction, Math.Sqrt(dx * dx + dy * dy));
            }
        }
        return result;
    }
    public static int Differences(Bitmap left, Bitmap right) {
        if (left.Width != right.Width || left.Height != right.Height) return -1;
        int count = 0;
        for (int y = 0; y < left.Height; y++)
            for (int x = 0; x < left.Width; x++)
                if (left.GetPixel(x, y).ToArgb() != right.GetPixel(x, y).ToArgb()) count++;
        return count;
    }
}
'@
}

function Assert-Icon {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

function Get-ProjectPath {
    param([string]$RelativePath)
    $resolved = [System.IO.Path]::GetFullPath((Join-Path $projectRootPath $RelativePath))
    Assert-Icon ($resolved.StartsWith($projectRootPath + '\', [System.StringComparison]::OrdinalIgnoreCase)) 'Icon source must stay inside the project.'
    return $resolved
}

function Get-AndroidAttribute {
    param([System.Xml.XmlElement]$Element, [string]$Name)
    return $Element.GetAttribute($Name, $androidNamespace)
}

function Get-NormalizedPath {
    param([string]$Data)
    return [regex]::Replace($Data, '[\s,]', '')
}

function Get-RelativeLuminance {
    param([System.Drawing.Color]$Color)
    $channels = @($Color.R, $Color.G, $Color.B) | ForEach-Object {
        $channel = $_ / 255.0
        if ($channel -le 0.04045) { $channel / 12.92 }
        else { [Math]::Pow(($channel + 0.055) / 1.055, 2.4) }
    }
    return 0.2126 * $channels[0] + 0.7152 * $channels[1] + 0.0722 * $channels[2]
}

function Get-PixelCheck {
    param([System.Drawing.Bitmap]$Image, [int]$Size, [bool]$Maskable = $false, [bool]$CheckEdges = $true)
    $stats = [AiocybIconPixels]::Inspect($Image, $backgroundColor.ToArgb(), $foregroundColor.ToArgb())
    Assert-Icon ($stats.Width -eq $Size -and $stats.Height -eq $Size) "Expected a $Size by $Size icon."
    Assert-Icon ($stats.NonOpaque -eq 0) 'Every exported pixel must have alpha 255.'
    if ($CheckEdges) {
        Assert-Icon ($stats.WrongEdge -eq 0) "Every edge pixel of the $Size px export must equal the full-bleed background color ($($stats.WrongEdge) mismatches)."
    }
    Assert-Icon ($stats.InkPixels -ge $Size * $Size * 0.06) "The high-contrast symbol occupies too little of the $Size px icon."
    $minimumHeight = if ($Maskable) { 0.55 } else { 0.65 }
    Assert-Icon (($stats.Bottom - $stats.Top + 1) / $Size -ge $minimumHeight) 'The symbol is unexpectedly small.'
    if ($Maskable) {
        Assert-Icon ($stats.MaximumRadiusFraction -le 0.40) 'Maskable artwork exceeds the central 40-percent safe radius.'
    }
    return [ordered]@{
        size = $Size
        non_opaque_pixels = $stats.NonOpaque
        wrong_background_edge_pixels = $stats.WrongEdge
        solid_symbol_pixels = $stats.CorePixels
        high_contrast_symbol_pixels = $stats.InkPixels
        symbol_bounds = @($stats.Left, $stats.Top, ($stats.Right + 1), ($stats.Bottom + 1))
        measured_symbol_radius_fraction = [Math]::Round($stats.MaximumRadiusFraction, 5)
        maskable = $Maskable
    }
}

function Invoke-AaptText {
    param([string[]]$Arguments)
    $lines = & $Aapt @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) { throw "aapt failed: $($lines -join ' ')" }
    return $lines -join "`n"
}

function Get-ResourceRecords {
    param([string]$Resources)
    $configuration = ''
    $pending = $null
    foreach ($line in ($Resources -split "`n")) {
        if ($line -match '^\s*config (.+):\s*$') { $configuration = $Matches[1] }
        if ($line -match '^\s*resource (0x[0-9a-fA-F]+) [^:]+:([^/]+)/([^:]+): (.+)$') {
            $pending = [pscustomobject]@{
                id = $Matches[1]; type = $Matches[2]; name = $Matches[3]
                config = $configuration; value = $Matches[4]; path = $null
            }
            if ($pending.type -eq 'color' -and $pending.name -eq 'aiocyb_icon_background') { $pending }
        } elseif ($null -ne $pending -and $line -match '^\s*\(string(?:8|16)\) "([^"]+)"') {
            $pending.path = $Matches[1]
            $pending
            $pending = $null
        }
    }
}

function Read-ZipBytes {
    param([System.IO.Compression.ZipArchive]$Archive, [string]$Name)
    $entry = $Archive.GetEntry($Name)
    Assert-Icon ($null -ne $entry) "APK resource is missing: $Name"
    $stream = $entry.Open()
    $memory = [System.IO.MemoryStream]::new()
    try { $stream.CopyTo($memory); return ,$memory.ToArray() }
    finally { $stream.Dispose(); $memory.Dispose() }
}

$versionMatch = [regex]::Match([System.IO.File]::ReadAllText((Get-ProjectPath 'pubspec.yaml')), '(?m)^version:\s*(\S+)')
$version = $versionMatch.Groups[1].Value
$report = [ordered]@{
    date = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::UtcNow, 'SA Pacific Standard Time').ToString('yyyy-MM-dd')
    version = $version
    status = 'failed'
    scope = 'source_only'
    design = 'Original flat geometric A; full-bleed cyan background and dark navy symbol.'
    png_exports = 0
    png_checks = @()
    windows_ico_sizes = @()
    windows_ico_checks = @()
    adaptive_safe_radius_dp = 33
    measured_artwork_radius_dp = $null
    monochrome_matches_source = $false
    source_files = @()
    compiled_adaptive_variants = 0
    compiled_monochrome_variants = 0
    compiled_png_pixel_checks = @()
    compiled_vector_checks = @()
    apk = $null
    apk_verified = $false
    hardware_launcher_tested = $false
    windows_executable_built = $false
    errors = @()
}
$sourceNames = [System.Collections.Generic.List[string]]::new()

try {
    Assert-Icon ($versionMatch.Success) 'pubspec.yaml must declare the application version.'
    [xml]$svg = [System.IO.File]::ReadAllText((Get-ProjectPath 'assets/branding/aiocyb-simple.svg'))
    Assert-Icon ($svg.svg.viewBox -eq '0 0 108 108') 'Expected a 108 by 108 SVG viewport.'
    Assert-Icon (@($svg.svg.rect).Count -eq 1 -and @($svg.svg.path).Count -eq 1) 'Expected one background rectangle and one geometric symbol.'
    Assert-Icon ($svg.svg.rect.width -eq '108' -and $svg.svg.rect.height -eq '108') 'The background must cover the full SVG viewport.'
    $backgroundHex = [string]$svg.svg.rect.fill
    $foregroundHex = [string]$svg.svg.path.fill
    Assert-Icon ($backgroundHex -eq '#22D3EE' -and $foregroundHex -eq '#081820') 'Unexpected colors in the flat icon source.'
    Assert-Icon ($svg.svg.path.'fill-rule' -eq 'evenodd') 'The A counter requires even-odd filling.'
    $backgroundColor = [System.Drawing.ColorTranslator]::FromHtml($backgroundHex)
    $foregroundColor = [System.Drawing.ColorTranslator]::FromHtml($foregroundHex)
    $contrast = ((Get-RelativeLuminance $backgroundColor) + 0.05) / ((Get-RelativeLuminance $foregroundColor) + 0.05)
    Assert-Icon ($contrast -ge 7) 'The flat symbol must retain high luminance contrast.'
    $report['background'] = $backgroundHex
    $report['foreground'] = $foregroundHex
    $report['contrast_ratio'] = [Math]::Round($contrast, 2)
    $pathData = [string]$svg.svg.path.d
    $pathPattern = '([ML])\s*([\d.]+)[,\s]+([\d.]+)|(Z)'
    Assert-Icon ([regex]::Replace($pathData, $pathPattern, '').Trim().Length -eq 0) 'Only explicit M/L/Z polygons are supported by this audit.'
    $radius = 0.0
    $vertices = 0
    foreach ($token in [regex]::Matches($pathData, $pathPattern)) {
        if ($token.Groups[4].Success) { continue }
        $pointX = [double]::Parse($token.Groups[2].Value, [System.Globalization.CultureInfo]::InvariantCulture)
        $pointY = [double]::Parse($token.Groups[3].Value, [System.Globalization.CultureInfo]::InvariantCulture)
        $radius = [Math]::Max($radius, [Math]::Sqrt([Math]::Pow($pointX - 54, 2) + [Math]::Pow($pointY - 54, 2)))
        $vertices++
    }
    Assert-Icon ($vertices -ge 6 -and $radius -le 33) 'The essential Android symbol exceeds its safe circle.'
    $report['measured_artwork_radius_dp'] = [Math]::Round($radius, 5)
    $sourceNames.Add('assets/branding/aiocyb-simple.svg')

    $exports = @(
        @('assets/branding/aiocyb-icon-1024.png', 1024),
        @('assets/branding/play-store-icon-512.png', 512),
        @('android/app/src/main/res/mipmap-mdpi/ic_launcher.png', 48),
        @('android/app/src/main/res/mipmap-hdpi/ic_launcher.png', 72),
        @('android/app/src/main/res/mipmap-xhdpi/ic_launcher.png', 96),
        @('android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png', 144),
        @('android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png', 192),
        @('web/favicon.png', 48),
        @('web/icons/Icon-192.png', 192),
        @('web/icons/Icon-512.png', 512),
        @('web/icons/Icon-maskable-192.png', 192),
        @('web/icons/Icon-maskable-512.png', 512)
    )
    foreach ($export in $exports) {
        $image = [System.Drawing.Bitmap]::FromFile((Get-ProjectPath $export[0]))
        try {
            $check = Get-PixelCheck $image $export[1] ($export[0] -like '*maskable*')
            $check['path'] = $export[0]
            $report['png_checks'] += $check
        } finally { $image.Dispose() }
        $sourceNames.Add($export[0])
    }
    $report['png_exports'] = $report['png_checks'].Count
    Assert-Icon ($report['png_exports'] -eq 12) 'Expected exactly twelve current PNG exports.'

    foreach ($variant in @(@('aiocyb_icon_foreground', $foregroundHex), @('aiocyb_icon_monochrome', '#FFFFFF'))) {
        $relative = "android/app/src/main/res/drawable/$($variant[0]).xml"
        [xml]$vector = [System.IO.File]::ReadAllText((Get-ProjectPath $relative))
        Assert-Icon ($vector.DocumentElement.LocalName -eq 'vector') 'Adaptive foregrounds must be vector resources.'
        foreach ($attribute in @('width', 'height')) {
            Assert-Icon ((Get-AndroidAttribute $vector.vector $attribute) -eq '108dp') 'Vector dimensions must be 108dp.'
        }
        foreach ($attribute in @('viewportWidth', 'viewportHeight')) {
            Assert-Icon ((Get-AndroidAttribute $vector.vector $attribute) -eq '108') 'Vector viewport must match the SVG.'
        }
        Assert-Icon (@($vector.vector.path).Count -eq 1) 'Unexpected extra shapes in the Android vector.'
        Assert-Icon ((Get-NormalizedPath (Get-AndroidAttribute $vector.vector.path 'pathData')) -ceq (Get-NormalizedPath $pathData)) 'Android pathData differs from the editable SVG.'
        Assert-Icon ((Get-AndroidAttribute $vector.vector.path 'fillColor') -eq $variant[1]) 'Unexpected vector fill color.'
        Assert-Icon ((Get-AndroidAttribute $vector.vector.path 'fillType') -eq 'evenOdd') 'Android path fill rule differs from the SVG.'
        $sourceNames.Add($relative)
    }
    $report['monochrome_matches_source'] = $true
    [xml]$colors = [System.IO.File]::ReadAllText((Get-ProjectPath 'android/app/src/main/res/values/icon_colors.xml'))
    Assert-Icon ([string]($colors.resources.color | Where-Object { $_.name -eq 'aiocyb_icon_background' }).InnerText -eq $backgroundHex) 'Android adaptive background color differs from the SVG.'
    foreach ($level in @(26, 33)) {
        $relative = "android/app/src/main/res/mipmap-anydpi-v$level/ic_launcher.xml"
        [xml]$adaptive = [System.IO.File]::ReadAllText((Get-ProjectPath $relative))
        $icon = $adaptive.DocumentElement
        Assert-Icon ($icon.LocalName -eq 'adaptive-icon') 'Expected an adaptive-icon resource.'
        Assert-Icon ((Get-AndroidAttribute $icon.background 'drawable') -eq '@color/aiocyb_icon_background') 'Wrong adaptive background reference.'
        Assert-Icon ((Get-AndroidAttribute $icon.foreground 'drawable') -eq '@drawable/aiocyb_icon_foreground') 'Wrong adaptive foreground reference.'
        if ($level -eq 33) {
            Assert-Icon ((Get-AndroidAttribute $icon.monochrome 'drawable') -eq '@drawable/aiocyb_icon_monochrome') 'Wrong themed icon reference.'
        } else { Assert-Icon ($null -eq $icon.monochrome) 'The API 26 variant must not require the API 33 monochrome layer.' }
        $sourceNames.Add($relative)
    }
    [xml]$manifest = [System.IO.File]::ReadAllText((Get-ProjectPath 'android/app/src/main/AndroidManifest.xml'))
    foreach ($attribute in @('icon', 'roundIcon')) {
        Assert-Icon ((Get-AndroidAttribute $manifest.manifest.application $attribute) -eq '@mipmap/ic_launcher') 'Launcher and round launcher must reference the current icon.'
    }

    $icoRelative = 'windows/runner/resources/app_icon.ico'
    $icoBytes = [System.IO.File]::ReadAllBytes((Get-ProjectPath $icoRelative))
    $icoMemory = [System.IO.MemoryStream]::new($icoBytes, $false)
    $reader = [System.IO.BinaryReader]::new($icoMemory)
    $expectedSizes = @(16, 24, 32, 48, 64, 128, 256)
    try {
        Assert-Icon ($reader.ReadUInt16() -eq 0 -and $reader.ReadUInt16() -eq 1 -and $reader.ReadUInt16() -eq 7) 'Expected a Windows ICO containing seven frames.'
        $frames = @()
        foreach ($expectedSize in $expectedSizes) {
            $width = [int]$reader.ReadByte(); if ($width -eq 0) { $width = 256 }
            $height = [int]$reader.ReadByte(); if ($height -eq 0) { $height = 256 }
            $null = $reader.ReadByte(); $null = $reader.ReadByte()
            $planes = $reader.ReadUInt16(); $bits = $reader.ReadUInt16()
            $length = $reader.ReadUInt32(); $offset = $reader.ReadUInt32()
            Assert-Icon ($width -eq $expectedSize -and $height -eq $expectedSize -and $planes -eq 1 -and $bits -eq 32) 'Invalid ICO frame dimensions or pixel format.'
            Assert-Icon ($offset -ge 118 -and $offset + $length -le $icoBytes.Length) 'ICO frame offset exceeds the file.'
            $frames += [pscustomobject]@{ size = $expectedSize; length = $length; offset = $offset }
        }
        foreach ($frame in $frames) {
            $icoMemory.Position = $frame.offset
            $frameBytes = $reader.ReadBytes($frame.length)
            Assert-Icon ([BitConverter]::ToString($frameBytes, 0, 8) -eq '89-50-4E-47-0D-0A-1A-0A') 'Each ICO frame must contain a real PNG.'
            $frameStream = [System.IO.MemoryStream]::new($frameBytes, $false)
            $frameImage = [System.Drawing.Bitmap]::FromStream($frameStream)
            # Tiny ICO frames may antialias to the edge; the strict all-edge
            # background check applies to the twelve standalone PNG exports.
            try { $report['windows_ico_checks'] += Get-PixelCheck $frameImage $frame.size $false $false }
            finally { $frameImage.Dispose(); $frameStream.Dispose() }
        }
        $report['windows_ico_sizes'] = $expectedSizes
    } finally { $reader.Dispose(); $icoMemory.Dispose() }

    if ($Apk) {
        $Apk = (Resolve-Path -LiteralPath $Apk).Path
        $null = Get-Command $Aapt -ErrorAction Stop
        $expectedVersion = $version -split '\+'
        $badging = Invoke-AaptText @('dump', 'badging', $Apk)
        Assert-Icon ($badging -match "package: name='com.aiocyb.aiocyb' versionCode='$($expectedVersion[1])' versionName='$($expectedVersion[0])'") 'APK version or application ID does not match pubspec.yaml.'
        $resources = Invoke-AaptText @('dump', '--values', 'resources', $Apk)
        $records = @(Get-ResourceRecords $resources)
        $launcher = @($records | Where-Object { $_.type -eq 'mipmap' -and $_.name -eq 'ic_launcher' })
        Assert-Icon ($launcher.Count -eq 7) 'APK must contain five legacy densities and two adaptive launcher configurations.'
        $launcherId = $launcher[0].id
        Assert-Icon (@($launcher.id | Select-Object -Unique).Count -eq 1) 'Launcher configurations must share the same resource ID.'
        $compiledManifest = Invoke-AaptText @('dump', 'xmltree', $Apk, 'AndroidManifest.xml')
        foreach ($attribute in @('icon', 'roundIcon')) {
            Assert-Icon ($compiledManifest -match ('android:' + $attribute + '\([^)]*\)=@' + [regex]::Escape($launcherId) + '(?:\s|$)')) 'Compiled manifest points to a different launcher resource.'
        }
        $zip = [System.IO.Compression.ZipFile]::OpenRead($Apk)
        try {
            foreach ($density in @(@('mdpi', 48), @('hdpi', 72), @('xhdpi', 96), @('xxhdpi', 144), @('xxxhdpi', 192))) {
                $record = @($launcher | Where-Object { $_.config -eq $density[0] })
                Assert-Icon ($record.Count -eq 1 -and $record[0].path -match '^res/.+\.png$') 'APK launcher density must resolve to one PNG resource.'
                $source = "android/app/src/main/res/mipmap-$($density[0])/ic_launcher.png"
                $original = [System.Drawing.Bitmap]::FromFile((Get-ProjectPath $source))
                $entryBytes = Read-ZipBytes $zip $record[0].path
                $entryStream = [System.IO.MemoryStream]::new($entryBytes, $false)
                $packaged = [System.Drawing.Bitmap]::FromStream($entryStream)
                try {
                    $null = Get-PixelCheck $packaged $density[1]
                    $differences = [AiocybIconPixels]::Differences($original, $packaged)
                    Assert-Icon ($differences -eq 0) "Packaged launcher pixels differ from $source"
                    $report['compiled_png_pixel_checks'] += [ordered]@{ source = $source; resource = $record[0].path; config = $density[0]; size = $density[1]; pixel_mismatches = $differences }
                } finally { $original.Dispose(); $packaged.Dispose(); $entryStream.Dispose() }
            }
            $background = @($records | Where-Object { $_.type -eq 'color' -and $_.name -eq 'aiocyb_icon_background' })
            Assert-Icon ($background.Count -eq 1 -and $background[0].value -match 'd=0xff22d3ee\b') 'APK background color differs from the full-bleed source.'
            $vectorIds = @{}
            foreach ($variant in @(@('aiocyb_icon_foreground', '#081820'), @('aiocyb_icon_monochrome', '#ffffff'))) {
                $vectorRecord = @($records | Where-Object { $_.type -eq 'drawable' -and $_.name -eq $variant[0] })
                Assert-Icon ($vectorRecord.Count -eq 1) 'APK vector resource is missing or ambiguous.'
                $vectorIds[$variant[0]] = $vectorRecord[0].id
                $tree = Invoke-AaptText @('dump', 'xmltree', $Apk, $vectorRecord[0].path)
                $compiledPath = [regex]::Match($tree, 'android:pathData\([^)]*\)="([^"]+)"')
                Assert-Icon ($tree -match 'E: vector\b' -and ([regex]::Matches($tree, 'E: path\b')).Count -eq 1) 'Packaged icon must contain one vector path.'
                Assert-Icon ($compiledPath.Success -and (Get-NormalizedPath $compiledPath.Groups[1].Value) -ceq (Get-NormalizedPath $pathData)) 'Compiled vector path differs from the SVG.'
                $argb = '0xff' + $variant[1].TrimStart('#')
                Assert-Icon ($tree -match ('android:fillColor\([^)]*\)=\(type 0x1[cd]\)' + $argb + '\b')) 'Compiled vector color differs from its source.'
                Assert-Icon ($tree -match 'android:fillType\([^)]*\)=\(type 0x10\)0x1\b') 'Compiled vector must preserve even-odd filling.'
                foreach ($attribute in @('viewportWidth', 'viewportHeight')) {
                    Assert-Icon ($tree -match ('android:' + $attribute + '\([^)]*\)=\(type 0x4\)0x42d80000\b')) 'Compiled vector viewport must remain 108 by 108.'
                }
                $report['compiled_vector_checks'] += [ordered]@{ name = $variant[0]; resource = $vectorRecord[0].path; path_matches_svg = $true; fill = $variant[1] }
            }
            foreach ($level in @(26, 33)) {
                $record = @($launcher | Where-Object { $_.config -eq "anydpi-v$level" })
                Assert-Icon ($record.Count -eq 1) "Missing API $level adaptive configuration."
                $tree = Invoke-AaptText @('dump', 'xmltree', $Apk, $record[0].path)
                Assert-Icon ($tree -match 'E: adaptive-icon\b') 'Launcher variant is not a compiled adaptive icon.'
                foreach ($layer in @(@('background', $background[0].id), @('foreground', $vectorIds['aiocyb_icon_foreground']))) {
                    Assert-Icon ($tree -match ('E: ' + $layer[0] + '[^\r\n]*\r?\n\s+A: android:drawable\([^)]*\)=@' + [regex]::Escape($layer[1]) + '(?:\s|$)')) 'Compiled adaptive layer points to the wrong resource.'
                }
                if ($level -eq 33) {
                    Assert-Icon ($tree -match ('E: monochrome[^\r\n]*\r?\n\s+A: android:drawable\([^)]*\)=@' + [regex]::Escape($vectorIds['aiocyb_icon_monochrome']) + '(?:\s|$)')) 'Compiled themed layer points to the wrong monochrome vector.'
                    $report['compiled_monochrome_variants']++
                } else { Assert-Icon ($tree -notmatch 'E: monochrome\b') 'The API 26 variant unexpectedly includes the API 33 monochrome layer.' }
                $report['compiled_adaptive_variants']++
            }
        } finally { $zip.Dispose() }
        $report['apk'] = [ordered]@{ path = $Apk; bytes = (Get-Item -LiteralPath $Apk).Length; sha256 = (Get-FileHash -LiteralPath $Apk -Algorithm SHA256).Hash.ToLowerInvariant() }
        $report['apk_verified'] = $true
        $report['scope'] = 'source_and_packaged_apk'
    }

    foreach ($relative in @($icoRelative, 'tool/generate_icons.ps1', 'tool/audit_icons.ps1', 'pubspec.yaml', 'android/app/src/main/AndroidManifest.xml', 'android/app/src/main/res/values/icon_colors.xml', 'web/manifest.json', 'web/index.html')) { $sourceNames.Add($relative) }
    foreach ($relative in $sourceNames) {
        $report['source_files'] += [ordered]@{ path = $relative; sha256 = (Get-FileHash -LiteralPath (Get-ProjectPath $relative) -Algorithm SHA256).Hash.ToLowerInvariant() }
    }
    $report['status'] = 'passed'
} catch {
    $report['errors'] = @($_.Exception.Message)
} finally {
    [System.IO.File]::WriteAllText($reportPath, ($report | ConvertTo-Json -Depth 10) + [Environment]::NewLine, $utf8)
}

[ordered]@{ status = $report['status']; scope = $report['scope']; version = $report['version']; png_exports = $report['png_exports']; apk_verified = $report['apk_verified']; errors = $report['errors'] } | ConvertTo-Json -Depth 3
if ($report['status'] -ne 'passed') { exit 1 }
