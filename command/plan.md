# 開發任務管理與流程協議

AI 在接收指令後，應優先判定任務類別，並依類別執行對應的記錄與開發流程。

除非特別標示，本文所有路徑皆相對於本規則庫根目錄。若規則庫在使用專案中掛載為 `.prompts/`，則 `doc/plan/` 的實際路徑為 `.prompts/doc/plan/`。

## 1. 任務判定 (Task Categorization)

- **簡單任務 (Simple Task) [預設]**：
    - 定義：常規修改、諮詢、單一檔案的 Bug Fix。
    - 流程：直接執行，不需建立文件記錄。
- **計畫任務 (Planned Task)**：
    - 觸發條件：
        1. **使用者明確要求** 使用計畫模式。
        2. 涉及 3 個以上檔案的連動修改。
        3. 涉及資料庫 Schema 或核心合約 (API Contract) 的變動。

## 2. 計畫任務記錄規範 (Planning Sub-directory Structure)

所有計畫應建立於本規則庫根目錄下的 `doc/plan/` 資料夾中，與使用專案的其他技術文件 (如架構說明、API 規格) 區隔。

> `doc/plan/` 是實際任務產物，已由本規則庫的 `.gitignore` 排除；`command/template/` 才是應保留在版控中的模板來源。

### 序號獲取
在建立新計畫前，**必須**先讀取 `doc/plan/task-index.md`。
若不存在，從 `command/template/task-index.md` 建立初始索引，第一筆任務編號為 `001`。

### 第一層：計畫索引 (`doc/plan/task-index.md`)
這是計畫區的入口，記錄編號、任務名稱、狀態與路徑。
- **格式規範**：必須參考 `command/template/task-index.md`。

### 第二層：獨立任務資料夾 (`doc/plan/[三位序號]-[task-name]/`)
每個任務擁有專屬子資料夾：
- `plan.md`：核心計畫，必須以 `command/template/plan-detail.md` 建立。
- `research/`、`assets/`：選填附屬資源。

---

## 3. 命名慣例 (Naming Convention)

- **資料夾**：`doc/plan/[三位序號]-[task-name]/`
- **主文件**：`plan.md` (位於上述資料夾內)

### A. Research (研究)
- 讀取相關規則檔並分析現狀。

### B. Design (設計方案)
- 產出實作檔案清單 (YAML)。
- **注意**：實作過程中若發現設計需重大變更，**必須先更新此文件並取得核准**。

### C. Execution Plan (執行計畫)
- 具體的實作步驟與語言專屬順序。

---

## 4. 實作順序 (Implementation Sequence)

- **.NET 順序**：`Entity → DTO → Interface → Factory → Service → Controller`
- **TypeScript 順序**：`types → api module → store → view → router`

## 5. 驗證與收尾 (Verify & Wrap-up)

1. Builder 完成 D. Implementation Record，將 plan doc 與 `doc/plan/task-index.md` 狀態更新為 `awaiting-review`。
2. Reviewer 依 `command/audit-*.md` 審查。
3. Reviewer 將 plan doc 與 `doc/plan/task-index.md` 狀態更新為 `approved` 或 `changes-required`。
