# FE/BE 共用 API 合約

> 前後端 API 模組開發時必須與此合約對齊。

## 回應格式

專案標準 API 回應結構為 `{Project}ApiResponse<T>`，實際型別名稱依開發單位或共用套件 profile 定義，對外 JSON 欄位固定如下。

所有 API 回應由專案標準 middleware 統一封裝成 `{Project}ApiResponse<T>`，**Controller 禁止手動封裝 `{Project}ApiResponse` / `ApiResult` / 自訂 wrapper**：

```json
{
  "success": true,
  "data": { ... },
  "errorCode": null,
  "message": null
}
```

失敗時：

```json
{
  "success": false,
  "data": null,
  "errorCode": "{SYS}-INV-40005",
  "message": "庫存數量不足。"
}
```

## 分頁

### 請求（後端 DTO 欄位）

| 欄位 | 型別 | 說明 |
|------|------|------|
| `page` | `number` | 目前頁碼（從 1 開始）|
| `pageSize` | `number` | 每頁筆數 |

### 回應

| 欄位 | 型別 | 說明 |
|------|------|------|
| `items` | `T[]` | 當頁資料 |
| `totalCount` | `number` | 總筆數 |
| `pageNumber` | `number` | 目前頁碼 |
| `pageSize` | `number` | 每頁筆數 |

### 前端 TypeScript 型別（來自共用套件）

```ts
export interface PageResult<T> {
  items: T[]
  totalCount: number
  pageNumber: number
  pageSize: number
}

export interface ApiResult<T> {
  success: boolean
  data: T
  errorCode: string | null
  message: string | null
}
```

## 模糊查詢（Searches）

欄位型模糊搜尋統一用 `searches` 陣列傳遞，格式為 `"FieldName:value"`，條件之間 AND 連接：

```json
{
  "page": 1,
  "pageSize": 20,
  "searches": ["Code:AB", "Name:倉"]
}
```

| 約束 | 說明 |
|------|------|
| MUST | 前端每個搜尋欄位組合成 `"FieldName:value"` 字串放入陣列 |
| MUST | `FieldName` 大小寫需與後端 `_containsSearchFields` 定義一致 |
| MUST | 多條件之間為 AND 關係 |

## Enum 序列化

| 約束 | 說明 |
|------|------|
| MUST | API 傳輸的 Enum 值為**全大寫字串**（如 `"ACTIVE"`、`"ROOMTEM"`）|
| MUST | 前端比對或賦值使用 `.toUpperCase()` 或 `nameof` 轉大寫 |
| MUST NOT | 用數字表示 Enum 值 |

> 外部合作 API 例外：Mock 或對接外部 API 時，Enum 格式以 `core/external-contract.md` 的外部合約為準；內部 Service 層再轉回專案標準全大寫格式。

## 錯誤碼格式

格式：`{系統代號}-{領域前綴}-{代碼}`

| 範例 | 說明 |
|------|------|
| `{SYS}-COM-40001` | 系統通用錯誤 |
| `{SYS}-INV-40005` | 庫存領域錯誤 |
| `{SYS}-TSK-40010` | 任務領域錯誤 |

## HTTP Verb 慣例

| 操作 | Verb | 說明 |
|------|------|------|
| 查詢（含分頁/篩選）| `POST` | Body 傳遞查詢條件 |
| 新增 | `POST` | |
| 匯入 | `POST` | |
| 更新（含狀態變更）| `PATCH` | |
| 刪除 | `DELETE` | |

## 路由格式

Controller 名稱代表資源名稱，base route 固定為：

```csharp
[Route("api/[controller]")]
```

禁止使用：

```csharp
[Route("api/[controller]/[action]")]
```

Action route 只放短動作、子資源或特殊流程，不重複 Controller 資源名稱，也不使用完整 method 名稱。

| 情境 | Route 命名 |
|------|------------|
| 查詢 | `query` |
| 新增 | `create` |
| 更新 | `update` |
| 子資源更新 | `{sub-resource}/update` |
| 批次操作 | 動作後加 `-batch` |
| 外部系統流程 | 以子路徑分組，例如 `erp/forward` |
| 特殊檔案或文件 | 使用明確名詞，例如 `shipment-pdf` |

路徑規劃範例：

```text
/api/SalesOrder/query
/api/SalesOrder/{salesOrderId}/product-prices
/api/SalesOrder/product-prices/query

/api/SalesOrder/update
/api/SalesOrder/status/update
/api/SalesOrder/status/update-batch
/api/SalesOrder/items/update

/api/SalesOrder/erp/forward
/api/SalesOrder/erp/forward-batch
/api/SalesOrder/erp/cancel
/api/SalesOrder/erp/cancel-batch
/api/SalesOrder/erp/sync

/api/SalesOrder/create
/api/SalesOrder/lock
/api/SalesOrder/unlock
/api/SalesOrder/shipment-pdf
```
