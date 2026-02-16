# 🤖 适用于 Termux 的 GitHub Copilot CLI

[![Termux](https://img.shields.io/badge/Termux-000000?style=for-the-badge&logo=android&logoColor=white)](https://termux.com)
[![Node.js](https://img.shields.io/badge/Node.js-43853D?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org)
[![Stars](https://img.shields.io/github/stars/kastielslip/copilot-termux?style=for-the-badge)](https://github.com/kastielslip/copilot-termux)

### *微软的 AI 100% 运行在你的 Android 上*

------------------------------------------------------------------------

## 🚀 快速安装

> **一条命令安装 - 全自动完成**

``` bash
curl -fsSL https://raw.githubusercontent.com/2376780283/copilot-termux-chinese/master/install.sh | bash
```

### 版本 0.0.353（最新）

``` bash
bash <(curl -fsSL https://raw.githubusercontent.com/2376780283/copilot-termux-chinese/master/install.sh) 0.0.353
```

### 版本 0.0.346（稳定版）

``` bash
bash <(curl -fsSL https://raw.githubusercontent.com/2376780283/copilot-termux-chinese/master/install.sh) 0.0.346
```

------------------------------------------------------------------------

## 📚 文档

好吧，那它是怎么工作的？这里有完整清晰的解释（没有 500 页那种枯燥说明书）：

### [📖 工作原理](https://raw.githack.com/kastielslip/copilot-termux/master/docs/COMO_FUNCIONA.html)

详细介绍 bypass 系统架构以及 Copilot 如何在 Termux 中运行。

**内容包括：** - 原生模块绕过系统 - node-pty 与 sharp 架构 - 安装流程 -
文件结构 - 环境变量

### [🔧 安装指南](https://raw.githack.com/kastielslip/copilot-termux/master/docs/INSTALACAO.html)

完整的逐步安装指南。

**内容包括：** - 自动安装 - 手动安装 - 环境配置 - 安装验证 - 初始命令

### [🛠️ 故障排除](https://raw.githack.com/kastielslip/copilot-termux/master/docs/TROUBLESHOOTING.html)

常见问题与错误解决方案。

**内容包括：** - 原生模块错误 - NODE_OPTIONS 问题 - 认证错误 -
性能与优化 - 日志与诊断

------------------------------------------------------------------------

## ✨ 特性
### 🎯 完全自动化

-   ✅ 自动下载
-   ✅ 零配置安装
-   ✅ 原生模块绕过
-   ✅ 自动环境配置

### 🔧 技术特性

-   ✅ 系统检测
-   ✅ 多版本支持
-   ✅ 详细日志
-   ✅ 智能回退机制


------------------------------------------------------------------------

## 🎯 使用方法

### 安装完成后：

> ⚠️ **使用前请重启终端**

### 命令：

**查看版本：**

``` bash
copilot --version
```

**查看帮助：**

``` bash
copilot --help
```

**交互模式：**

``` bash
copilot
```

**直接执行提示：**

``` bash
copilot -p "如何在 linux 中列出文件？"
```

------------------------------------------------------------------------

## 🔄 更新

``` bash
npm uninstall -g @github/copilot
bash <(curl -fsSL https://raw.githubusercontent.com/kastielslip/copilot-termux/master/install.sh) 0.0.353
```

------------------------------------------------------------------------

## 📊 兼容性

  版本      状态      已测试
  --------- --------- -------------------
  0.0.346   ✅ 稳定   Android 11+ ARM64
  0.0.353   ✅ 可用   Android 11+ ARM64

------------------------------------------------------------------------

## 📜 许可证

MIT License - [LICENSE](LICENSE)

------------------------------------------------------------------------

## 翻译

zzhlife Pixel ZZ

------------------------------------------------------------------------

**由 ☕ 驱动，作者 [kastielslip](https://github.com/kastielslip)**

[![GitHub](https://img.shields.io/badge/GitHub-kastielslip-181717?style=for-the-badge&logo=github)](https://github.com/kastielslip)
