#!/bin/bash
# auto_patch_antigravity.sh - 自动查找并修补系统里的 Antigravity CLI
# 用法: ./auto_patch_antigravity.sh

set -e

# 定义可能的安装路径（按优先级从高到低）
SEARCH_PATHS=(
    "$HOME/.local/bin/agy"
    "$HOME/Library/Application Support/agy/bin/agy"
    "$HOME/.local/share/agy/bin/agy"
    "/opt/homebrew/bin/agy"
    "/usr/local/bin/agy"
)

BINARY=""

# 遍历查找
for path in "${SEARCH_PATHS[@]}"; do
    if [ -f "$path" ] && [ -x "$path" ]; then
        BINARY="$path"
        echo "✅ 找到 agy: $BINARY"
        break
    fi
done

# 如果没找到，尝试用 which 命令
if [ -z "$BINARY" ]; then
    if command -v agy &> /dev/null; then
        BINARY=$(which agy)
        echo "✅ 通过 PATH 找到 agy: $BINARY"
    fi
fi

# 仍然没找到则报错退出
if [ -z "$BINARY" ]; then
    echo "❌ 错误: 未找到 agy 二进制文件"
    echo "请确认 Antigravity CLI 已安装，或手动指定路径："
    echo "  ./auto_patch_antigravity.sh /path/to/agy"
    exit 1
fi

# 检查是否已是修补版本（可选：通过校验和或字节比对）
# 这里简单检查偏移 0x1e9b508 处是否已经是 3a 00 00 14
CURRENT_BYTE=$(xxd -p -s 0x1e9b508 -l 4 "$BINARY" 2>/dev/null || echo "")
if [ "$CURRENT_BYTE" = "3a000014" ]; then
    echo "ℹ️  检测到已修补，跳过。"
    exit 0
fi

# 备份原文件
BACKUP="${BINARY}.bak"
if [ ! -f "$BACKUP" ]; then
    echo "📦 创建备份: $BACKUP"
    cp "$BINARY" "$BACKUP"
else
    echo "📦 备份已存在: $BACKUP"
fi

# 写入补丁字节
OFFSET=$((0x1e9b508))
echo "✏️  写入补丁到偏移 0x$(printf '%x' $OFFSET) ..."
printf "\x3a\x00\x00\x14" | dd of="$BINARY" bs=1 seek=$OFFSET conv=notrunc status=none
echo "✅ 补丁字节写入完成"

# 重新签名
echo "🔏 移除旧签名并重新签名 (ad-hoc) ..."
codesign --remove-signature "$BINARY" 2>/dev/null || true
codesign --sign - "$BINARY" || {
    echo "⚠️  签名失败，请检查证书或尝试 sudo"
    exit 1
}
echo "✅ 签名完成"

# 验证签名
echo "🔍 验证签名状态:"
codesign -vvv "$BINARY" 2>&1 | head -3

echo ""
echo "🎉 补丁成功！运行以下命令启动（禁用自动更新）:"
echo "   AGY_CLI_DISABLE_AUTO_UPDATE=1 $BINARY"
