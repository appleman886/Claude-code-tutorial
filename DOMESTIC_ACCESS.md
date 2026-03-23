# 国内访问解决方案

## 🚀 Gitee Pages 部署指南

由于 GitHub Pages 在国内访问受限，建议同时在 Gitee 上部署网站，这样国内用户可以正常访问。

### 步骤1：创建 Gitee 仓库
1. 访问 [Gitee](https://gitee.com) 注册/登录账号
2. 点击 "+" → "新建仓库"
3. 仓库名称：`claude-code-tutorial`
4. 选择"开源"或"私有"
5. 点击"创建"

### 步骤2：推送代码到 Gitee

#### Windows 用户
```batch
# 运行部署脚本
deploy_gitee.bat
```

#### Mac/Linux 用户
```bash
# 给脚本添加执行权限
chmod +x deploy_gitee.sh

# 运行脚本
./deploy_gitee.sh
```

#### 手动操作
```bash
# 1. 添加 Gitee 远程仓库
git remote add gitee https://gitee.com/您的用户名/claude-code-tutorial.git

# 2. 推送代码
git push -u gitee main
```

### 步骤3：启用 Gitee Pages
1. 进入 Gitee 仓库页面
2. 点击 "管理" → "仓库设置"
3. 选择 "Gitee Pages" 选项卡
4. 选择 "master" 分支（注意：Gitee 使用 master 而不是 main）
5. 开启 Gitee Pages 服务
6. 等待 1-5 分钟自动部署

### 步骤4：访问网站
部署成功后，您的网站可以通过以下地址访问：
```
https://您的用户名.gitee.io/claude-code-tutorial
```

## 🔄 双平台维护脚本

### sync-gh-gitee.bat (Windows)
```batch
@echo off
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
```

### sync-gh-gitee.sh (Linux/Mac)
```bash
#!/bin/bash

echo "========================================"
echo " 同步到 GitHub 和 Gitee"
echo "========================================"
echo

# 检查 Git 状态
echo "当前 Git 状态："
git status
echo

# 添加所有修改的文件
git add .

echo
read -p "输入提交信息（默认：更新教程内容）: " commit_msg
if [ -z "$commit_msg" ]; then
    commit_msg="更新教程内容"
fi

echo
echo "提交代码..."
git commit -m "$commit_msg"

echo
echo "推送到 GitHub..."
git push origin main

echo
echo "推送到 Gitee..."
git push gitee main

echo
echo "✅ 同步完成！"
echo
echo "GitHub: https://github.com/appleman886/claude-code-tutorial"
echo "Gitee:  https://gitee.com/您的用户名/claude-code-tutorial"
```

## 📋 访问地址汇总

### 全球访问
- **GitHub Pages**: https://appleman886.github.io/Claude-code-tutorial/
  - 特点：国外访问快，国内需要代理
  - 适合：海外用户、技术爱好者

- **Gitee Pages**: https://您的用户名.gitee.io/claude-code-tutorial/
  - 特点：国内访问快，无需代理
  - 适合：国内普通用户

### 推荐使用方式
1. **教程中建议**: 优先使用 Gitee Pages 地址
2. **README 文档**: 同时提供两个地址
3. **二维码**: 生成两个网站的二维码供用户选择

## 🔧 其他可选方案

### 方案1：自定义域名
购买域名后，同时配置 GitHub Pages 和 Gitee Pages 的自定义域名，实现全球加速。

### 方案2：Cloudflare Pages
使用 Cloudflare 的 Pages 服务，可以绑定 GitHub 仓库，全球 CDN 加速。

### 方案3：国内云服务商
- 阿里云 OSS + CDN
- 腾讯云 COS + CDN
- 华为云 OBS + CDN

这些方案需要一定的技术配置和维护成本。