#!/bin/bash

# ========================================
# Git 一键安装脚本 (macOS/Linux 版)
# ========================================

set -e

echo "========================================"
echo "   Git 一键安装程序"
echo "   macOS/Linux 版本"
echo "========================================"
echo ""

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        echo "[信息] 检测到 macOS 系统"
    else
        OS="linux"
        echo "[信息] 检测到 Linux 系统"
    fi
}

# 检查是否已安装 Git
check_existing() {
    if command -v git &> /dev/null; then
        GIT_VER=$(git --version)
        echo "[信息] Git 已安装：$GIT_VER"

        read -p "是否重新安装？(y/N): " REINSTALL
        if [[ "$REINSTALL" =~ ^[Yy]$ ]]; then
            echo "[操作] 正在卸载旧版本..."
            if [[ "$OS" == "macos" ]]; then
                brew uninstall git 2>/dev/null || true
            else
                sudo apt-get remove git -y 2>/dev/null || \
                sudo yum remove git -y 2>/dev/null || true
            fi
        else
            echo "[完成] 已跳过安装"
            return 0
        fi
    fi
}

# 安装 Git
install_git() {
    echo ""
    echo "========================================"
    echo "[步骤] 安装 Git"
    echo "========================================"
    echo ""

    if [[ "$OS" == "macos" ]]; then
        # macOS 使用 Homebrew
        if ! command -v brew &> /dev/null; then
            echo "[提示] 未检测到 Homebrew，正在安装..."
            /bin/bash -c "$(curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git/install.sh)"
        fi

        echo "[操作] 使用 Homebrew 安装 Git..."
        brew install git
    else
        # Linux 使用包管理器
        if command -v apt-get &> /dev/null; then
            echo "[操作] 使用 apt 安装 Git..."
            sudo apt-get update
            sudo apt-get install -y git
        elif command -v yum &> /dev/null; then
            echo "[操作] 使用 yum 安装 Git..."
            sudo yum install -y git
        elif command -v dnf &> /dev/null; then
            echo "[操作] 使用 dnf 安装 Git..."
            sudo dnf install -y git
        elif command -v pacman &> /dev/null; then
            echo "[操作] 使用 pacman 安装 Git..."
            sudo pacman -S git
        else
            echo "[错误] 未找到支持的包管理器"
            echo "请手动安装 Git"
            return 1
        fi
    fi
}

# 配置 Git（可选）
configure_git() {
    echo ""
    echo "========================================"
    echo "[可选] 配置 Git 用户信息"
    echo "========================================"
    echo ""

    # 检查是否已配置
    EXISTING_NAME=$(git config --global user.name 2>/dev/null)
    EXISTING_EMAIL=$(git config --global user.email 2>/dev/null)

    if [[ -n "$EXISTING_NAME" ]] && [[ -n "$EXISTING_EMAIL" ]]; then
        echo "[信息] Git 已配置:"
        echo "  姓名：$EXISTING_NAME"
        echo "  邮箱：$EXISTING_EMAIL"
        read -p "是否修改？(y/N): " RECONFIG
        if [[ ! "$RECONFIG" =~ ^[Yy]$ ]]; then
            echo "[完成] 已跳过配置"
            return 0
        fi
    fi

    echo "请输入 Git 配置信息："
    read -p "姓名 (例如：Zhang San): " USER_NAME
    read -p "邮箱 (例如：zhangsan@example.com): " USER_EMAIL

    git config --global user.name "$USER_NAME"
    git config --global user.email "$USER_EMAIL"

    echo "[成功] Git 配置完成"
}

# 验证安装
verify_install() {
    echo ""
    echo "========================================"
    echo "[步骤] 验证安装"
    echo "========================================"
    echo ""

    if command -v git &> /dev/null; then
        GIT_VER=$(git --version)
        echo "[成功] Git: $GIT_VER"
    else
        echo "[未找到] Git - 请重新运行脚本或手动安装"
        return 1
    fi

    echo ""
    echo "========================================"
    echo "   安装成功!"
    echo "========================================"
    echo ""
    echo "下一步:"
    echo "  1. 运行 git --version 验证"
    echo "  2. 配置 Git 用户信息 (git config)"
    echo "  3. 继续安装 Claude Code"
    echo ""
}

# 主程序
detect_os
check_existing
if [[ $? -ne 0 ]]; then
    exit 0
fi
install_git
if [[ $? -ne 0 ]]; then
    exit 1
fi
configure_git
verify_install
