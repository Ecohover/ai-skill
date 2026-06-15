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

多 app 共用前端部署時，runtime config 必須優先由 app scope 讀取，再 fallback 到通用設定。例如 Portal app 應優先讀 `__PORTAL_API_URL__` / `__PORTAL_APP_URL__`，OMS app 應優先讀 `__OMS_API_URL__` / `__OMS_APP_URL__`。

本機 VS Code debug 或 task/launch 啟動時，應由 task/launch 注入對應 runtime/env 設定；前端程式不得固定吃某一份 `config.js` 的正式或 dev URL。

服務跳轉 URL 必須保留目前部署前綴，例如 `/dev/portal`、`/dev/oms`。不得以 origin 根路徑直接組正式區 URL，避免 dev 頁面點擊後跳到正式區。
