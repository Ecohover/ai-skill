# Claude Code Prompt 載入腳本
# 版本：v4.1 (支援擴展設定)

# ============================================
# 配置區（動態路徑）
# ============================================
if ($env:CLAUDE_PROMPTS_PATH) {
    $PROMPTS_BASE_PATH = $env:CLAUDE_PROMPTS_PATH
} else {
    $PROMPTS_BASE_PATH = (Resolve-Path "$PSScriptRoot\..\..").Path
}

# 設定檔路徑
$script:CONFIG_FILE = Join-Path $env:USERPROFILE ".claude-prompts-config"

# 儲存原生 claude 指令路徑
$script:CLAUDE_NATIVE = (Get-Command claude -CommandType Application -ErrorAction SilentlyContinue).Source

# ============================================
# 設定檔管理
# ============================================
function Get-PromptConfig {
    param([string]$Key)

    if (-not (Test-Path $script:CONFIG_FILE)) {
        return $null
    }

    $config = Get-Content $script:CONFIG_FILE -Encoding UTF8 | Where-Object { $_ -match "^$Key=" }
    if ($config) {
        return ($config -replace "^$Key=", "").Trim()
    }
    return $null
}

function Set-PromptConfig {
    param(
        [string]$Key,
        [string]$Value
    )

    $lines = @()
    $found = $false

    if (Test-Path $script:CONFIG_FILE) {
        $lines = @(Get-Content $script:CONFIG_FILE -Encoding UTF8)
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match "^$Key=") {
                $lines[$i] = "$Key=$Value"
                $found = $true
                break
            }
        }
    }

    if (-not $found) {
        $lines += "$Key=$Value"
    }

    Set-Content -Path $script:CONFIG_FILE -Value $lines -Encoding UTF8
}

function Get-ExtensionConfig {
    param([string]$Extension)

    # 根據 extension 名稱取得需要的設定
    switch ($Extension.ToLower()) {
        "dachan" {
            $commonUtilsPath = Get-PromptConfig -Key "DACHAN_COMMONUTILS_PATH"

            if ([string]::IsNullOrEmpty($commonUtilsPath)) {
                Write-Host ""
                Write-Host "=== Dachan 擴展設定 ===" -ForegroundColor Cyan
                Write-Host "首次使用需要設定 CommonUtils 專案路徑" -ForegroundColor Yellow
                Write-Host ""
                $commonUtilsPath = Read-Host "請輸入 CommonUtils 專案路徑"

                if (-not [string]::IsNullOrEmpty($commonUtilsPath)) {
                    Set-PromptConfig -Key "DACHAN_COMMONUTILS_PATH" -Value $commonUtilsPath
                    Write-Host "已儲存設定" -ForegroundColor Green
                }
            }

            return @{
                "DACHAN_COMMONUTILS_PATH" = $commonUtilsPath
            }
        }
        default {
            return @{}
        }
    }
}

# ============================================
# 主函數：覆蓋 claude 指令
# ============================================
function claude {
    param(
        [Parameter(Position=0, ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )

    # 檢查是否有 --skip 或 -s 參數
    if ($Arguments -contains "--skip" -or $Arguments -contains "-s") {
        $filteredArgs = $Arguments | Where-Object { $_ -ne "--skip" -and $_ -ne "-s" }
        Write-Host "啟動原生 Claude..." -ForegroundColor Gray
        & $script:CLAUDE_NATIVE @filteredArgs
        return
    }

    # 檢查是否有 --prompt 或 -p 參數（強制選擇 prompt）
    $forcePrompt = $Arguments -contains "--prompt" -or $Arguments -contains "-p"
    if ($forcePrompt) {
        $Arguments = $Arguments | Where-Object { $_ -ne "--prompt" -and $_ -ne "-p" }
    }

    # 檢查本地是否已有 .clauderules
    $localRules = Join-Path (Get-Location) ".clauderules"
    $hasLocalRules = Test-Path $localRules

    # 檢查全域是否已有設定
    $globalRules = Join-Path $env:USERPROFILE ".claude\CLAUDE.md"
    $hasGlobalRules = Test-Path $globalRules

    # 決定是否需要選擇 prompt
    if ($forcePrompt -or (-not $hasLocalRules -and -not $hasGlobalRules)) {
        # 詢問用戶
        Write-Host ""
        Write-Host "=== Claude Prompt 設定 ===" -ForegroundColor Cyan
        Write-Host "  [1] 選擇 Prompt 規則" -ForegroundColor White
        Write-Host "  [2] 不使用 Prompt（原生模式）" -ForegroundColor White
        if ($hasGlobalRules) {
            Write-Host "  [3] 使用全域設定" -ForegroundColor White
        }
        Write-Host ""

        $choice = Read-Host "請選擇"

        switch ($choice) {
            "1" {
                # 互動選擇 prompt
                $language = Select-Language
                if ([string]::IsNullOrEmpty($language)) {
                    Write-Host "已取消，啟動原生 Claude..." -ForegroundColor Yellow
                    & $script:CLAUDE_NATIVE @Arguments
                    return
                }

                $languagePath = Join-Path $PROMPTS_BASE_PATH "languages\$language"
                $extension = Select-Extension -LanguagePath $languagePath
                $modules = Select-Modules

                $combinedPrompt = Build-CombinedPrompt -Language $language -Extension $extension -Modules $modules
                Set-Content -Path $localRules -Value $combinedPrompt -Encoding UTF8

                Write-Host ""
                Write-Host "已載入 Prompt: $language" -ForegroundColor Green
                if (-not [string]::IsNullOrEmpty($extension)) {
                    Write-Host "   擴展: $extension" -ForegroundColor Cyan
                }
            }
            "2" {
                Write-Host "啟動原生 Claude..." -ForegroundColor Gray
                & $script:CLAUDE_NATIVE @Arguments
                return
            }
            "3" {
                if ($hasGlobalRules) {
                    Write-Host "使用全域設定..." -ForegroundColor Gray
                } else {
                    Write-Host "啟動原生 Claude..." -ForegroundColor Gray
                }
                & $script:CLAUDE_NATIVE @Arguments
                return
            }
            default {
                Write-Host "啟動原生 Claude..." -ForegroundColor Gray
                & $script:CLAUDE_NATIVE @Arguments
                return
            }
        }
    } elseif ($hasLocalRules) {
        # 顯示目前使用的設定
        $firstLines = Get-Content $localRules -TotalCount 5 -Encoding UTF8
        $configLine = $firstLines | Where-Object { $_ -match "^Language:" }
        if ($configLine) {
            Write-Host "使用本地 Prompt: $($configLine -replace 'Language:\s*', '')" -ForegroundColor Gray
        }
    } elseif ($hasGlobalRules) {
        Write-Host "使用全域 Prompt 設定" -ForegroundColor Gray
    }

    Write-Host ""
    & $script:CLAUDE_NATIVE @Arguments
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
    Write-Host "=== 選擇額外模組 (多選，Enter 結束) ===" -ForegroundColor Cyan

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
    $configValues = @{}

    Write-Host ""
    Write-Host "載入中..." -ForegroundColor Gray

    # 取得擴展設定（如果有）
    if (-not [string]::IsNullOrEmpty($Extension)) {
        $configValues = Get-ExtensionConfig -Extension $Extension
    }

    # Metadata
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

            # 替換佔位符
            foreach ($key in $configValues.Keys) {
                $placeholder = "{{$key}}"
                $value = $configValues[$key]
                if ([string]::IsNullOrEmpty($value)) {
                    $value = "(未設定)"
                }
                $content = $content -replace [regex]::Escape($placeholder), $value
            }

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
# 設定全域 Prompt
# ============================================
function Set-GlobalPrompt {
    param([string]$Prompt)

    $globalClaudeDir = Join-Path $env:USERPROFILE ".claude"
    if (-not (Test-Path $globalClaudeDir)) {
        New-Item -ItemType Directory -Path $globalClaudeDir -Force | Out-Null
    }

    $globalClaudeMd = Join-Path $globalClaudeDir "CLAUDE.md"
    Set-Content -Path $globalClaudeMd -Value $Prompt -Encoding UTF8

    Write-Host "   已寫入: $globalClaudeMd" -ForegroundColor Gray
}

# ============================================
# 輔助指令
# ============================================

# 清除本地 prompt
function Clear-LocalPrompt {
    $localRules = Join-Path (Get-Location) ".clauderules"
    if (Test-Path $localRules) {
        Remove-Item $localRules -Force
        Write-Host "已清除本地 .clauderules" -ForegroundColor Green
    } else {
        Write-Host "沒有本地設定" -ForegroundColor Yellow
    }
}

# 清除全域 prompt
function Clear-GlobalPrompt {
    $globalClaudeMd = Join-Path $env:USERPROFILE ".claude\CLAUDE.md"
    if (Test-Path $globalClaudeMd) {
        Remove-Item $globalClaudeMd -Force
        Write-Host "已清除全域 Prompt 設定" -ForegroundColor Green
    } else {
        Write-Host "沒有全域設定" -ForegroundColor Yellow
    }
}

# 顯示目前設定狀態
function Show-PromptStatus {
    Write-Host ""
    Write-Host "=== Prompt 設定狀態 ===" -ForegroundColor Cyan

    $globalClaudeMd = Join-Path $env:USERPROFILE ".claude\CLAUDE.md"
    if (Test-Path $globalClaudeMd) {
        $content = Get-Content $globalClaudeMd -TotalCount 5 -Encoding UTF8
        $langLine = $content | Where-Object { $_ -match "^Language:" }
        Write-Host "  [全域] $globalClaudeMd" -ForegroundColor Green
        if ($langLine) {
            Write-Host "         $langLine" -ForegroundColor Gray
        }
    } else {
        Write-Host "  [全域] 未設定" -ForegroundColor Yellow
    }

    $localRules = Join-Path (Get-Location) ".clauderules"
    if (Test-Path $localRules) {
        $content = Get-Content $localRules -TotalCount 5 -Encoding UTF8
        $langLine = $content | Where-Object { $_ -match "^Language:" }
        Write-Host "  [本地] $localRules" -ForegroundColor Green
        if ($langLine) {
            Write-Host "         $langLine" -ForegroundColor Gray
        }
    } else {
        Write-Host "  [本地] 未設定" -ForegroundColor Yellow
    }

    # 顯示擴展設定
    if (Test-Path $script:CONFIG_FILE) {
        Write-Host ""
        Write-Host "=== 擴展設定 ===" -ForegroundColor Cyan
        Get-Content $script:CONFIG_FILE -Encoding UTF8 | ForEach-Object {
            Write-Host "  $_" -ForegroundColor Gray
        }
    }

    Write-Host ""
}

# 設定全域 prompt（互動）
function Set-GlobalClaudePrompt {
    $language = Select-Language
    if ([string]::IsNullOrEmpty($language)) {
        Write-Host "已取消" -ForegroundColor Red
        return
    }

    $languagePath = Join-Path $PROMPTS_BASE_PATH "languages\$language"
    $extension = Select-Extension -LanguagePath $languagePath
    $modules = Select-Modules

    $combinedPrompt = Build-CombinedPrompt -Language $language -Extension $extension -Modules $modules
    Set-GlobalPrompt -Prompt $combinedPrompt

    Write-Host ""
    Write-Host "已設定全域 Prompt: $language" -ForegroundColor Green
    Write-Host "此設定將套用於所有專案（除非有本地 .clauderules）" -ForegroundColor Yellow
}

# 設定擴展參數
function Set-ExtensionConfig {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Extension
    )

    switch ($Extension.ToLower()) {
        "dachan" {
            Write-Host ""
            Write-Host "=== 設定 Dachan 擴展 ===" -ForegroundColor Cyan
            $currentPath = Get-PromptConfig -Key "DACHAN_COMMONUTILS_PATH"
            if ($currentPath) {
                Write-Host "目前設定: $currentPath" -ForegroundColor Gray
            }
            $newPath = Read-Host "請輸入 CommonUtils 專案路徑 (空白保留原設定)"
            if (-not [string]::IsNullOrEmpty($newPath)) {
                Set-PromptConfig -Key "DACHAN_COMMONUTILS_PATH" -Value $newPath
                Write-Host "已更新設定" -ForegroundColor Green
            }
        }
        default {
            Write-Host "未知的擴展: $Extension" -ForegroundColor Red
        }
    }
}

# ============================================
# 歡迎訊息（僅首次顯示）
# ============================================
if (-not $env:CLAUDE_PROMPT_LOADED) {
    $env:CLAUDE_PROMPT_LOADED = "1"
    Write-Host ""
    Write-Host "Claude Prompt 系統已就緒 (v4.1)" -ForegroundColor Green
    Write-Host ""
    Write-Host "使用方式：" -ForegroundColor Cyan
    Write-Host "  claude              # 自動詢問是否載入 prompt" -ForegroundColor White
    Write-Host "  claude -s           # 跳過 prompt，使用原生模式" -ForegroundColor White
    Write-Host "  claude -p           # 強制重新選擇 prompt" -ForegroundColor White
    Write-Host ""
    Write-Host "輔助指令：" -ForegroundColor Cyan
    Write-Host "  Show-PromptStatus            # 查看目前設定" -ForegroundColor Gray
    Write-Host "  Set-GlobalClaudePrompt       # 設定全域 prompt" -ForegroundColor Gray
    Write-Host "  Set-ExtensionConfig dachan   # 設定擴展參數" -ForegroundColor Gray
    Write-Host "  Clear-LocalPrompt            # 清除本地設定" -ForegroundColor Gray
    Write-Host "  Clear-GlobalPrompt           # 清除全域設定" -ForegroundColor Gray
    Write-Host ""
}
