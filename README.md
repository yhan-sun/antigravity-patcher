# Antigravity Patcher (Antigravity 补丁工具)

[English Version (英文说明)](README.en.md) | [![GitHub License](https://img.shields.io/github/license/yhan-sun/antigravity-patcher)](LICENSE)

一个为 Google Antigravity CLI (`agy`) 二进制文件提供热修补的轻量级工具。它可以帮助您轻松解除自动更新等行为限制，保持本地开发环境的稳定。

---

## 💡 这是什么？
`Antigravity Patcher` 是一个智能化、通用型的二进制补丁工具。支持 macOS (ARM64) 和 Windows。

不同于市面上仅支持单一版本的硬编码偏移补丁，本工具**内置了指令级特征分析引擎**。它能通过扫描机器码，动态定位 `agy` 二进制中 `userInputLoop` 内的 eligibility (账号准入) 检测拦截点。并将拦截条件修改为无条件通过。

因此，**本工具能够完美兼容当前及未来的各种 `agy` 版本**。

## 🚀 为什么要使用它？
* ⚡ **全版本通用（Dynamic Pattern Matching）**：自动分析机器码，不再依赖特定版本的固定偏移量。
* ⚡ **一键极速修复**：支持使用单行命令直接远程运行，无需克隆仓库。
* 🔍 **智能路径搜索**：自动识别系统下各种主流的安装路径（如 Homebrew、本地 Application Support、User Profile 等）。
* 📦 **安全第一**：在写入任何字节之前，脚本会自动为您创建备份文件 (`.bak`)，如有需要可随时还原。
* 🔏 **自动签名处理**：修补后自动移除损坏的签名并重新进行本地签名，确保 macOS 系统不会抛出崩溃或不可信警告。

---

## 🛠️ 一键远程运行命令 (推荐)

无需下载或克隆仓库，直接复制以下命令在终端中运行：

### 🍎 macOS / 💻 Windows (推荐 Python 动态分析版)
只要您的系统装有 Python 3（macOS 默认自带），即可使用该命令，它会**自动动态分析并修补**任意版本的二进制：
```bash
curl -fsSL https://raw.githubusercontent.com/yhan-sun/antigravity-patcher/main/patch_antigravity.py | python3
```

### 🐚 纯 Shell 脚本 (macOS)
如果您的系统没有 Python 环境，可以使用 Shell 版（优先尝试调用 Python，无 Python 时 fallback 到 1.1.2 版本的硬编码偏移补丁）：
```bash
curl -fsSL https://raw.githubusercontent.com/yhan-sun/antigravity-patcher/main/patch_antigravity.sh | bash
```

### 💻 纯 PowerShell 脚本 (Windows)
如果您的系统没有 Python 环境，可以使用 PowerShell 版：
```powershell
powershell -ExecutionPolicy Bypass -Command "iex (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/yhan-sun/antigravity-patcher/main/patch_antigravity.ps1')"
```

---

## 🏃‍♀️ 运行修补后的 CLI
修补完成后，建议使用以下命令来启动 `agy`，从而彻底禁用自动更新：

```bash
AGY_CLI_DISABLE_AUTO_UPDATE=1 agy
```

---

## 📂 备份与还原
如果需要回滚，可以直接将原有的备份文件重命名还原：
```bash
mv ~/.local/bin/agy.bak ~/.local/bin/agy  # 根据实际安装路径进行还原
```

## ⚖️ 免责声明
本工具仅用于学习与个人定制化开发环境。修改二进制文件存在一定风险，请在执行前确认已保存重要数据。
