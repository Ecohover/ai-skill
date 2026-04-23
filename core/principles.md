# 通用協作原則

> 適用於所有語言與專案。原則衝突時優先順序：**可讀性 > KISS > DRY > 抽象化**

## 專案目錄結構 (全語言通用)

所有語言的專案皆必須遵循以下大成標準根目錄配置：

| 目錄/路徑 | 職責 | 說明 |
|------|------|------|
| `doc/` | 技術文件與規格 | 存放架構圖、API 規格、需求文件等。 |
| `deploy/` | 部署設定 | Dockerfile, K8s manifests, CI/CD 腳本等。 |
| `src/` | 原始碼 | 所有的專案程式碼（包含語言特定的套件、模組）**必須**收斂在此目錄下。 |

## 程式碼結構 (原則)

| 約束 | 說明 |
|------|------|
| MUST | 一個類別/方法只做一件事（SRP）|
| MUST | 方法開頭使用 Guard Clauses 驗證參數，優先 Early Return |
| PREFER | 方法長度 50 行以內，最多 2-3 層嵌套 |
| PREFER | 不同方法/成員之間保留一行空行，禁止多餘連續空行 |

## 命名

| 約束 | 說明 |
|------|------|
| MUST | 布林命名以 `is`、`has`、`can`、`should` 開頭 |
| MUST | 方法命名動詞開頭（Get, Create, Update, Delete, Validate, Apply）|
| MUST NOT | Lambda / 回調參數使用 `x`、`i` 等無意義名稱，必須用業務語意名稱 |
| MUST NOT | 使用縮寫（公認縮寫除外：HTTP, JSON, API, URL, ID, DTO）|
| MUST NOT | 使用 `temp`、`data`、`info`、`obj` 等模糊名稱 |

### 語意識別規範

| 名稱 | 用途 | 說明 |
|------|------|------|
| `Id` | 機器識別（UUID/GUID/ObjectId）| 人類不可讀 |
| `Code` | 人類識別 | 英數、日期、簡單符號混合 |
| `Type` | 分類標記 | 必須用 Enum，傳輸/儲存用 string |

## 設計原則

| 約束 | 說明 |
|------|------|
| MUST | 透過建構函式注入依賴，禁止在方法內 `new` 依賴 |
| MUST NOT | 魔術數字，必須用 const 或 enum 命名 |
| MUST | 啟用 Nullable / Strict 型別檢查，明確處理 null |
| MUST | 重複邏輯超過 3 次才抽取（DRY）|
| PREFER | 優先選擇簡單方案（KISS）|

## 時間處理

| 約束 | 說明 |
|------|------|
| MUST | 服務內部與資料庫一律使用 UTC+0 |
| PREFER | 僅在 API 輸出給前端時轉換為當地時區 |
