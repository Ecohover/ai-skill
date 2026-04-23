# TypeScript 提交前自審清單

提交程式碼前逐項確認：

- [ ] **型別安全** 是否完全避開 `any`？API 回傳是否有對應 interface？
- [ ] **命名** Vue SFC 檔名是否 PascalCase？Composable 是否以 `use` 開頭？
- [ ] **環境變數** 是否透過 `import.meta.env.VITE_*`，而非 hardcode URL？
- [ ] **API 模組** 新增的 API 呼叫是否放在 `composables/api/modules/` 下？
- [ ] **路由** 新 View 是否已加入 router，並使用 `() => import(...)` lazy load？
- [ ] **路由路徑** 是否包含 `/oms/` 或 `/wms/` 前綴？（必須沒有，base 已設定）
- [ ] **Shared 優先** `ApiResult`、`PageResult` 是否從 `@dachan/shared` 引入？
- [ ] **Searches** 模糊查詢欄位是否組合成 `"FieldName:value"` 格式的陣列？
- [ ] **Enum 比對** 是否使用 `.toUpperCase()` 比對大寫 Enum 字串？
- [ ] **樣式** 是否優先使用 TailwindCSS utility class，避免多餘自訂 CSS？
- [ ] **Element Plus** 是否優先使用 Element Plus 組件？
- [ ] **Store** 是否只存跨組件共享狀態，頁面內部狀態用 `ref`/`reactive`？
