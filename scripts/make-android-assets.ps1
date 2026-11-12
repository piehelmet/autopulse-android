# Generates Android launcher icons and splash screens from the app's icon.
# Usage: powershell -ExecutionPolicy Bypass -File scripts/make-android-assets.ps1
param(
    [string]$SourceIcon = "C:\Users\rykce\autopulse-obd\assets\icon-512.png"
)

Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$res = Join-Path $root 'android\app\src\main\res'
$src = [System.Drawing.Image]::FromFile($SourceIcon)
$bg = [System.Drawing.ColorTranslator]::FromHtml('#070B10')

function New-Canvas([int]$w, [int]$h) {
    $bmp = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    return $bmp
}

function Draw-Cover($g, $img, [int]$x, [int]$y, [int]$w, [int]$h) {
    $scale = [Math]::Max($w / $img.Width, $h / $img.Height)
    $dw = [int]($img.Width * $scale)
    $dh = [int]($img.Height * $scale)
    $dx = $x + [int](($w - $dw) / 2)
    $dy = $y + [int](($h - $dh) / 2)
    $g.DrawImage($img, $dx, $dy, $dw, $dh)
}

function New-RoundedPath([int]$w, [int]$h, [int]$r) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $path.AddArc(0, 0, $d, $d, 180, 90)
    $path.AddArc($w - $d, 0, $d, $d, 270, 90)
    $path.AddArc($w - $d, $h - $d, $d, $d, 0, 90)
    $path.AddArc(0, $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

function Save-Png($bmp, [string]$path) {
    $dir = Split-Path -Parent $path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
}

$densities = @{ 'mdpi' = 48; 'hdpi' = 72; 'xhdpi' = 96; 'xxhdpi' = 144; 'xxxhdpi' = 192 }
$foreground = @{ 'mdpi' = 108; 'hdpi' = 162; 'xhdpi' = 216; 'xxhdpi' = 324; 'xxxhdpi' = 432 }

foreach ($name in $densities.Keys) {
    $size = $densities[$name]

    # Square launcher icon with slightly rounded corners.
    $bmp = New-Canvas $size $size
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $path = New-RoundedPath $size $size ([int]($size * 0.18))
    $g.SetClip($path)
    Draw-Cover $g $src 0 0 $size $size
    $g.ResetClip()
    $g.Dispose()
    Save-Png $bmp (Join-Path $res "mipmap-$name\ic_launcher.png")
    $bmp.Dispose()

    # Round launcher icon.
    $bmp = New-Canvas $size $size
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $circle = New-Object System.Drawing.Drawing2D.GraphicsPath
    $circle.AddEllipse(0, 0, $size, $size)
    $g.SetClip($circle)
    Draw-Cover $g $src 0 0 $size $size
    $g.ResetClip()
    $g.Dispose()
    Save-Png $bmp (Join-Path $res "mipmap-$name\ic_launcher_round.png")
    $bmp.Dispose()

    # Adaptive foreground: icon at ~62% of the 108dp canvas, transparent around.
    $fsize = $foreground[$name]
    $bmp = New-Canvas $fsize $fsize
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $inner = [int]($fsize * 0.62)
    $offset = [int](($fsize - $inner) / 2)
    $g.DrawImage($src, $offset, $offset, $inner, $inner)
    $g.Dispose()
    Save-Png $bmp (Join-Path $res "mipmap-$name\ic_launcher_foreground.png")
    $bmp.Dispose()
}

# Splash screens: dark background with the icon centred.
$splashes = Get-ChildItem -Path $res -Recurse -File -Filter 'splash.png'
foreach ($file in $splashes) {
    $old = [System.Drawing.Image]::FromFile($file.FullName)
    $w = $old.Width; $h = $old.Height
    $old.Dispose()

    $bmp = New-Canvas $w $h
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear($bg)
    $iconSize = [int]([Math]::Min($w, $h) * 0.30)
    $g.DrawImage($src, [int](($w - $iconSize) / 2), [int](($h - $iconSize) / 2), $iconSize, $iconSize)
    $g.Dispose()
    Save-Png $bmp $file.FullName
    $bmp.Dispose()
}

$src.Dispose()
Write-Output "Generated launcher icons and splash screens in $res"
