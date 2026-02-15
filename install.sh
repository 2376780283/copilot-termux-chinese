#!/data/data/com.termux/files/usr/bin/bash
################################################################################
# GitHub Copilot CLI - Termux 全自动安装器
# 版本：2.0 - 完全自动化
# 日期：2025-10-31
# 支持：v0.0.346（稳定版）和 v0.0.353（最新版）
################################################################################

set -euo pipefail

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 配置
VERSION="${1:-0.0.353}"  # 默认版本：0.0.353
LOG_FILE="$HOME/copilot-install-$(date +%Y%m%d_%H%M%S).log"
TEMP_DIR="$HOME/.copilot-temp"
HOOKS_DIR="$HOME/.copilot-hooks"

# 下载地址
TARBALL_URL="https://registry.npmjs.org/@github/copilot/-/copilot-${VERSION}.tgz"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🤖 GitHub Copilot CLI - 自动安装程序                  ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}📦 已选择版本：${VERSION}${NC}"
echo -e "${YELLOW}📝 日志文件：${LOG_FILE}${NC}"
echo ""

# 重定向输出到日志
exec > >(tee -a "$LOG_FILE") 2>&1

# 日志函数
log() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $*"
}

error() {
    echo -e "${RED}[错误]${NC} $*"
    exit 1
}

warning() {
    echo -e "${YELLOW}[警告]${NC} $*"
}

# 1. 检测系统
log "🔍 正在检测系统..."
ARCH=$(uname -m)
OS=$(uname -o)
NODE_VERSION=$(node -v 2>/dev/null || echo "未安装")

echo "   • 架构：$ARCH"
echo "   • 操作系统：$OS"
echo "   • Node.js：$NODE_VERSION"
echo ""

# 2. 检查依赖
log "✅ 正在检查依赖..."

if [ "$OS" != "Android" ]; then
    error "该安装器仅适用于 Termux/Android"
fi

if [ "$ARCH" != "aarch64" ]; then
    warning "当前架构 $ARCH 可能存在兼容问题（推荐：aarch64）"
fi

if ! command -v node &>/dev/null; then
    log "📥 正在安装 Node.js..."
    pkg install -y nodejs || error "Node.js 安装失败"
fi

if ! command -v wget &>/dev/null; then
    log "📥 正在安装 wget..."
    pkg install -y wget || error "wget 安装失败"
fi

if ! command -v git &>/dev/null; then
    log "📥 正在安装 git..."
    pkg install -y git || error "git 安装失败"
fi

# 3. 清理旧版本
log "🧹 清理旧版本..."
npm uninstall -g @github/copilot 2>/dev/null || true
rm -rf "$TEMP_DIR" "$HOOKS_DIR"
mkdir -p "$TEMP_DIR" "$HOOKS_DIR"

# 4. 下载 tarball
log "📥 下载 Copilot v${VERSION}..."
cd "$TEMP_DIR"
if ! wget -q --show-progress "$TARBALL_URL" -O "copilot-${VERSION}.tgz"; then
    error "从 ${TARBALL_URL} 下载失败"
fi

# 5. 安装包
log "📦 安装 @github/copilot@${VERSION}..."
npm install -g "./copilot-${VERSION}.tgz" --ignore-scripts --force 2>&1 | grep -v "npm WARN" || true

# 6. 创建 bypass-final.js
log "🔧 为原生模块创建绕过补丁..."
cat > "$HOOKS_DIR/bypass-final.js" << 'ENDBYPASS'
const Module = require('module');
const originalLoad = Module._load;

console.log('[BYPASS] Copilot Termux v2.0 - 原生模块');

Module._load = function(request, parent) {
  // node-pty 绕过
  if (request.includes('pty.node') || request.includes('node-pty')) {
    return {
      spawn: () => ({ 
        pid: 9999, 
        on: () => ({}), 
        write: () => true, 
        resize: () => {}, 
        kill: () => {} 
      }),
      Terminal: class { 
        constructor() { this.pid = 9999; } 
        on() { return this; } 
        write() { return true; } 
        resize() {} 
        kill() {} 
      }
    };
  }
  
  // sharp 绕过
  if (request.includes('sharp') && !request.endsWith('sharp.js')) {
    class Sharp {
      constructor(input, options) {
        this.options = options || {};
        this.input = input;
      }
      resize() { return this; }
      extract() { return this; }
      trim() { return this; }
      extend() { return this; }
      flatten() { return this; }
      negate() { return this; }
      normalize() { return this; }
      toBuffer(callback) {
        const buffer = Buffer.from('');
        const info = { format: 'raw', width: 0, height: 0, channels: 0, size: 0 };
        if (callback) callback(null, buffer, info);
        return Promise.resolve(buffer);
      }
      toFile(path, callback) {
        const info = { format: 'raw', width: 0, height: 0, size: 0 };
        if (callback) callback(null, info);
        return Promise.resolve(info);
      }
      metadata(callback) {
        const meta = { format: 'raw', width: 0, height: 0, channels: 0 };
        if (callback) callback(null, meta);
        return Promise.resolve(meta);
      }
      clone() { return new Sharp(this.input, this.options); }
    }
    
    const sharp = (input, options) => new Sharp(input, options);
    const formatDef = {
      input: { file: true, buffer: true, stream: true },
      output: { file: true, buffer: true, stream: true, alias: [] }
    };
    
    sharp.cache = () => ({});
    sharp.concurrency = () => 1;
    sharp.counters = () => ({});
    sharp.simd = () => false;
    sharp.format = () => ({
      jpeg: formatDef,
      png: formatDef,
      webp: formatDef,
      tiff: formatDef,
      gif: formatDef,
      svg: formatDef,
      avif: formatDef,
      heif: { ...formatDef, output: { ...formatDef.output, alias: ['heic'] } },
      jp2k: { ...formatDef, output: { ...formatDef.output, alias: ['jp2', 'j2k'] } },
      jxl: formatDef,
      raw: formatDef
    });
    sharp.versions = { vips: '8.17.0', sharp: '0.33.0' };
    sharp.libvipsVersion = () => '8.17.0';
    sharp.vendor = { platform: 'linux', arch: 'arm64' };
    
    return sharp;
  }
  
  return originalLoad.apply(this, arguments);
};
ENDBYPASS

# 7. 配置 .bashrc
log "⚙️  配置环境变量..."

# 删除旧配置
sed -i '/NODE_OPTIONS.*bypass-final/d' ~/.bashrc
sed -i '/NODE_OPTIONS.*copilot/d' ~/.bashrc
sed -i '/LD_PRELOAD.*libandroid/d' ~/.bashrc

# 添加新配置
cat >> ~/.bashrc << 'ENDBASHRC'

# GitHub Copilot CLI - 原生模块绕过
export NODE_OPTIONS="--require $HOME/.copilot-hooks/bypass-final.js"
ENDBASHRC

# 当前会话立即生效
export NODE_OPTIONS="--require $HOME/.copilot-hooks/bypass-final.js"

# 8. 清理临时文件
log "🧹 清理临时文件..."
rm -rf "$TEMP_DIR"

# 9. 测试安装
log "🧪 测试安装..."
echo ""

if ! command -v copilot &>/dev/null; then
    error "安装后未找到 'copilot' 命令"
fi

INSTALLED_VERSION=$(copilot --version 2>&1 | head -1 || echo "错误")

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ 安装成功完成！                                      ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📦 已安装版本：${NC} ${INSTALLED_VERSION}"
echo -e "${BLUE}📁 Hooks 文件：${NC} ~/.copilot-hooks/bypass-final.js"
echo -e "${BLUE}📝 完整日志：${NC} ${LOG_FILE}"
echo ""
echo -e "${YELLOW}⚠️  重要提示：${NC}"
echo -e "   ${YELLOW}请重启终端或执行：${NC}"
echo -e "   ${GREEN}source ~/.bashrc${NC}"
echo ""
echo -e "${BLUE}🚀 后续操作：${NC}"
echo -e "   1. ${GREEN}copilot --help${NC}     - 查看帮助"
echo -e "   2. ${GREEN}copilot${NC}            - 启动 Copilot"
echo -e "   3. ${GREEN}copilot -p '文本'${NC}  - 执行提示词"
echo ""