@echo off
setlocal

set "INSTALL_DIR=%LOCALAPPDATA%\SimpleShare"

reg delete "HKCU\Software\Classes\Directory\shell\SimpleShare" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Directory\Background\shell\SimpleShare" /f >nul 2>&1

if exist "%INSTALL_DIR%" (
    rmdir /S /Q "%INSTALL_DIR%"
)

echo.
echo SimpleShare context menu has been removed for the current user.
echo Installed files have also been removed from:
echo %INSTALL_DIR%
echo.
pause
