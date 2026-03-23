@echo off
chcp 65001 >nul
echo ========================================
echo  同步到 GitHub 和 Gitee
echo ========================================
echo.

REM 检查 Git 状态
echo 当前 Git 状态：
git status
echo.

REM 添加所有修改的文件
git add .

echo.
echo 输入提交信息：
set /p commit_msg=

if "%commit_msg%"=="" (
    set commit_msg=更新教程内容
)

echo.
echo 提交代码...
git commit -m "%commit_msg%"

echo.
echo 推送到 GitHub...
git push origin main

echo.
echo 推送到 Gitee...
git push gitee main

echo.
echo ✅ 同步完成！
echo.
echo GitHub: https://github.com/appleman886/claude-code-tutorial
echo Gitee:  https://gitee.com/您的用户名/claude-code-tutorial
echo.
pause