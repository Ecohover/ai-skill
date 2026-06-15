# CommonUtils API Response 規範

## 回應封裝

所有 API 回應由共用套件提供的標準 middleware 統一封裝成 `{Project}ApiResponse<T>`。

Controller 禁止手動封裝：

- `{Project}ApiResponse<T>`
- `ApiResult<T>`
- 自訂 response wrapper

若服務已由 filter 或既有標準機制產生 `{Project}ApiResponse<T>`，共用 middleware 必須辨識已包裝 response 並透傳，禁止形成巢狀 envelope。

反向代理或 Ingress 使用前綴路徑時，例如 `/dev/oms/api`，服務內部 path 可能被 rewrite 成 `/Item/query`。API response middleware 應同時考慮 path 與 forwarded prefix，不得造成本機與 K8S 包裝行為不一致。

## JSON 欄位

```json
{
  "success": true,
  "data": { },
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

## 名稱替換

`{Project}ApiResponse<T>` 是抽象名稱，實際型別由開發單位 profile 決定。

## 清單 Response

清單 API 應回傳列表頁需要的摘要 DTO，不得把明細頁才需要的大型集合、request / response body、完整 audit trail 或 step results 一起塞進列表 DTO。

完整明細應由 detail API 依 id 查詢。若 entity 本身包含大型集合，repository 查詢清單時應使用 projection 或專用 summary DTO，避免查出後再丟棄。

## 大型 Payload Response

若系統需要保存外部 API 原始 request / response、排程 step response、匯入檔案內容或其他 MB 等級資料，API response 設計應拆成 metadata 與 payload 兩段：

1. 列表與一般明細只回傳 metadata，例如是否有 payload、原始大小、壓縮大小、content type、payload id。
2. 原始 payload 需透過明確 endpoint 按需讀取，不得隨列表或 detail 初始化一起回傳。
3. Repository 查詢列表時必須使用 projection 或專用 query，避免把大型 payload 從 DB 讀出後再丟棄。
4. DB 內部可使用 GZip binary 儲存 payload；CommonUtils / 服務端負責解壓後輸出標準 API response，前端不處理 DB 壓縮格式。
5. HTTP 傳輸壓縮由 ASP.NET Core / ingress / reverse proxy 處理，不能取代 DB payload 拆分。
