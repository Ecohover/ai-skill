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

## 3. 資料寫入與異動操作

| 情境 | 回傳 HttpStatusCode | 回傳內容 | 說明 |
|------|---------------------|----------|------|
| 成功且需回傳資料 | `200 OK` / `201 Created` | 新增/修改後的 JSON 物件 | 適用於需回傳最新欄位（如自動產生 ID）的情境 |
| 成功但不需回傳資料 | `200 OK` | `null` 或空物件 | 常用於 `DELETE` 或純狀態更新的動作。**嚴禁使用 204**，以確保回應能被專案的中介軟體統一包裝。 |

## 4. 處理第三方 API (如 LINE API) 查無資料

當後端依賴的第三方服務回傳 `404`（例如使用者尚未加入 LINE Bot），且此屬於「正常業務分支」而非系統錯誤時：

| 約束 | 說明 |
|------|------|
| MUST NOT | 在系統中將第三方的 `404` 直接作為 Exception 拋出並轉發給前端。這會觸發前端的「全域錯誤攔截器」，跳出錯誤彈窗導致中斷使用者的操作流程。 |
| MUST | 將查無資料視為合法的查詢結果。API 改回傳 `200 OK` 搭配 `null` 資料。 |
| OR | API 改回傳 `200 OK` 搭配自訂 DTO（包含 `IsFound` 等判斷欄位），例如：`{ "isFound": false, "profile": null }`，供前端依此決定 UI 走向。 |

## 5. 後端狀態碼實作機制 (例外處理)

在 C# 後端實作時，Controller 層 **不可** 手動回傳 `NotFound()`、`BadRequest()` 等狀態碼。所有業務邏輯異常（包含資料不存在、格式錯誤），皆須透過拋出例外來處理。

| 約束 | 說明 |
|------|------|
| MUST NOT | Controller 方法內直接回傳 `return NotFound()` 或 `return BadRequest()`。Controller 只負責回傳 `Ok(result)` 或 `Ok()`。 |
| MUST | 業務錯誤與狀態碼必須定義於領域專屬的 Error 類別中（例如 `ItemError.cs`），並明確指定 `HttpStatusCode`（如 `HttpStatusCode.NotFound`）。 |
| MUST | 在 Service 層判斷資料不存在或檢核失敗時，拋出例外（例如 `throw new BusinessException(ItemError.ItemNotFound);`），交由全域中介軟體統一攔截並轉換狀態碼與標準錯誤外殼。 |

## 6. 嚴禁使用 204 No Content

專案中 **絕對禁止** 任何 API 回傳 `204 No Content`：

| 約束 | 說明 |
|------|------|
| MUST NOT | **任何情境下皆不可回傳 `204 No Content`**。 |
| 說明 | `204` 狀態碼會被 `DachanApiResponseEnvelopeMiddleware` 略過且 *無任何 Body*。使用 `204` 會破壞 API 合約，導致 Response Body 無法被大成標準的格式外殼統一包裝（如 `success`, `errorCode`, `traceId` 等）。 |
