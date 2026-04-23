# AI 規則庫入口 (Agent Routing)

為了節省 Token 並保持上下文精準，請**按需載入**規則檔案。**禁止一次性讀取所有檔案**。
請依照以下三個階段，根據你目前的任務循序漸進地讀取所需的規則。

---

## 階段 1：跨語言通用規範 (全專案適用)
> 無論你現在使用哪種程式語言，開始前**必須**先了解這些核心原則。

* **`core/principles.md`**：基礎協作原則 (命名、大成標準目錄結構、設計原則、時間處理)。
* **`core/api-contract.md`**：(按需) 如果任務涉及開發或串接**內部 API**，必讀此合約 (包含分頁、模糊查詢、Enum 與錯誤格式)。
* **`core/external-contract.md`**：(按需) 如果任務涉及 Mock 或串接**外部第三方系統**，必讀此合約 (完美偽裝原則)。

---

## 階段 2：語言與框架專屬規範 (依任務選擇)
> 根據你目前正在開發的語言，讀取對應的基礎與進階規則。

### 🟢 .NET (WMS 後端)
* **基礎必讀**: `dotnet/base.md` (格式、集合封裝、充血模型)
* **依任務附加 (按需)**:
  * 新增或修改功能: `dotnet/dachan/structure.md` (Controller/Service/DTO/Factory 職責)
  * 查詢/分頁/搜尋: `dotnet/dachan/query.md`
  * 錯誤處理/拋出: `dotnet/dachan/error.md`
  * 日誌記錄: `dotnet/dachan/logging.md`
  * Enum 處理: `dotnet/dachan/enum.md`
  * 環境變數存取: `dotnet/dachan/env.md`

### 🔵 TypeScript / Vue 3 (前端)
* **基礎必讀**: `typescript/base.md` (Vue 3 語法、型別安全、命名)
* **依任務附加 (按需)**:
  * 新增頁面/模組/路由: `typescript/dachan/structure.md`
  * API 串接與 composable: `typescript/dachan/api-module.md`
  * 環境變數存取: `typescript/dachan/env.md`

### 🟡 Python (FastAPI / Mock Service / 工具)
* **基礎必讀**: `python/base.md` (型別標註、命名、Docstrings)
* **依任務附加 (按需)**:
  * 實作 API 功能: `python/fastapi.md` (Router/Service 職責、依賴注入)

---

## 階段 3：開發流程與提交前驗證
> 準備開始實作，或實作完成準備收尾時讀取。

* **`commands/plan.md`**：(實作前) 新功能開發流程協議 (Research -> Design -> Implement -> Verify)。
* **提交前自審清單 (實作後)**：
  * .NET: `commands/audit-dotnet.md`
  * TypeScript: `commands/audit-typescript.md`
  * Python: `commands/audit-python.md`
