# Gemini Prompts install script
param([switch]$Uninstall)
$scriptDir = $PSScriptRoot
$projectRoot = (Resolve-Path "$PSScriptRoot\..\..").Path
$loaderPath = Join-Path $scriptDir "loader.ps1"
$envVarName = "GEMINI_PROMPTS_PATH"
$profileLine = ". `"$loaderPath`""
$configFile = Join-Path $env:USERPROFILE ".gemini-prompts-config"
if ($Uninstall) {
    Write-Host "Uninstalling Gemini Prompts..." -ForegroundColor Cyan
    [Environment]::SetEnvironmentVariable($envVarName, $null, "User")
    if (Test-Path $configFile) { Remove-Item $configFile -Force }
    if (Test-Path $PROFILE) {
        $profileContent = Get-Content $PROFILE -Raw -Encoding UTF8
        if ($profileContent -match [regex]::Escape($loaderPath)) {
            $newContent = $profileContent -replace "# Gemini Prompts Loader", ""
            $newContent = $newContent -replace [regex]::Escape($profileLine), ""
            Set-Content -Path $PROFILE -Value $newContent.Trim() -Encoding UTF8
        }
    }
    Write-Host "Done." -ForegroundColor Green
    return
}
Write-Host "Installing Gemini Prompts..." -ForegroundColor Cyan
[Environment]::SetEnvironmentVariable($envVarName, $projectRoot, "User")
$env:GEMINI_PROMPTS_PATH = $projectRoot
$profileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force | Out-Null }
$profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($profileContent -and $profileContent.Contains($loaderPath)) {
    Write-Host "Profile already contains loader." -ForegroundColor Yellow
} else {
    Add-Content -Path $PROFILE -Value ""
    Add-Content -Path $PROFILE -Value "# Gemini Prompts Loader"
    Add-Content -Path $PROFILE -Value $profileLine
    Write-Host "Added to Profile: $PROFILE" -ForegroundColor Green
}
Write-Host "Installation complete! Please restart PowerShell." -ForegroundColor Green
