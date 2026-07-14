# patch_antigravity.ps1 - Universal patch script for Windows Antigravity CLI
# Usage: .\patch_antigravity.ps1 [path\to\agy.exe]

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 1. Locate binary
$searchPaths = @(
    "$env:LOCALAPPDATA\agy\bin\agy.exe",
    "$env:USERPROFILE\AppData\Local\agy\bin\agy.exe"
)

$binary = $null
if ($args.Count -gt 0) {
    $binary = $args[0]
} else {
    foreach ($path in $searchPaths) {
        if (Test-Path $path) {
            $binary = $path
            Write-Host "✅ Found agy binary: $binary" -ForegroundColor Green
            break
        }
    }
}

if (-not $binary) {
    $cmd = Get-Command agy.exe -ErrorAction SilentlyContinue
    if ($cmd) {
        $binary = $cmd.Source
        Write-Host "✅ Found agy via PATH: $binary" -ForegroundColor Green
    }
}

if (-not $binary) {
    Write-Host "❌ Error: Could not locate agy binary." -ForegroundColor Red
    Write-Host "Please specify the path manually:" -ForegroundColor Yellow
    Write-Host "  .\patch_antigravity.ps1 -BinaryPath C:\path\to\agy.exe" -ForegroundColor Yellow
    exit 1
}

# Try running python patcher first
$pythonCmd = where.exe python 2>$null
if ($pythonCmd) {
    Write-Host "🔄 Running universal dynamic patcher via Python..." -ForegroundColor Cyan
    & python "$scriptDir\patch_antigravity.py" "$binary"
    exit $LASTEXITCODE
}

# Fallback to static patching
Write-Host "⚠️ Python not found. Falling back to static patching..." -ForegroundColor Yellow

$offset = 0x1e9b510
try {
    $bytes = [System.IO.File]::ReadAllBytes($binary)
    if ($bytes.Length -gt ($offset + 3)) {
        $current = $bytes[$offset..($offset+3)]
        if ($current[0] -eq 0x3A -and $current[1] -eq 0x00 -and $current[2] -eq 0x00 -and $current[3] -eq 0x14) {
            Write-Host "ℹ️ Binary is already patched (fallback check)." -ForegroundColor Yellow
            exit 0
        }
    }
} catch {}

# Backup
$backup = "$binary.bak"
if (-not (Test-Path $backup)) {
    Write-Host "📦 Creating backup: $backup" -ForegroundColor Cyan
    Copy-Item $binary $backup
}

# Write static bytes
$patchBytes = [byte[]]@(0x38, 0x00, 0x00, 0x14)
Write-Host "✏️ Writing static patch to offset 0x$($offset.ToString('X'))..." -ForegroundColor Cyan
try {
    $fs = [System.IO.File]::OpenWrite($binary)
    $fs.Seek($offset, [System.IO.SeekOrigin]::Begin) | Out-Null
    $fs.Write($patchBytes, 0, $patchBytes.Length)
    $fs.Close()
    Write-Host "🎉 Fallback patch successful!" -ForegroundColor Green
    Write-Host "Run with:" -ForegroundColor Yellow
    Write-Host "   `$env:AGY_CLI_DISABLE_AUTO_UPDATE=1; & `"$binary`"" -ForegroundColor White
} catch {
    Write-Host "❌ Write failed: $_" -ForegroundColor Red
    exit 1
}
