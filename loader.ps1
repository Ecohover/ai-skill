# Claude Code Prompt 載入腳本
# 版本：v3.0 (可攜式)

# ============================================
# 配置區（動態路徑）
# ============================================
# 優先使用環境變數，否則使用腳本所在目錄
if ($env:CLAUDE_PROMPTS_PATH) {
    $PROMPTS_BASE_PATH = $env:CLAUDE_PROMPTS_PATH
} else {
    $PROMPTS_BASE_PATH = $PSScriptRoot
}

# ============================================
# 主函數：啟動 Claude Code
# ============================================
function Start-ClaudeWithPrompts {
    param(
        [Parameter(Mandatory=$false)]
        [string]$Language = "",

        [Parameter(Mandatory=$false)]
        [string]$Extension = "",

        [Parameter(Mandatory=$false)]
        [string[]]$Modules = @(),

        [Parameter(Mandatory=$false)]
        [switch]$Interactive,

        [Parameter(Mandatory=$false)]
        [switch]$Global  # 新增：設定為全域
    )

    # 互動模式
    if ([string]::IsNullOrEmpty($Language) -or $Interactive) {
        $Language = Select-Language
        if ([string]::IsNullOrEmpty($Language)) {
            Write-Host "已取消" -ForegroundColor Red
            return
        }
    }

    # 檢查語言目錄
    $languagePath = Join-Path $PROMPTS_BASE_PATH "languages\$Language"
    if (-not (Test-Path $languagePath)) {
        Write-Host "找不到語言目錄: $languagePath" -ForegroundColor Red
        return
    }

    # 選擇擴展
    if ([string]::IsNullOrEmpty($Extension) -or $Interactive) {
        $Extension = Select-Extension -LanguagePath $languagePath
    }

    # 選擇模組
    if ($Modules.Count -eq 0 -and $Interactive) {
        $Modules = Select-Modules
    }

    # 組合 Prompt
    $combinedPrompt = Build-CombinedPrompt -Language $Language -Extension $Extension -Modules $Modules

    if ([string]::IsNullOrEmpty($combinedPrompt)) {
        Write-Host "無法建立 Prompt" -ForegroundColor Red
        return
    }

    if ($Global) {
        # 全域模式：寫入 Claude 全域設定
        Set-GlobalPrompt -Prompt $combinedPrompt
        Write-Host ""
        Write-Host "已設定全域 Prompt:" -ForegroundColor Green
        Write-Host "   語言: $Language" -ForegroundColor Cyan
        if (-not [string]::IsNullOrEmpty($Extension)) {
            Write-Host "   擴展: $Extension" -ForegroundColor Cyan
        }
        if ($Modules.Count -gt 0) {
            Write-Host "   模組: $($Modules -join ', ')" -ForegroundColor Cyan
        }
        Write-Host ""
        Write-Host "此設定將套用於所有專案（除非有本地 .clauderules）" -ForegroundColor Yellow
    }
    else {
        # 本地模式：寫入 .clauderules
        $rulesFile = Join-Path (Get-Location) ".clauderules"
        Set-Content -Path $rulesFile -Value $combinedPrompt -Encoding UTF8

        Write-Host ""
        Write-Host "已載入 Prompt 規則:" -ForegroundColor Green
        Write-Host "   語言: $Language" -ForegroundColor Cyan
        if (-not [string]::IsNullOrEmpty($Extension)) {
            Write-Host "   擴展: $Extension" -ForegroundColor Cyan
        }
        if ($Modules.Count -gt 0) {
            Write-Host "   模組: $($Modules -join ', ')" -ForegroundColor Cyan
        }
        Write-Host "   檔案: $rulesFile" -ForegroundColor Gray
        Write-Host ""

        # 啟動 Claude Code
        claude
    }
}

# ============================================
# 設定全域 Prompt
# ============================================
function Set-GlobalPrompt {
    param([string]$Prompt)

    # 使用 claude config 設定全域 system prompt
    # 需要將換行轉換為單行（使用 \n）
    $escapedPrompt = $Prompt -replace "`r`n", "\n" -replace "`n", "\n"

    # 寫入全域 CLAUDE.md
    $globalClaudeDir = Join-Path $env:USERPROFILE ".claude"
    if (-not (Test-Path $globalClaudeDir)) {
        New-Item -ItemType Directory -Path $globalClaudeDir -Force | Out-Null
    }

    $globalClaudeMd = Join-Path $globalClaudeDir "CLAUDE.md"
    Set-Content -Path $globalClaudeMd -Value $Prompt -Encoding UTF8

    Write-Host "   已寫入: $globalClaudeMd" -ForegroundColor Gray
}

# ============================================
# 清除全域設定
# ============================================
function Clear-GlobalPrompt {
    $globalClaudeMd = Join-Path $env:USERPROFILE ".claude\CLAUDE.md"
    if (Test-Path $globalClaudeMd) {
        Remove-Item $globalClaudeMd -Force
        Write-Host "已清除全域 Prompt 設定" -ForegroundColor Green
    }
    else {
        Write-Host "沒有全域設定" -ForegroundColor Yellow
    }
}

# ============================================
# 顯示目前設定狀態
# ============================================
function Show-PromptStatus {
    Write-Host ""
    Write-Host "=== Prompt 設定狀態 ===" -ForegroundColor Cyan

    # 檢查全域
    $globalClaudeMd = Join-Path $env:USERPROFILE ".claude\CLAUDE.md"
    if (Test-Path $globalClaudeMd) {
        $content = Get-Content $globalClaudeMd -Raw -Encoding UTF8
        $firstLine = ($content -split "`n")[0]
        Write-Host "  [全域] $globalClaudeMd" -ForegroundColor Green
        Write-Host "         $firstLine" -ForegroundColor Gray
    }
    else {
        Write-Host "  [全域] 未設定" -ForegroundColor Yellow
    }

    # 檢查本地
    $localRules = Join-Path (Get-Location) ".clauderules"
    if (Test-Path $localRules) {
        $content = Get-Content $localRules -Raw -Encoding UTF8
        $firstLine = ($content -split "`n")[0]
        Write-Host "  [本地] $localRules" -ForegroundColor Green
        Write-Host "         $firstLine" -ForegroundColor Gray
    }
    else {
        Write-Host "  [本地] 未設定" -ForegroundColor Yellow
    }

    Write-Host ""
}

# ============================================
# 選擇語言
# ============================================
function Select-Language {
    Write-Host ""
    Write-Host "=== 選擇開發語言 ===" -ForegroundColor Cyan

    $langPath = Join-Path $PROMPTS_BASE_PATH "languages"
    $languages = Get-ChildItem -Path $langPath -Directory | Select-Object -ExpandProperty Name

    if ($languages.Count -eq 0) {
        Write-Host "找不到任何語言目錄" -ForegroundColor Red
        return ""
    }

    for ($i = 0; $i -lt $languages.Count; $i++) {
        Write-Host "  [$($i + 1)] $($languages[$i])" -ForegroundColor White
    }
    Write-Host "  [0] 取消" -ForegroundColor Gray

    $choice = Read-Host "請選擇"

    if ($choice -eq "0" -or [string]::IsNullOrEmpty($choice)) {
        return ""
    }

    $index = [int]$choice - 1
    if ($index -ge 0 -and $index -lt $languages.Count) {
        return $languages[$index]
    }

    return ""
}

# ============================================
# 選擇擴展
# ============================================
function Select-Extension {
    param([string]$LanguagePath)

    $extPath = Join-Path $LanguagePath "extensions"
    if (-not (Test-Path $extPath)) {
        return ""
    }

    $extensions = Get-ChildItem -Path $extPath -Filter "*.md" | Select-Object -ExpandProperty BaseName

    if ($extensions.Count -eq 0) {
        return ""
    }

    Write-Host ""
    Write-Host "=== 選擇專案擴展 ===" -ForegroundColor Cyan
    Write-Host "  [0] 僅使用基礎規範" -ForegroundColor Gray

    for ($i = 0; $i -lt $extensions.Count; $i++) {
        Write-Host "  [$($i + 1)] $($extensions[$i])" -ForegroundColor White
    }

    $choice = Read-Host "請選擇"

    if ($choice -eq "0" -or [string]::IsNullOrEmpty($choice)) {
        return ""
    }

    $index = [int]$choice - 1
    if ($index -ge 0 -and $index -lt $extensions.Count) {
        return $extensions[$index]
    }

    return ""
}

# ============================================
# 選擇模組
# ============================================
function Select-Modules {
    $modulesPath = Join-Path $PROMPTS_BASE_PATH "modules"
    if (-not (Test-Path $modulesPath)) {
        return @()
    }

    $modules = Get-ChildItem -Path $modulesPath -Filter "*.md" | Select-Object -ExpandProperty BaseName

    if ($modules.Count -eq 0) {
        return @()
    }

    Write-Host ""
    Write-Host "=== 選擇額外模組 (多選，空白結束) ===" -ForegroundColor Cyan

    for ($i = 0; $i -lt $modules.Count; $i++) {
        Write-Host "  [$($i + 1)] $($modules[$i])" -ForegroundColor White
    }
    Write-Host "  [0] 完成選擇" -ForegroundColor Gray

    $selected = @()

    while ($true) {
        $choice = Read-Host "請選擇"

        if ($choice -eq "0" -or [string]::IsNullOrEmpty($choice)) {
            break
        }

        $index = [int]$choice - 1
        if ($index -ge 0 -and $index -lt $modules.Count) {
            $moduleName = $modules[$index]
            if ($selected -notcontains $moduleName) {
                $selected += $moduleName
                Write-Host "   已加入: $moduleName" -ForegroundColor Green
            }
        }
    }

    return $selected
}

# ============================================
# 組合 Prompt
# ============================================
function Build-CombinedPrompt {
    param(
        [string]$Language,
        [string]$Extension,
        [string[]]$Modules
    )

    $promptParts = @()
    $separator = "`n`n---`n`n"

    Write-Host ""
    Write-Host "載入中..." -ForegroundColor Gray

    # 0. 加入 metadata 標頭
    $modulesStr = if ($Modules.Count -gt 0) { $Modules -join ", " } else { "none" }
    $extensionStr = if ([string]::IsNullOrEmpty($Extension)) { "none" } else { $Extension }
    $metadata = @"
<!-- PROMPT CONFIG
Language: $Language
Extension: $extensionStr
Modules: $modulesStr
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
-->

"@
    $promptParts += $metadata

    # 1. 載入 common
    $commonPath = Join-Path $PROMPTS_BASE_PATH "common"
    if (Test-Path $commonPath) {
        $commonFiles = Get-ChildItem -Path $commonPath -Filter "*.md"
        foreach ($file in $commonFiles) {
            $content = Get-Content $file.FullName -Raw -Encoding UTF8
            $promptParts += $content
            Write-Host "   [common] $($file.Name)" -ForegroundColor Gray
        }
    }

    # 2. 載入語言基礎
    $basePath = Join-Path $PROMPTS_BASE_PATH "languages\$Language\base.md"
    if (Test-Path $basePath) {
        $content = Get-Content $basePath -Raw -Encoding UTF8
        $promptParts += $content
        Write-Host "   [base] $Language/base.md" -ForegroundColor Gray
    }

    # 3. 載入擴展
    if (-not [string]::IsNullOrEmpty($Extension)) {
        $extPath = Join-Path $PROMPTS_BASE_PATH "languages\$Language\extensions\$Extension.md"
        if (Test-Path $extPath) {
            $content = Get-Content $extPath -Raw -Encoding UTF8
            $promptParts += $content
            Write-Host "   [extension] $Extension.md" -ForegroundColor Gray
        }
    }

    # 4. 載入模組
    foreach ($module in $Modules) {
        $modulePath = Join-Path $PROMPTS_BASE_PATH "modules\$module.md"
        if (Test-Path $modulePath) {
            $content = Get-Content $modulePath -Raw -Encoding UTF8
            $promptParts += $content
            Write-Host "   [module] $module.md" -ForegroundColor Gray
        }
    }

    return ($promptParts -join $separator)
}

# ============================================
# 重新載入 Prompt（不啟動 claude）
# ============================================
function Set-ClaudePrompt {
    param(
        [Parameter(Mandatory=$false)]
        [string]$Language = "",

        [Parameter(Mandatory=$false)]
        [string]$Extension = "",

        [Parameter(Mandatory=$false)]
        [string[]]$Modules = @(),

        [Parameter(Mandatory=$false)]
        [switch]$Global
    )

    # 互動模式
    if ([string]::IsNullOrEmpty($Language)) {
        $Language = Select-Language
        if ([string]::IsNullOrEmpty($Language)) {
            Write-Host "已取消" -ForegroundColor Red
            return
        }
        $Extension = Select-Extension -LanguagePath (Join-Path $PROMPTS_BASE_PATH "languages\$Language")
        $Modules = Select-Modules
    }

    # 組合 Prompt
    $combinedPrompt = Build-CombinedPrompt -Language $Language -Extension $Extension -Modules $Modules

    if ([string]::IsNullOrEmpty($combinedPrompt)) {
        Write-Host "無法建立 Prompt" -ForegroundColor Red
        return
    }

    if ($Global) {
        Set-GlobalPrompt -Prompt $combinedPrompt
        Write-Host ""
        Write-Host "已更新全域 Prompt" -ForegroundColor Green
    }
    else {
        $rulesFile = Join-Path (Get-Location) ".clauderules"
        Set-Content -Path $rulesFile -Value $combinedPrompt -Encoding UTF8
        Write-Host ""
        Write-Host "已更新本地 .clauderules" -ForegroundColor Green
        Write-Host "請在 Claude 中輸入 /refresh 重新載入規則" -ForegroundColor Yellow
    }
}

# ============================================
# 別名設定
# ============================================
Set-Alias ccp Start-ClaudeWithPrompts
Set-Alias csp Set-ClaudePrompt

# 快速啟動
function Start-ClaudeDotnet {
    param(
        [string]$Extension = "",
        [string[]]$Modules = @(),
        [switch]$Global
    )
    Start-ClaudeWithPrompts -Language "dotnet" -Extension $Extension -Modules $Modules -Global:$Global -Interactive:($Extension -eq "")
}

function Start-ClaudePython {
    param(
        [string]$Extension = "",
        [string[]]$Modules = @(),
        [switch]$Global
    )
    Start-ClaudeWithPrompts -Language "python" -Extension $Extension -Modules $Modules -Global:$Global -Interactive:($Extension -eq "")
}

Set-Alias ccpd Start-ClaudeDotnet
Set-Alias ccpp Start-ClaudePython

# ============================================
# 歡迎訊息
# ============================================
Write-Host ""
Write-Host "Claude Prompt 系統已就緒 (v3.0)" -ForegroundColor Green
Write-Host "  路徑: $PROMPTS_BASE_PATH" -ForegroundColor Gray
Write-Host ""
Write-Host "啟動指令：" -ForegroundColor Cyan
Write-Host "  ccp                   # 互動式選擇並啟動" -ForegroundColor White
Write-Host "  ccpd                  # 快速啟動 .NET" -ForegroundColor White
Write-Host "  ccpp                  # 快速啟動 Python" -ForegroundColor White
Write-Host ""
Write-Host "設定指令（不啟動 claude）：" -ForegroundColor Cyan
Write-Host "  csp                   # 切換/更新 prompt 設定" -ForegroundColor White
Write-Host "  Show-PromptStatus     # 查看目前設定" -ForegroundColor White
Write-Host "  Clear-GlobalPrompt    # 清除全域設定" -ForegroundColor White
Write-Host ""
Write-Host "全域設定：" -ForegroundColor Cyan
Write-Host "  ccpd -Global          # 設定 .NET 為全域預設" -ForegroundColor Gray
Write-Host "  csp -Global           # 切換全域設定" -ForegroundColor Gray
Write-Host ""
