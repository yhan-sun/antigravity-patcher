# Antigravity Patcher

[中文说明 (Chinese Version)](README.md) | [![GitHub License](https://img.shields.io/github/license/yhan-sun/antigravity-patcher)](LICENSE)

A simple utility script to patch the Antigravity CLI (`agy`) binary on macOS and Windows, enabling customization or fixing behavior such as disabling auto-updates.

## 💡 What is this?
`Antigravity Patcher` is an automated tool designed to search for and patch the `agy` binary. It overwrites specific offset bytes (`0x1e9b508`) with custom values (`\x3a\x00\x00\x14`) to disable checks like auto-updates, and handles macOS codesigning issues so that the binary can run without warnings.

## 🚀 Why Use It?
* ⚡ **One-line Execution**: Execute directly from GitHub without cloning or downloading manually.
* 🔍 **Smart Search**: Autodetects paths for common installations (Homebrew, Local AppData, etc.).
* 📦 **Automatic Backup**: Backs up your original executable to `.bak` automatically.
* 🔏 **Ad-hoc Codesigning**: Re-signs modified macOS binaries on the fly.

---

## 🛠️ Quick One-Liner Commands

### macOS / Linux
```bash
curl -fsSL https://raw.githubusercontent.com/yhan-sun/antigravity-patcher/main/patch_antigravity.sh | bash
```

### Windows (PowerShell)
```powershell
powershell -ExecutionPolicy Bypass -Command "iex (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/yhan-sun/antigravity-patcher/main/patch_antigravity.ps1')"
```

---

## 🏃‍♀️ Running the Patched CLI
After patching, run the `agy` client with the environment variable:

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
