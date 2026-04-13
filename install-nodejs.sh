#!/bin/bash

# ========================================
# Node.js 一键安装脚本 (macOS/Linux 版)
# ========================================

set -e

echo "========================================"
echo "   Node.js 一键安装程序"
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

# 检查是否已安装 Node.js
check_existing() {
    if command -v node &> /dev/null; then
        NODE_VER=$(node -v)
        echo "[信息] Node.js 已安装：$NODE_VER"

        if command -v npm &> /dev/null; then
            NPM_VER=$(npm -v)
            echo "[信息] npm 已安装：$NPM_VER"
        fi

        read -p "是否卸载并重新安装？(y/N): " REINSTALL
        if [[ "$REINSTALL" =~ ^[Yy]$ ]]; then
            echo "[操作] 正在卸载旧版本..."
            if [[ "$OS" == "macos" ]]; then
                brew uninstall node 2>/dev/null || true
            else
                sudo apt-get remove nodejs npm -y 2>/dev/null || \
                sudo yum remove nodejs npm -y 2>/dev/null || true
            fi
        else
            echo "[完成] 已跳过安装"
            return 0
        fi
    fi
}

# 安装 Node.js
install_nodejs() {
    echo ""
    echo "========================================"
    echo "[步骤] 安装 Node.js"
    echo "========================================"
    echo ""

    if [[ "$OS" == "macos" ]]; then
        # macOS 使用 Homebrew
        if ! command -v brew &> /dev/null; then
            echo "[提示] 未检测到 Homebrew，正在安装..."
            /bin/bash -c "$(curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git/install.sh)"
        fi

        echo "[操作] 使用 Homebrew 安装 Node.js..."
        brew install node
    else
        # Linux 使用包管理器
        if command -v apt-get &> /dev/null; then
            echo "[操作] 使用 apt 安装 Node.js..."
            sudo apt-get update
            sudo apt-get install -y nodejs npm
        elif command -v yum &> /dev/null; then
            echo "[操作] 使用 yum 安装 Node.js..."
            sudo yum install -y nodejs npm
        elif command -v dnf &> /dev/null; then
            echo "[操作] 使用 dnf 安装 Node.js..."
            sudo dnf install -y nodejs npm
        else
            # 使用 NodeSource
            echo "[操作] 使用 NodeSource 安装..."
            curl -fsSL https://mirrors.cloud.tencent.com/nodesource/gpg/setup-nodesource-release | sudo bash -s 20
            sudo apt-get install -y nodejs
        fi
    fi
}

# 验证安装
verify_install() {
    echo ""
    echo "========================================"
    echo "[步骤] 验证安装"
    echo "========================================"
    echo ""

    if command -v node &> /dev/null; then
        NODE_VER=$(node -v)
        echo "[成功] Node.js: $NODE_VER"
    else
        echo "[未找到] Node.js - 请重新运行脚本或手动安装"
        return 1
    fi

    if command -v npm &> /dev/null; then
        NPM_VER=$(npm -v)
        echo "[成功] npm: $NPM_VER"
    else
        echo "[未找到] npm - 请重新运行脚本或手动安装"
        return 1
    fi

    echo ""
    echo "========================================"
    echo "   安装成功!"
    echo "========================================"
    echo ""
    echo "下一步:"
    echo "  1. 运行 node -v 和 npm -v 验证"
    echo "  2. 继续安装 Git 和 Claude Code"
    echo ""
}

# 主程序
detect_os
check_existing
if [[ $? -ne 0 ]]; then
    exit 0
fi
install_nodejs
verify_install
