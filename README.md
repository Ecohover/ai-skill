# AI Code Prompt 管理系統

這是一個用於 AI 協作開發的 Prompt 規則管理庫。
透過分層疊加 (Layered Stacking) 的方式，讓不同的 AI 工具 (Claude, Gemini) 都能載入統一的開發規範。

## 支援的 AI 客戶端

請進入對應資料夾查看安裝說明：

*   **[Gemini Client](./clients/gemini/README.md)** (Windows PowerShell)
*   **[Claude Client](./clients/claude/README.md)** (Windows / Mac / Linux)

## 核心架構

Prompt 規則統一存放於此專案根目錄，供所有客戶端共用。

```
.
├── common/                     # Level 1: 通用規則 (Clean Code, 協作規範)
│   └── collaboration.md
│
├── languages/                  # Level 2: 語言基礎規範
│   ├── dotnet/
│   │   ├── base.md
│   │   └── extensions/         # Level 3: 專案特定擴展 (架構, 私有庫)
│   │       └── dachan.md
│   └── python/
│       └── ...
│
└── modules/                    # Level 4: 選用模組 (DB, 工具庫)
    └── mongodb.md
```

## 組合邏輯

當您使用客戶端工具 (如 `gemini` 或 `claude`) 選擇 Prompt 時，系統會依照以下順序組合檔案：

1.  **Metadata**: 自動生成的標頭 (時間、配置資訊)。
2.  **Common**: 載入 `common/` 下的所有 `.md` 檔案。
3.  **Language Base**: 載入 `languages/{selected_lang}/base.md`。
4.  **Extension (Optional)**: 載入 `languages/{selected_lang}/extensions/{selected_ext}.md`。
    *   支援變數替換 (如 `{{DACHAN_COMMONUTILS_PATH}}`)。
5.  **Modules (Optional)**: 載入 `modules/{selected_mod}.md`。

## 如何新增規則

### 新增語言 (Language)
1. 在 `languages/` 下建立新資料夾 (如 `golang`)。
2. 建立 `base.md`，定義該語言的基礎開發規範。

### 新增擴展 (Extension)
1. 在語言資料夾下的 `extensions/` 目錄中建立 `.md` 檔案 (如 `dachan.md`)。
2. 若需要動態路徑，可使用 `{{VAR_NAME}}` 佔位符，並在客戶端的 `loader` 腳本中設定對應邏輯。

### 新增模組 (Module)
1. 在 `modules/` 下建立 `.md` 檔案。
2. 模組應盡量設計為「跨語言通用」或「技術特定但語言無關」的規範 (如 SQL 命名規範)。
