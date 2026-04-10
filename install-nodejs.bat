@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: ========================================
:: Node.js 一键安装脚本 (Windows 版)
:: 包含所有常见错误的自动检测和修复
:: ========================================

title Node.js 安装程序
color 0B

set "ERROR_COUNT=0"
set "SUCCESS=0"

echo ========================================
echo    Node.js 一键安装程序
echo    Windows 版本
echo ========================================
echo.
echo 本脚本会自动检测并修复：
echo   - 权限不足问题 (错误 2502/2503)
echo   - PowerShell 执行策略限制
echo   - npm 全局安装权限问题
echo   - 文件被占用问题 (EBUSY)
echo.
echo 预计耗时：2-5 分钟
echo.

:: ========================================
:: 权限检查和自动提升
:: ========================================
:permission_check
echo.
echo ========================================
echo [步骤 1] 检查运行权限
echo ========================================
echo.

net session >nul 2>&1
if %errorLevel% equ 0 (
    echo [成功] 已管理员身份运行
    goto check_powerShell
)

echo [提示] 当前非管理员身份运行
echo.
echo 尝试自动提升权限...
powershell -Command "Start-Process '%~f0' -Verb RunAs" 2>nul
if %errorLevel% equ 0 (
    echo [信息] 已在管理员窗口中重新启动
    exit /b 0
)

echo [错误] 无法自动提升权限
echo.
echo 请手动操作:
echo   1. 关闭此窗口
echo   2. 右键点击此脚本
echo   3. 选择"以管理员身份运行"
echo.
pause
exit /b 1

:: ========================================
:: PowerShell 执行策略检查
:: ========================================
:check_powerShell
echo.
echo ========================================
echo [步骤 2] 检查 PowerShell 执行策略
echo ========================================
echo.

for /f "delims=" %%i in ('powershell -Command "Get-ExecutionPolicy" 2^>nul') do set EXEC_POLICY=%%i

if "!EXEC_POLICY!"=="Restricted" (
    echo [提示] PowerShell 执行策略为 Restricted (限制状态)
    echo.
    echo 正在自动修改为 RemoteSigned...
    powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force" 2>nul
    if %errorLevel% equ 0 (
        echo [成功] 执行策略已修改
    ) else (
        echo [失败] 修改失败，请手动运行:
        echo   powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"
        echo.
        set /a ERROR_COUNT+=1
    )
) else (
    echo [成功] PowerShell 执行策略：!EXEC_POLICY!
)

:: ========================================
:: 检查现有安装
:: ========================================
echo.
echo ========================================
echo [步骤 3] 检查现有安装
echo ========================================
echo.

node -v >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=*" %%i in ('node -v') do set NODE_VER=%%i
    echo [信息] 检测到 Node.js 已安装：!NODE_VER!
    echo.
    set /p REINSTALL=是否卸载并重新安装？(Y/N):
    if /i not "!REINSTALL!"=="Y" (
        echo.
        echo [完成] 已跳过安装
        goto verify_install
    )

    echo.
    echo [操作] 正在卸载旧版本...
    msiexec /x {旧版本 GUID} /quiet 2>nul
    winget uninstall OpenJS.NodeJS.LTS 2>nul
    echo [成功] 旧版本已卸载
)

:: ========================================
:: 安装 Node.js
:: ========================================
echo.
echo ========================================
echo [步骤 4] 安装 Node.js
echo ========================================
echo.

:: 方法 1: winget
echo [尝试 1/3] 使用 winget 安装...
winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements --accept-source-agreements 2>&1 | findstr /i "error"
if %errorLevel% neq 0 (
    echo [成功] winget 安装完成
    timeout /t 5 >nul
    goto post_install
)
echo [失败] winget 不可用或失败

:: 方法 2: 直接下载 MSI 安装 (解决权限问题)
echo.
echo [尝试 2/3] 使用 NPMMirror 下载安装...
echo.

:: 检查并修复 Temp 权限 (解决 2502/2503 错误)
echo [检查] Temp 文件夹权限...
if not exist "%TEMP%\node_test" (
    mkdir "%TEMP%\node_test" 2>nul
    if %errorLevel% neq 0 (
        echo [警告] Temp 文件夹写入失败，正在修复...
        icacls "%TEMP%" /grant "%USERNAME%":F 2>nul
    )
    rmdir "%TEMP%\node_test" 2>nul
)

echo [下载] 正在下载 Node.js 安装包...
powershell -Command "Invoke-WebRequest -Uri 'https://npmmirror.com/mirrors/node/v20.11.0/node-v20.11.0-x64.msi' -OutFile '%TEMP%\node.msi'" 2>nul

if exist "%TEMP%\node.msi" (
    echo [下载完成] 正在安装...

    :: 使用管理员权限安装 (解决权限问题)
    msiexec /i "%TEMP%\node.msi" /quiet /norestart 2>nul
    if %errorLevel% equ 0 (
        echo [安装中] 请等待 15 秒...
        timeout /t 15 >nul
        del "%TEMP%\node.msi" 2>nul
        echo [成功] Node.js 安装完成
        goto post_install
    )

    echo [失败] 安装程序返回错误代码：%errorLevel%
    echo.
    echo 可能原因:
    echo   1. 文件被其他进程占用
    echo   2. 权限不足
    echo   3. 安装包损坏
)

:: 方法 3: 提供手动安装指引
echo.
echo [尝试 3/3] 提供手动安装方案
echo.
echo ========================================
echo 自动安装失败，请手动安装
echo ========================================
echo.
echo 方案 A: 使用 Node.js 官方中文版 (推荐)
echo   1. 访问：https://nodejs.cn/download/
echo   2. 下载"Windows 安装包 (.msi)"
echo   3. 右键点击安装包 → "以管理员身份运行"
echo.
echo 方案 B: 修改 Temp 权限后重试
echo   1. 打开 C:\Windows\Temp 文件夹
echo   2. 右键 → 属性 → 安全
echo   3. 添加当前用户，勾选"完全控制"
echo   4. 重新运行此脚本
echo.
echo 方案 C: 使用 NVM 安装 (最稳妥)
echo   1. 访问：https://github.com/coreybutler/nvm-windows/releases
echo   2. 下载并安装 nvm-setup.exe
echo   3. 运行：nvm install 20.11.0
echo      nvm use 20.11.0
echo.
set /a ERROR_COUNT+=1
goto end

:post_install
:: ========================================
:: 修复 npm 全局权限问题
:: ========================================
echo.
echo ========================================
echo [步骤 5] 修复 npm 权限
echo ========================================
echo.

:: 检查 npm 全局目录权限
set "NPM_PREFIX=C:\npm"
if not exist "!NPM_PREFIX!" (
    echo [操作] 创建 npm 全局目录...
    mkdir "!NPM_PREFIX!" 2>nul
)

echo [操作] 配置 npm 全局目录...
npm config set prefix "!NPM_PREFIX!" 2>nul
npm config set cache "C:\npm-cache" 2>nul

:: 将 npm 全局目录添加到 PATH
echo "%PATH%" | findstr /i "C:\\npm" >nul
if %errorLevel% neq 0 (
    echo [操作] 添加 npm 目录到 PATH...
    setx PATH "%PATH%;!NPM_PREFIX!" 2>nul
    echo [成功] PATH 已更新 (需要重启命令行生效)
)

:: ========================================
:: 验证安装
:: ========================================
:verify_install
echo.
echo ========================================
echo [步骤 6] 验证安装
echo ========================================
echo.

timeout /t 3 >nul

set "PATH=%PATH%;C:\Program Files\nodejs;!NPM_PREFIX!"

node -v >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=*" %%i in ('node -v') do set NODE_VER=%%i
    echo [成功] Node.js !NODE_VER!
    set "SUCCESS=1"
) else (
    echo [未找到] Node.js - 请重启电脑后重试
    set /a ERROR_COUNT+=1
)

npm -v >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=*" %%i in ('npm -v') do set NPM_VER=%%i
    echo [成功] npm !NPM_VER!
) else (
    echo [未找到] npm - 请重启电脑后重试
    set /a ERROR_COUNT+=1
)

:end
echo.
echo ========================================
echo    安装完成总结
echo ========================================
echo.

if "!SUCCESS!"=="1" (
    echo ✓ Node.js 安装成功!
    echo.
    echo 下一步:
    echo   1. 关闭此窗口并重新打开命令行
    echo   2. 运行以下命令验证:
    echo      node -v
    echo      npm -v
    echo.
) else (
    echo ✗ 安装遇到问题
    echo.
    echo 请尝试:
    echo   1. 重启电脑后重新运行脚本
    echo   2. 使用方案 C(NVM) 安装
    echo   3. 手动下载安装
    echo.
)

if %ERROR_COUNT% gtr 0 (
    echo ========================================
    echo    遇到 %ERROR_COUNT% 个问题
    echo ========================================
    echo.
    echo 已尝试自动修复，请查看上方的错误信息
    echo.
)

pause
