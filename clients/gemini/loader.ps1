# Gemini Code Prompt Loader Script
# Version: v4.1 (Extension Support)

# ============================================
# Configuration Area (Dynamic Paths)
# ============================================
if ($env:GEMINI_PROMPTS_PATH) {
    $PROMPTS_BASE_PATH = $env:GEMINI_PROMPTS_PATH
} else {
    $PROMPTS_BASE_PATH = (Resolve-Path "$PSScriptRoot\..\..").Path
}

# Config file path
$script:CONFIG_FILE = Join-Path $env:USERPROFILE ".gemini-prompts-config"

# Store native gemini command path
$nativeCommands = Get-Command gemini -CommandType Application -ErrorAction SilentlyContinue
if ($nativeCommands -is [array]) {
    $script:GEMINI_NATIVE = $nativeCommands[0].Source
} elseif ($nativeCommands) {
    $script:GEMINI_NATIVE = $nativeCommands.Source
} else {
    $script:GEMINI_NATIVE = $null
}

# ============================================
# Config Management
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

    # Get config based on extension name
    switch ($Extension.ToLower()) {
        "dachan" {
            $commonUtilsPath = Get-PromptConfig -Key "DACHAN_COMMONUTILS_PATH"

            if ([string]::IsNullOrEmpty($commonUtilsPath)) {
                Write-Host ""
                Write-Host "=== Dachan Extension Setup ===" -ForegroundColor Cyan
                Write-Host "First time setup: CommonUtils project path is required." -ForegroundColor Yellow
                Write-Host ""
                $commonUtilsPath = Read-Host "Enter CommonUtils Project Path"

                if (-not [string]::IsNullOrEmpty($commonUtilsPath)) {
                    Set-PromptConfig -Key "DACHAN_COMMONUTILS_PATH" -Value $commonUtilsPath
                    Write-Host "Config saved." -ForegroundColor Green
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
# Main Function: gprompt (Gemini Prompt Loader)
# ============================================
function gprompt {
    param(
        [Parameter(Position=0, ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )

    # Check local rules
    $localRules = Join-Path (Get-Location) ".geminirules"
    $hasLocalRules = Test-Path $localRules

    # Check global rules
    $globalRules = Join-Path $env:USERPROFILE ".gemini\GEMINI.md"
    $hasGlobalRules = Test-Path $globalRules

    # Check Always Ask config
    $alwaysAsk = (Get-PromptConfig -Key "ALWAYS_ASK_PROMPT") -eq "true"

    # Decide whether to select prompt
    # Logic: If Always Ask is ON, OR if Local Rules are MISSING, show the menu.
    # We want gprompt to be the tool for setting up local rules, so if they don't exist, ask.
    if ($alwaysAsk -or -not $hasLocalRules) {
        # Ask user
        Write-Host ""
        Write-Host "=== Gemini Prompt Setup ===" -ForegroundColor Cyan
        
        if ($hasLocalRules) {
            Write-Host "  [0] Use Local Rules (.geminirules)" -ForegroundColor Green
        }
        
        Write-Host "  [1] Select/Create New Rules" -ForegroundColor White
        Write-Host "  [2] No Prompt (Native Mode)" -ForegroundColor White
        
        if ($hasGlobalRules) {
            Write-Host "  [3] Use Global Config" -ForegroundColor White
        }
        Write-Host ""

        $choice = Read-Host "Select"

        switch ($choice) {
            "0" {
                if ($hasLocalRules) {
                    Write-Host "Using Local Rules..." -ForegroundColor Gray
                } else {
                    Write-Host "Invalid selection." -ForegroundColor Red
                    return
                }
            }
            "1" {
                # Interactive prompt selection
                $language = Select-Language
                if ([string]::IsNullOrEmpty($language)) {
                    Write-Host "Cancelled." -ForegroundColor Yellow
                    return
                }

                $languagePath = Join-Path $PROMPTS_BASE_PATH "languages\$language"
                $extension = Select-Extension -LanguagePath $languagePath
                $modules = Select-Modules

                $combinedPrompt = Build-CombinedPrompt -Language $language -Extension $extension -Modules $modules
                Set-Content -Path $localRules -Value $combinedPrompt -Encoding UTF8

                Write-Host ""
                Write-Host "Prompt Loaded: $language" -ForegroundColor Green
                if (-not [string]::IsNullOrEmpty($extension)) {
                    Write-Host "   Extension: $extension" -ForegroundColor Cyan
                }
            }
            "2" {
                Write-Host "Starting native Gemini..." -ForegroundColor Gray
                if ($script:GEMINI_NATIVE) { & $script:GEMINI_NATIVE @Arguments }
                return
            }
            "3" {
                if ($hasGlobalRules) {
                    Write-Host "Using Global Config..." -ForegroundColor Gray
                    if ($script:GEMINI_NATIVE) { & $script:GEMINI_NATIVE @Arguments }
                    return
                } else {
                    Write-Host "Global config not found." -ForegroundColor Red
                    return
                }
            }
            default {
                if ($hasLocalRules -and [string]::IsNullOrEmpty($choice)) {
                     Write-Host "Using Local Rules..." -ForegroundColor Gray
                } else {
                    Write-Host "Starting native Gemini..." -ForegroundColor Gray
                    if ($script:GEMINI_NATIVE) { & $script:GEMINI_NATIVE @Arguments }
                    return
                }
            }
        }
    } elseif ($hasLocalRules) {
        # Show current config from metadata
        $metadata = Get-Content $localRules -TotalCount 10 -Encoding UTF8
        $lang = ($metadata | Where-Object { $_ -match "^Language:" } | Out-String).Trim() -replace "Language:\s*", ""
        $ext  = ($metadata | Where-Object { $_ -match "^Extension:" } | Out-String).Trim() -replace "Extension:\s*", ""
        $mods = ($metadata | Where-Object { $_ -match "^Modules:" } | Out-String).Trim() -replace "Modules:\s*", ""

        Write-Host ""
        Write-Host "=== Loading Local Prompt Context ===" -ForegroundColor Cyan
        Write-Host "  Language:  $lang" -ForegroundColor White
        Write-Host "  Extension: $ext" -ForegroundColor White
        Write-Host "  Modules:   $mods" -ForegroundColor White
        Write-Host "  Path:      $localRules" -ForegroundColor Gray
        Write-Host "====================================" -ForegroundColor Cyan
    } elseif ($hasGlobalRules) {
        Write-Host "Using Global Prompt Config" -ForegroundColor Gray
    }

    Write-Host ""
    if ($script:GEMINI_NATIVE) {
        & $script:GEMINI_NATIVE @Arguments
    } else {
        Write-Host "Error: Native gemini command not found." -ForegroundColor Red
    }
}

# ============================================
# Select Language
# ============================================
function Select-Language {
    Write-Host ""
    Write-Host "=== Select Language ===" -ForegroundColor Cyan

    $langPath = Join-Path $PROMPTS_BASE_PATH "languages"
    $languages = Get-ChildItem -Path $langPath -Directory | Select-Object -ExpandProperty Name

    if ($languages.Count -eq 0) {
        Write-Host "No language directories found." -ForegroundColor Red
        return ""
    }

    for ($i = 0; $i -lt $languages.Count; $i++) {
        Write-Host "  [$($i + 1)] $($languages[$i])" -ForegroundColor White
    }
    Write-Host "  [0] Cancel" -ForegroundColor Gray

    $choice = Read-Host "Select"

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
# Select Extension
# ============================================
function Select-Extension {
    param([string]$LanguagePath)

    $extPath = Join-Path $LanguagePath "extensions"
    if (-not (Test-Path $extPath)) {
        return ""
    }

    $extensions = @(Get-ChildItem -Path $extPath -Filter "*.md" | Select-Object -ExpandProperty BaseName)

    if ($extensions.Count -eq 0) {
        return ""
    }

    Write-Host ""
    Write-Host "=== Select Extension ===" -ForegroundColor Cyan
    Write-Host "  [0] Base Only" -ForegroundColor Gray

    for ($i = 0; $i -lt $extensions.Count; $i++) {
        Write-Host "  [$($i + 1)] $($extensions[$i])" -ForegroundColor White
    }

    $choice = Read-Host "Select"

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
# Select Modules
# ============================================
function Select-Modules {
    $modulesPath = Join-Path $PROMPTS_BASE_PATH "modules"
    if (-not (Test-Path $modulesPath)) {
        return @()
    }

    $modules = @(Get-ChildItem -Path $modulesPath -Filter "*.md" | Select-Object -ExpandProperty BaseName)

    if ($modules.Count -eq 0) {
        return @()
    }

    Write-Host ""
    Write-Host "=== Select Extra Modules (Multiple, Enter to finish) ===" -ForegroundColor Cyan

    for ($i = 0; $i -lt $modules.Count; $i++) {
        Write-Host "  [$($i + 1)] $($modules[$i])" -ForegroundColor White
    }
    Write-Host "  [0] Done" -ForegroundColor Gray

    $selected = @()

    while ($true) {
        $choice = Read-Host "Select"

        if ($choice -eq "0" -or [string]::IsNullOrEmpty($choice)) {
            break
        }

        $index = [int]$choice - 1
        if ($index -ge 0 -and $index -lt $modules.Count) {
            $moduleName = $modules[$index]
            if ($selected -notcontains $moduleName) {
                $selected += $moduleName
                Write-Host "   Added: $moduleName" -ForegroundColor Green
            }
        }
    }

    return $selected
}

# ============================================
# Build Combined Prompt
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
    Write-Host "Loading..." -ForegroundColor Gray

    # Get extension config if any
    if (-not [string]::IsNullOrEmpty($Extension)) {
        $configValues = Get-ExtensionConfig -Extension $Extension
    }

    # Metadata
    $modulesStr = if ($Modules.Count -gt 0) { $Modules -join ", " } else { "none" }
    $extensionStr = if ([string]::IsNullOrEmpty($Extension)) { "none" } else { $Extension }
    
    # Use string concatenation instead of Here-String to avoid parsing issues
    $metadata = "<!-- PROMPT CONFIG`n" +
                "Language: $Language`n" +
                "Extension: $extensionStr`n" +
                "Modules: $modulesStr`n" +
                "Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")`n" +
                "-->`n"

    $promptParts += $metadata

    # 1. Load common
    $commonPath = Join-Path $PROMPTS_BASE_PATH "common"
    if (Test-Path $commonPath) {
        $commonFiles = Get-ChildItem -Path $commonPath -Filter "*.md"
        foreach ($file in $commonFiles) {
            $content = Get-Content $file.FullName -Raw -Encoding UTF8
            $promptParts += $content
            Write-Host "   [common] $($file.Name)" -ForegroundColor Gray
        }
    }

    # 2. Load base language
    $basePath = Join-Path $PROMPTS_BASE_PATH "languages\$Language\base.md"
    if (Test-Path $basePath) {
        $content = Get-Content $basePath -Raw -Encoding UTF8
        $promptParts += $content
        Write-Host "   [base] $Language/base.md" -ForegroundColor Gray
    }

    # 3. Load extension
    if (-not [string]::IsNullOrEmpty($Extension)) {
        $extPath = Join-Path $PROMPTS_BASE_PATH "languages\$Language\extensions\$Extension.md"
        if (Test-Path $extPath) {
            $content = Get-Content $extPath -Raw -Encoding UTF8

            # Replace placeholders
            foreach ($key in $configValues.Keys) {
                $placeholder = "{{$key}}"
                $value = $configValues[$key]
                if ([string]::IsNullOrEmpty($value)) {
                    $value = "(Not Set)"
                }
                $content = $content -replace [regex]::Escape($placeholder), $value
            }

            $promptParts += $content
            Write-Host "   [extension] $Extension.md" -ForegroundColor Gray
        }
    }

    # 4. Load modules
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
# Set Global Prompt
# ============================================
function Set-GlobalPrompt {
    param([string]$Prompt)

    $globalGeminiDir = Join-Path $env:USERPROFILE ".gemini"
    if (-not (Test-Path $globalGeminiDir)) {
        New-Item -ItemType Directory -Path $globalGeminiDir -Force | Out-Null
    }

    $globalGeminiMd = Join-Path $globalGeminiDir "GEMINI.md"
    Set-Content -Path $globalGeminiMd -Value $Prompt -Encoding UTF8

    Write-Host "   Written to: $globalGeminiMd" -ForegroundColor Gray
}

# ============================================
# Helper Commands
# ============================================

# Clear local prompt
function Clear-LocalPrompt {
    $localRules = Join-Path (Get-Location) ".geminirules"
    if (Test-Path $localRules) {
        Remove-Item $localRules -Force
        Write-Host "Cleared local .geminirules" -ForegroundColor Green
    } else {
        Write-Host "No local rules found." -ForegroundColor Yellow
    }
}

# Clear global prompt
function Clear-GlobalPrompt {
    $globalGeminiMd = Join-Path $env:USERPROFILE ".gemini\GEMINI.md"
    if (Test-Path $globalGeminiMd) {
        Remove-Item $globalGeminiMd -Force
        Write-Host "Cleared Global Prompt settings." -ForegroundColor Green
    } else {
        Write-Host "No global settings found." -ForegroundColor Yellow
    }
}

# Show current status
function Show-PromptStatus {
    Write-Host ""
    Write-Host "=== Gemini Prompt Status ===" -ForegroundColor Cyan

    $globalGeminiMd = Join-Path $env:USERPROFILE ".gemini\GEMINI.md"
    if (Test-Path $globalGeminiMd) {
        $content = Get-Content $globalGeminiMd -TotalCount 5 -Encoding UTF8
        $langLine = $content | Where-Object { $_ -match "^Language:" }
        Write-Host "  [Global] $globalGeminiMd" -ForegroundColor Green
        if ($langLine) {
            Write-Host "           $langLine" -ForegroundColor Gray
        }
    } else {
        Write-Host "  [Global] Not Set" -ForegroundColor Yellow
    }

    $localRules = Join-Path (Get-Location) ".geminirules"
    if (Test-Path $localRules) {
        $content = Get-Content $localRules -TotalCount 5 -Encoding UTF8
        $langLine = $content | Where-Object { $_ -match "^Language:" }
        Write-Host "  [Local]  $localRules" -ForegroundColor Green
        if ($langLine) {
            Write-Host "           $langLine" -ForegroundColor Gray
        }
    } else {
        Write-Host "  [Local]  Not Set" -ForegroundColor Yellow
    }

    # Show extension config
    if (Test-Path $script:CONFIG_FILE) {
        Write-Host ""
        Write-Host "=== Extension Config ===" -ForegroundColor Cyan
        Get-Content $script:CONFIG_FILE -Encoding UTF8 | ForEach-Object {
            Write-Host "  $_" -ForegroundColor Gray
        }
    }

    Write-Host ""
}

# Set global prompt (Interactive)
function Set-GlobalGeminiPrompt {
    $language = Select-Language
    if ([string]::IsNullOrEmpty($language)) {
        Write-Host "Cancelled" -ForegroundColor Red
        return
    }

    $languagePath = Join-Path $PROMPTS_BASE_PATH "languages\$language"
    $extension = Select-Extension -LanguagePath $languagePath
    $modules = Select-Modules

    $combinedPrompt = Build-CombinedPrompt -Language $language -Extension $extension -Modules $modules
    Set-GlobalPrompt -Prompt $combinedPrompt

    Write-Host ""
    Write-Host "Global Prompt Set: $language" -ForegroundColor Green
    Write-Host "This setting applies to all projects (unless .geminirules exists)." -ForegroundColor Yellow
}

# Set extension config
function Set-ExtensionConfig {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Extension
    )

    switch ($Extension.ToLower()) {
        "dachan" {
            Write-Host ""
            Write-Host "=== Set Dachan Extension Config ===" -ForegroundColor Cyan
            $currentPath = Get-PromptConfig -Key "DACHAN_COMMONUTILS_PATH"
            if ($currentPath) {
                Write-Host "Current: $currentPath" -ForegroundColor Gray
            }
            $newPath = Read-Host "Enter CommonUtils path (empty to keep current)"
            if (-not [string]::IsNullOrEmpty($newPath)) {
                Set-PromptConfig -Key "DACHAN_COMMONUTILS_PATH" -Value $newPath
                Write-Host "Config Updated" -ForegroundColor Green
            }
        }
        default {
            Write-Host "Unknown extension: $Extension" -ForegroundColor Red
        }
    }
}

# Set Always Ask Mode
function Set-AskMode {
    param([switch]$Off)

    if ($Off) {
        Set-PromptConfig -Key "ALWAYS_ASK_PROMPT" -Value "false"
        Write-Host "Always Ask Mode: OFF (Auto-load existing rules)" -ForegroundColor Yellow
    } else {
        Set-PromptConfig -Key "ALWAYS_ASK_PROMPT" -Value "true"
        Write-Host "Always Ask Mode: ON (Will ask every time)" -ForegroundColor Green
    }
}

# ============================================
# Welcome Message (First time only)
# ============================================
if (-not $env:GEMINI_PROMPT_LOADED) {
    $env:GEMINI_PROMPT_LOADED = "1"
    Write-Host ""
    Write-Host "Gemini Prompt System Ready (v4.3)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Cyan
    Write-Host "  gemini              # Run native Gemini CLI" -ForegroundColor White
    Write-Host "  gprompt             # Load prompt context & run Gemini" -ForegroundColor White
    Write-Host ""
    Write-Host "Helper Commands:" -ForegroundColor Cyan
    Write-Host "  Show-PromptStatus            # Show current status" -ForegroundColor Gray
    Write-Host "  Set-AskMode                  # Toggle 'Always Ask' mode" -ForegroundColor Gray
    Write-Host "  Set-GlobalGeminiPrompt       # Set global prompt" -ForegroundColor Gray
    Write-Host "  Set-ExtensionConfig dachan   # Set extension config" -ForegroundColor Gray
    Write-Host "  Clear-LocalPrompt            # Clear local rules" -ForegroundColor Gray
    Write-Host "  Clear-GlobalPrompt           # Clear global rules" -ForegroundColor Gray
    Write-Host ""
}
