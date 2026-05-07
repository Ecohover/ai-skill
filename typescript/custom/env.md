# Vue Frontend — 環境變數

## 規則

| 約束 | 說明 |
|------|------|
| MUST | 所有環境變數以 `VITE_` 開頭 |
| MUST | 存取使用 `import.meta.env.VITE_*` |
| MUST | 預設值定義在 `.env` 或 `.env.development` |
| MUST NOT | 在程式碼中 hardcode API base URL |
| MUST NOT | 將敏感資訊（token、密碼）放入 `.env` 並 commit |

## 環境變數清單（範例）

| 變數 | 用途 |
|------|------|
| `VITE_{APP}_API_BASE_URL` | 後端 API base URL |
| `VITE_BASE_URL` | 前端靜態資源 base（CDN 切換用）|

## Runtime Config（部署覆蓋）

`index.html` 中 runtime config 路徑必須用 `%BASE_URL%`，不要寫死前綴：

```html
<script src="%BASE_URL%config.js" onerror="void(0)"></script>
```

api-client.ts 中優先使用 runtime config，fallback 至環境變數：

```ts
const baseURL = (window as any).__APP_API_URL__
  ?? import.meta.env.VITE_APP_API_BASE_URL
  ?? ''
```
