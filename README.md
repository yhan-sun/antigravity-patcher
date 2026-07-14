# Antigravity Patcher (Antigravity 补丁工具)

[English Version (英文说明)](README.en.md) | [![GitHub License](https://img.shields.io/github/license/yhan-sun/antigravity-patcher)](LICENSE)

一个为 Google Antigravity CLI (`agy`) 二进制文件提供热修补的轻量级工具。它可以帮助您轻松解除自动更新等行为限制，保持本地开发环境的稳定。

---

## 💡 这是什么？
`Antigravity Patcher` 是一个自动化补丁脚本，支持 macOS (Bash) 和 Windows (PowerShell)。它能够自动在您的系统默认安装路径中搜索 `agy` 客户端，对二进制文件的特定偏移量（`0x1e9b508`）写入补丁字节（`\x3a\x00\x00\x14`），并自动处理 macOS 上的临时签名（ad-hoc signature），使补丁能够无缝运行。

## 🚀 为什么要使用它？
* ⚡ **一键极速修复**：支持使用单行命令直接远程运行，无需克隆仓库或手动下载。
* 🔍 **智能路径搜索**：自动识别 macOS 和 Windows 下各种主流的安装路径（如 Homebrew、本地 Application Support、User Profile 等）。
* 📦 **安全第一**：在写入任何字节之前，脚本会自动为您创建备份文件 (`.bak`)，如有需要可随时还原。
* 🔏 **自动签名处理**：修补后自动移除损坏的签名并重新进行本地签名，确保 macOS 系统不会抛出崩溃或不可信警告。

---

## 🛠️ 一键远程运行命令

无需下载或克隆仓库，直接复制以下命令在终端中运行：

### macOS / Linux
```bash
curl -fsSL https://raw.githubusercontent.com/yhan-sun/antigravity-patcher/main/patch_antigravity.sh | bash
```

### Windows (PowerShell)
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
