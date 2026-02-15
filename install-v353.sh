#!/data/data/com.termux/files/usr/bin/bash
# GitHub Copilot CLI v0.0.353 - 自动安装器
# 作者: kastielslip
# 日期: 29/10/2025

echo "🚀 GitHub Copilot CLI v0.0.353 - Termux 安装器"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ 未找到 Node.js!"
    echo "请执行: pkg install nodejs"
    exit 1
fi

echo "✅ Node.js $(node --version)"
echo ""

# 下载 tarball（如果不存在）
if [ ! -f "github-copilot-0.0.353.tgz" ]; then
    echo "📥 请下载 v0.0.353 的 tarball:"
    echo "   https://registry.npmjs.org/@github/copilot/-/copilot-0.0.353.tgz"
    echo ""
    echo "❌ 当前目录未找到 tarball 文件"
    exit 1
fi

echo "✅ 已找到 tarball"
echo ""

# 安装
echo "📦 正在安装 Copilot v0.0.353..."
npm install -g ./github-copilot-0.0.353.tgz --ignore-scripts --force

if [ $? -ne 0 ]; then
    echo "❌ 安装出错!"
    exit 1
fi

echo "✅ 安装完成"
echo ""

# 创建 hook
echo "🔧 正在创建 Module._load hook..."
mkdir -p ~/.copilot-hooks
cp hooks/bypass-final.js ~/.copilot-hooks/

echo "✅ Hook 创建完成"
echo ""

# 配置 NODE_OPTIONS
echo "⚙️  正在配置 NODE_OPTIONS..."
if ! grep -q "NODE_OPTIONS.*bypass-final" ~/.bashrc; then
    echo 'export NODE_OPTIONS="--require $HOME/.copilot-hooks/bypass-final.js"' >> ~/.bashrc
    echo "✅ 已添加到 ~/.bashrc"
else
    echo "✅ ~/.bashrc 中已配置"
fi

# 在当前会话中生效
export NODE_OPTIONS="--require $HOME/.copilot-hooks/bypass-final.js"

echo ""
echo "🧪 正在测试安装..."
copilot --version

if [ $? -eq 0 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎉 安装成功完成!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  🚀 后续步骤:"
    echo "  1. 测试: copilot --version"
    echo "  2. 认证: copilot (首次运行)"
    echo "  3. 使用: copilot -p '你的命令'"
    echo ""
    echo ""
else
    echo ""
    echo "❌ 测试时出错，请检查日志。"
fi