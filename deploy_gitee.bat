@echo off
echo ========================================
echo  Claude Code 教程网站 - Gitee 部署脚本
echo ========================================
echo.

REM 检查 Git 是否已安装
git --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo 错误：Git 未安装！请先安装 Git。
    pause
    exit /b 1
)

echo 1. 检查当前 Git 状态...
git status

echo.
echo 2. 添加 Gitee 仓库...
echo 请确保您已经：
echo   - 注册了 Gitee 账号
echo   - 创建了新仓库（仓库名建议：claude-code-tutorial）
echo.
set /p gitee_url="请输入您的 Gitee 仓库 HTTPS 地址（如：https://gitee.com/yourname/claude-code-tutorial.git）："
if "%gitee_url%"=="" (
    echo 错误：Gitee 仓库地址不能为空！
    pause
    exit /b 1
)

echo.
echo 3. 添加 Gitee 远程仓库...
git remote add gitee "%gitee_url%"

echo.
echo 4. 推送代码到 Gitee...
git push -u gitee main

echo.
echo 5. 检查推送结果...
if %ERRORLEVEL% EQU 0 (
    echo ✅ 代码已成功推送到 Gitee！
    echo.
    echo ========================================
    echo 下一步操作：
    echo 1. 访问 Gitee 仓库：https://gitee.com/yourname/claude-code-tutorial
    echo 2. 进入 "仓库设置" → "Gitee Pages"
    echo 3. 选择 "main" 分支
    echo 4. 开启 Gitee Pages 服务
    echo 5. 等待几分钟，访问您的网站：https://yourname.gitee.io/claude-code-tutorial
    echo ========================================
) else (
    echo ❌ 推送失败，请检查 Gitee 地址和网络连接
)

pause