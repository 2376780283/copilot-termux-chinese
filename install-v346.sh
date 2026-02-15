#!/data/data/com.termux/files/usr/bin/bash
# ==========================================================
# GitHub Copilot CLI - Termux 修正版安装器
# 版本：1.1 - 含 Sharp Stub（适用于 Android ARM64）
# 环境：Android ARM64（Termux）
# ==========================================================

set -euo pipefail

# 配置
LOG_FILE="$HOME/copilot_install_$(date +%Y%m%d_%H%M%S).log"
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
NODE_MODULES="$PREFIX/lib/node_modules"
COPILOT_DIR="$NODE_MODULES/@github/copilot"

# 将输出重定向到日志和控制台
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================="
echo "🤖 GitHub Copilot CLI - Termux 安装器"
echo "=========================================="
echo "日志: $LOG_FILE"
echo "环境: $(uname -o) $(uname -m)"
echo "------------------------------------------"

# 日志函数
log() {
  echo "[$(date '+%H:%M:%S')] $*"
}

# 检查环境
check_environment() {
  log "正在检查环境..."
  
  if ! command -v node &>/dev/null; then
    log "❌ 未找到 Node.js"
    echo "请执行: pkg install nodejs"
    exit 1
  fi
  
  local node_ver
  node_ver=$(node -v | sed 's/^v//' | cut -d. -f1)
  if (( node_ver < 18 )); then
    log "❌ 需要 Node.js 18+（当前版本: $(node -v)）"
    exit 1
  fi
  
  log "✅ Node.js $(node -v) 正常"
  log "✅ npm $(npm -v) 正常"
}

# 安装依赖
install_dependencies() {
  log "正在安装依赖..."
  
  pkg install -y libvips git wget >/dev/null 2>&1 || log "⚠️ 部分依赖安装失败"
  log "✅ 依赖安装完成"
}

# 清理旧安装
clean_previous() {
  log "正在清理旧版本..."
  npm uninstall -g @github/copilot 2>/dev/null || true
  npm cache clean --force 2>/dev/null || true
  log "✅ 清理完成"
}

# 安装 Copilot
install_copilot() {
  log "正在安装 @github/copilot@0.0.346..."
  
  if npm install -g @github/copilot@0.0.346 --ignore-scripts --force 2>&1 | tee -a "$LOG_FILE"; then
    log "✅ 安装完成"
    return 0
  fi
  
  log "❌ 安装失败"
  return 1
}

# 为 Sharp 创建 stub（图像模块）
create_sharp_stub() {
  log "正在为 sharp 模块创建 stub..."
  
  local sharp_file="$COPILOT_DIR/node_modules/sharp/lib/sharp.js"
  
  if [[ ! -f "$sharp_file" ]]; then
    log "⚠️ 未找到 Sharp，跳过"
    return 0
  fi
  
  cat > "$sharp_file" << 'EOFSHARP'
// Sharp 完整 stub（适用于 Termux Android ARM64）
'use strict';

const formats = {
  jpeg: { id: 'jpeg', output: { alias: ['jpg', 'jpeg'] } },
  png: { id: 'png', output: { alias: ['png'] } },
  webp: { id: 'webp', output: { alias: ['webp'] } },
  avif: { id: 'avif', output: { alias: ['avif'] } },
  heif: { id: 'heif', output: { alias: ['heif', 'heic'] } },
  jxl: { id: 'jxl', output: { alias: ['jxl'] } },
  tiff: { id: 'tiff', output: { alias: ['tiff', 'tif'] } },
  gif: { id: 'gif', output: { alias: ['gif'] } },
  svg: { id: 'svg', output: { alias: ['svg'] } },
  jp2k: { id: 'jp2k', output: { alias: ['jp2', 'j2k'] } },
  raw: { id: 'raw', output: { alias: ['raw'] } }
};

const sharp = () => ({
  metadata: () => Promise.resolve({ format: 'png', width: 100, height: 100 }),
  toBuffer: () => Promise.resolve(Buffer.alloc(0)),
  toFile: () => Promise.resolve({ size: 0 }),
  resize: function() { return this; },
  extract: function() { return this; },
  trim: function() { return this; },
  extend: function() { return this; },
  flatten: function() { return this; },
  unflatten: function() { return this; },
  negate: function() { return this; },
  normalise: function() { return this; },
  normalize: function() { return this; },
  clahe: function() { return this; },
  convolve: function() { return this; },
  threshold: function() { return this; },
  boolean: function() { return this; },
  linear: function() { return this; },
  recomb: function() { return this; },
  modulate: function() { return this; },
  tint: function() { return this; },
  greyscale: function() { return this; },
  grayscale: function() { return this; },
  pipelineColourspace: function() { return this; },
  pipelineColorspace: function() { return this; },
  toColourspace: function() { return this; },
  toColorspace: function() { return this; }
});

// sharp.format 既是函数也是属性
sharp.format = Object.assign(
  () => formats,
  formats
);

sharp.versions = {
  vips: '8.17.2'
};

sharp.libvipsVersion = () => '8.17.2';
sharp.cache = () => ({ memory: 0, files: 0, items: 0 });
sharp.concurrency = () => 1;
sharp.queue = { length: 0 };
sharp.simd = () => false;
sharp.counters = () => ({ queue: 0, process: 0 });

module.exports = sharp;
EOFSHARP

  log "✅ Sharp stub 创建完成"
}

# 测试安装
test_installation() {
  log "正在测试安装..."
  
  if ! command -v copilot &>/dev/null; then
    log "❌ 未找到 copilot 命令"
    return 1
  fi
  
  local version
  version=$(copilot --version 2>&1 | head -1)
  
  if [[ -z "$version" ]]; then
    log "❌ 执行 copilot 时出错"
    return 1
  fi
  
  log "✅ Copilot 已安装: $version"
  return 0
}

# 执行安装流程
main() {
  check_environment
  install_dependencies
  clean_previous
  install_copilot
  create_sharp_stub
  
  echo ""
  echo "=========================================="
  
  if test_installation; then
    echo "✅ 安装成功完成！"
    echo "=========================================="
    echo ""
    echo "后续操作："
    echo "  1. copilot --help    - 查看帮助"
    echo "  2. copilot           - 启动 Copilot"
    echo "  3. copilot -p '...'  - 直接执行提示"
    echo ""
  else
    echo "❌ 安装存在问题"
    echo "=========================================="
    echo "请查看日志: $LOG_FILE"
    exit 1
  fi
}

main "$@"