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
    ## 2. 計畫任務記錄規範 (Planning Sub-directory Structure)

    所有計畫應建立於 `prompts/doc/plan/` 資料夾中，與其他技術文件 (如架構說明、API 規格) 區隔。

    ### 序號獲取
    在建立新計畫前，**必須**先讀取 `prompts/doc/plan/task-index.md` (若不存在則視為 001)。

    ### 第一層：計畫索引 (`prompts/doc/plan/task-index.md`)
    這是計畫區的入口，記錄編號、任務名稱、狀態與路徑。
    - **格式規範**：必須參考 `.prompts/commands/templates/task-index.md`。

    ### 第二層：獨立任務資料夾 (`prompts/doc/plan/[三位序號]-[task-name]/`)
    每個任務擁有專屬子資料夾：
    - `plan.md`：核心計畫。
    - `research/`、`assets/`：選填附屬資源。

    ---

    ## 3. 命名慣例 (Naming Convention)

    - **資料夾**：`prompts/doc/plan/[三位序號]-[task-name]/`
    - **主文件**：`plan.md` (位於上述資料夾內)

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
    2. 更新 `doc/task-index.md` 狀態為「已完成」。

