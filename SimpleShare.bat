@echo off
setlocal
:: 切换编码为UTF-8，防止中文乱码
chcp 65001 >nul

:: ========================================================
:: [核心修改] 锁定当前目录
:: %~dp0 代表这个bat文件所在的磁盘和路径
:: cd /d 确保即使跨盘符（比如从C盘切到D盘）也能成功
:: ========================================================
cd /d "%~dp0"

echo ========================================================
echo        Python 文件共享服务器 (自动锁定当前目录)
echo ========================================================
echo.

:: 显示当前锁定的路径给用户确认
echo [当前共享/保存路径]: 
echo %cd%
echo.

:: 1. 检查是否安装了 Python
python --version >nul 2>&1
if %errorlevel% NEQ 0 (
    echo [错误] 未检测到 Python，请先安装 Python 并添加到环境变量。
    pause
    exit /b
)

:: 2. 检查是否安装了 uploadserver 模块
echo [检测中] 正在检查 uploadserver 模块...
python -c "import uploadserver" >nul 2>&1

if %errorlevel% NEQ 0 (
    echo.
    echo [提示] 未检测到 'uploadserver' 模块。
    echo --------------------------------------------------------
    set /p install_choice="是否立即安装? (输入 y 确认, 其他键退出): "
    if /i "%install_choice%"=="y" (
        echo [安装中] 正在执行 pip install uploadserver...
        pip install uploadserver
        if %errorlevel% NEQ 0 (
            echo [失败] 安装失败，请检查网络或手动安装。
            pause
            exit /b
        )
        echo [成功] 安装完成！
    ) else (
        echo [退出] 你选择了不安装，脚本即将退出。
        pause
        exit /b
    )
) else (
    echo [状态] uploadserver 模块已安装。
)

:: 3. 显示本机 IP 地址
echo.
echo ========================================================
echo               本机 IP 地址列表
echo ========================================================
echo 请将以下 IP 发送给同一局域网的朋友：
echo.
ipconfig | findstr "IPv4"
echo.
echo ========================================================

:: 4. 确认并启动服务器
echo.
echo 正在启动服务...
echo 所有人上传的文件将保存在: "%cd%"
echo 访问地址示例: http://192.168.x.x:8000
echo.
echo (服务运行中... 关闭此窗口即可停止)
echo --------------------------------------------------------

:: 启动服务器
python -m uploadserver

pause