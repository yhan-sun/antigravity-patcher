# Antigravity Patcher

[中文说明 (Chinese Version)](README.md) | [![GitHub License](https://img.shields.io/github/license/yhan-sun/antigravity-patcher)](LICENSE)

A simple utility script to patch the Antigravity CLI (`agy`) binary on macOS and Windows, enabling customization or fixing behavior such as disabling auto-updates.

## 💡 What is this?
`Antigravity Patcher` is an automated, smart binary patching tool. Unlike static offset patchers, it **features an instruction-level pattern matching engine** that scans the machine code of the `agy` binary to dynamically locate the eligibility check within `userInputLoop` and bypass it.

Therefore, **this patcher supports all past and future versions** of the `agy` CLI client dynamically.

## 🚀 Why Use It?
* ⚡ **Universal Compatibility**: Dynamically parses instructions without relying on fixed offsets.
* ⚡ **One-line Execution**: Execute directly from GitHub without cloning or downloading manually.
* 🔍 **Smart Search**: Autodetects paths for common installations (Homebrew, Local AppData, etc.).
* 📦 **Automatic Backup**: Backs up your original executable to `.bak` automatically.
* 🔏 **Ad-hoc Codesigning**: Re-signs modified macOS binaries on the fly.

---

## 🛠️ Quick One-Liner Commands (Recommended)

### 🍎 macOS / 💻 Windows (Recommended: Python Dynamic Analyzer)
As long as Python 3 is installed on your system, this command will **automatically locate, analyze, and patch** any version of the CLI client:
```bash
curl -fsSL https://raw.githubusercontent.com/yhan-sun/antigravity-patcher/main/patch_antigravity.py | python3
```

### 🐚 Pure Shell Script (macOS Fallback)
If you don't have Python 3, you can use the Shell script (attempts to run Python, falls back to static 1.1.2 offset patch):
```bash
curl -fsSL https://raw.githubusercontent.com/yhan-sun/antigravity-patcher/main/patch_antigravity.sh | bash
```

### 💻 Pure PowerShell Script (Windows Fallback)
If you don't have Python 3, you can run:
```powershell
powershell -ExecutionPolicy Bypass -Command "iex (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/yhan-sun/antigravity-patcher/main/patch_antigravity.ps1')"
```

---

## 🏃‍♀️ Running the Patched CLI
After patching, run the `agy` client with the environment variable to prevent auto-updates:

```bash
AGY_CLI_DISABLE_AUTO_UPDATE=1 agy
```

---

## 📂 Backup & Rollback
If you need to roll back, you can restore your binary from the backup file:
```bash
mv ~/.local/bin/agy.bak ~/.local/bin/agy  # Adjust path to match your installation
```

## ⚖️ Disclaimer
This script modifies binary files. Use at your own risk. Always make sure your backup is secure.
