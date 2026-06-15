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

## 大型 Payload 與原始內容

列表 API 與一般明細 API 不得預設回傳 MB 等級原始內容，例如完整 `RequestJson`、`ResponseJson`、外部 API 原文、匯入檔案內容、完整 step response 或大型 audit trail。

| 約束 | 說明 |
|------|------|
| MUST | 列表 API 回傳 summary DTO，只包含列表顯示、排序、篩選與連結所需欄位 |
| MUST | 大型原始內容使用獨立 payload endpoint 延遲載入，例如 `GET /{resource}/{id}/payloads/response` |
| MUST | 主文件只保存 payload metadata，例如 `PayloadId`、`Bytes`、`ContentType`、`Compression`、`HasPayload` |
| MUST | 後端可將 payload 以 GZip 等格式壓縮存放於獨立 collection / storage，但 API 回傳給前端時應是已解壓的標準 JSON 或文字 |
| MUST | HTTP 傳輸壓縮交給 Web server / middleware / ingress 的 gzip 或 br；這與 DB 內部壓縮是兩件事 |
| MUST NOT | 讓前端直接處理資料庫壓縮格式或 Mongo binary payload |
| MUST NOT | 為了保存壓縮內容，把 binary 轉 base64 後塞回主文件的大字串欄位 |

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

## Enum Metadata API

後端提供給前端下拉、篩選或狀態顯示使用的 enum option 必須透過標準 enum metadata API 回傳完整 `ApiResult<Record<string, EnumOption[]>>`，不得在前端 hardcode 同一份選項。

| 約束 | 說明 |
|------|------|
| MUST | API 回傳 `value`, `i18nKey`, `description`, `metadata`，並由標準 response middleware 包裝 |
| MUST | `metadata` 只能由 enum value 上 attribute 的 `[EnumMetadataField("metadataKey")]` property 宣告產生 |
| MUST | enum value 上的業務設定 attribute 使用 named argument，例如 `[OrderSetting(printDescription: "...")]`、`[ErpSetting(erpDocType: "...")]`，避免位置參數隱藏語意 |
| MUST NOT | enum metadata service 內不得 hardcode 特定業務欄位，例如 ERP 相關 key |
| MUST NOT | 沒有 metadata attribute 的 enum value 不得補領域特定預設值 |
| MUST | 若多個 attribute 輸出同名 metadata key，服務啟動時必須失敗 |

Enum metadata 通常在服務啟動時組合並快取，反射不在 request path；但新增 metadata attribute 仍需測試 response shape。

## Auth / Permission Contract

採用 Portal + CommonUtils auth 的系統，Token 與 UserInfo 欄位命名需一致：

| 約束 | 說明 |
|------|------|
| MUST | 使用 `userId` 表示 Portal 使用者 ObjectId |
| MUST | `sub` 若需放使用者識別，應與 `userId` 一致 |
| MUST | 員工編號使用 `employeeCode` |
| MUST | 權限 claim / response 欄位使用 `permissions` |
| MUST NOT | 新 token 發出 `mongo_id`、`employee_id`、`AD`、`permission` 等舊或混淆命名 |

服務代碼使用清楚的大寫名稱，例如 `PORTAL`、`OMS`、`WMS`、`TMS`、`IMS`、`SCHEDULER`，不得再用 `SCH` 這類不易辨識縮寫。

權限 grant 使用四段格式：

```text
{SERVICE}::{RESOURCE}::{GRANT_TYPE}::{VALUE}
```

範例：

```text
OMS::ORDER::ACTION::CREATE
OMS::ORDER::COMPANY::QAS0
OMS::*::*::*
SCHEDULER::*::*::*
```

多權限不得以逗號塞在同一字串，需展開為多筆 grant。

## 錯誤碼格式

格式：`{系統代號}-{領域前綴}-{代碼}`

| 範例 | 說明 |
|------|------|
| `{SYS}-COM-40001` | 系統通用錯誤 |
| `{SYS}-INV-40005` | 庫存領域錯誤 |
| `{SYS}-TSK-40010` | 任務領域錯誤 |

HTTP Verb 與 route 命名依 `core/api-routing.md`。
