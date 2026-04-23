# AI 規則庫入口

依下表讀取對應檔案，**按需載入，勿一次全讀**。

---

## .NET（WMS 後端）

| 場景 | 必讀 |
|------|------|
| 任何 .NET 開發（基礎） | `core/principles.md` + `dotnet/base.md` |
| 新增功能（目錄/Entity/DTO/Controller/Service/Factory） | + `dotnet/dachan/structure.md` |
| 查詢 / 過濾 / 分頁 | + `dotnet/dachan/query.md` |
| 錯誤處理 | + `dotnet/dachan/error.md` |
| 日誌 | + `dotnet/dachan/logging.md` |
| Enum 定義或序列化 | + `dotnet/dachan/enum.md` |
| 環境變數 | + `dotnet/dachan/env.md` |
| FE/BE API 合約（分頁欄位/Searches/錯誤格式） | + `core/api-contract.md` |

## TypeScript（Dachan Frontend）

| 場景 | 必讀 |
|------|------|
| 任何 Vue/TS 開發（基礎） | `core/principles.md` + `typescript/base.md` |
| 新增頁面或模組（目錄/路由/Pinia） | + `typescript/dachan/structure.md` |
| 呼叫後端 API（composable / Searches） | + `typescript/dachan/api-module.md` |
| 環境變數 | + `typescript/dachan/env.md` |
| FE/BE API 合約 | + `core/api-contract.md` |

## 流程 / 品質

| 場景 | 必讀 |
|------|------|
| 開始規劃新功能 | `commands/plan.md` |
| .NET 提交前自審 | `commands/audit-dotnet.md` |
| TypeScript 提交前自審 | `commands/audit-typescript.md` |

---

> 每個檔案各自獨立。只做查詢功能時只讀 `query.md`，不需讀整個 `dachan/`。
