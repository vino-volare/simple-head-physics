@echo off
setlocal enabledelayedexpansion

REM Set paths
set SOURCE_DIR=./extension/lua/cockpit-camera/simpleHP
set BUILD_DIR=./build
set ZIP_NAME=simpleHP.zip

REM Create directories if they don't exist
if not exist "%SOURCE_DIR%" mkdir "%SOURCE_DIR%"
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

REM Copy files to the source directory
copy cockpit.lua "%SOURCE_DIR%\" 2>nul
copy manifest.ini "%SOURCE_DIR%\" 2>nul
copy settings.ini "%SOURCE_DIR%\" 2>nul

REM Create zip file using PowerShell
powershell -command "Compress-Archive -Path './extension' -DestinationPath '%BUILD_DIR%/%ZIP_NAME%' -Force"

echo Compression complete: %BUILD_DIR%/%ZIP_NAME%
rmdir /s /q "./extension" 2>nul