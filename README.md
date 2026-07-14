# Antigravity Patcher (Antigravity 补丁工具)

[English Version (英文说明)](README.en.md) | [![GitHub License](https://img.shields.io/github/license/yhan-sun/antigravity-patcher)](LICENSE)

一个为 Google Antigravity CLI (`agy`) 二进制客户端提供热修补的轻量级工具。它可以帮助您跳过本地账号准入限制，保持本地 AI 对话环境的稳定。

---

## 💡 这是什么？

在较新版本的 Antigravity 交互式客户端中，引入了本地的 **Eligibility Check（账号准入限制）** 拦截。若您的 Google 账号未被配置为授权用户，客户端会在 TUI（命令行界面）中拦截任何输入并反复提示：
`Your current account is not eligible for Antigravity...`

本工具内置了**指令级特征分析引擎**，在不修改任何网络通信或服务端数据的前提下，自动识别并跳过客户端本地的阻断逻辑，使得任意未授权的账号也可以在本地顺畅地与 AI 进行交互。

因此，**本工具能够完美兼容当前及未来的各种 `agy` 版本**。

### 📊 已测试支持版本
<!-- BEGIN_SUPPORTED_VERSIONS -->
1.1.2
<!-- END_SUPPORTED_VERSIONS -->

---

## 🚀 核心功能

* ⚡ **全版本通用**：通过扫描机器码特征，动态定位 `userInputLoop` 内部的逻辑跳转点，无需依赖固定版本的文件偏移量，完美适配新老版本。
* 🔍 **自动路径检测**：支持自动搜索系统中常见的 `agy` 安装目录（如 Homebrew、User Path、Application Support 等）。
* 📦 **安全自动备份**：在写入补丁前自动生成原二进制的 `.bak` 备份文件，支持随时回滚。
* 🔏 **智能代码重签名**：在 macOS 环境下，修补后会自动移除已失效的旧签名并对可执行文件进行 ad-hoc 签名，避免触发系统崩溃或安全警告。

---

## 🛠️ 一键使用方法

您无需下载或手动克隆仓库，直接复制以下对应的命令在您的终端中执行即可：

### 1. 动态特征版（推荐，支持 macOS / Windows）
如果您的系统中安装了 Python 3（macOS 通常自带），该脚本会启动指令级特征定位器，实现**全版本动态分析与完美适配**：
```bash
curl -fsSL https://raw.githubusercontent.com/yhan-sun/antigravity-patcher/main/patch_antigravity.py | python3
```

### 2. 纯 Shell 脚本版（macOS 备用）
若无 Python 环境，可以使用 Shell 脚本版（会尝试寻找 Python，找不到时 fallback 到特定版本静态字节修补）：
```bash
curl -fsSL https://raw.githubusercontent.com/yhan-sun/antigravity-patcher/main/patch_antigravity.sh | bash
```

### 3. 纯 PowerShell 脚本版（Windows 备用）
在 Windows 上且没有 Python 环境时，可以以管理员身份运行：
```powershell
powershell -ExecutionPolicy Bypass -Command "iex (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/yhan-sun/antigravity-patcher/main/patch_antigravity.ps1')"
```

---

## 🏃‍♀️ 运行修补后的 CLI
修补完成后，建议使用以下命令来启动 `agy`，从而彻底禁用自动更新，防止补丁被覆盖：

```bash
AGY_CLI_DISABLE_AUTO_UPDATE=1 agy
```

---

## 📂 备份与还原
如果需要回退到未修补的状态，可以直接将自动生成的备份文件重命名还原即可：
```bash
# 还原示例
mv ~/.local/bin/agy.bak ~/.local/bin/agy
```

## ⚖️ 免责声明
本工具仅用于学习与个人定制化开发环境。修改二进制文件存在一定风险，请在执行前确认已保存重要数据。
