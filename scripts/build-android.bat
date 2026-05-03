@echo off
echo ============================================================
echo   AI App - Build Android APK
echo ============================================================
echo.

flutter build apk --release

if %errorlevel% equ 0 (
    echo.
    echo Build successful!
    echo Output: build\app\outputs\flutter-apk\
) else (
    echo.
    echo Build failed!
    pause
    exit /b 1
)
