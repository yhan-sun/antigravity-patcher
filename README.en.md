# Antigravity Patcher

[中文说明 (Chinese Version)](README.md) | [![GitHub License](https://img.shields.io/github/license/yhan-sun/antigravity-patcher)](LICENSE)

A simple utility script to patch the Antigravity CLI (`agy`) binary on macOS and Windows, bypassing the local account eligibility restrictions and keeping your local AI development environment stable.

---

## 💡 What is this?

In newer versions of the interactive Antigravity CLI client (`agy`), a local **Eligibility Check** is enforced. If your Google account is not configured as eligible on the server, the client blocks all inputs in the interactive terminal (TUI) and prompts:
`Your current account is not eligible for Antigravity...`

This tool features an **instruction-level pattern matching engine** that scans the machine code of the `agy` binary to dynamically locate and bypass the local gate in `userInputLoop` without modifying any network configurations, allowing you to use local AI chat with any account.

Therefore, **this patcher supports all past and future versions** of the `agy` CLI client dynamically.

### 📊 Tested & Supported Versions
<!-- BEGIN_SUPPORTED_VERSIONS -->
1.1.2
<!-- END_SUPPORTED_VERSIONS -->

---

## 🚀 Key Features

* ⚡ **Universal Compatibility**: Dynamically parses binary instructions without relying on fixed offsets. It matches the pattern across past and future compilation versions.
* ⚡ **One-line Execution**: Run directly via terminal pipes without manual downloads or cloning.
* 🔍 **Smart Search**: Autodetects paths for common installations (Homebrew, Local AppData, User Profiles, etc.).
* 📦 **Automatic Backup**: Safely backs up the original executable to `.bak` before applying patches.
* 🔏 **Ad-hoc Codesigning**: Automatically removes invalid signatures and signs modified macOS binaries on the fly to avoid system warnings.

---

## 🛠️ Quick One-Liner Commands

You don't need to clone this repository. Copy and paste the corresponding command directly into your terminal:

### 1. Dynamic Patcher (Recommended, macOS & Windows)
If Python 3 is installed on your system (default on macOS), this will invoke the instruction-level scanner for **perfect version compatibility**:
```bash
curl -fsSL https://raw.githubusercontent.com/yhan-sun/antigravity-patcher/main/patch_antigravity.py | python3
```

### 2. Pure Shell Version (macOS Fallback)
If Python 3 is not available:
```bash
curl -fsSL https://raw.githubusercontent.com/yhan-sun/antigravity-patcher/main/patch_antigravity.sh | bash
```

### 3. Pure PowerShell Version (Windows Fallback)
If Python 3 is not available on Windows, run as Administrator:
```powershell
powershell -ExecutionPolicy Bypass -Command "iex (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/yhan-sun/antigravity-patcher/main/patch_antigravity.ps1')"
```

---

## 🏃‍♀️ Running the Patched CLI
After patching, start `agy` with the environment variable to disable auto-updates and prevent the patch from being overwritten:

```bash
AGY_CLI_DISABLE_AUTO_UPDATE=1 agy
```

---

## 📂 Backup & Rollback
If you need to roll back, simply restore your binary from the backup file:
```bash
# Example for macOS default installation path
mv ~/.local/bin/agy.bak ~/.local/bin/agy
```

## ⚖️ Disclaimer
This script modifies binary files. Use at your own risk. Always make sure your backup is secure.
