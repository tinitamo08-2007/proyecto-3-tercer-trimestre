@echo off
REM Atajo para descargar las librerias en un doble clic (llama al PowerShell).
echo Descargando librerias para Granja Digital...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0descargar_librerias.ps1"
