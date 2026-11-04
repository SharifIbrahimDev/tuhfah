# PowerShell script to create release keystore for Google Play
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

$keystorePath = Join-Path $scriptDir "upload-keystore.jks"
$alias = "upload"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  Generating Release Keystore for Google Play Store" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

if (Test-Path $keystorePath) {
    Write-Warning "Keystore already exists at: $keystorePath"
    Write-Host "If you want to create a new one, remove or rename the existing file."
    exit 0
}

# Locate keytool
$keytool = Get-Command keytool -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (-not $keytool) {
    $adoptium = "C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot\bin\keytool.exe"
    if (Test-Path $adoptium) {
        $keytool = $adoptium
    } else {
        Write-Error "keytool could not be found. Please install a JDK or add keytool to PATH."
    }
}

Write-Host "Using keytool at: $keytool" -ForegroundColor Green
Write-Host "Generating keystore at: $keystorePath (alias: $alias)..."

& $keytool -genkey -v -keystore $keystorePath -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias $alias

if ($LASTEXITCODE -eq 0 -and (Test-Path $keystorePath)) {
    Write-Host "`nKeystore generated successfully!" -ForegroundColor Green
    Write-Host "Keystore location: $keystorePath"
    Write-Host "`nNext Step: Create or edit android/key.properties with your chosen passwords:" -ForegroundColor Yellow
    Write-Host "storePassword=YOUR_PASSWORD"
    Write-Host "keyPassword=YOUR_PASSWORD"
    Write-Host "keyAlias=upload"
    Write-Host "storeFile=../upload-keystore.jks"
} else {
    Write-Error "Failed to generate keystore."
}
