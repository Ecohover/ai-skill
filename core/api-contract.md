# FE/BE 共用 API 合約

> 後端以 WMS 為標準。前端開發 API 模組時必須與此合約對齊。

## 回應格式

所有 API 回應由 `ApiResponseMiddleware` 統一封裝，**Controller 禁止手動封裝**：

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
  "errorCode": "WMS-INV-40005",
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

### 前端 TypeScript 型別（來自 `@dachan/shared`）

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

## 錯誤碼格式

格式：`{系統代號}-{領域前綴}-{代碼}`

| 範例 | 說明 |
|------|------|
| `WMS-COM-40001` | WMS 通用錯誤 |
| `WMS-INV-40005` | WMS 庫存領域錯誤 |
| `WMS-TSK-40010` | WMS 任務領域錯誤 |

## HTTP Verb 慣例（WMS 標準）

| 操作 | Verb | 說明 |
|------|------|------|
| 查詢（含分頁/篩選）| `POST` | Body 傳遞查詢條件 |
| 新增 | `POST` | |
| 匯入 | `POST` | |
| 更新（含狀態變更）| `PATCH` | |
| 刪除 | `DELETE` | |

## 路由格式

`/api/{Controller}/{Action}`

範例：`POST /api/Warehouse/GetWarehouse`、`PATCH /api/Warehouse/UpdateWarehouse`
