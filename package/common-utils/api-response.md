# CommonUtils API Response 規範

## 回應封裝

所有 API 回應由共用套件提供的標準 middleware 統一封裝成 `{Project}ApiResponse<T>`。

Controller 禁止手動封裝：

- `{Project}ApiResponse<T>`
- `ApiResult<T>`
- 自訂 response wrapper

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
