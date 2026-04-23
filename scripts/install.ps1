# AI Prompt Generator - Install Script (Windows PowerShell)

param(
    [switch]$Uninstall
)

$scriptDir      = $PSScriptRoot
$projectRoot    = (Resolve-Path "$scriptDir\..").Path
$generateScript = Join-Path $scriptDir "generate.ps1"
$envVarName     = "PROMPTS_PATH"
$markerBegin    = "# BEGIN AI Prompt Generator"
$markerEnd      = "# END AI Prompt Generator"

# ============================================
# Uninstall
# ============================================
if ($Uninstall) {
    Write-Host ""
    Write-Host "=== Uninstalling AI Prompt Generator ===" -ForegroundColor Cyan

    [Environment]::SetEnvironmentVariable($envVarName, $null, "User")
    Write-Host "  Removed: $envVarName" -ForegroundColor Green

    if (Test-Path $PROFILE) {
        $lines    = Get-Content $PROFILE -Encoding UTF8
        $inside   = $false
        $filtered = [System.Collections.Generic.List[string]]::new()
        foreach ($line in $lines) {
            if ($line -eq $markerBegin) { $inside = $true;  continue }
            if ($line -eq $markerEnd)   { $inside = $false; continue }
            if (-not $inside) { $filtered.Add($line) }
        }
        Set-Content -Path $PROFILE -Value $filtered -Encoding UTF8
        Write-Host "  Removed aprompt from: $PROFILE" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "Done. Please restart PowerShell." -ForegroundColor Green
    Write-Host ""
    return
}

# ============================================
# Install
# ============================================
Write-Host ""
Write-Host "=== Installing AI Prompt Generator ===" -ForegroundColor Cyan
Write-Host ""

# 1. Environment variable
Write-Host "[1/2] Setting environment variable..." -ForegroundColor White
[Environment]::SetEnvironmentVariable($envVarName, $projectRoot, "User")
$env:PROMPTS_PATH = $projectRoot
Write-Host "  $envVarName = $projectRoot" -ForegroundColor Green

# 2. PowerShell Profile
Write-Host ""
Write-Host "[2/2] Updating PowerShell Profile..." -ForegroundColor White

$profileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

$existing = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($existing -and $existing.Contains($markerBegin)) {
    Write-Host "  aprompt already installed, skipping." -ForegroundColor Yellow
} else {
    $line2 = '$env:PROMPTS_PATH = "' + $projectRoot + '"'
    $line3 = 'function aprompt { & "' + $generateScript + '" @args }'
    Add-Content -Path $PROFILE -Value ""            -Encoding UTF8
    Add-Content -Path $PROFILE -Value $markerBegin  -Encoding UTF8
    Add-Content -Path $PROFILE -Value $line2        -Encoding UTF8
    Add-Content -Path $PROFILE -Value $line3        -Encoding UTF8
    Add-Content -Path $PROFILE -Value $markerEnd    -Encoding UTF8
    Write-Host "  Added aprompt to: $PROFILE" -ForegroundColor Green
}

# Done
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Done! Restart PowerShell, then run from any project folder:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  aprompt" -ForegroundColor White
Write-Host ""
Write-Host "  To uninstall: .\install.ps1 -Uninstall" -ForegroundColor DarkGray
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
