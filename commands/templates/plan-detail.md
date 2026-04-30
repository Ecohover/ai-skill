# 計畫任務：{{TITLE}}

| 欄位 | 內容 |
|------|------|
| 任務編號 | {{ID}} |
| 建立日期 | {{DATE}} |
| 語言 | {{LANG}} |
| 狀態 | `awaiting-builder` |

> 狀態流轉：`awaiting-builder` → `awaiting-review` → `approved` / `changes-required`

---
<!-- ════════════════════════════════════
     PLANNER 填寫（Builder 不得修改）
     ════════════════════════════════════ -->

## A. Research（研究）

### 讀取的規則文件
- [ ] `core/principles.md`
- [ ] （列出其他讀取的 MD 檔案）

### 現狀分析
（描述目前程式碼的邏輯或問題）

---

## B. Design（設計方案）

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

### Audit Checklist 結果
（依 `commands/audit-{{LANG}}.md` 逐項確認）

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
