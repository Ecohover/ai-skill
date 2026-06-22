# 設計：Dispatcher（派工）角色與重新派工迴圈

| 欄位 | 內容 |
|------|------|
| 日期 | 2026-06-22 |
| 範圍 | `AI Engineering Rule Pack`（本規則庫 repo） |
| 關聯 | 與 `2026-06-22-harness-engineering-loop-design.md`、`2026-06-22-routing-token-optimization-design.md` 互補，三份一起實作 |

## 1. 背景與動機

一次 chat 實際上是多個 AI session、不同角色分次進來。目前「判斷任務方向、決定載哪些規則」這件事散落在 `AGENT.md` Step 1–3 與各角色檔的「載入規則」裡，由每個角色各自重新判斷，造成路由邏輯重複、且沒有「給的規則不足時回頭修正」的機制。

本設計把 routing-token-optimization 的**靜態派工表升級為一個會動的角色**：由一個「派工角色」當第一棒，集中決定載入清單，並帶一條「處理/檢核角色發現規則不足 → 回頭重派」的迴圈。

> 切點說明：派工 ↔ 處理之間的契約是「一份載入清單（檔案列表）」，介面很窄、交棒幾乎不失真，是適合拆分的位置。

## 2. 架構

### 2.1 新增 Dispatcher（派工）角色

- **觸發**：每個任務的第一棒。簡單任務與計畫任務都先經過 Dispatcher。
- **職責**：
  1. 判斷問題大方向與任務類型（簡單 / 計畫）——將 `AGENT.md` Step 1–2 的隱性工作顯式化。
  2. 用 SKILL 薄派工表產出一份 **Load Manifest（載入清單）**：本次要載哪些檔，附一句「為何選這些」。
  3. 交棒：簡單任務 → Builder；計畫任務 → Planner。
  4. 接收下游「規則不足」回饋 → 重整清單 → 再交付（見 2.3）。
- **不做**：不寫程式碼、不審查、不做細部規劃（細部規劃仍是 Planner）。Dispatcher 只決定「方向 + 載什麼 + 交給誰」。

> 角色數量：本設計使 rule pack 成為 5 角色（Dispatcher + Planner / Builder / Reviewer / Code Inspector）。這與 harness-loop spec「不新增第五個角色」的敘述不衝突——後者指的是方案 B 的 Curator；Dispatcher 是經明確決策加入的不同角色。

### 2.2 Load Manifest（載入清單）

- **內容**：baseline（角色檔 + `core/agent-mandates.md` + `core/principles.md` + `core/verification.md` + `core/escalation.md`）＋命中的任務訊號對應檔＋「為何選這些」一句＋版本號（v1、v2…）。
- **落點**：
  - 計畫任務：寫進 plan doc 一個 **Load Manifest** section（併在 A. Research 之前或之內），下游角色直接拿。
  - 簡單任務：Dispatcher 在開場宣告一小段清單，下游照單載入。

### 2.3 重新派工迴圈（Re-dispatch loop）

- **觸發**：處理或檢核角色發現「給的 SKILL 不足以判斷或執行」→ 回報 Dispatcher，附：缺什麼、卡在哪。
- **派工動作**：補上遺漏檔，出 v(n+1) manifest，再交付。
- **帶記憶的接力（必要）**：每次重派**必須承接前次派工狀況**——附上前次的載入清單，並明確指出「上一輪觀察到的缺失部分與原因說明」，供本輪派工與後續角色參考。Manifest 因此累積一份 **re-dispatch 紀錄**（v1 → 缺失說明 → v2 → …），而非冷重試。
- **上限與終止（接既有機制，不空轉）**：重整**上限 2 次**（呼應 2 次失敗門檻）。重整 2 次仍不足、或根本沒有對應規則時：
  - 視為規則缺口的 lessons 候選 → 寫 `doc/lessons/`，**連同完整 re-dispatch 紀錄**（這份歷史正是 lesson 材料）。
  - 若需人類決策 → 進 `blocked`。

### 2.4 角色檔瘦身（附帶 token 收益）

- 各角色檔現有的「載入規則」清單，改為「**依 Dispatcher 提供的 Load Manifest 載入**」，把重複的路由散文從 `builder.md` / `reviewer.md` / `planner.md` / `code-inspector.md` 拔掉。
- **graceful degrade（tool-agnostic）**：沒有派工角色的工具，依 SKILL 派工表自行產生 Manifest，行為等價、不阻斷。

## 3. 逐檔變更

- **新增 `role/dispatcher.md`**：角色定位、Load Manifest 產出規範、重新派工迴圈（含帶記憶接力與 2 次上限）、graceful degrade、禁止事項（不寫碼 / 不審 / 不細規劃）。
- `AGENT.md`：
  - Step 1 角色表新增 Dispatcher 為第一棒；流程改為 `Dispatcher → (Planner) → Builder → Reviewer`，簡單任務 `Dispatcher → Builder → Reviewer`。
  - Step 3 各角色載入改為「依 Manifest」導向，保留「無派工時自行依派工表產生」的後路。
  - 禁止事項補：未經派工或未產生 Manifest，不得逕自開工。
- `SKILL.md`：派工表標明「供 Dispatcher 使用」。
- `role/builder.md` / `reviewer.md` / `planner.md` / `code-inspector.md`：載入規則瘦身為 Manifest 導向；新增「發現規則不足 → 回報 Dispatcher 重派」的動作。
- `command/template/plan-detail.md`：新增 **Load Manifest** section（含版本與 re-dispatch 紀錄）。
- `command/plan.md`：流程補 Dispatcher 為第一棒、Manifest 與重派迴圈。
- `README.md`：角色清單加 Dispatcher；維護者準則補「任務型規則新增時由派工表承載，Dispatcher 負責選用」。

## 4. 與另兩份 spec 的整合（閉環）

- 薄派工表（routing-token-optimization）＝ Dispatcher 手上的工具。
- lessons / blocked（harness-engineering-loop）＝ 重新派工迴圈的終止出口。
- 三者合成：**派工 → 處理 → 不足回派工（帶記憶，上限 2 次）→ 仍不足則 lessons / blocked**，主動防漏與被動補漏閉環。

## 5. 相容性與非目標

**相容性**
- 新增角色與 Manifest，不破壞既有 `awaiting-builder → awaiting-review → approved / changes-required` 狀態機。
- 多工具 degrade 留後路，無派工角色的工具仍可運作。

**非目標（Not In Scope）**
- 不取代 Planner 的細部規劃職責。
- 不引入原生 subagent 依賴；拆分以 markdown 協議承載，保持 tool-agnostic。
- 不引入失敗分類學或指標（沿用 harness-loop spec 的範圍界定）。
