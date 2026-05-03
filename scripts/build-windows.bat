@echo off
echo ============================================================
echo   AI App - Build Windows Release
echo ============================================================
echo.

flutter build windows --release

if %errorlevel% equ 0 (
    echo.
    echo Build successful!
    echo Output: build\windows\x64\runner\Release\
) else (
    echo.
    echo Build failed!
    pause
    exit /b 1
)
