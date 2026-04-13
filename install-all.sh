#!/bin/bash

# ========================================
# Claude Code 完全一键安装脚本 (macOS/Linux 版)
# 自动安装 Node.js + Git + Claude Code
# ========================================

set -e

echo "========================================"
echo "   Claude Code 完全一键安装程序"
echo "   macOS/Linux 版本"
echo "========================================"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        echo -e "${GREEN}[信息]${NC} 检测到 macOS 系统"
    else
        OS="linux"
        echo -e "${GREEN}[信息]${NC} 检测到 Linux 系统"
    fi
}

# 权限检查
check_root() {
    echo ""
    echo "========================================"
    echo "[步骤 1] 检查权限"
    echo "========================================"
    echo ""

    if [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}[提示]${NC} 建议以 sudo 权限运行此脚本"
        echo ""
        echo "请运行：sudo bash $0"
        echo ""
        exit 1
    fi

    echo -e "${GREEN}[成功]${NC} 已以 root 权限运行"
}

# 安装 Node.js
install_nodejs() {
    echo ""
    echo "========================================"
    echo "[步骤 2/3] 安装 Node.js"
    echo "========================================"
    echo ""

    if command -v node &> /dev/null; then
        NODE_VER=$(node -v)
        echo -e "${GREEN}[信息]${NC} Node.js 已安装：$NODE_VER"
        SUCCESS_NODE=1
        return 0
    fi

    echo -e "${YELLOW}[操作]${NC} 正在安装 Node.js..."

    if [[ "$OS" == "macos" ]]; then
        # macOS 使用 Homebrew
        if ! command -v brew &> /dev/null; then
            echo "[提示] 未检测到 Homebrew，正在安装..."
            if /bin/bash -c "$(curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git/install.sh)" 2>&1; then
                echo "[成功] Homebrew 安装完成"
            else
                echo -e "${RED}[失败]${NC} Homebrew 安装失败"
            fi
        fi

        echo "[操作] 使用 Homebrew 安装 Node.js..."
        if brew install node 2>&1; then
            echo -e "${GREEN}[成功]${NC} Node.js 安装完成"
            SUCCESS_NODE=1
        else
            echo -e "${RED}[失败]${NC} Node.js 安装失败"
        fi
    else
        # Linux 使用包管理器
        if command -v apt-get &> /dev/null; then
            echo "[操作] 使用 apt 安装 Node.js..."
            apt-get update -qq
            if apt-get install -y nodejs npm 2>&1; then
                echo -e "${GREEN}[成功]${NC} Node.js 安装完成"
                SUCCESS_NODE=1
            else
                echo -e "${RED}[失败]${NC} Node.js 安装失败"
            fi
        elif command -v yum &> /dev/null; then
            echo "[操作] 使用 yum 安装 Node.js..."
            if yum install -y nodejs npm 2>&1; then
                echo -e "${GREEN}[成功]${NC} Node.js 安装完成"
                SUCCESS_NODE=1
            else
                echo -e "${RED}[失败]${NC} Node.js 安装失败"
            fi
        else
            echo -e "${RED}[错误]${NC} 未找到支持的包管理器"
            echo "请手动安装 Node.js: https://nodejs.org/"
        fi
    fi
}

# 安装 Git
install_git() {
    echo ""
    echo "========================================"
    echo "[步骤 3/3] 安装 Git"
    echo "========================================"
    echo ""

    if command -v git &> /dev/null; then
        GIT_VER=$(git --version)
        echo -e "${GREEN}[信息]${NC} Git 已安装：$GIT_VER"
        SUCCESS_GIT=1
        return 0
    fi

    echo -e "${YELLOW}[操作]${NC} 正在安装 Git..."

    if [[ "$OS" == "macos" ]]; then
        # macOS 使用 Homebrew
        if brew install git 2>&1; then
            echo -e "${GREEN}[成功]${NC} Git 安装完成"
            SUCCESS_GIT=1
        else
            echo -e "${RED}[失败]${NC} Git 安装失败"
        fi
    else
        # Linux 使用包管理器
        if command -v apt-get &> /dev/null; then
            if apt-get install -y git 2>&1; then
                echo -e "${GREEN}[成功]${NC} Git 安装完成"
                SUCCESS_GIT=1
            else
                echo -e "${RED}[失败]${NC} Git 安装失败"
            fi
        elif command -v yum &> /dev/null; then
            if yum install -y git 2>&1; then
                echo -e "${GREEN}[成功]${NC} Git 安装完成"
                SUCCESS_GIT=1
            else
                echo -e "${RED}[失败]${NC} Git 安装失败"
            fi
        else
            echo -e "${RED}[错误]${NC} 未找到支持的包管理器"
        fi
    fi
}

# 安装 Claude Code
install_claude() {
    echo ""
    echo "========================================"
    echo "[步骤 4/4] 安装 Claude Code"
    echo "========================================"
    echo ""

    # 检查 npm
    if ! command -v npm &> /dev/null; then
        echo -e "${RED}[错误]${NC} npm 不可用!"
        echo "Node.js 可能未正确安装"
        return 1
    fi

    if command -v claude &> /dev/null; then
        CLAUDE_VER=$(claude --version)
        echo -e "${GREEN}[信息]${NC} Claude Code 已安装：$CLAUDE_VER"
        SUCCESS_CLAUDE=1
        return 0
    fi

    echo -e "${YELLOW}[操作]${NC} 正在安装 Claude Code..."

    # 使用 NPMMirror 安装
    if npm install -g @anthropic-ai/claude-code --registry=https://registry.npmmirror.com 2>&1; then
        echo -e "${GREEN}[成功]${NC} Claude Code 安装完成"
        SUCCESS_CLAUDE=1
        return 0
    fi

    # 尝试阿里云镜像
    echo "[尝试] 使用阿里云镜像..."
    if npm install -g @anthropic-ai/claude-code --registry=https://mirrors.aliyun.com/npm/ 2>&1; then
        echo -e "${GREEN}[成功]${NC} Claude Code 安装完成"
        SUCCESS_CLAUDE=1
        return 0
    fi

    echo -e "${RED}[失败]${NC} Claude Code 安装失败"
    echo ""
    echo "解决方法:"
    echo "  手动运行：npm install -g @anthropic-ai/claude-code --registry=https://registry.npmmirror.com"
    return 1
}

# 验证安装
verify_install() {
    echo ""
    echo "========================================"
    echo "验证安装结果"
    echo "========================================"
    echo ""

    if command -v node &> /dev/null; then
        NODE_VER=$(node -v)
        echo -e "${GREEN}[成功]${NC} Node.js: $NODE_VER"
    else
        echo -e "${RED}[未找到]${NC} Node.js"
    fi

    if command -v git &> /dev/null; then
        GIT_VER=$(git --version)
        echo -e "${GREEN}[成功]${NC} Git: $GIT_VER"
    else
        echo -e "${RED}[未找到]${NC} Git"
    fi

    if command -v claude &> /dev/null; then
        CLAUDE_VER=$(claude --version)
        echo -e "${GREEN}[成功]${NC} Claude Code: $CLAUDE_VER"
    else
        echo -e "${RED}[未找到]${NC} Claude Code"
    fi

    echo ""
    echo "========================================"
    echo "   安装完成总结"
    echo "========================================"
    echo ""

    if [[ "$SUCCESS_NODE" == "1" ]] && [[ "$SUCCESS_GIT" == "1" ]] && [[ "$SUCCESS_CLAUDE" == "1" ]]; then
        echo -e "${GREEN}✓ 所有组件安装成功!${NC}"
        echo ""
        echo "下一步：配置 API 密钥"
        echo "========================================"
        echo ""
        echo "方法 1: 使用智谱官方助手 (推荐)"
        echo "  运行：npx @z_ai/coding-helper"
        echo ""
        echo "方法 2: 手动配置环境变量"
        echo "  智谱 AI:"
        echo '    export ANTHROPIC_AUTH_TOKEN="你的 API Key"'
        echo '    export ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/paas/v4"'
        echo ""
        echo "  阿里云百炼:"
        echo '    export ANTHROPIC_AUTH_TOKEN="你的 API Key"'
        echo '    export ANTHROPIC_BASE_URL="https://dashscope.aliyuncs.com/compatible-mode/v1"'
        echo ""
        echo "添加到 shell 配置 (~/.zshrc 或 ~/.bashrc):"
        echo '  export ANTHROPIC_AUTH_TOKEN="你的 API Key"'
        echo '  export ANTHROPIC_BASE_URL="https://dashscope.aliyuncs.com/compatible-mode/v1"'
        echo ""
        echo "配置完成后:"
        echo "  1. 关闭此窗口并重新打开终端"
        echo "  2. 运行 claude 启动程序"
        echo ""
    else
        echo -e "${YELLOW}✗ 部分组件安装失败${NC}"
        echo ""
        echo "请:"
        echo "  1. 查看上方的错误信息"
        echo "  2. 重启终端后重新运行脚本"
        echo "  3. 或参考解决方法手动安装"
        echo ""
    fi
}

# 主程序
SUCCESS_NODE=0
SUCCESS_GIT=0
SUCCESS_CLAUDE=0

detect_os

# macOS 非 root 运行检查
if [[ "$OS" == "macos" ]] && [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}[提示]${NC} 检测到 macOS 系统"
    echo ""
    echo "此脚本需要管理员权限安装软件"
    echo ""
    read -p "是否使用 sudo 运行？(y/N): " USE_SUDO
    if [[ "$USE_SUDO" =~ ^[Yy]$ ]]; then
        echo "正在以 sudo 权限重新启动..."
        sudo bash "$0"
        exit $?
    fi
fi

check_root
install_nodejs
install_git
install_claude
verify_install
