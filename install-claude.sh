#!/bin/bash

# ========================================
# Claude Code 一键安装脚本 (macOS/Linux 版)
# ========================================

set -e

echo "========================================"
echo "   Claude Code 一键安装程序"
echo "   macOS/Linux 版本"
echo "========================================"
echo ""

# 检查是否已安装 Node.js
check_prerequisites() {
    echo "========================================"
    echo "[步骤 1] 检查前置条件"
    echo "========================================"
    echo ""

    if ! command -v node &> /dev/null; then
        echo "[错误] 未检测到 Node.js!"
        echo ""
        echo "请先安装 Node.js:"
        echo "  1. 运行 ./install-nodejs.sh 脚本"
        echo ""
        echo "  2. 或手动安装:"
        echo "     macOS:  brew install node"
        echo "     Linux: sudo apt-get install nodejs npm"
        echo ""
        exit 1
    fi

    NODE_VER=$(node -v)
    echo "[成功] Node.js: $NODE_VER"

    if ! command -v npm &> /dev/null; then
        echo "[错误] 未检测到 npm!"
        echo ""
        echo "Node.js 已安装但 npm 不可用"
        echo "请重新安装 Node.js"
        echo ""
        exit 1
    fi

    NPM_VER=$(npm -v)
    echo "[成功] npm: $NPM_VER"
    echo ""
}

# 检查现有安装
check_existing() {
    echo "========================================"
    echo "[步骤 2] 检查 Claude Code 安装"
    echo "========================================"
    echo ""

    if command -v claude &> /dev/null; then
        CLAUDE_VER=$(claude --version)
        echo "[信息] Claude Code 已安装：$CLAUDE_VER"
        echo ""

        read -p "是否卸载并重新安装？(y/N): " REINSTALL
        if [[ "$REINSTALL" =~ ^[Yy]$ ]]; then
            echo "[操作] 正在卸载旧版本..."
            npm uninstall -g @anthropic-ai/claude-code 2>/dev/null || true
            echo "[成功] 旧版本已卸载"
        else
            echo "[完成] 已跳过安装"
            goto_install_complete
            return 0
        fi
    fi
}

# 安装 Claude Code
install_claude() {
    echo ""
    echo "========================================"
    echo "[步骤 3] 安装 Claude Code"
    echo "========================================"
    echo ""

    # 方法 1: NPMMirror (推荐)
    echo "[尝试 1/3] 使用 NPMMirror 安装..."
    echo ""

    if npm install -g @anthropic-ai/claude-code --registry=https://registry.npmmirror.com 2>&1; then
        echo ""
        echo "[成功] NPMMirror 安装完成"
        return 0
    fi

    echo ""
    echo "[失败] NPMMirror 安装失败，尝试其他方法..."
    echo ""

    # 方法 2: 阿里云镜像
    echo "[尝试 2/3] 使用阿里云镜像安装..."
    echo ""

    if npm install -g @anthropic-ai/claude-code --registry=https://mirrors.aliyun.com/npm/ 2>&1; then
        echo ""
        echo "[成功] 阿里云镜像安装完成"
        return 0
    fi

    echo ""
    echo "[失败] 阿里云镜像安装失败"
    echo ""

    # 方法 3: 官方源
    echo "[尝试 3/3] 使用官方源安装..."
    echo ""

    if npm install -g @anthropic-ai/claude-code 2>&1; then
        echo ""
        echo "[成功] 官方源安装完成"
        return 0
    fi

    echo ""
    echo "[失败] 官方源安装失败"
    echo ""

    # 安装失败，提供解决方法
    echo "========================================"
    echo "自动安装失败，请尝试以下方法"
    echo "========================================"
    echo ""
    echo "方法 1: 手动运行安装命令"
    echo "  npm install -g @anthropic-ai/claude-code \\"
    echo "    --registry=https://registry.npmmirror.com"
    echo ""
    echo "方法 2: 检查网络连接"
    echo "  确保网络连接正常"
    echo "  如果使用代理，请确保代理可用"
    echo ""
    echo "方法 3: 清理 npm 缓存"
    echo "  npm cache clean --force"
    echo "  然后重新安装"
    echo ""
    echo "方法 4: 使用 Native 安装器"
    echo "  访问：https://code.claude.com/"
    echo "  下载 macOS 安装器并运行"
    echo ""

    return 1
}

# 验证安装
verify_install() {
    echo ""
    echo "========================================"
    echo "[步骤 4] 验证安装"
    echo "========================================"
    echo ""

    # 刷新 PATH
    export PATH="$PATH:$(npm config get prefix)/bin"

    if command -v claude &> /dev/null; then
        CLAUDE_VER=$(claude --version)
        echo "[成功] Claude Code: $CLAUDE_VER"
        INSTALL_SUCCESS=1
    else
        echo "[未找到] Claude Code"
        echo ""
        echo "可能原因:"
        echo "  1. PATH 环境变量未更新"
        echo "  2. 需要重启终端"
        echo ""
        echo "解决方法:"
        echo "  1. 关闭此窗口并重新打开终端"
        echo "  2. 运行 claude --version 验证"
        echo ""
    fi
}

# 安装完成
installation_complete() {
    echo ""
    echo "========================================"
    echo "   安装完成总结"
    echo "========================================"
    echo ""

    if [[ "$INSTALL_SUCCESS" == "1" ]]; then
        echo "✓ Claude Code 安装成功!"
        echo ""
        echo "下一步：配置 API 密钥"
        echo "========================================"
        echo ""
        echo "方法 1: 使用智谱官方助手 (推荐)"
        echo "  运行：npx @z_ai/coding-helper"
        echo "  说明：交互式向导，自动配置智谱 API"
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
        echo "添加到 shell 配置:"
        echo "  echo 'export ANTHROPIC_AUTH_TOKEN=\"你的 API Key\"' >> ~/.zshrc"
        echo "  echo 'export ANTHROPIC_BASE_URL=\"https://dashscope.aliyuncs.com/compatible-mode/v1\"' >> ~/.zshrc"
        echo "  source ~/.zshrc"
        echo ""
        echo "配置完成后:"
        echo "  1. 关闭此窗口并重新打开终端"
        echo "  2. 运行 claude 启动程序"
        echo ""
    else
        echo "✗ 安装遇到问题"
        echo ""
        echo "请尝试:"
        echo "  1. 重启终端后重新运行脚本"
        echo "  2. 使用 Native 安装器"
        echo "  3. 手动运行 npm install 命令"
        echo ""
    fi
}

# 主程序
INSTALL_SUCCESS=0

check_prerequisites
check_existing
if [[ $? -ne 0 ]]; then
    exit 0
fi
install_claude
verify_install
installation_complete
