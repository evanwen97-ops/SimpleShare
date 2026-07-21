@echo off
setlocal EnableDelayedExpansion
:: 切换编码为 UTF-8，防止中文乱码，并支持二维码字符输出
chcp 65001 >nul

:: ========================================================
:: 锁定工作目录为本 bat 文件所在目录
:: %~dp0 表示这个 bat 文件所在的磁盘和路径
:: cd /d 确保跨盘符时也能成功切换目录
:: ========================================================
cd /d "%~dp0"
set "PORT=8000"

echo ========================================================
echo        Python 文件共享服务器（当前文件夹）
echo ========================================================
echo.

:: 显示当前共享/上传目录
echo [共享/上传目录]:
echo %cd%
echo.

:: 1. 检查 Python
python --version >nul 2>&1
if %errorlevel% NEQ 0 (
    echo [错误] 未检测到 Python，请先安装 Python 并添加到 PATH 环境变量。
    pause
    exit /b
)

:: 2. 检查 uploadserver 模块
echo [检测] 正在检查 uploadserver 模块...
python -c "import uploadserver" >nul 2>&1

if %errorlevel% NEQ 0 (
    echo.
    echo [提示] 未检测到 'uploadserver' 模块。
    echo --------------------------------------------------------
    set /p install_choice="是否现在安装？输入 y 确认，输入其他内容退出: "
    if /i "!install_choice!"=="y" (
        echo [安装] 正在执行 python -m pip install uploadserver...
        python -m pip install uploadserver
        if errorlevel 1 (
            echo [失败] 安装失败，请检查网络，或手动安装。
            pause
            exit /b
        )
        echo [完成] 安装完成。
    ) else (
        echo [退出] 未安装模块，脚本即将退出。
        pause
        exit /b
    )
) else (
    echo [正常] uploadserver 模块已安装。
)

:: 3. 检查 qrcode 模块
echo [检测] 正在检查 qrcode 模块...
python -c "import qrcode" >nul 2>&1

if %errorlevel% NEQ 0 (
    echo.
    echo [提示] 未检测到 'qrcode' 模块，显示二维码需要此模块。
    echo --------------------------------------------------------
    set /p install_qrcode_choice="是否现在安装？输入 y 确认，输入其他内容退出: "
    if /i "!install_qrcode_choice!"=="y" (
        echo [安装] 正在执行 python -m pip install qrcode...
        python -m pip install qrcode
        if errorlevel 1 (
            echo [失败] 安装失败，请检查网络，或手动安装。
            pause
            exit /b
        )
        echo [完成] qrcode 安装完成。
    ) else (
        echo [退出] 未安装模块，无法显示二维码，脚本即将退出。
        pause
        exit /b
    )
) else (
    echo [正常] qrcode 模块已安装。
)

:: 4. 显示访问链接和二维码
echo.
echo ========================================================
echo                扫码访问文件共享服务
echo ========================================================
echo 请确保手机和这台电脑连接到同一个网络。
echo 如果电脑同时连接了 Wi-Fi、以太网、VPN 或虚拟网络，
echo 这里会显示多个二维码。请选择对应网络的二维码扫描。
echo.

set "IP_COUNT=0"

for /f "tokens=1 delims=|" %%A in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.AddressState -eq 'Preferred' -and $_.IPAddress -notmatch '^(127\.|169\.254\.|0\.0\.0\.0$)' } | Sort-Object InterfaceMetric, InterfaceIndex, IPAddress | ForEach-Object { $_.IPAddress }"') do (
    set /a IP_COUNT+=1 >nul
    echo.
    echo --------------------------------------------------------
    echo [网络 !IP_COUNT!]
    echo [地址] http://%%A:%PORT%/
    echo.
    python -c "import qrcode, sys; qr=qrcode.QRCode(border=1); qr.add_data(sys.argv[1]); qr.make(fit=True); qr.print_ascii(invert=True)" "http://%%A:%PORT%/"
)

if "!IP_COUNT!"=="0" (
    echo [警告] 未发现可用于局域网访问的 IPv4 地址。
    echo 请检查 Wi-Fi/以太网连接，或确认 Windows 防火墙允许 Python 访问网络。
)

echo.
echo ========================================================

:: 5. 启动服务器
echo.
echo 正在启动服务...
echo 端口: %PORT%
echo 上传的文件将保存到: "%cd%"
echo 服务启动后，可以扫描上面的二维码访问。
echo 如果手机无法打开页面，请检查是否在同一网络，
echo 并允许 Windows 防火墙中的 Python 网络访问。
echo.
echo （服务运行中... 关闭此窗口即可停止服务）
echo --------------------------------------------------------

:: 启动 uploadserver
python -m uploadserver %PORT%

pause
