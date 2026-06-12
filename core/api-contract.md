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

後端清單查詢 DTO 必須繼承 `DachanApiQueryRequest`，不可在各服務自建分頁 request 型別。

| 欄位 | 型別 | 說明 |
|------|------|------|
| `page` | `number` | 目前頁碼（從 1 開始）|
| `pageSize` | `number` | 每頁筆數 |

### 回應

| 欄位 | 型別 | 說明 |
|------|------|------|
| `list` | `T[]` | 當頁資料 |
| `totalCount` | `number` | 總筆數 |
| `pageNumber` | `number` | 目前頁碼 |
| `pageSize` | `number` | 每頁筆數 |

### 前端 TypeScript 型別（來自共用套件）

```ts
export interface PagedResult<T> {
  list: T[]
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

前端 API module 必須回傳完整 `ApiResult<T>`，由 view/composable 從 `result.data` 取資料；清單資料從 `result.data.list` 取值。不得在 API module 內自行 unwrap 成裸資料。

`ApiResult.statusCode` 僅作為後端 envelope 診斷資訊，可能因後端 enum serializer 呈現為文字（如 `"OK"`）。前端不得用 `ApiResult.statusCode` 判斷 HTTP 狀態；HTTP flow control 必須使用原生 HTTP response status（例如 shared API client 拋出的 `error.status` / `error.response.status`），業務成功失敗以 `success`、`errorCode`、`message` 判斷。

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
| MUST | 自家前端 API 傳輸的 Enum 值為**全大寫 snake_case 字串**（如 `"ACTIVE"`、`"ROOMTEM"`、`"SENT_TO_ERP_SUCCESS"`）|
| MUST | 前端收到 API enum 字串時，以全大寫 snake_case 值比對；後端 C# 內部邏輯依 `language/dotnet/custom/enum.md` 直接使用 enum 型別比對 |
| MUST NOT | 用數字表示 Enum 值 |

> 外部合作 API 例外：Mock 或對接外部 API 時，Enum 格式以 `core/external-contract.md` 的外部合約為準；內部 Service 層再轉回專案標準全大寫格式。

## 錯誤碼格式

格式：`{系統代號}-{領域前綴}-{代碼}`

| 範例 | 說明 |
|------|------|
| `{SYS}-COM-40001` | 系統通用錯誤 |
| `{SYS}-INV-40005` | 庫存領域錯誤 |
| `{SYS}-TSK-40010` | 任務領域錯誤 |

HTTP Verb 與 route 命名依 `core/api-routing.md`。
