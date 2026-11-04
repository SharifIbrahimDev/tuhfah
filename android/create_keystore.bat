@echo off
setlocal
cd /d "%~dp0"

echo ========================================================
echo   Generating Release Keystore for Google Play Store
echo ========================================================
echo.

set KEYSTORE_PATH=upload-keystore.jks
set KEY_ALIAS=upload

if exist "%KEYSTORE_PATH%" (
    echo [WARNING] %KEYSTORE_PATH% already exists!
    echo To regenerate, delete or back up the existing file first.
    pause
    exit /b 0
)

REM Find keytool in PATH or Adoptium JDK
set KEYTOOL=keytool
where keytool >nul 2>&1
if %errorlevel% neq 0 (
    if exist "C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot\bin\keytool.exe" (
        set "KEYTOOL=C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot\bin\keytool.exe"
    ) else (
        echo [ERROR] keytool was not found in PATH or standard JDK location.
        echo Please ensure Java JDK is installed and in your PATH.
        pause
        exit /b 1
    )
)

echo Generating keystore: %KEYSTORE_PATH%
"%KEYTOOL%" -genkey -v -keystore "%KEYSTORE_PATH%" -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias %KEY_ALIAS%

if %errorlevel% neq 0 (
    echo [ERROR] Keystore creation failed.
    pause
    exit /b %errorlevel%
)

echo.
echo ========================================================
echo Keystore created successfully!
echo Path: %~dp0%KEYSTORE_PATH%
echo Alias: %KEY_ALIAS%
echo.
echo Please create or update android\key.properties with:
echo   storePassword=YOUR_PASSWORD
echo   keyPassword=YOUR_PASSWORD
echo   keyAlias=%KEY_ALIAS%
echo   storeFile=../%KEYSTORE_PATH%
echo ========================================================
echo.
pause
