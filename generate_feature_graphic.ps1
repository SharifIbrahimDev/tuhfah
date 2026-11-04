Add-Type -AssemblyName System.Drawing

$width = 1024
$height = 500
$bmp = New-Object System.Drawing.Bitmap($width, $height)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# Emerald dark gradient background
$rect = New-Object System.Drawing.Rectangle(0, 0, $width, $height)
$startColor = [System.Drawing.Color]::FromArgb(255, 12, 38, 26)
$endColor = [System.Drawing.Color]::FromArgb(255, 0, 85, 48)
$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $startColor, $endColor, 35.0)
$g.FillRectangle($brush, $rect)

# Draw gold ornate border
$goldPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 197, 168, 128), 3)
$g.DrawRectangle($goldPen, 18, 18, $width - 36, $height - 36)
$innerPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(100, 197, 168, 128), 1)
$g.DrawRectangle($innerPen, 24, 24, $width - 48, $height - 48)

# Load logo if exists
$logoPath = "assets\data\logo.png"
if (Test-Path $logoPath) {
    try {
        $logo = [System.Drawing.Image]::FromFile($logoPath)
        $logoSize = 240
        $logoX = 80
        $logoY = [int](($height - $logoSize) / 2)
        $g.DrawImage($logo, $logoX, $logoY, $logoSize, $logoSize)
        $logo.Dispose()
    } catch {}
}

# Fonts & Brushes
$titleFont = New-Object System.Drawing.Font("Segoe UI", 42, [System.Drawing.FontStyle]::Bold)
$subFont = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$descFont = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Regular)

$whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
$goldBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 225, 195, 140))
$silverBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 215, 228, 220))

$stringFormat = New-Object System.Drawing.StringFormat
$stringFormat.Alignment = [System.Drawing.StringAlignment]::Center
$stringFormat.LineAlignment = [System.Drawing.StringAlignment]::Center

$titleText = "TUHFAH"
$subText = "80 Noble Hadiths on the Holy Quran"
$descText = "Audio Recitations | Daily Reminders | Original PDF"

$rightRectTitle = New-Object System.Drawing.RectangleF(360, 110, 620, 80)
$g.DrawString($titleText, $titleFont, $goldBrush, $rightRectTitle, $stringFormat)

$rightRectSub = New-Object System.Drawing.RectangleF(360, 200, 620, 50)
$g.DrawString($subText, $subFont, $whiteBrush, $rightRectSub, $stringFormat)

$rightRectDesc = New-Object System.Drawing.RectangleF(360, 270, 620, 50)
$g.DrawString($descText, $descFont, $silverBrush, $rightRectDesc, $stringFormat)

$outputPath = "store_assets\feature_graphic_1024x500.png"
$bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmp.Dispose()
Write-Host "Feature graphic saved to $outputPath"
