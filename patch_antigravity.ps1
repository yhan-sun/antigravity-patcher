# patch_antigravity.ps1 - 自动查找并修补 Windows 上的 Antigravity CLI
# 用法: 在 PowerShell 中运行 .\patch_antigravity.ps1
# 需要管理员权限（用于签名操作）

# 1. 查找 agy.exe
$searchPaths = @(
    "$env:LOCALAPPDATA\agy\bin\agy.exe",
    "$env:USERPROFILE\AppData\Local\agy\bin\agy.exe"
)

$binary = $null
foreach ($path in $searchPaths) {
    if (Test-Path $path) {
        $binary = $path
        Write-Host "✅ 找到 agy: $binary" -ForegroundColor Green
        break
    }
}

# 如果没找到，尝试用 Get-Command 查找
if (-not $binary) {
    $cmd = Get-Command agy.exe -ErrorAction SilentlyContinue
    if ($cmd) {
        $binary = $cmd.Source
        Write-Host "✅ 通过 PATH 找到 agy: $binary" -ForegroundColor Green
    }
}

if (-not $binary) {
    Write-Host "❌ 错误: 未找到 agy.exe" -ForegroundColor Red
    Write-Host "请确认 Antigravity CLI 已安装，或手动指定路径：" -ForegroundColor Yellow
    Write-Host "  .\patch_antigravity.ps1 -BinaryPath C:\path\to\agy.exe" -ForegroundColor Yellow
    exit 1
}

# 2. 检查是否已修补（偏移 0x1e9b508 处是否为 3A 00 00 14）
try {
    $bytes = [System.IO.File]::ReadAllBytes($binary)
    $offset = 0x1e9b508
    if ($bytes.Length -gt ($offset + 3)) {
        $current = $bytes[$offset..($offset+3)]
        if ($current[0] -eq 0x3A -and $current[1] -eq 0x00 -and $current[2] -eq 0x00 -and $current[3] -eq 0x14) {
            Write-Host "ℹ️  检测到已修补，跳过。" -ForegroundColor Yellow
            exit 0
        }
    }
} catch {
    # 读取失败则继续修补
}

# 3. 备份原文件
$backup = "$binary.bak"
if (-not (Test-Path $backup)) {
    Write-Host "📦 创建备份: $backup" -ForegroundColor Cyan
    Copy-Item $binary $backup
} else {
    Write-Host "📦 备份已存在: $backup" -ForegroundColor Cyan
}

# 4. 写入补丁字节
# 偏移: 0x1e9b508，原指令 cbz x7, 0x101e9b5f0 -> 改为 b 0x101e9b5f0
# 新指令编码: 0x1400003A (小端存储: 3A 00 00 14)
$offset = 0x1e9b508
$patchBytes = [byte[]]@(0x3A, 0x00, 0x00, 0x14)

Write-Host "✏️  写入补丁到偏移 0x$($offset.ToString('X')) ..." -ForegroundColor Cyan

try {
    $fs = [System.IO.File]::OpenWrite($binary)
    $fs.Seek($offset, [System.IO.SeekOrigin]::Begin) | Out-Null
    $fs.Write($patchBytes, 0, $patchBytes.Length)
    $fs.Close()
    Write-Host "✅ 补丁字节写入完成" -ForegroundColor Green
} catch {
    Write-Host "❌ 写入失败: $_" -ForegroundColor Red
    Write-Host "请尝试以管理员身份运行 PowerShell" -ForegroundColor Yellow
    exit 1
}

# 5. Windows 不需要 codesign，直接完成
Write-Host ""
Write-Host "🎉 补丁成功！" -ForegroundColor Green
Write-Host "运行以下命令启动（禁用自动更新）:" -ForegroundColor Yellow
Write-Host "   `$env:AGY_CLI_DISABLE_AUTO_UPDATE=1; & `"$binary`"" -ForegroundColor White
