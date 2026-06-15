# TypeScript 提交前自審清單

提交程式碼前逐項確認：

- [ ] **型別安全** 是否完全避開 `any`？API 回傳是否有對應 interface？
- [ ] **命名** Vue SFC 檔名是否 PascalCase？Composable 是否以 `use` 開頭？
- [ ] **環境變數** 是否透過 `import.meta.env.VITE_*`，而非 hardcode URL？
- [ ] **Runtime config** 是否依 app scope 優先讀取對應設定，且 dev path / base path 不會跳到正式區？
- [ ] **API 模組** 新增的 API 呼叫是否放在 `composables/api/modules/` 下？
- [ ] **Scoped token** 多服務 token 是否分開保存，沒有用 Portal token 呼叫 OMS/Scheduler 或用 Scheduler token 覆蓋 OMS token？
- [ ] **路由** 新 View 是否已加入 router，並使用 `() => import(...)` lazy load？
- [ ] **路由路徑** 是否包含 `/{app}/` 前綴？（必須沒有，base 已設定）
- [ ] **Shared 優先** `ApiResult`、`PageResult` 是否從共用套件引入？（如 `@{project}/shared`）
- [ ] **Searches** 模糊查詢欄位是否組合成 `"FieldName:value"` 格式的陣列？
- [ ] **Enum 比對** 是否使用 `.toUpperCase()` 比對大寫 Enum 字串？
- [ ] **樣式** 是否優先使用 TailwindCSS utility class，避免多餘自訂 CSS？
- [ ] **Element Plus** 是否優先使用 Element Plus 組件？
- [ ] **標準元件** 主檔列表、搜尋、操作欄與 detail 區塊是否優先使用開發單位 profile 指定的 shared package 或專案既有標準元件？
- [ ] **主檔流程** 新增、查看、編輯是否使用 detail 頁模式，而不是用 dialog/modal 承載主要編輯流程？
- [ ] **Detail 頁操作** 是否使用頁首「編輯 / 儲存 / 取消」切換狀態，並參考商品/客戶主檔作法？
- [ ] **Audit Log UI** 需要稽核紀錄的 detail 頁是否使用 `EntityAuditPanel`，並以 drawer 查詢完整異動紀錄？
- [ ] **Store** 是否只存跨組件共享狀態，頁面內部狀態用 `ref`/`reactive`？
