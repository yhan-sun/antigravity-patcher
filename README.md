# Antigravity Patcher

A simple utility script to patch the Antigravity CLI (`agy`) binary on macOS and Windows, enabling customization or fixing behavior such as disabling auto-updates.

## Supported Platforms
- **macOS**: Shell script (`patch_antigravity.sh`) with automatic binary search, binary modification, and ad-hoc code resign.
- **Windows**: PowerShell script (`patch_antigravity.ps1`).

## How it Works
The script searches for the `agy` binary in default locations, backs up the original binary, writes patch bytes (`\x3a\x00\x00\x14`) to offset `0x1e9b508`, and (on macOS) re-signs the executable to ensure it can run on modern macOS systems.

---

## Usage Instructions

### macOS / Linux

1. Clone or download this repository.
2. Grant execution permission to the script:
   ```bash
   chmod +x patch_antigravity.sh
   ```
3. Run the script:
   ```bash
   ./patch_antigravity.sh
   ```
4. If your binary is located in a custom directory, you can specify it as an argument:
   ```bash
   ./patch_antigravity.sh /path/to/your/agy
   ```
5. Once patched, run the CLI with the auto-update check disabled:
   ```bash
   AGY_CLI_DISABLE_AUTO_UPDATE=1 agy
   ```

### Windows

1. Open PowerShell as Administrator.
2. Run the PowerShell script:
   ```powershell
   .\patch_antigravity.ps1
   ```

---

## Disclaimer
This script modifies binary files. Please make sure you have backed up any critical data before running the patcher. Use at your own risk.
