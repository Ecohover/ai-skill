# 計畫任務：{{TITLE}}

| 欄位 | 內容 |
|------|------|
| 任務編號 | {{ID}} |
| 建立日期 | {{DATE}} |
| 任務目的 | {{GOAL}} |
| 狀態 | `awaiting-builder` |

## 涉及專案
| 專案名稱 | 專案路徑 | 類型 (FE/BE) | 語言 | 備註 |
|----------|----------|--------------|------|------|
| {{PROJECT_NAME}} | {{PROJECT_PATH}} | | | |

> 狀態流轉：`awaiting-builder` → `awaiting-review` → `approved` / `changes-required`

---
<!-- ════════════════════════════════════
     PLANNER 填寫（Builder 不得修改）
     ════════════════════════════════════ -->

## A. Research（研究）

### 讀取的基礎規則 (Core Skills)
- [ ] `core/agent-mandates.md`
- [ ] `core/principles.md`

### 識別的語言規範 (Language Skills)
- [ ] `language/{{LANG}}/base.md`
- [ ] （列出其他讀取的技術規範 MD 檔案）

### 現狀分析
（描述目前技術棧現況、前後端互動邏輯或問題）

---

## B. Design（設計方案）

### 設計依據
（註明參考了哪些專案特有的開發手冊或規範）

### 非目標（Not In Scope）
- （明確列出本次不處理的項目，避免 Builder 自行擴充）

### 實作檔案清單
```yaml
new:
  - path/to/new-file.cs
modify:
  - path/to/existing-file.cs
```

### 邏輯說明
（具體描述每個檔案要修改的內容）

### 測試策略

| 項目 | 內容 |
|------|------|
| 測試等級 | `TDD / 先測試` / `完成後測試` / `替代驗證` |
| 判定原因 | （說明是否涉及 bug fix、核心邏輯、API contract、資料轉換、權限、金流、同步、排程、環境設定或高回歸風險） |
| 測試檔案 | （列出要新增或修改的測試；若無，填「無」並說明原因） |
| 失敗情境 | （TDD 時填寫要先重現或新增的 failing test；非 TDD 可填「不適用」） |
| 驗證指令 | （列出完成後要執行的 test/build/lint/static check；若無法執行，填替代驗證方式） |

### 驗收條件
（Reviewer 用來判斷任務是否完成的明確標準，可測試、可驗證）
- [ ] 條件一
- [ ] 條件二

---

## C. Execution Plan（執行計畫）

### 實作順序
（依語言層次排列）

**.NET 順序**：`Entity → DTO → Interface → Factory → Service → Controller`
**TypeScript 順序**：`types → api module → store → view → router`

### 執行步驟
1. [ ] 步驟一
2. [ ] 步驟二

### TDD / 驗證步驟
- [ ] 若測試等級為 `TDD / 先測試`，先新增或確認失敗測試。
- [ ] 完成實作後，執行測試策略指定的驗證指令。
- [ ] 若無法執行測試，記錄原因與替代驗證。

---
<!-- ════════════════════════════════════
     BUILDER 填寫（Reviewer 不得修改）
     ════════════════════════════════════ -->

## D. Implementation Record（實作紀錄）

> 狀態更新為 `awaiting-review` 後填寫此 section。

### 實際修改檔案清單
```yaml
new:
  - （實際新增的檔案）
modify:
  - （實際修改的檔案）
```

### 與計畫的差異
| 差異項目 | 原計畫 | 實際做法 | 原因 |
|----------|--------|----------|------|
| （若無差異填「無」）| | | |

### 測試與驗證紀錄
| 項目 | 結果 | 備注 |
|------|------|------|
| 測試 / build / lint / static check | pass / fail / not-run | （填寫指令、結果；not-run 時說明原因與替代驗證） |

### 給 Reviewer 的備注
（需要特別關注的實作細節或已知風險）

---
<!-- ════════════════════════════════════
     REVIEWER 填寫（其他角色不得修改）
     ════════════════════════════════════ -->

## E. Review（審查結果）

> 由 Reviewer 填寫，結論為 `approved` 或 `changes-required`。

### 驗收條件確認
- [ ] 條件一（對應 B. Design 的驗收條件）
- [ ] 條件二

### 測試策略確認
| 項目 | 結果 | 備注 |
|------|------|------|
| 是否依測試策略執行 | ✅ pass / ❌ fail | |
| TDD / 先測試是否有失敗情境紀錄 | ✅ pass / ❌ fail / N/A | |
| 測試或替代驗證是否足夠 | ✅ pass / ❌ fail | |

### Audit Checklist 結果
（依 `command/audit-{{LANG}}.md` 逐項確認）

| 項目 | 結果 | 備注 |
|------|------|------|
| （項目名稱）| ✅ pass / ❌ fail | （fail 時說明原因與位置）|

### 計畫符合性
- 實作範圍是否在 B. Design 範圍內：
- 偏離說明是否合理：

### 問題清單
（changes-required 時列出，approved 時填「無」）

| 優先度 | 檔案 | 問題說明 |
|--------|------|----------|
| | | |

### 結論
**`approved`** / **`changes-required`**

審查日期：{{REVIEW_DATE}}
