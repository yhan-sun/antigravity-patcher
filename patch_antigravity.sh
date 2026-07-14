#!/usr/bin/env bash
# patch_antigravity.sh - Universal patch script for Antigravity CLI
# Usage: ./patch_antigravity.sh [path/to/agy]

set -e

# Resolve script directory to find sibling files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define possible installation paths (highest to lowest priority)
SEARCH_PATHS=(
    "$HOME/.local/bin/agy"
    "$HOME/Library/Application Support/agy/bin/agy"
    "$HOME/.local/share/agy/bin/agy"
    "/opt/homebrew/bin/agy"
    "/usr/local/bin/agy"
)

BINARY=""

# If path is provided as argument
if [ -n "$1" ]; then
    BINARY="$1"
else
    # Traverse default paths
    for path in "${SEARCH_PATHS[@]}"; do
        if [ -f "$path" ] && [ -x "$path" ]; then
            BINARY="$path"
            echo "✅ Found agy binary: $BINARY"
            break
        fi
    done
fi

# Fallback to which
if [ -z "$BINARY" ]; then
    if command -v agy &> /dev/null; then
        BINARY=$(which agy)
        echo "✅ Found agy via PATH: $BINARY"
    fi
fi

if [ -z "$BINARY" ]; then
    echo "❌ Error: Could not locate agy binary."
    echo "Please specify the path manually:"
    echo "  ./patch_antigravity.sh /path/to/agy"
    exit 1
fi

# Run python patcher if available
if command -v python3 &> /dev/null; then
    echo "🔄 Running universal dynamic patcher via Python..."
    python3 "$SCRIPT_DIR/patch_antigravity.py" "$BINARY"
    exit $?
fi

# Fallback to static offset patching if python3 is not available
echo "⚠️ Python3 not found. Falling back to static version-specific patching..."

OFFSET=$((0x1e9b508))
# Check if already patched
CURRENT_BYTE=$(xxd -p -s $OFFSET -l 4 "$BINARY" 2>/dev/null || echo "")
if [ "$CURRENT_BYTE" = "3a000014" ]; then
    echo "ℹ️ Binary is already patched (fallback check)."
    exit 0
fi

# Backup
BACKUP="${BINARY}.bak"
if [ ! -f "$BACKUP" ]; then
    echo "📦 Creating backup: $BACKUP"
    cp "$BINARY" "$BACKUP"
fi

# Write static patch bytes (valid for 1.1.2 arm64 macOS)
echo "✏️ Writing static patch to offset 0x$(printf '%x' $OFFSET)..."
printf "\x3a\x00\x00\x14" | dd of="$BINARY" bs=1 seek=$OFFSET conv=notrunc status=none

# Re-sign
echo "🔏 Re-signing binary..."
codesign --remove-signature "$BINARY" 2>/dev/null || true
codesign --sign - "$BINARY" || {
    echo "⚠️ Codesigning failed."
    exit 1
}

echo "🎉 Fallback patch successful! Run with:"
echo "   AGY_CLI_DISABLE_AUTO_UPDATE=1 $BINARY"
