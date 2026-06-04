# TypeScript / Vue 3 基礎規則

## TypeScript

| 約束 | 說明 |
|------|------|
| MUST | 完全啟用 `strict` 模式 |
| MUST | 所有 API 回傳型別必須明確定義 interface |
| MUST | 禁止使用 `any`，必要時用 `unknown` 再做型別收窄 |
| MUST | 函式參數與回傳型別明確標註 |
| MUST NOT | 使用 `as any` 強制轉型 |

## Vue 組件

| 約束 | 說明 |
|------|------|
| MUST | 使用 `<script setup lang="ts">` Composition API |
| MUST | Props 用 `defineProps<{}>()` 加型別定義 |
| MUST | Emits 用 `defineEmits<{}>()` 加型別定義 |
| MUST | 優先使用 Element Plus 組件 |
| MUST | 樣式優先使用 TailwindCSS utility class |
| MUST NOT | 使用 Options API（`export default { data() {} }`）|
| MUST NOT | 在 `<template>` 中寫複雜邏輯，應抽至 composable |

## Dachan Shared 元件與主檔頁面

| 約束 | 說明 |
|------|------|
| MUST | OMS/WMS/TMS 既有共用元件可滿足需求時，優先使用 `@dachan/shared` 或專案既有標準元件 |
| MUST | 主檔列表頁優先參考商品、客戶、訂單等既有 List/SearchTable 版型，保持搜尋區、列表外框、分頁與操作欄一致 |
| MUST | 主檔新增、查看、編輯優先使用 detail 頁模式，參考商品/客戶主檔的 `DetailPageShell`、`DetailPageHeader`、`DetailFieldSection` |
| MUST | detail 頁的編輯行為使用頁首「編輯 / 儲存 / 取消」動作切換唯讀與可編輯狀態 |
| MUST NOT | 用 dialog/modal 承載主檔主要新增或編輯流程；dialog 只適合確認、提示或輕量子資料 |
| MUST NOT | 自行刻搜尋框、列表容器、表格操作欄或 detail 區塊樣式，除非現有標準元件無法支援且已說明原因 |

## Audit Log UI

| 約束 | 說明 |
|------|------|
| MUST | 需要顯示 audit log 的主檔 detail 頁，優先使用既有 `EntityAuditPanel` |
| MUST | detail footer 顯示 entity 內嵌的最近異動紀錄，完整紀錄透過既有 AuditLog API 查詢 |
| MUST | 完整異動紀錄呈現方式參考商品/客戶主檔既有 drawer pattern |
| MUST NOT | 在執行紀錄或同步紀錄頁重複呈現完整 OldValue / NewValue；若需要追溯異動細節，應連結或查詢 audit log |

## 命名

| 約束 | 說明 |
|------|------|
| MUST | Vue SFC 檔名使用 PascalCase（`OrderDetail.vue`）|
| MUST | Composable 以 `use` 開頭（`useApiClient`）|
| MUST | Pinia store 以 `use` 開頭並以 `Store` 結尾（`useAuthStore`）|
| MUST | 事件 handler 以 `handle` 開頭（`handleSubmit`）|
| MUST | interface / type 名稱使用 PascalCase |

## Pinia Store

| 約束 | 說明 |
|------|------|
| MUST | 使用 Composition API 風格（`defineStore('name', () => {})`）|
| MUST | Store 只存「跨組件共享」的狀態，頁面內部狀態用 `ref`/`reactive` |
| MUST NOT | Store 直接操作 DOM 或呼叫 router |

## 路由

| 約束 | 說明 |
|------|------|
| MUST | 所有 View import 使用 `() => import(...)` lazy load |
| MUST | `createWebHistory` base 設為 `/{app}/`（各 app 自己的前綴）|
| MUST NOT | 路由 `path` 或 `router.push()` 包含 `/{app}/` 前綴（base 已設定，重複會變 `/{app}/{app}/`）|
| MUST | 需要登入的路由透過 Navigation Guard 統一保護 |

## 打包（Code Splitting）

| 約束 | 說明 |
|------|------|
| MUST | `vite.config.ts` 設定 `manualChunks` 分離 vendor 與 page chunk |
| MUST | vendor chunk 分三層：`vendor-vue`、`vendor-ui`、`vendor-utils` |
| MUST NOT | 將所有套件打包成單一 JS 檔 |
