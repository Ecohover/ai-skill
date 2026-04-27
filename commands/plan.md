# 開發任務管理與流程協議

AI 在接收指令後，應優先判定任務類別，並依類別執行對應的記錄與開發流程。

## 1. 任務判定 (Task Categorization)

- **簡單任務 (Simple Task) [預設]**：
    - 定義：常規修改、諮詢、單一檔案的 Bug Fix。
    - 流程：直接執行，不需建立文件記錄。
- **計畫任務 (Planned Task)**：
    - 觸發條件：
        1. **使用者明確要求** 使用計畫模式。
        2. 涉及 3 個以上檔案的連動修改。
        3. 涉及資料庫 Schema 或核心合約 (API Contract) 的變動。
    - 流程：執行以下「兩層式文件記錄」規範。

## 2. 計畫任務記錄規範 (Two-Layer Documentation)

### 序號獲取
在建立新計畫前，**必須**先讀取 `docs/task-index.md` (若不存在則視為 001)，確認目前最後一個編號，並取用下一個序號。

### 第一層：計畫清單 (`docs/task-index.md`)
- 內容格式：
    | 日期 | 編號 | 任務名稱 | 狀態 | 詳情連結 |
    | :--- | :--- | :--- | :--- | :--- |
    | yyyy-mm-dd | 001 | [任務摘要名稱] | (進行中/已完成) | [./plans/001-task-name.md] |

### 第二層：任務詳情 (`docs/plans/[編號]-[task-name].md`)
應包含以下階段：

#### A. Research (研究)
- 讀取相關規則檔並分析現狀。

#### B. Design (設計方案)
- 產出實作檔案清單 (YAML)。
- **注意**：實作過程中若發現設計需重大變更，**必須先更新此文件並取得核准**，嚴禁「先斬後奏」。

#### C. Execution Plan (執行計畫)
- 具體的實作步驟與語言專屬順序。

---

## 3. 實作順序 (Implementation Sequence)

- **.NET 順序**：`Entity → DTO → Interface → Factory → Service → Controller`
- **TypeScript 順序**：`types → api module → store → view → router`

## 4. 驗證與收尾 (Verify & Wrap-up)

1. 執行 `audit-*.md` 自審。
2. 更新 `docs/task-index.md` 狀態為「已完成」。
