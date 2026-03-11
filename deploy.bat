@echo off
REM Claude Code 教程网站部署脚本 (Windows 版本)
REM 用于部署到 GitHub Pages

echo ========================================
echo   Claude Code 教程网站部署脚本
echo ========================================
echo.

REM 检查是否已初始化 git 仓库
if not exist ".git" (
    echo [1/6] 初始化 Git 仓库...
    git init

    echo [2/6] 添加文件到暂存区...
    git add .

    echo [3/6] 提交代码...
    git commit -m "Initial commit - Claude Code 教程网站"

    echo [4/6] 设置 GitHub 仓库信息...
    set /p REPO_NAME="请输入您的 GitHub 仓库名称（例如：claude-code-tutorial）: "
    set /p USERNAME="请输入您的 GitHub 用户名（例如：appleman886）: "

    set REMOTE_URL=https://github.com/%USERNAME%/%REPO_NAME%.git

    echo 添加远程仓库: %REMOTE_URL%
    git remote add origin %REMOTE_URL%

    echo [5/6] 重命名分支为 main...
    git branch -M main

    echo [6/6] 推送到 GitHub...
    git push -u origin main

    echo.
    echo ========================================
    echo   ✓ 代码已推送到 GitHub！
    echo ========================================
    echo.
    echo 接下来请手动执行以下步骤：
    echo.
    echo 1. 访问: https://github.com/%USERNAME%/%REPO_NAME%/settings/pages
    echo 2. 在 Build and deployment 中选择 Source 为 Deploy from a branch
    echo 3. 选择分支为 main 和文件夹为 / (root)
    echo 4. 点击 Save
    echo.
    echo 等待几分钟后，访问: https://%USERNAME%.github.io/%REPO_NAME%/
    echo.

) else (
    echo Git 仓库已存在
    echo [1/3] 添加文件到暂存区...
    git add .

    echo [2/3] 提交更改...
    git commit -m "Update website content"

    echo [3/3] 推送到远程仓库...
    git push

    echo.
    echo ========================================
    echo   ✓ 网站已更新！
    echo ========================================
    echo.
)

echo 部署完成！
pause
