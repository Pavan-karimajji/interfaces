@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "CLEAN=%~1"
set "BUILD_DIR=%~dp0build"

where conan >nul 2>&1
if errorlevel 1 (
  echo ERROR: Conan is not installed or not in PATH.
  exit /b 1
)

if /I "%CLEAN%"=="clean" (
  echo Cleaning %BUILD_DIR% ...
  if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
  if exist "%~dp0CMakeUserPresets.json" del "%~dp0CMakeUserPresets.json"
)

REM No --output-folder: this relies on cmake_layout()'s own local-development
REM folder scheme (build/), which is also what editable-mode consumers
REM resolve headers/libs against (conanfile.py's layout()) - an explicit
REM --output-folder here would double up with that and break the paths.
echo Installing Conan dependencies...
conan install . --build=missing -s build_type=Release
if errorlevel 1 exit /b 1

echo Configuring preset conan-default ...
cmake --preset conan-default
if errorlevel 1 exit /b 1

echo Building preset conan-release ...
cmake --build --preset conan-release
if errorlevel 1 exit /b 1

echo.
echo Build finished for adas-interfaces.
exit /b 0
