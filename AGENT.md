# AI 規則庫入口 (Agent Routing)

為了節省 Token 並保持上下文精準，請**嚴格遵守按需載入**原則。
**禁止跨語言讀取**（例如：開發 .NET 時不應讀取 TypeScript 規範）。

---

## 階段 1：跨語言通用規範 (全專案適用)
> 開始前**僅讀取與任務直接相關**的檔案。

* **`core/principles.md`**：基礎協作原則 (必讀)。
* **`core/api-contract.md`**：涉及**內部 API** 開發時讀取。
* **`core/external-contract.md`**：涉及**第三方系統**對接時讀取。

---

## 階段 2：語言與框架專屬規範 (限選一種語言)
> **精準讀取**：先讀取 `base.md`，再根據要修改的模組讀取 1-2 個特定的 `dachan/*.md`。

### 🟢 .NET (WMS 後端)
* **基礎**: `dotnet/base.md`
* **特定任務**: 根據 `dachan/` 下的檔名（如 `error`, `query`, `logging`）精準選取。

### 🔵 TypeScript / Vue 3 (前端)
* **基礎**: `typescript/base.md`
* **特定任務**: 根據 `dachan/` 下的檔名（如 `api-module`, `structure`）精準選取。

---

## 階段 3：開發流程與提交前驗證
> **判定與記錄**：進入開發前必須先閱讀 `commands/plan.md`。

* **`commands/plan.md`**：判定任務等級。若為「計畫任務」，**必須**先在專案 `doc/` 建立記錄。
* **`commands/audit-*.md`**：實作完成後才讀取對應的自審清單。
