@echo off
echo ============================================================
echo   AI App - Clean Project
echo ============================================================
echo.

echo Cleaning Flutter project...
flutter clean

echo.
echo Removing build directories...
if exist "build" rmdir /s /q "build"
if exist ".dart_tool" rmdir /s /q ".dart_tool"

echo.
echo Cleaning completed!
