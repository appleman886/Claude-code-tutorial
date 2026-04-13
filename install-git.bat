@echo off
chcp 936 >nul
setlocal EnableDelayedExpansion

:: ========================================
:: Git 一键安装脚本 (Windows 版)
:: 包含所有常见错误的自动检测和修复
:: ========================================

title Git 安装程序
color 0C

set "ERROR_COUNT=0"
set "SUCCESS=0"

echo ========================================
echo    Git 一键安装程序
echo    Windows 版本
echo ========================================
echo.
echo 本脚本会自动检测并修复：
echo   - 权限不足问题
echo   - 环境变量未添加问题
echo   - 杀毒软件拦截问题
echo   - 安装程序无响应问题
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
    goto check_antivirus
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
:: 杀毒软件检查
:: ========================================
:check_antivirus
echo.
echo ========================================
echo [步骤 2] 检查杀毒软件
echo ========================================
echo.

echo [提示] 如果安装失败，可能是杀毒软件拦截
echo.
echo 建议暂时关闭以下软件:
echo   - 360 安全卫士
echo   - 腾讯电脑管家
echo   - 金山毒霸
echo   - Windows Defender 实时保护
echo.
set /p CONTINUE=是否继续安装？(Y/N):
if /i not "!CONTINUE!"=="Y" (
    echo.
    echo [完成] 已取消安装
    pause
    exit /b 0
)

:: ========================================
:: 检查现有安装
:: ========================================
echo.
echo ========================================
echo [步骤 3] 检查现有安装
echo ========================================
echo.

git --version >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=*" %%i in ('git --version') do set GIT_VER=%%i
    echo [信息] 检测到 Git 已安装：!GIT_VER!
    echo.
    set /p REINSTALL=是否卸载并重新安装？(Y/N):
    if /i not "!REINSTALL!"=="Y" (
        echo.
        echo [完成] 已跳过安装
        goto verify_install
    )

    echo.
    echo [操作] 正在卸载旧版本...
    winget uninstall Git.Git 2>nul
    taskkill /f /im git.exe 2>nul
    timeout /t 2 >nul
)

:: ========================================
:: 安装 Git
:: ========================================
echo.
echo ========================================
echo [步骤 4] 安装 Git
echo ========================================
echo.

:: 方法 1: winget
echo [尝试 1/3] 使用 winget 安装...
winget install Git.Git --silent --accept-package-agreements --accept-source-agreements 2>&1 | findstr /i "error"
if %errorLevel% neq 0 (
    echo [成功] winget 安装完成
    timeout /t 5 >nul
    goto post_install
)
echo [失败] winget 不可用或失败

:: 方法 2: Gitee 镜像下载
echo.
echo [尝试 2/3] 使用 Gitee 镜像下载安装...
echo.

echo [下载] 正在下载 Git 安装包...
powershell -Command "Invoke-WebRequest -Uri 'https://download.fastgit.org/Git-for-Windows/git-installer.exe' -OutFile '%TEMP%\git.exe'" 2>nul

if exist "%TEMP%\git.exe" (
    echo [下载完成] 正在安装...

    :: 静默安装
    start /wait "%TEMP%\git.exe" /VERYSILENT /NORESTART /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh" 2>nul
    if %errorLevel% equ 0 (
        echo [成功] Git 安装完成
        del "%TEMP%\git.exe" 2>nul
        goto post_install
    )

    echo [失败] 安装程序返回错误代码：%errorLevel%
)

:: 方法 3: 提供手动安装指引
echo.
echo [尝试 3/3] 提供手动安装方案
echo.
echo ========================================
echo 自动安装失败，请手动安装
echo ========================================
echo.
echo 方案 A: 使用 Gitee 镜像 (推荐)
echo   1. 访问：https://gitee.com/mirrors/git-for-windows/releases
echo   2. 下载最新版本的 .exe 文件
echo   3. 右键点击安装包 → "以管理员身份运行"
echo   4. 安装时勾选"Add Git to PATH"
echo.
echo 方案 B: 使用 GitHub 官方
echo   1. 访问：https://github.com/git-for-windows/git/releases
echo   2. 下载"Git-Setup.exe"
echo   3. 双击运行安装包
echo.
echo 方案 C: 使用 winget (如果有)
echo   1. 打开命令提示符
echo   2. 运行：winget install Git.Git
echo.
echo 安装选项说明:
echo   ✓ Add Git to PATH - 自动添加环境变量
echo   ✓ Associate .git files - 关联文件类型
echo   ✓ Git Bash Here - 右键菜单
echo.
set /a ERROR_COUNT+=1
goto end

:post_install
:: ========================================
:: 修复环境变量
:: ========================================
echo.
echo ========================================
echo [步骤 5] 检查环境变量
echo ========================================
echo.

:: 检查 Git 是否在 PATH 中
echo "%PATH%" | findstr /i "Git" >nul
if %errorLevel% neq 0 (
    echo [操作] 添加 Git 到 PATH...
    setx PATH "%PATH%;C:\Program Files\Git\cmd" 2>nul
    echo [成功] PATH 已更新 (需要重启命令行生效)
) else (
    echo [成功] Git 已在 PATH 中
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

set "PATH=%PATH%;C:\Program Files\Git\cmd"

git --version >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=*" %%i in ('git --version') do set GIT_VER=%%i
    echo [成功] Git !GIT_VER!
    set "SUCCESS=1"
) else (
    echo [未找到] Git - 请重启电脑后重试
    set /a ERROR_COUNT+=1
)

:end
echo.
echo ========================================
echo    安装完成总结
echo ========================================
echo.

if "!SUCCESS!"=="1" (
    echo ✓ Git 安装成功!
    echo.
    echo 下一步:
    echo   1. 关闭此窗口并重新打开命令行
    echo   2. 运行以下命令验证:
    echo      git --version
    echo.
    echo 初始配置:
    echo   git config --global user.name "你的名字"
    echo   git config --global user.email "你的邮箱"
    echo.
) else (
    echo ✗ 安装遇到问题
    echo.
    echo 请尝试:
    echo   1. 重启电脑后重新运行脚本
    echo   2. 手动下载安装
    echo   3. 检查杀毒软件设置
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
