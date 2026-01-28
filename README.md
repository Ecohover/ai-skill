# AI Code Prompt 管理系統

這是一個用於 AI 協作開發的 Prompt 規則管理庫。
透過分層疊加 (Layered Stacking) 的方式，讓不同的 AI 工具 (Claude, Gemini) 都能載入統一的開發規範。

## 🚀 快速開始

### 1. 安裝客戶端

**Windows (PowerShell)**:
```powershell
cd clients\gemini
.\install.ps1
```

**Mac / Linux**:
```bash
cd clients/gemini
./install.sh
```

### 2. 使用指令

安裝後，您將擁有以下指令：

| 指令 | 說明 | 適用情境 |
|------|------|----------|
| **`gprompt`** | **(推薦)** 載入專案 Prompt 並啟動 AI | 開發特定專案、需要遵循規範時 |
| **`gemini`** | 啟動原生 Gemini CLI (不載入專案規則) | 閒聊、簡單問答、非開發任務 |

**首次在專案目錄執行 `gprompt` 時**，系統會跳出選單讓您選擇：
1.  **語言** (e.g., .NET, Python)
2.  **專案擴展** (e.g., DaChan, MyProject)
3.  **功能模組** (e.g., MongoDB, Redis)

設定完成後會產生 `.geminirules` 檔，之後該目錄就會自動套用這些規則。

---

## 📂 核心架構

Prompt 規則統一存放於此專案根目錄，供所有客戶端共用。

```
.
├── common/                     # Level 1: 通用規則 (Clean Code, 協作規範)
│   └── collaboration.md        # 所有專案都會載入這份
│
├── languages/                  # Level 2: 語言基礎規範
│   ├── dotnet/
│   │   ├── base.md             # .NET 基礎規範
│   │   └── extensions/         # Level 3: 專案特定擴展
│   │       └── dachan.md       # (選用) 大成專案特定架構
│   └── python/
│       └── ...
│
└── modules/                    # Level 4: 選用模組
    └── mongodb.md              # (選用) DB 設計規範
```

---

## 🛠 如何新增/修改 Prompt

### 1. 新增程式語言 (Language)
建立資料夾 `languages/<語言名稱>/` 並新增 `base.md`。

*   **路徑範例**: `languages/golang/base.md`
*   **內容建議**: 命名慣例、目錄結構、推薦的 Libraries。

### 2. 新增專案擴展 (Extension)
當某個專案有特定的架構要求 (如 Clean Architecture) 或私有套件引用規則時。

*   **路徑範例**: `languages/dotnet/extensions/my-app.md`
*   **支援動態變數**:
    可以在 Markdown 中使用 `{{VAR_NAME}}`。
    *   *Markdown 寫法*: `私有庫路徑: {{MY_LIB_PATH}}`
    *   *設定方式*: 首次載入時，Loader 會提示輸入該變數的值，並儲存在 `~/.gemini-prompts-config`。
    *   *(進階使用者需修改 `loader.ps1` / `loader.sh` 來註冊新的變數讀取邏輯)*

### 3. 新增功能模組 (Module)
針對特定技術棧的規範，可跨專案複用。

*   **路徑範例**: `modules/docker.md`
*   **內容建議**: Dockerfile 撰寫規範、Docker Compose 命名規則。

---

## ⚙️ 進階指令

| PowerShell 指令 | 說明 |
|-----------------|------|
| `Show-PromptStatus` | 查看當前目錄載入了哪些規則 |
| `Clear-LocalPrompt` | 刪除當前目錄的 `.geminirules` (以便重新選擇) |
| `Set-GlobalGeminiPrompt` | 設定全域預設 Prompt (不推薦，建議使用 gprompt) |