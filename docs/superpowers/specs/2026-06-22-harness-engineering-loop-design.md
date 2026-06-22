# 設計：Harness Engineering Loop（自我監控 / 中斷協議 / 失敗回饋）

| 欄位 | 內容 |
|------|------|
| 日期 | 2026-06-22 |
| 範圍 | `AI Engineering Rule Pack`（本規則庫 repo） |
| 落地強度 | 方案 A（輕量整合進現有結構，不新增角色） |

## 1. 背景與目標

本規則庫已是一套不錯的 harness engineering 成果：按需載入、四角色分工、單一真理來源。本次要補的是 harness engineering loop 中目前較弱或缺少的環節，使 AI agent 在執行時能自我監控、卡住時主動交人、並把失敗系統化餵回規則庫。

四個交織目標：

1. **執行中自我監控**：agent 邊做邊自檢，不在無證據下宣稱完成。
2. **事實單元測試 + code review**：用測試與審查把「做對了」變成可驗證的事實。
3. **無解 → 人類介入中斷點**：agent 認知到卡住／超出職權 → 停下、結構化回報、交人決策，而非硬猜或唬爛。
4. **失敗回饋迭代機制**：把反覆失敗收斂，並透過人類閘門回匯規則庫。

## 2. 架構決策

### 2.1 保留現有角色架構（tool-agnostic 理由）

使用情境為**多種 AI 工具混用**，其中部分工具沒有原生 plan mode / subagent。因此把計畫/簡單任務分流、四角色（Planner / Builder / Reviewer / Code Inspector）與 handoff **顯式編碼在 markdown**，是補足那些工具缺的 harness 能力的合理代價，予以保留。

主流趨勢雖是「單一 agent 走階段」，但那建立在工具具備原生 plan mode / subagent 的前提上；本規則庫不能假設此前提。

- Reviewer 與 Code Inspector 雖近似，但分工為「單一任務對照計畫的驗收審查」vs「大型變更的分批低上下文規則稽核」，是合理區分，維持兩者。
- 本次新增的機制掛在「角色」上，而非「階段」上。

### 2.2 失敗回饋兩層

- **Layer 1（消費專案內）**：失敗結構化記錄在使用專案的 plan doc 與 `doc/lessons/lessons-log.md`（產物，比照 `doc/plan/` 被 ignore）。
- **Layer 2（回匯規則庫）**：人類在「晉升閘門」決定哪些 lesson 值得變成規則庫的正式規則 / audit 項。

架構張力：`doc/plan/`、`doc/lessons/` 是消費端產物，但規則變更落在本 rule pack repo。兩者靠 `command/promote-lesson.md` 定義的晉升閘門橋接。

## 3. 四個機制

### 機制① 自我監控與證據 — 新檔 `core/verification.md`（全角色必讀，< 100 行）

把 `core/agent-mandates.md` §4 的「驗證」從一句話升級為硬規則：

- **證據優於宣稱**：不得在沒有貼出「執行的指令 + 實際輸出」的情況下宣稱「完成 / 修好 / 通過」。測試沒跑就不能說綠。
- **自我監控訊號**（執行中自檢）：
  - 同一個錯誤用「不同方法」嘗試 **≥ 2 次**仍失敗 → 觸發中斷流程（連到機制③）。
  - 發現自己改了又改、來回擺盪 → 停下重新評估，而非繼續猜。
  - 發現需求／計畫前後矛盾或證據不足以判斷 → 停下。
- **把正確性變成事實**（接目標②）：核心行為以單元測試斷言「真實觀察到的行為」，不寫只驗證實作細節或恆真的測試；review 對照證據而非感覺。

### 機制③ 中斷協議 + `blocked` 狀態 — 新檔 `core/escalation.md`（全角色必讀，< 100 行）

通用「無解 → 交人」協議，取代散落各處的零星觸發。

- **停止訊號（何時算卡住）**：
  1. 機制①的反覆失敗訊號（2 次不同方法仍失敗）。
  2. 需求矛盾／歧義，且無法從程式碼或上下文解決。
  3. 缺權限／憑證／外部決策／超出角色職權。
  4. 需要破壞性或不可逆動作。
- **中斷動作**：立即停止；**不得唬爛或硬造**；不得繼續鬼打牆；輸出結構化 blocked 報告；進入 `blocked` 狀態交回人類。
- **blocked 報告格式**：目標 / 已嘗試什麼（附證據）/ 為何判定無解 / 需要人類提供什麼 / 可選方案（若有）。

#### 既有不符規範修正的擴散閘門（本機制內並列規則）

發現既有程式碼不符規範、但本次新增內容會用到它時，依下列順序判定：

1. **先過質性閘門**，命中任一即**停下詢問**，與檔案數無關：
   - 修正會改變行為 / 合約 / 公開介面（非純機械式改名）。
   - 跨越邊界：API contract、跨服務、跨模組的 public 介面。
   - 修正會擴散到計畫檔案清單以外的模組。
2. **再看數量閘門**：以**受影響的檔案數**計。
   - **≤ 20 個檔案**：直接修正，並記錄偏離（D. Implementation Record）+ 在 `doc/lessons/` 留晉升候選。
   - **> 20 個檔案**：停下詢問。

「既有程式碼不符規範」本身即一筆失敗訊號（規則庫沒擋住，或該段 code 早於規則），因此即使直接修正也必須記錄，天然餵養回饋 loop。

### 機制④-Layer1 失敗紀錄 — `doc/lessons/lessons-log.md`（消費專案產物，ignore）

- **何時寫**：blocked 事件落幕後、Reviewer / Code Inspector 抓到反覆出現的同類 fail、人類指出 agent 又犯同樣錯、或機制③的 ≤20 檔案直接修正。
- **格式**：日期 / 關聯任務 / 失敗現象 / 根因 / 當下修法 / 是否為晉升候選。
- **用途**：累積跨任務的反覆失敗，餵給 Layer 2。

### 機制④-Layer2 晉升閘門 — 新檔 `command/promote-lesson.md`（維護者按需讀，可略超 100 行）

把現在手動補 `SKILL.md`「XX 任務必讀」這件事正規化。

- **晉升判準**：跨任務 / 跨專案反覆出現、可一般化、非單一專案特例 → 才值得進規則庫。
- **落點對照**：coding style → `language/`；套件行為 → `package/`；合約 → `core/`；「該載沒載」的觸發問題 → `AGENT.md` / `SKILL.md` 路由。
- **人類閘門**：command 只**產出建議的規則 diff**，由人類核准才寫入。

## 4. 逐檔變更

### 4.1 新增（3 檔）

| 檔案 | 內容 | 必讀對象 |
|------|------|----------|
| `core/verification.md` | 機制① | 全角色必讀 |
| `core/escalation.md` | 機制③ + 20 檔案／質性閘門 | 全角色必讀 |
| `command/promote-lesson.md` | 機制④-Layer2 | 維護者按需 |

### 4.2 狀態機（新增 `blocked`）

- `command/template/task-index.md`：狀態說明補 `blocked`（任務卡住、等待人類介入）。
- `command/template/plan-detail.md`：頭部狀態流轉補 `blocked` 分支；D. Implementation Record 補「既有不符規範修正紀錄」欄（記 ≤20 檔案的直接修正 + lessons 候選）；新增 **F. Blocked / Lessons** section（記中斷報告與晉升候選）。
- `command/plan.md` §5：狀態流轉補 `blocked`（任一角色可進入，人類解除後回到對應狀態）。

### 4.3 角色檔（四個都加 `verification.md` + `escalation.md` 進必讀）

- `role/builder.md`：載入加兩份；「實作規範」把現有「小幅偏離」改寫為明確的 20 檔案／質性閘門規則；交接動作加 `blocked` 分支；要求既有不符規範的直接修正記進 D + 留 lessons 候選。
- `role/reviewer.md`：載入加兩份；審查範圍加「證據是否齊全（不得無輸出宣稱通過）」「blocked 是否正確處理」「反覆 fail 是否標為 lessons 候選」。
- `role/code-inspector.md`：載入加兩份；既有 `needs-follow-up` 連到 lessons 候選。
- `role/planner.md`：載入加兩份；測試／目錄判定旁補「規劃時標出已知高風險／可能卡住點」。

### 4.4 入口與文件

- `AGENT.md`：四個角色載入清單各加 `core/verification.md`、`core/escalation.md`（必讀）；禁止事項／流程補「任一角色察覺停止訊號須進 `blocked` 交人，不得硬幹」。
- `SKILL.md`：啟動流程補 blocked + 證據原則；新增一小段「失敗回饋」指向 `doc/lessons/` 與 `command/promote-lesson.md`。
- `README.md`：
  1. 清掉 git submodule 殘留——開頭（現「透過 Git Submodule 引入專案」）與刪除線整段，改寫為「clone 到同層級 + 指定路徑讀取」的正式敘述。
  2. 目錄結構與 ignore 註記加 `doc/lessons/`。
  3. 維護者準則加一節「失敗回饋與 lesson 晉升」流程。
- `.gitignore`：加 `/doc/lessons/`（比照 `/doc/plan/`，產物不回提規則庫）。

## 5. 簡單任務（無 plan doc）下的 blocked

簡單任務沒有 plan doc 可填，卡住時直接對使用者輸出 blocked 報告，並視情況補寫 `doc/lessons/`。

## 6. 相容性與規模

- `blocked` 為新增狀態，不破壞既有 `awaiting-builder → awaiting-review → approved / changes-required` 流，向後相容。
- 全部新檔 < 100 行（`promote-lesson.md` 可略超，符合維護者按需例外）。
- submodule 清理純文件層，不影響路由邏輯。
- 角色架構維持不變，僅在既有角色上掛載新機制。

## 7. 不在本次範圍（Not In Scope）

- 不收斂或合併現有角色（保留現狀）。
- 不引入失敗分類學、機器可解析失敗紀錄或指標（方案 C 的內容，YAGNI）。
- 不新增第五個角色（方案 B 的內容）。
- 不改動既有 audit 清單、語言規範、合約規範的實質內容。
