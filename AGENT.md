# AI 協作入口（Agent Routing）

本文件是所有 AI agent 的通用入口，不限定任何特定 AI 工具。

為節省 Token 並保持上下文精準，**嚴格遵守按需載入**原則。

---

## Step 1：確認角色

進入 session 時，先確認自己是哪個角色，再載入對應規則。

| 角色 | 觸發時機 | 詳細規範 |
| :--- | :--- | :--- |
| **Planner** | 使用者呼叫規劃、或任務達到計畫門檻 | `role/planner.md` |
| **Builder** | 使用者呼叫實作、或收到 `awaiting-builder` 的 plan doc | `role/builder.md` |
| **Reviewer** | 使用者呼叫審查、或收到 `awaiting-review` 的 plan doc | `role/reviewer.md` |
| **Code Inspector** | 使用者要求依規範逐步檢查程式碼，或需要低上下文風險的規則稽核 | `role/code-inspector.md` |

---

## Step 2：判斷任務類型

### 計畫任務（需要 Planner）

符合以下任一條件：
- 涉及 3 個以上檔案的連動修改
- 涉及資料庫 Schema 或 API Contract 變動
- 使用者明確要求計畫模式

**流程：Planner → Builder → Reviewer**

### 簡單任務（直接 Builder）

- 單檔案修改、bug fix、諮詢

**流程：Builder → Reviewer**

---

## Step 3：依角色載入規則

### Planner 載入
```
role/planner.md
core/agent-mandates.md
core/principles.md
core/api-contract.md        ← 涉及 API 時
core/api-routing.md         ← 涉及 API route / HTTP verb 時
core/external-contract.md   ← 涉及第三方時
package/[共用套件]/*.md      ← 專案採用共用套件時，按需載入
unit/[開發單位]/*.md        ← 專案指定開發單位規範時，按需載入
language/[語言]/base.md     ← 進入 B. Design 前，依涉及語言載入
command/plan.md
```

### Builder 載入
```
role/builder.md
core/agent-mandates.md
core/principles.md
package/[共用套件]/*.md      ← 專案採用共用套件時，按需載入
unit/[開發單位]/*.md        ← 專案指定開發單位規範時，按需載入
language/[語言]/base.md     ← 依任務語言選一種
language/[語言]/custom/[模組].md ← 精準選 1-2 個
doc/plan/[id]-[name]/plan.md ← 計畫任務才讀
```

### Reviewer 載入
```
role/reviewer.md
core/agent-mandates.md
core/principles.md
core/api-contract.md        ← 涉及 API 時
core/api-routing.md         ← 涉及 API route / HTTP verb 時
core/external-contract.md   ← 涉及第三方時
package/[共用套件]/*.md      ← 專案採用共用套件時，按需載入
unit/[開發單位]/*.md        ← 專案指定開發單位規範時，按需載入
command/audit-[lang].md     ← 依實作語言選一種
language/[語言]/custom/[模組].md ← audit 無法判定或疑似 fail 時再讀對應細規則
doc/plan/[id]-[name]/plan.md ← 計畫任務才讀
```

### Code Inspector 載入
```
role/code-inspector.md
core/agent-mandates.md
core/principles.md
core/api-contract.md         ← 涉及 API 時
core/api-routing.md          ← 涉及 API route / HTTP verb 時
package/[共用套件]/*.md      ← 專案採用共用套件時，按需載入
unit/[開發單位]/*.md        ← 專案指定開發單位規範時，按需載入
language/[語言]/base.md      ← 依實作語言選一種
language/[語言]/custom/[模組].md ← 只讀本次檢查範圍需要的 1-2 份
command/audit-[lang].md      ← 依實作語言選一種
command/audit-chunked.md
doc/plan/[id]-[name]/plan.md ← 計畫任務才讀
```

---

## 禁止事項

- 禁止跨語言載入（開發 .NET 時不讀 TypeScript 規則）。
- Planner 不寫程式碼。
- Builder 不執行 audit。
- Reviewer 不修改程式碼。
- Code Inspector 不一次讀完整個程式碼庫，也不修改程式碼。
- 計畫任務不得跳過 handoff 文件直接進入下一個角色的工作。
