#!/usr/bin/env python3
import os
import sys
import shutil
import struct
import subprocess

# Possible search paths for the agy binary
SEARCH_PATHS = [
    os.path.expanduser("~/.local/bin/agy"),
    os.path.expanduser("~/Library/Application Support/agy/bin/agy"),
    os.path.expanduser("~/.local/share/agy/bin/agy"),
    "/opt/homebrew/bin/agy",
    "/usr/local/bin/agy",
]

def find_binary():
    # 1. Check SEARCH_PATHS
    for path in SEARCH_PATHS:
        if os.path.isfile(path) and os.access(path, os.X_OK):
            return path
    
    # 2. Check PATH environment variable
    agy_path = shutil.which("agy")
    if agy_path:
        return agy_path
        
    return None

def scan_binary_for_pattern(data):
    """Scans binary data for the eligibility gate pattern and returns offset and patch bytes."""
    n = len(data)
    for i in range(0, n - 20, 4):
        inst1, inst2, inst3, inst4, inst5 = struct.unpack('<5I', data[i:i+20])
        
        # Pattern 1: ldrb wA, [xB, #0x58] -> 0x39416000 | (B << 5) | A
        if (inst1 & 0xfffffc00) != 0x39416000:
            continue
        B = (inst1 >> 5) & 0x1f
        A = inst1 & 0x1f
        
        # Pattern 2: tbnz wA, #0, label1 -> 0x37000000 | (imm14 << 5) | A
        if (inst2 & 0xffe0001f) != (0x37000000 | A):
            continue
            
        # Pattern 3: ldr xC, [xB, #0x38] -> 0xf9401c00 | (B << 5) | C
        if (inst4 & 0xfffffc00) != 0xf9401c00 or ((inst4 >> 5) & 0x1f) != B:
            continue
        C = inst4 & 0x1f
        
        # Pattern 4: cbz xC, label_send -> 0xb4000000 | (imm19 << 5) | C
        if (inst5 & 0xffe0001f) != (0xb4000000 | C):
            continue
            
        # Extract and sign-extend imm19 from cbz
        imm19_raw = (inst5 >> 5) & 0x7ffff
        if imm19_raw & 0x40000:
            imm19 = imm19_raw - 0x80000
        else:
            imm19 = imm19_raw
            
        patch_offset = i + 16
        # Encode unconditional branch: b label_send (0x14000000 | (imm19 & 0x3ffffff))
        b_inst = 0x14000000 | (imm19 & 0x3ffffff)
        new_inst_bytes = struct.pack('<I', b_inst)
        return patch_offset, new_inst_bytes
        
    return None, None

def patch_binary(filepath):
    # If the file is already patched, try using the backup file to extract correct offsets
    backup_path = filepath + ".bak"
    scan_filepath = filepath
    if os.path.exists(backup_path):
        print(f"[*] Found backup file {backup_path}. Scanning backup to ensure original pattern is found...")
        scan_filepath = backup_path

    print(f"[*] Reading binary: {scan_filepath}")
    with open(scan_filepath, 'rb') as f:
        data = bytearray(f.read())
        
    patch_offset, new_inst_bytes = scan_binary_for_pattern(data)
    
    if patch_offset is None:
        # Check if active is already patched and no backup was found/scanned
        if scan_filepath == filepath:
            # Check if active is already patched
            for i in range(0, len(data) - 20, 4):
                inst1, inst2, inst3, inst4, inst5 = struct.unpack('<5I', data[i:i+20])
                if (inst1 & 0xfffffc00) == 0x39416000:
                    B = (inst1 >> 5) & 0x1f
                    A = inst1 & 0x1f
                    if (inst2 & 0xffe0001f) == (0x37000000 | A):
                        if (inst4 & 0xfffffc00) == 0xf9401c00 and ((inst4 >> 5) & 0x1f) == B:
                            C = inst4 & 0x1f
                            if (inst5 & 0xfc000000) == 0x14000000:
                                print("ℹ️ Binary is already patched.")
                                return True
                                
        print("❌ Error: Pattern not found. This version of the CLI might not have the eligibility gate, or the structure has changed.")
        return False
        
    # Read active binary for applying patch
    with open(filepath, 'rb') as f:
        active_data = bytearray(f.read())
        
    # Check if active is already patched
    active_inst5 = struct.unpack('<I', active_data[patch_offset:patch_offset+4])[0]
    if active_inst5 == struct.unpack('<I', new_inst_bytes)[0]:
        print("ℹ️ Binary is already patched.")
    else:
        # Create backup if not exists
        if not os.path.exists(backup_path):
            print(f"[*] Creating backup: {backup_path}")
            shutil.copy2(filepath, backup_path)
        else:
            print(f"[*] Backup already exists: {backup_path}")
            
        # Apply patch
        print(f"[*] Applying patch at offset 0x{patch_offset:x}...")
        with open(filepath, 'r+b') as f:
            f.seek(patch_offset)
            f.write(new_inst_bytes)
        print("✅ Patch applied successfully.")
        
        # Re-sign on macOS
        if sys.platform == "darwin":
            print("[*] Re-signing binary on macOS...")
            try:
                subprocess.run(["codesign", "--remove-signature", filepath], check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                subprocess.run(["codesign", "--sign", "-", filepath], check=True)
                print("✅ Re-signed successfully.")
            except Exception as e:
                print(f"⚠️ Warning: Codesigning failed ({e}). You may need to sign it manually.")
                
    return True

def main():
    if len(sys.argv) > 1:
        target = sys.argv[1]
    else:
        target = find_binary()
        
    if not target:
        print("❌ Error: agy binary not found in default paths.")
        print("Please specify the path to your agy binary:")
        print("  python3 patch_antigravity.py /path/to/agy")
        sys.exit(1)
        
    if not os.path.exists(target):
        print(f"❌ Error: File not found: {target}")
        sys.exit(1)
        
    success = patch_binary(target)
    if not success:
        sys.exit(1)
        
    print("\n🎉 Patch complete! Run the client with:")
    print("   AGY_CLI_DISABLE_AUTO_UPDATE=1 agy")

if __name__ == "__main__":
    main()
