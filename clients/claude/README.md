# Claude Code Prompt Client

這是 **AI Code Prompt 管理系統** 的 Claude 客戶端。
它會攔截 `claude` 指令，讓您在啟動 Claude CLI 前選擇要載入的 Prompt。

## 安裝

### Windows (PowerShell)

```powershell
# 進入目錄
cd clients\claude

# 執行安裝
.\install.ps1
```

### Mac / Linux (Bash/Zsh)

```bash
# 進入目錄
cd clients/claude

# 給予執行權限並安裝
chmod +x install.sh
./install.sh

# 重新載入設定
source ~/.zshrc  # 或 ~/.bashrc
```

## 使用方式

安裝後，直接使用 `claude` 指令即可。

```bash
claude              # 互動模式：詢問是否載入 Prompt
claude -s           # Skip：跳過 Prompt，直接使用原生 Claude
claude -p           # Prompt：強制重新選擇 Prompt
```

## 輔助指令

| PowerShell | Bash | 說明 |
|------------|------|------|
| `Show-PromptStatus` | `show_prompt_status` | 查看目前設定 |
| `Set-GlobalClaudePrompt` | `set_global_claude_prompt` | 設定全域 Prompt |
| `Set-ExtensionConfig` | `set_extension_config` | 設定擴展參數 |
| `Clear-LocalPrompt` | `clear_local_prompt` | 刪除本地設定 |
| `Clear-GlobalPrompt` | `clear_global_prompt` | 刪除全域設定 |

## 檔案位置

| 類型 | 路徑 | 說明 |
|------|------|------|
| **本地規則** | `./.clauderules` | 當前專案的 Prompt 緩存 |
| **全域規則** | `~/.claude/CLAUDE.md` | 全域預設規則 |
| **設定檔** | `~/.claude-prompts-config` | 儲存擴展變數 |

## 解除安裝

**Windows:**
```powershell
.\install.ps1 -Uninstall
```

**Mac/Linux:**
```bash
./install.sh --uninstall
```
