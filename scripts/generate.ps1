# AI Prompt 產生工具（核心腳本）
# 用途：選擇語言/擴展/模組，組合成 .prompt.md 輸出至當前目錄

# 支援透過環境變數或相對路徑取得 Repo 根目錄
if ($env:PROMPTS_PATH) {
    $PROMPTS_BASE = $env:PROMPTS_PATH
} else {
    $PROMPTS_BASE = (Resolve-Path "$PSScriptRoot\..").Path
}

# ============================================
# 輔助函數
# ============================================

function Get-Languages {
    Get-ChildItem -Path "$PROMPTS_BASE\languages" -Directory |
        Select-Object -ExpandProperty Name
}

function Get-Extensions {
    param([string]$Language)
    $extPath = "$PROMPTS_BASE\languages\$Language\extensions"
    if (Test-Path $extPath) {
        Get-ChildItem -Path $extPath -Filter "*.md" |
            Select-Object -ExpandProperty BaseName
    } else {
        @()
    }
}

function Get-Modules {
    Get-ChildItem -Path "$PROMPTS_BASE\modules" -Filter "*.md" |
        Select-Object -ExpandProperty BaseName
}

function Show-Menu {
    param(
        [string]$Title,
        [string[]]$Options,
        [switch]$AllowSkip,
        [switch]$MultiSelect
    )

    Write-Host ""
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host "  $("-" * $Title.Length)" -ForegroundColor DarkGray

    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host "  [$($i + 1)] $($Options[$i])" -ForegroundColor White
    }
    if ($AllowSkip) {
        Write-Host "  [0] 跳過" -ForegroundColor DarkGray
    }
    Write-Host ""

    if ($MultiSelect) {
        $raw = Read-Host "  選項（多個用逗號分隔，0 跳過）"
        if ($raw -eq "0" -or [string]::IsNullOrWhiteSpace($raw)) { return @() }

        $result = @()
        foreach ($part in $raw.Split(',')) {
            $n = $part.Trim()
            if ($n -match '^\d+$') {
                $idx = [int]$n - 1
                if ($idx -ge 0 -and $idx -lt $Options.Count) {
                    $result += $Options[$idx]
                }
            }
        }
        return $result
    } else {
        $raw = Read-Host "  選項"
        if ($raw -eq "0" -or [string]::IsNullOrWhiteSpace($raw)) { return $null }
        if ($raw -match '^\d+$') {
            $idx = [int]$raw - 1
            if ($idx -ge 0 -and $idx -lt $Options.Count) { return $Options[$idx] }
        }
        Write-Host "  無效輸入，已跳過。" -ForegroundColor Yellow
        return $null
    }
}

# 從源文件中提取 <!-- RULES --> 區塊（到 <!-- PATTERNS --> 或檔尾）
# 若無標記，將整份內容視為規則
function Extract-RulesSection {
    param([string]$Content)
    if ($Content -notmatch '<!-- RULES -->') {
        return $Content.Trim()
    }
    if ($Content -match '(?s)<!-- RULES -->(.*?)(?=<!-- PATTERNS -->|\z)') {
        return $Matches[1].Trim()
    }
    return ""
}

# 從源文件中提取 <!-- PATTERNS --> 區塊（到檔尾）
function Extract-PatternsSection {
    param([string]$Content)
    if ($Content -match '(?s)<!-- PATTERNS -->(.*?)\z') {
        return $Matches[1].Trim()
    }
    return ""
}

function Build-Prompt {
    param(
        [string]$Language,
        [string]$Extension,
        [string[]]$Modules
    )

    $extDisplay = if ([string]::IsNullOrEmpty($Extension)) { "none" } else { $Extension }
    $modDisplay = if ($Modules.Count -eq 0) { "none" } else { $Modules -join ", " }
    $generated  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # 依層序收集源文件路徑
    $sourceFiles = @()
    $f = "$PROMPTS_BASE\common\collaboration.md"
    if (Test-Path $f) { $sourceFiles += $f }

    $f = "$PROMPTS_BASE\languages\$Language\base.md"
    if (Test-Path $f) { $sourceFiles += $f }

    if (-not [string]::IsNullOrEmpty($Extension)) {
        $f = "$PROMPTS_BASE\languages\$Language\extensions\$Extension.md"
        if (Test-Path $f) { $sourceFiles += $f }
    }

    foreach ($mod in $Modules) {
        $f = "$PROMPTS_BASE\modules\$mod.md"
        if (Test-Path $f) { $sourceFiles += $f }
    }

    # 兩段式收集：先收 RULES，再收 PATTERNS
    $rulesBlocks    = @()
    $patternsBlocks = @()

    foreach ($file in $sourceFiles) {
        $raw = Get-Content $file -Raw -Encoding UTF8
        $rules = Extract-RulesSection -Content $raw
        if (-not [string]::IsNullOrWhiteSpace($rules)) {
            $rulesBlocks += $rules
        }
        $patterns = Extract-PatternsSection -Content $raw
        if (-not [string]::IsNullOrWhiteSpace($patterns)) {
            $patternsBlocks += $patterns
        }
    }

    # 組合輸出
    $sep = "`n`n---`n`n"

    # META 只放 ASCII（動態值），避免腳本編碼問題
    $meta = "<!-- PROMPT_META`nLanguage: $Language`nExtension: $extDisplay`nModules: $modDisplay`nGenerated: $generated`n-->"

    # 靜態 header（含中文）從檔案讀取，明確指定 UTF-8
    $headerFile = "$PROMPTS_BASE\templates\prompt-header.md"
    $header = if (Test-Path $headerFile) {
        (Get-Content $headerFile -Raw -Encoding UTF8).Trim()
    } else { "" }

    $output = $meta + "`n`n" + $header + "`n`n---`n`n# RULES`n`n"
    $output += ($rulesBlocks -join $sep)

    if ($patternsBlocks.Count -gt 0) {
        $output += "$sep# PATTERNS$sep"
        $output += ($patternsBlocks -join $sep)
    }

    return $output
}

# ============================================
# Main
# ============================================

Write-Host ""
Write-Host "========================================"  -ForegroundColor Cyan
Write-Host "        AI Prompt 產生工具"               -ForegroundColor Cyan
Write-Host "========================================"  -ForegroundColor Cyan

# 1. 語言
$langs = @(Get-Languages)
if ($langs.Count -eq 0) { Write-Host "找不到任何語言定義。" -ForegroundColor Red; exit 1 }
$lang = Show-Menu -Title "選擇語言" -Options $langs
if ($null -eq $lang) { Write-Host "已取消。" -ForegroundColor Yellow; exit 0 }

# 2. 專案擴展（選用）
$exts = @(Get-Extensions -Language $lang)
$ext  = $null
if ($exts.Count -gt 0) {
    $ext = Show-Menu -Title "選擇專案擴展（選用）" -Options $exts -AllowSkip
}

# 3. 功能模組（選用，複選）
$allMods      = @(Get-Modules)
$selectedMods = @()
if ($allMods.Count -gt 0) {
    $selectedMods = @(Show-Menu -Title "選擇功能模組（選用，可複選）" -Options $allMods -AllowSkip -MultiSelect)
}

# 4. 產生並寫出至當前目錄
$outputFile = Join-Path (Get-Location).Path ".prompt.md"
$content = Build-Prompt -Language $lang -Extension $ext -Modules $selectedMods
Set-Content -Path $outputFile -Value $content -Encoding UTF8

Write-Host ""
Write-Host "========================================"  -ForegroundColor Green
Write-Host "  已產生：$outputFile"                    -ForegroundColor Green
Write-Host "  語言　：$lang"                          -ForegroundColor White
if (-not [string]::IsNullOrEmpty($ext))  { Write-Host "  擴展　：$ext"                       -ForegroundColor White }
if ($selectedMods.Count -gt 0)           { Write-Host "  模組　：$($selectedMods -join ', ')" -ForegroundColor White }
Write-Host "========================================"  -ForegroundColor Green
Write-Host ""
