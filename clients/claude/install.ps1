# Claude Prompts 安裝腳本
# 用途：設定環境變數並加入 PowerShell Profile

param(
    [switch]$Uninstall
)

$scriptDir = $PSScriptRoot
$projectRoot = (Resolve-Path "$PSScriptRoot\..\..").Path
$loaderPath = Join-Path $scriptDir "loader.ps1"
$envVarName = "CLAUDE_PROMPTS_PATH"
$profileLine = ". `"$loaderPath`""
$configFile = Join-Path $env:USERPROFILE ".claude-prompts-config"

# ============================================
# 解除安裝
# ============================================
if ($Uninstall) {
    Write-Host ""
    Write-Host "=== 解除安裝 Claude Prompts ===" -ForegroundColor Cyan

    # 移除環境變數
    [Environment]::SetEnvironmentVariable($envVarName, $null, "User")
    Write-Host "  已移除環境變數: $envVarName" -ForegroundColor Green

    # 移除設定檔
    if (Test-Path $configFile) {
        Remove-Item $configFile -Force
        Write-Host "  已移除設定檔: $configFile" -ForegroundColor Green
    }

    # 自動從 Profile 移除
    if (Test-Path $PROFILE) {
        $profileContent = Get-Content $PROFILE -Raw -Encoding UTF8
        if ($profileContent -match [regex]::Escape($loaderPath)) {
            $newContent = $profileContent -replace "# Claude Prompts Loader\r?\n", ""
            $newContent = $newContent -replace [regex]::Escape($profileLine) + "\r?\n?", ""
            Set-Content -Path $PROFILE -Value $newContent.Trim() -Encoding UTF8
            Write-Host "  已從 Profile 移除載入腳本" -ForegroundColor Green
        }
    }

    Write-Host ""
    Write-Host "解除安裝完成！請重新開啟 PowerShell。" -ForegroundColor Green
    Write-Host ""
    return
}

# ============================================
# 安裝
# ============================================
Write-Host ""
Write-Host "=== 安裝 Claude Prompts ===" -ForegroundColor Cyan
Write-Host ""

# 1. 設定環境變數
Write-Host "[1/3] 設定環境變數..." -ForegroundColor White
[Environment]::SetEnvironmentVariable($envVarName, $projectRoot, "User")
$env:CLAUDE_PROMPTS_PATH = $projectRoot
Write-Host "  $envVarName = $projectRoot" -ForegroundColor Green

# 2. 檢查 Profile 是否存在
Write-Host ""
Write-Host "[2/3] 設定 PowerShell Profile..." -ForegroundColor White

$profileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    Write-Host "  已建立 Profile: $PROFILE" -ForegroundColor Gray
}

# 3. 加入 loader 到 Profile（如果尚未加入）
$profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($profileContent -and $profileContent.Contains($loaderPath)) {
    Write-Host "  Profile 已包含 loader，跳過" -ForegroundColor Yellow
} else {
    Add-Content -Path $PROFILE -Value "`n# Claude Prompts Loader"
    Add-Content -Path $PROFILE -Value $profileLine
    Write-Host "  已加入 Profile: $PROFILE" -ForegroundColor Green
}

# 完成
Write-Host ""
Write-Host "[3/3] 安裝完成！" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "請重新開啟 PowerShell 視窗，然後使用：" -ForegroundColor Yellow
Write-Host ""
Write-Host "  ccp     # 互動式選擇並啟動 Claude" -ForegroundColor White
Write-Host "  ccpd    # 快速啟動 .NET" -ForegroundColor White
Write-Host "  ccpp    # 快速啟動 Python" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
