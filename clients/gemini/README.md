# Gemini Code Prompt Client

這是 **AI Code Prompt 管理系統** 的 Gemini 客戶端。
它會攔截 `gemini` 指令，讓您在啟動 Gemini CLI 前選擇要載入的 Prompt (Context)。

## 安裝 (Windows PowerShell)

```powershell
# 進入目錄
cd clients\gemini

# 執行安裝
.\install.ps1

# 安裝後請重新開啟 PowerShell
```

> **注意**：目前僅支援 Windows PowerShell。

## 使用方式

安裝後，直接使用 `gemini` 指令即可。

```powershell
gemini              # 互動模式：詢問是否載入 Prompt
gemini -s           # Skip：跳過 Prompt，直接使用原生 Gemini
gemini -p           # Prompt：強制重新選擇 Prompt
```

### 運作原理

1. 腳本會檢查當前目錄是否有 `.geminirules`。
2. 檢查全域是否有 `~/.gemini/GEMINI.md`。
3. 如果都沒有，會跳出選單讓您選擇：
   *   **語言** (對應 `/languages/{lang}`)
   *   **專案擴展** (對應 `/languages/{lang}/extensions/{ext}`)
   *   **模組** (對應 `/modules/{mod}`)
4. 選擇後的 Prompt 會被組合併儲存，傳遞給 Gemini CLI。

## 輔助指令

這些指令在 PowerShell 中可用：

| 指令 | 說明 |
|------|------|
| `Show-PromptStatus` | 查看目前生效的設定 (本地 .geminirules 或全域設定) |
| `Set-GlobalGeminiPrompt` | 設定 **全域** Prompt (儲存於 `~/.gemini/GEMINI.md`) |
| `Set-ExtensionConfig` | 設定擴展參數 (例如設定 dachan 的專案路徑) |
| `Clear-LocalPrompt` | 刪除當前目錄的 `.geminirules` |
| `Clear-GlobalPrompt` | 刪除全域設定檔 |

## 檔案位置

| 類型 | 路徑 | 說明 |
|------|------|------|
| **本地規則** | `./.geminirules` | 當前專案的 Prompt 緩存 |
| **全域規則** | `~/.gemini/GEMINI.md` | 使用 `Set-GlobalGeminiPrompt` 設定的預設規則 |
| **設定檔** | `~/.gemini-prompts-config` | 儲存擴展變數 (如路徑設定) |

## 解除安裝

```powershell
.\install.ps1 -Uninstall
```
