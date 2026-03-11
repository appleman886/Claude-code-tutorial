#!/bin/bash

# Claude Code 教程网站部署脚本
# 用于部署到 GitHub Pages

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Claude Code 教程网站部署脚本${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 检查是否已初始化 git 仓库
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}初始化 Git 仓库...${NC}"
    git init
    git add .
    git commit -m "Initial commit - Claude Code 教程网站"

    echo -e "${YELLOW}请输入您的 GitHub 仓库名称（例如：claude-code-tutorial）:${NC}"
    read REPO_NAME

    echo -e "${YELLOW}请输入您的 GitHub 用户名（例如：appleman886）:${NC}"
    read USERNAME

    REMOTE_URL="https://github.com/${USERNAME}/${REPO_NAME}.git"

    echo -e "${YELLOW}添加远程仓库: ${REMOTE_URL}${NC}"
    git remote add origin ${REMOTE_URL}

    echo -e "${YELLOW}重命名分支为 main...${NC}"
    git branch -M main

    echo -e "${YELLOW}推送到 GitHub...${NC}"
    git push -u origin main

    echo ""
    echo -e "${GREEN}✓ 代码已推送到 GitHub！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${YELLOW}接下来请手动执行以下步骤：${NC}"
    echo ""
    echo -e "1. 访问: ${GREEN}https://github.com/${USERNAME}/${REPO_NAME}/settings/pages${NC}"
    echo -e "2. 在 'Build and deployment' 中选择 Source 为 'Deploy from a branch'"
    echo -e "3. 选择分支为 'main' 和文件夹为 '/ (root)'"
    echo -e "4. 点击 Save"
    echo ""
    echo -e "${GREEN}等待几分钟后，访问: https://${USERNAME}.github.io/${REPO_NAME}/${NC}"
    echo ""

else
    echo -e "${YELLOW}Git 仓库已存在${NC}"
    echo -e "${YELLOW}添加文件到暂存区...${NC}"
    git add .

    echo -e "${YELLOW}提交更改...${NC}"
    git commit -m "Update website content"

    echo -e "${YELLOW}推送到远程仓库...${NC}"
    git push

    echo ""
    echo -e "${GREEN}✓ 网站已更新！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
fi

echo -e "${GREEN}部署完成！${NC}"
