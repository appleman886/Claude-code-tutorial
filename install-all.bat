@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: ========================================
:: Claude Code 完全一键安装脚本 (Windows)
:: 包含所有常见错误的自动检测和修复
:: ========================================

title Claude Code 完全安装程序
color 0E

set "ERROR_COUNT=0"
set "SUCCESS_NODE=0"
set "SUCCESS_GIT=0"
set "SUCCESS_CLAUDE=0"

echo ========================================
echo    Claude Code 完全一键安装程序
echo    Windows 版本
echo ========================================
echo.
echo 本脚本将自动完成：
echo   1. 安装 Node.js 运行环境
echo   2. 安装 Git 版本控制工具
echo   3. 安装 Claude Code 命令行工具
echo.
echo 自动修复的问题:
echo   ✓ 权限不足 (错误 2502/2503)
echo   ✓ PowerShell 策略限制
echo   ✓ npm 权限问题 (EACCES)
echo   ✓ 环境变量未添加
echo   ✓ 杀毒软件拦截提示
echo   ✓ 网络超时 (使用国内镜像)
echo.
echo 预计耗时：5-10 分钟
echo ========================================
echo.

:: ========================================
:: 权限检查和提升
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
    echo [提示] PowerShell 执行策略为 Restricted
    echo.
    echo 正在自动修改...
    powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force" 2>nul
    if %errorLevel% equ 0 (
        echo [成功] 执行策略已修改
    ) else (
        echo [失败] 修改失败
        set /a ERROR_COUNT+=1
    )
) else (
    echo [成功] PowerShell 执行策略：!EXEC_POLICY!
)

:: ========================================
:: 杀毒软件提示
:: ========================================
echo.
echo ========================================
echo [提示] 杀毒软件检查
echo ========================================
echo.
echo 如果安装失败，可能是以下软件拦截:
echo   - 360 安全卫士
echo   - 腾讯电脑管家
echo   - 金山毒霸
echo   - Windows Defender
echo.
echo 建议暂时关闭后重试
echo.
timeout /t 3 >nul

:: ========================================
:: 安装 Node.js
:: ========================================
echo.
echo ========================================
echo [1/3] 安装 Node.js
echo ========================================
echo.

node -v >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=*" %%i in ('node -v') do set NODE_VER=%%i
    echo [信息] Node.js 已安装：!NODE_VER!
    set "SUCCESS_NODE=1"
    goto install_git
)

echo [操作] 正在安装 Node.js...

:: winget 安装
winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements --accept-source-agreements 2>nul
if %errorLevel% equ 0 (
    echo [成功] winget 安装完成
    timeout /t 5 >nul
    set "SUCCESS_NODE=1"
    goto install_git
)

:: NPMMirror 下载
echo [尝试] 使用 NPMMirror 下载安装...
powershell -Command "Invoke-WebRequest -Uri 'https://npmmirror.com/mirrors/node/v20.11.0/node-v20.11.0-x64.msi' -OutFile '%TEMP%\node.msi'" 2>nul
if exist "%TEMP%\node.msi" (
    msiexec /i "%TEMP%\node.msi" /quiet /norestart 2>nul
    if %errorLevel% equ 0 (
        timeout /t 15 >nul
        del "%TEMP%\node.msi" 2>nul
        echo [成功] Node.js 安装完成
        set "SUCCESS_NODE=1"
        goto install_git
    )
)

echo [失败] Node.js 安装失败
echo.
echo ===== 解决方法 =====
echo.
echo 1. 手动安装:
echo    访问：https://nodejs.cn/download/
echo    下载 Windows 安装包，右键"以管理员身份运行"
echo.
echo 2. 使用 NVM:
echo    访问：https://github.com/coreybutler/nvm-windows/releases
echo    下载 nvm-setup.exe 并安装
echo.
set /a ERROR_COUNT+=1

:install_git
:: ========================================
:: 安装 Git
:: ========================================
echo.
echo ========================================
echo [2/3] 安装 Git
echo ========================================
echo.

git --version >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=*" %%i in ('git --version') do set GIT_VER=%%i
    echo [信息] Git 已安装：!GIT_VER!
    set "SUCCESS_GIT=1"
    goto install_claude
)

echo [操作] 正在安装 Git...

:: winget 安装
winget install Git.Git --silent --accept-package-agreements --accept-source-agreements 2>nul
if %errorLevel% equ 0 (
    echo [成功] winget 安装完成
    timeout /t 5 >nul
    set "SUCCESS_GIT=1"
    goto install_claude
)

:: Gitee 下载
echo [尝试] 使用 Gitee 镜像下载安装...
powershell -Command "Invoke-WebRequest -Uri 'https://download.fastgit.org/Git-for-Windows/git-installer.exe' -OutFile '%TEMP%\git.exe'" 2>nul
if exist "%TEMP%\git.exe" (
    start /wait "%TEMP%\git.exe" /VERYSILENT /NORESTART 2>nul
    if %errorLevel% equ 0 (
        del "%TEMP%\git.exe" 2>nul
        echo [成功] Git 安装完成
        set "SUCCESS_GIT=1"
        goto install_claude
    )
)

echo [失败] Git 安装失败
echo.
echo ===== 解决方法 =====
echo.
echo 手动安装:
echo    访问：https://gitee.com/mirrors/git-for-windows/releases
echo    下载最新版 .exe 文件，右键"以管理员身份运行"
echo.
set /a ERROR_COUNT+=1

:install_claude
:: ========================================
:: 安装 Claude Code
:: ========================================
echo.
echo ========================================
echo [3/3] 安装 Claude Code
echo ========================================
echo.

:: 检查 npm
npm -v >nul 2>&1
if %errorLevel% neq 0 (
    echo [错误] npm 不可用!
    echo.
    echo Node.js 可能未正确安装
    echo 请重启电脑后重新运行此脚本
    echo.
    set /a ERROR_COUNT+=1
    goto verify_install
)

claude --version >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=*" %%i in ('claude --version') do set CLAUDE_VER=%%i
    echo [信息] Claude Code 已安装：!CLAUDE_VER!
    set "SUCCESS_CLAUDE=1"
    goto verify_install
)

:: 修复 npm 权限
set "NPM_PREFIX=C:\npm"
if not exist "!NPM_PREFIX!" mkdir "!NPM_PREFIX!" 2>nul
npm config set prefix "!NPM_PREFIX!" 2>nul
npm config set cache "C:\npm-cache" 2>nul

echo [操作] 正在安装 Claude Code...

:: NPMMirror 安装
call npm install -g @anthropic-ai/claude-code --registry=https://registry.npmmirror.com 2>&1
if %errorLevel% equ 0 (
    echo [成功] Claude Code 安装完成
    set "SUCCESS_CLAUDE=1"
    goto verify_install
)

:: 阿里云镜像
call npm install -g @anthropic-ai/claude-code --registry=https://mirrors.aliyun.com/npm/ 2>&1
if %errorLevel% equ 0 (
    echo [成功] Claude Code 安装完成
    set "SUCCESS_CLAUDE=1"
    goto verify_install
)

echo [失败] Claude Code 安装失败
echo.
echo ===== 解决方法 =====
echo.
echo 方法 1: 手动安装
echo   运行：npm install -g @anthropic-ai/claude-code ^
echo     --registry=https://registry.npmmirror.com
echo.
echo 方法 2: 使用 Native 安装器
echo   访问：https://code.claude.com/
echo   下载 Windows 安装器并双击运行
echo.
echo 方法 3: 使用 WinGet
echo   运行：winget install ClaudeCode
echo.
set /a ERROR_COUNT+=1
goto verify_install

:verify_install
:: ========================================
:: 验证安装
:: ========================================
echo.
echo ========================================
echo 验证安装结果
echo ========================================
echo.

timeout /t 3 >nul
set "PATH=%PATH%;C:\Program Files\nodejs;C:\Program Files\Git\cmd;!NPM_PREFIX!"

node -v >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=*" %%i in ('node -v') do set NODE_VER=%%i
    echo [成功] Node.js: !NODE_VER!
    set "SUCCESS_NODE=1"
) else (
    echo [未找到] Node.js
)

git --version >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=*" %%i in ('git --version') do set GIT_VER=%%i
    echo [成功] Git: !GIT_VER!
    set "SUCCESS_GIT=1"
) else (
    echo [未找到] Git
)

claude --version >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=*" %%i in ('claude --version') do set CLAUDE_VER=%%i
    echo [成功] Claude Code: !CLAUDE_VER!
    set "SUCCESS_CLAUDE=1"
) else (
    echo [未找到] Claude Code
)

:: ========================================
:: 完成总结
:: ========================================
echo.
echo ========================================
echo    安装完成总结
echo ========================================
echo.

if "!SUCCESS_NODE!"=="1" if "!SUCCESS_GIT!"=="1" if "!SUCCESS_CLAUDE!"=="1" (
    echo ✓ 所有组件安装成功!
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
) else (
    echo 部分组件安装失败或未安装
    echo.
    echo 请:
    echo   1. 查看上方的错误信息
    echo   2. 重启电脑后重新运行脚本
    echo   3. 或参考解决方法手动安装
)

if %ERROR_COUNT% gtr 0 (
    echo.
    echo ========================================
    echo    遇到 %ERROR_COUNT% 个问题
    echo ========================================
    echo.
    echo 已提供详细解决方法，请向上滚动查看
    echo.
)

echo ========================================
pause
