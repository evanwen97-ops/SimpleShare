@echo off
setlocal

set "SOURCE_DIR=%~dp0"
set "INSTALL_DIR=%LOCALAPPDATA%\SimpleShare"
set "SOURCE_BAT=%SOURCE_DIR%SimpleShare_English.bat"
set "INSTALLED_BAT=%INSTALL_DIR%\SimpleShare_English.bat"
set "INSTALLED_EXE=%INSTALL_DIR%\SimpleShare.exe"
set "FALLBACK_ICON=%SystemRoot%\System32\shell32.dll,3"

if not exist "%SOURCE_BAT%" (
    echo [ERROR] SimpleShare_English.bat was not found in this folder.
    echo Please keep Install_Context_Menu.bat and SimpleShare_English.bat in the same folder.
    echo.
    pause
    exit /b 1
)

if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%"
    if errorlevel 1 (
        echo [ERROR] Failed to create install folder:
        echo %INSTALL_DIR%
        echo.
        pause
        exit /b 1
    )
)

copy /Y "%SOURCE_DIR%SimpleShare_English.bat" "%INSTALL_DIR%\SimpleShare_English.bat" >nul
if errorlevel 1 (
    echo [ERROR] Failed to copy SimpleShare_English.bat.
    echo.
    pause
    exit /b 1
)

if exist "%SOURCE_DIR%SimpleShare_Chinese.bat" (
    copy /Y "%SOURCE_DIR%SimpleShare_Chinese.bat" "%INSTALL_DIR%\SimpleShare_Chinese.bat" >nul
)

if exist "%SOURCE_DIR%SimpleShare.exe" (
    copy /Y "%SOURCE_DIR%SimpleShare.exe" "%INSTALLED_EXE%" >nul
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "$appBat=$env:INSTALLED_BAT; $appExe=$env:INSTALLED_EXE; $fallbackIcon=$env:FALLBACK_ICON; if (Test-Path -LiteralPath $appExe) { $icon=$appExe } else { $icon=$fallbackIcon }; $folderCmd='cmd.exe /k ""' + $appBat + '"" ""%%1""'; $backgroundCmd='cmd.exe /k ""' + $appBat + '"" ""%%V""'; $root=[Microsoft.Win32.Registry]::CurrentUser; $k=$root.CreateSubKey('Software\Classes\Directory\shell\SimpleShare'); $k.SetValue('', 'Share with SimpleShare'); $k.SetValue('Icon', $icon); $k.Close(); $k=$root.CreateSubKey('Software\Classes\Directory\shell\SimpleShare\command'); $k.SetValue('', $folderCmd); $k.Close(); $k=$root.CreateSubKey('Software\Classes\Directory\Background\shell\SimpleShare'); $k.SetValue('', 'Share this folder with SimpleShare'); $k.SetValue('Icon', $icon); $k.Close(); $k=$root.CreateSubKey('Software\Classes\Directory\Background\shell\SimpleShare\command'); $k.SetValue('', $backgroundCmd); $k.Close();"

if errorlevel 1 (
    echo.
    echo [FAILED] Context menu installation failed.
    echo.
    pause
    exit /b 1
)

echo.
echo SimpleShare context menu has been installed for the current user.
echo Installed files were copied to:
echo %INSTALL_DIR%
echo.
echo Context menu icon source:
if exist "%INSTALLED_EXE%" (
    echo %INSTALLED_EXE%
) else (
    echo %FALLBACK_ICON%
)
echo.
echo You can move or delete the original folder after installation.
echo To update the installed copy, run this installer again.
echo To remove the menu, run Uninstall_Context_Menu.bat.
echo.
echo On Windows 11, the menu may appear under "Show more options".
echo If the icon does not refresh immediately, restart Explorer or sign out and sign in again.
echo.
pause
