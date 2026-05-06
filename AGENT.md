# AI 協作入口（Agent Routing）

為節省 Token 並保持上下文精準，**嚴格遵守按需載入**原則。

---

## Step 1：確認角色

進入 session 時，先確認自己是哪個角色，再載入對應規則。

| 角色 | 觸發時機 | 詳細規範 |
| :--- | :--- | :--- |
| **Planner** | 使用者呼叫規劃、或任務達到計畫門檻 | `roles/planner.md` |
| **Builder** | 使用者呼叫實作、或收到 `awaiting-builder` 的 plan doc | `roles/builder.md` |
| **Reviewer** | 使用者呼叫審查、或收到 `awaiting-review` 的 plan doc | `roles/reviewer.md` |

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
roles/planner.md
core/agent-mandates.md
core/principles.md
core/api-contract.md        ← 涉及 API 時
core/external-contract.md   ← 涉及第三方時
commands/plan.md
```

### Builder 載入
```
roles/builder.md
core/agent-mandates.md
core/principles.md
[語言]/base.md              ← 依任務語言選一種
[語言]/dachan/[模組].md     ← 精準選 1-2 個
doc/plans/[id]-[name].md    ← 計畫任務才讀
```

### Reviewer 載入
```
roles/reviewer.md
core/agent-mandates.md
core/principles.md
core/api-contract.md        ← 涉及 API 時
commands/audit-[lang].md    ← 依實作語言選一種
doc/plans/[id]-[name].md    ← 計畫任務才讀
```

---

## 禁止事項

- 禁止跨語言載入（開發 .NET 時不讀 TypeScript 規則）。
- Planner 不寫程式碼。
- Builder 不執行 audit。
- Reviewer 不修改程式碼。
- 任何角色不得跳過 handoff 文件直接進入下一個角色的工作。
