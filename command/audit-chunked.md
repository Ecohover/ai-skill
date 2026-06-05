# 分批程式碼稽核流程

本流程提供 Code Inspector 使用，目的不是加更多規則，而是把現有規則拆成**低風險、可重複、低上下文壓力**的檢查步驟。

---

## 0. 稽核前整理

在讀任何程式碼前，先建立本次稽核矩陣：

| 維度 | 說明 |
|------|------|
| Rule Family | A, B, C, D, E, T |
| Language | .NET / TypeScript / Python |
| Package/Profile | 例如 `common-utils`、`unit-profile`，無則填 N/A |
| Package/Module | 例如 `Controllers`、`Services`、`composables/api/modules` |
| File Batch | 本輪要讀的 3-5 個檔案 |

輸出格式建議：

```md
Batch A1
- Rule Family: A. 結構與邊界
- Language: TypeScript
- Package: composables/api/modules
- Files: Warehouse.ts, api-client.ts
- Source Rules:
  - core/principles.md
  - language/typescript/base.md
  - language/typescript/custom/api-module.md
  - command/audit-typescript.md
```

---

## 1. 規則族分組

同類行為放同批，不同判斷維度拆批。

### A. 結構與邊界

檢查是否放在正確目錄、層級責任是否正確、是否越界。

- `core/principles.md`
- `AGENT.md`
- `language/[lang]/base.md`
- `package/[common-package]/*.md`（如適用）
- `unit/[unit-profile]/*.md`（如適用）
- `language/[lang]/custom/structure*.md` 或框架結構檔

適合一起檢查的例子：
- TypeScript: View / router / store / API module 邊界
- .NET: Controller / Service / Factory / Entity 分層
- Python: router / service / schema / model / factory 分層
- 單一資料夾超過 10 個檔案時，是否已先詢問使用者確認分層方式

### B. 型別、資料模型、合約

檢查型別安全、DTO/schema/interface、API 回傳與欄位型別。

- `core/api-contract.md`（如適用）
- `language/[lang]/base.md`
- `package/[common-package]/api-response.md`（如適用）
- `unit/[unit-profile]/package-profile.md`（如適用）
- `command/audit-[lang].md`

適合一起檢查的例子：
- TypeScript: `any`、API 回傳 interface、shared 型別引用
- .NET: DTO 命名、集合型別、Enum 集合型別
- Python: type hints、Pydantic DTO 命名、response_model

### C. 命名與可讀性

檢查命名、布林命名、方法命名、無意義參數、註解文件化。

- `core/principles.md`
- `language/[lang]/base.md`
- `command/audit-[lang].md`

適合一起檢查的例子：
- 布林命名
- handler / composable / service 方法命名
- lambda 參數語意
- XML docstring / Google docstring
- .NET 一個 `.cs` 檔案是否只定義一個主要型別

### D. 依賴、設定、環境、時間

檢查 DI、環境變數讀取方式、時間處理、外部依賴邊界。

- `core/principles.md`
- `language/[lang]/custom/env*.md`
- `language/[lang]/custom/di*.md`
- `package/[common-package]/environment.md`（如適用）
- `language/[lang]/framework*.md`
- `command/audit-[lang].md`

適合一起檢查的例子：
- .NET constructor injection / private field naming / DI order / env enum / audit initialize
- TypeScript `import.meta.env.VITE_*` / runtime config / base URL
- Python `Depends` / `BaseSettings` / async IO

### E. 框架/套件特規

檢查語言或套件特定規則，避免與其他規則群混在同批。

- TypeScript:
  - lazy route import
  - Tailwind / Element Plus
  - store 只放共享狀態
  - searches `"Field:value"`
- .NET:
  - partial service
  - `*.Logging.cs` + `[LoggerMessage]`
  - `.IfPresent()` / `.IfNotNull()`
  - 採用共用套件 audit 欄位時呼叫 `InitializeAudit()`
- Python:
  - FastAPI router 僅處理 request/response
  - custom exception + exception_handler
  - async database access

### T. 測試與驗證

檢查本次變更是否依風險導向測試策略執行，避免把測試充分性與 coding style 混在同批。

- `core/agent-mandates.md`
- `role/planner.md`
- `role/builder.md`
- `role/reviewer.md`
- plan doc 的測試策略與 Implementation Record（如適用）

適合一起檢查的例子：
- Bug fix 是否先重現失敗並補 regression test。
- 核心邏輯、API contract、資料轉換、權限、金流、同步、排程、環境設定是否先測試。
- 測試是否覆蓋行為，而不是只鎖定實作細節。
- 無測試時是否有合理原因與替代驗證。

---

## 2. 每批讀取策略

### 2.1 先讀規則，再讀命中檔案

每一批都依序做：

1. 選定 `Rule Family`
2. 選定 `Language`
3. 選定 `Package/Module`
4. 載入最少規則集合
5. 只讀本批相關的 3-5 個檔案
6. 每檔只讀命中區塊與必要前後文

### 2.2 單批讀檔上限

- 小檔：可完整讀 1-2 個。
- 中檔：每檔讀 80-200 行區塊。
- 大檔：先切成多批，不得一次完整讀。
- 若檔案跨多個規則群，仍只在本批處理一個規則群。

### 2.3 區塊切分方式

優先順序：

1. 先讀變更 diff 或命中片段
2. 再讀宣告區（class/function/interface/router）
3. 最後才補讀相依區塊

---

## 3. 建議批次順序

以下順序可降低誤判，因為先確定邊界，再看細節：

1. `A. 結構與邊界`
2. `B. 型別、資料模型、合約`
3. `C. 命名與可讀性`
4. `D. 依賴、設定、環境、時間`
5. `E. 框架/套件特規`
6. `T. 測試與驗證`

若是計畫任務，最前面先加：

0. `P. 計畫符合性`
- 只看 plan 範圍、檔案清單、驗收條件。
- 此批不進行語言審查。

---

## 4. 依語言的拆批模板

### TypeScript

| 批次 | Rule Family | Package/Module | 主要來源 |
|------|-------------|----------------|----------|
| A1 | 結構與邊界 | `views/`, `router/` | `core/principles.md`, `language/typescript/base.md` |
| A2 | 結構與邊界 | `stores/`, `composables/` | `language/typescript/base.md` |
| B1 | 型別與合約 | `composables/api/modules/` | `language/typescript/base.md`, `language/typescript/custom/api-module.md`, `command/audit-typescript.md` |
| C1 | 命名與可讀性 | 本輪涉及 TS/Vue 檔案 | `core/principles.md`, `language/typescript/base.md` |
| D1 | 環境與設定 | `api-client.ts`, `env`, `index.html` | `language/typescript/custom/env.md` |
| E1 | UI/Router 特規 | Vue SFC, router | `language/typescript/base.md`, `command/audit-typescript.md` |
| T1 | 測試與驗證 | 本輪測試檔與變更 diff | `core/agent-mandates.md`, plan doc |

### .NET

| 批次 | Rule Family | Package/Module | 主要來源 |
|------|-------------|----------------|----------|
| A1 | 結構與邊界 | `Controllers/`, `Services/` | `language/dotnet/custom/structure.md` |
| A2 | 結構與邊界 | `Domain/Entities`, `Infrastructure/Factories` | `language/dotnet/custom/structure.md` |
| B1 | 型別與合約 | DTO, entity, response | `language/dotnet/base.md`, `command/audit-dotnet.md` |
| C1 | 命名與文件 | public API, lambda, methods | `core/principles.md`, `command/audit-dotnet.md` |
| D1 | DI/Env/Time | service ctor, env, audit fields | `core/principles.md`, `language/dotnet/custom/di.md`, `language/dotnet/custom/env.md` |
| E1 | 套件特規 | logging, query, error, factory | `language/dotnet/custom/logging.md`, `language/dotnet/custom/query.md`, `language/dotnet/custom/error.md` |
| T1 | 測試與驗證 | test project / 本輪變更 diff | `core/agent-mandates.md`, plan doc |

### Python

| 批次 | Rule Family | Package/Module | 主要來源 |
|------|-------------|----------------|----------|
| A1 | 結構與邊界 | `src/api/routers`, `src/services` | `language/python/fastapi.md` |
| A2 | 結構與邊界 | `src/schemas`, `src/models`, `src/factories` | `language/python/base.md`, `language/python/fastapi.md` |
| B1 | 型別與合約 | DTO/schema/response_model | `language/python/base.md`, `command/audit-python.md` |
| C1 | 命名與文件 | public class/function | `core/principles.md`, `language/python/base.md` |
| D1 | DI/Env/Async | `Depends`, settings, IO | `language/python/base.md`, `language/python/fastapi.md` |
| E1 | FastAPI 特規 | exception, alias, mock contract | `language/python/fastapi.md`, `core/external-contract.md` |
| T1 | 測試與驗證 | tests / 本輪變更 diff | `core/agent-mandates.md`, plan doc |

---

## 5. 單批執行模板

每批都照這個格式執行：

### Step 1
列出本批：
- Rule Family
- Language
- Package/Module
- Files
- Source Rules

### Step 2
只讀本批需要的規則檔。

### Step 3
只讀本批相關檔案與區塊。

### Step 4
逐條對照規則，輸出：
- `pass`
- `fail`
- `needs-follow-up`

### Step 5
若 `needs-follow-up`，只追加下一批必要區塊，不重讀整批。

---

## 6. 判定規則

### pass
- 有足夠證據證明符合規範。

### fail
- 有明確證據證明違反規範。

### needs-follow-up
- 規則適用，但目前讀取範圍不足以判定。

### not-applicable
- 該批規則與本套件/檔案無關。

---

## 7. 最終彙總方式

所有批次結束後再做總結：

| 欄位 | 內容 |
|------|------|
| 已完成批次 | 例如 `A1, A2, B1, C1` |
| fail 規則數 | 依規則族與套件彙總 |
| needs-follow-up | 尚待補查項目 |
| 高風險問題 | 先修項目 |
| 建議下一輪 | 只列下一個最值得查的批次 |

結論只允許：

- `approved`
- `changes-required`
- `partial-review`
