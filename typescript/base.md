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
