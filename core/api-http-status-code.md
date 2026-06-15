# FE/BE API HttpStatusCode 合約

本文件定義 API 開發時，不同請求情境下的 HTTP 狀態碼回傳規範。

## 1. 查詢單一特定資源 (例如 `GET /items/{id}`)

| 資源狀態 | 回傳 HttpStatusCode | 回傳內容 | 說明 |
|----------|---------------------|----------|------|
| 資源存在 | `200 OK` | 該資源的 JSON 物件 | 例如回傳 `{ "id": 123, "name": "Apple" }` |
| 資源不存在 | `404 Not Found` | 錯誤訊息 JSON | ID 格式正確，但資料庫查無此資料 |
| ID 格式錯誤 | `400 Bad Request` | 錯誤訊息 JSON | 例如：要求 UUID，卻傳入不合法字串 |

## 2. 查詢複數資源或條件篩選 (例如 `POST /item/query` 或 `GET /items?name=apple`)

| 篩選結果 | 回傳 HttpStatusCode | 回傳內容 | 說明 |
|----------|---------------------|----------|------|
| 有符合資料 | `200 OK` | 陣列 `[...]` 或分頁物件 | 正常回傳列表或分頁結構。 |
| 查無資料 | `200 OK` | **空陣列 `[]`** 或空分頁物件 | **MUST NOT 回傳 404 或 204**。篩選不到資料為合法查詢結果，前端需能直接執行陣列操作 (`.map()`)。分頁物件範例：`{ "list": [], "totalCount": 0, "pageNumber": 1, "pageSize": 20 }` |

## 3. 後端狀態碼實作機制 (例外處理)

在 C# 後端實作時，Controller 層 **不可** 手動回傳 `NotFound()`、`BadRequest()` 等狀態碼。所有業務邏輯異常（包含資料不存在、格式錯誤），皆須透過拋出例外來處理。

| 約束 | 說明 |
|------|------|
| MUST NOT | Controller 方法內直接回傳 `return NotFound()` 或 `return BadRequest()`。Controller 只負責回傳 `Ok(result)` 或 `Ok()`。 |
| MUST | 業務錯誤與狀態碼必須定義於領域專屬的 Error 類別中（例如 `ItemError.cs`），並明確指定 `HttpStatusCode`（如 `HttpStatusCode.NotFound`）。 |
| MUST | 在 Service 層判斷資料不存在或檢核失敗時，拋出例外（例如 `throw new BusinessException(ItemError.ItemNotFound);`），交由全域中介軟體統一攔截並轉換狀態碼與標準錯誤外殼。 |
