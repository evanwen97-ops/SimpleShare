@echo off
setlocal EnableDelayedExpansion
:: Use UTF-8 code page for QR output.
chcp 65001 >nul

:: ========================================================
:: Lock the working directory to the folder that contains
:: this batch file. cd /d also supports switching drives.
:: ========================================================
cd /d "%~dp0"
set "PORT=8000"

echo ========================================================
echo        Python File Share Server (Current Folder)
echo ========================================================
echo.

:: Show the shared folder.
echo [Shared / Upload Folder]:
echo %cd%
echo.

:: 1. Check Python.
python --version >nul 2>&1
if %errorlevel% NEQ 0 (
    echo [ERROR] Python was not found. Please install Python and add it to PATH.
    pause
    exit /b
)

:: 2. Check uploadserver module.
echo [CHECK] Checking uploadserver module...
python -c "import uploadserver" >nul 2>&1

if %errorlevel% NEQ 0 (
    echo.
    echo [INFO] The 'uploadserver' module was not found.
    echo --------------------------------------------------------
    set /p install_choice="Install it now? (type y to confirm, anything else to exit): "
    if /i "!install_choice!"=="y" (
        echo [INSTALL] Running python -m pip install uploadserver...
        python -m pip install uploadserver
        if errorlevel 1 (
            echo [FAILED] Install failed. Please check your network or install it manually.
            pause
            exit /b
        )
        echo [OK] Install completed.
    ) else (
        echo [EXIT] Module was not installed. Exiting.
        pause
        exit /b
    )
) else (
    echo [OK] uploadserver module is installed.
)

:: 3. Check qrcode module.
echo [CHECK] Checking qrcode module...
python -c "import qrcode" >nul 2>&1

if %errorlevel% NEQ 0 (
    echo.
    echo [INFO] The 'qrcode' module was not found. It is required for QR codes.
    echo --------------------------------------------------------
    set /p install_qrcode_choice="Install it now? (type y to confirm, anything else to exit): "
    if /i "!install_qrcode_choice!"=="y" (
        echo [INSTALL] Running python -m pip install qrcode...
        python -m pip install qrcode
        if errorlevel 1 (
            echo [FAILED] Install failed. Please check your network or install it manually.
            pause
            exit /b
        )
        echo [OK] qrcode install completed.
    ) else (
        echo [EXIT] Module was not installed. QR codes cannot be shown. Exiting.
        pause
        exit /b
    )
) else (
    echo [OK] qrcode module is installed.
)

:: 4. Show access links and QR codes.
echo.
echo ========================================================
echo                Scan to Access File Share
echo ========================================================
echo Make sure your phone and this computer are on the same network.
echo If this computer has Wi-Fi, Ethernet, VPN, or virtual networks,
echo multiple QR codes may be shown. Scan the one for your network.
echo.

set "IP_COUNT=0"

for /f "tokens=1 delims=|" %%A in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.AddressState -eq 'Preferred' -and $_.IPAddress -notmatch '^(127\.|169\.254\.|0\.0\.0\.0$)' } | Sort-Object InterfaceMetric, InterfaceIndex, IPAddress | ForEach-Object { $_.IPAddress }"') do (
    set /a IP_COUNT+=1 >nul
    echo.
    echo --------------------------------------------------------
    echo [Network !IP_COUNT!]
    echo [URL] http://%%A:%PORT%/
    echo.
    python -c "import qrcode, sys; qr=qrcode.QRCode(border=1); qr.add_data(sys.argv[1]); qr.make(fit=True); qr.print_ascii(invert=True)" "http://%%A:%PORT%/"
)

if "!IP_COUNT!"=="0" (
    echo [WARNING] No usable LAN IPv4 address was found.
    echo Check your Wi-Fi/Ethernet connection or allow Python through Windows Firewall.
)

echo.
echo ========================================================

:: 5. Start server.
echo.
echo Starting server...
echo Port: %PORT%
echo Uploaded files will be saved to: "%cd%"
echo After the server starts, scan a QR code to access it.
echo If your phone cannot open the page, check the same-network setting
echo and allow Python network access in Windows Firewall.
echo.
echo (Server is running... Close this window to stop it.)
echo --------------------------------------------------------

:: Start uploadserver.
python -m uploadserver %PORT%

pause
