@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: ========================================
:: Claude Code 一键安装脚本 (Windows 版)
:: 包含所有常见错误的自动检测和修复
:: ========================================

title Claude Code 安装程序
color 0D

set "ERROR_COUNT=0"
set "SUCCESS=0"

echo ========================================
echo    Claude Code 一键安装程序
echo    Windows 版本
echo ========================================
echo.
echo 本脚本会自动检测并修复：
echo   - Node.js/npm 未安装问题
echo   - npm 权限问题 (EACCES 错误)
echo   - 网络连接超时问题
echo   - 命令未找到问题 (command not found)
echo.
echo 预计耗时：1-3 分钟
echo.

:: ========================================
:: 权限检查
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
    goto check_prerequisites
)

echo [提示] 建议以管理员身份运行
echo.
set /p RUN_AS_ADMIN=是否以管理员身份重新运行？(Y/N):
if /i "!RUN_AS_ADMIN!"=="Y" (
    powershell -Command "Start-Process '%~f0' -Verb RunAs" 2>nul
    if %errorLevel% equ 0 (
        exit /b 0
    )
)

:: ========================================
:: 检查前置条件
:: ========================================
:check_prerequisites
echo.
echo ========================================
echo [步骤 2] 检查前置条件
echo ========================================
echo.

:: 检查 Node.js
node -v >nul 2>&1
if %errorLevel% neq 0 (
    echo [错误] 未检测到 Node.js!
    echo.
    echo ===== 解决方法 =====
    echo.
    echo 请先安装 Node.js:
    echo   1. 运行 install-nodejs.bat 脚本
    echo.
    echo   2. 或手动安装:
    echo      访问：https://nodejs.cn/download/
    echo      下载 Windows 安装包并双击安装
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('node -v') do set NODE_VER=%%i
echo [成功] Node.js: !NODE_VER!

:: 检查 npm
npm -v >nul 2>&1
if %errorLevel% neq 0 (
    echo [错误] 未检测到 npm!
    echo.
    echo ===== 解决方法 =====
    echo.
    echo Node.js 已安装但 npm 不可用
    echo 请重启电脑后重新运行此脚本
    echo.
    echo 如果问题依然存在:
    echo   1. 重新安装 Node.js
    echo   2. 或使用 NVM: https://github.com/coreybutler/nvm-windows
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('npm -v') do set NPM_VER=%%i
echo [成功] npm: !NPM_VER!

:: ========================================
:: 检查现有安装
:: ========================================
echo.
echo ========================================
echo [步骤 3] 检查 Claude Code 安装
echo ========================================
echo.

claude --version >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=*" %%i in ('claude --version') do set CLAUDE_VER=%%i
    echo [信息] Claude Code 已安装：!CLAUDE_VER!
    echo.
    set /p REINSTALL=是否卸载并重新安装？(Y/N):
    if /i not "!REINSTALL!"=="Y" (
        echo.
        echo [完成] 已跳过安装
        goto installation_complete
    )

    echo.
    echo [操作] 正在卸载旧版本...
    npm uninstall -g @anthropic-ai/claude-code 2>nul
    timeout /t 2 >nul
    echo [成功] 旧版本已卸载
)

:: ========================================
:: 修复 npm 权限问题 (EACCES 错误)
:: ========================================
echo.
echo ========================================
echo [步骤 4] 修复 npm 权限
echo ========================================
echo.

:: 检查是否需要修复权限
set "NPM_PREFIX=C:\npm"
if not exist "!NPM_PREFIX!" (
    echo [操作] 创建 npm 全局目录...
    mkdir "!NPM_PREFIX!" 2>nul
)

echo [操作] 配置 npm 全局目录...
npm config set prefix "!NPM_PREFIX!" 2>nul
npm config set cache "C:\npm-cache" 2>nul

:: 检查 PATH
echo "%PATH%" | findstr /i "C:\\npm" >nul
if %errorLevel% neq 0 (
    echo [操作] 添加 npm 目录到 PATH...
    setx PATH "%PATH%;!NPM_PREFIX!" 2>nul
)

:: ========================================
:: 安装 Claude Code
:: ========================================
echo.
echo ========================================
echo [步骤 5] 安装 Claude Code
echo ========================================
echo.

:: 方法 1: NPMMirror (推荐)
echo [尝试 1/3] 使用 NPMMirror 安装...
echo.
echo 命令：npm install -g @anthropic-ai/claude-code --registry=https://registry.npmmirror.com
echo.

call npm install -g @anthropic-ai/claude-code --registry=https://registry.npmmirror.com 2>&1
if %errorLevel% equ 0 (
    echo.
    echo [成功] NPMMirror 安装完成
    goto verify_install
)

echo.
echo [失败] NPMMirror 安装失败
echo.

:: 方法 2: 阿里云镜像
echo [尝试 2/3] 使用阿里云镜像安装...
echo.

call npm install -g @anthropic-ai/claude-code --registry=https://mirrors.aliyun.com/npm/ 2>&1
if %errorLevel% equ 0 (
    echo.
    echo [成功] 阿里云镜像安装完成
    goto verify_install
)

echo.
echo [失败] 阿里云镜像安装失败
echo.

:: 方法 3: 官方源
echo [尝试 3/3] 使用官方源安装...
echo.

call npm install -g @anthropic-ai/claude-code 2>&1
if %errorLevel% equ 0 (
    echo.
    echo [成功] 官方源安装完成
    goto verify_install
)

echo.
echo [失败] 官方源安装失败
echo.

:: 安装失败，提供详细解决方法
echo ========================================
echo 自动安装失败，请尝试以下方法
echo ========================================
echo.
echo 方法 1: 手动运行安装命令
echo   打开命令提示符，运行:
echo   npm install -g @anthropic-ai/claude-code ^
echo     --registry=https://registry.npmmirror.com
echo.
echo 方法 2: 检查网络连接
echo   1. 确保网络连接正常
echo   2. 如果使用代理，请确保代理可用
echo   3. 尝试关闭防火墙后重试
echo.
echo 方法 3: 清理 npm 缓存
echo   运行：npm cache clean --force
echo   然后重新安装
echo.
echo 方法 4: 使用 Native 安装器 (推荐)
echo   1. 访问：https://code.claude.com/
echo   2. 下载 Windows 原生安装器
echo   3. 双击运行安装
echo.
echo 方法 5: 使用 WinGet (如果有)
echo   运行：winget install ClaudeCode
echo.
set /a ERROR_COUNT+=1
goto end

:verify_install
:: ========================================
:: 验证安装
:: ========================================
echo.
echo ========================================
echo [步骤 6] 验证安装
echo ========================================
echo.

timeout /t 2 >nul

set "PATH=%PATH%;!NPM_PREFIX!"

claude --version >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=*" %%i in ('claude --version') do set CLAUDE_VER=%%i
    echo [成功] Claude Code !CLAUDE_VER!
    set "SUCCESS=1"
) else (
    echo [未找到] Claude Code
    echo.
    echo 可能原因:
    echo   1. PATH 环境变量未更新
    echo   2. 需要重启命令行窗口
    echo.
    echo 解决方法:
    echo   1. 关闭此窗口并重新打开命令行
    echo   2. 运行 claude --version 验证
    echo.
)

:installation_complete
echo.
echo ========================================
echo    安装完成总结
echo ========================================
echo.

if "!SUCCESS!"=="1" (
    echo ✓ Claude Code 安装成功!
    echo.
    echo 下一步：配置 API 密钥
    echo ========================================
    echo.
    echo 方法 1: 使用智谱官方助手 (推荐)
    echo   运行：npx @z_ai/coding-helper
    echo   说明：交互式向导，自动配置智谱 API
    echo.
    echo 方法 2: 手动配置环境变量
    echo   智谱 AI:
    echo     setx ANTHROPIC_AUTH_TOKEN "你的 API Key"
    echo     setx ANTHROPIC_BASE_URL "https://open.bigmodel.cn/api/paas/v4"
    echo.
    echo   阿里云百炼:
    echo     setx ANTHROPIC_API_KEY "你的 API Key"
    echo     setx ANTHROPIC_BASE_URL "https://coding.dashscope.aliyuncs.com/apps/anthropic"
    echo.
    echo 配置完成后:
    echo   1. 关闭此窗口并重新打开命令行
    echo   2. 运行 claude 启动程序
    echo.
) else (
    echo ✗ 安装遇到问题
    echo.
    echo 请尝试:
    echo   1. 重启电脑后重新运行脚本
    echo   2. 使用 Native 安装器
    echo   3. 使用 WinGet: winget install ClaudeCode
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
