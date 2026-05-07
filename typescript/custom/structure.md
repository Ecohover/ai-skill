# Vue Frontend — 目錄結構 / 路由 / Pinia

## Monorepo 結構

```
src/
  apps/
    {app-a}/src/
      composables/api/
        api-client.ts          ← axios instance（含 interceptor）
        modules/               ← 每個後端模組一個檔案
      layouts/
      router/
      stores/
      views/                   ← 依業務領域分資料夾
    {app-b}/src/
      composables/api/
        api-client.ts
        modules/
      views/
  packages/
    shared/src/
      api/createApiClient.ts   ← axios factory（不含 baseURL）
      types/common.ts          ← ApiResult<T>, PageResult<T>
      index.ts
```

## 目錄職責

| 路徑 | 職責 |
|------|------|
| `composables/api/modules/` | 後端 API 模組封裝（型別 + 呼叫方法）|
| `composables/api/api-client.ts` | 各 app 的 axios instance，注入 baseURL |
| `layouts/` | 頁面骨架（Header / Sidebar 外框）|
| `router/` | 路由定義，所有 view import 必須 lazy load |
| `stores/` | Pinia 狀態管理 |
| `views/` | 頁面組件，依業務領域分資料夾 |
| `styles/` | 全域樣式、TailwindCSS 入口 |

## 規則

| 約束 | 說明 |
|------|------|
| MUST | 共用型別（`ApiResult`、`PageResult`）從共用套件引入（如 `@{project}/shared`），不在各 app 重複定義 |
| MUST NOT | View 直接呼叫 axios，必須透過 composable 或 api module |
| MUST NOT | Store 直接呼叫 axios，透過 api module 取得資料 |

## api-client.ts 範本

```ts
// src/apps/{app}/src/composables/api/api-client.ts
import { createApiClient } from '@{project}/shared'

const baseURL = (window as any).__APP_API_URL__
  ?? import.meta.env.VITE_APP_API_BASE_URL
  ?? ''

export const useApiClient = (requireAuth = true) =>
  createApiClient(requireAuth, { baseURL, unauthorizedRedirect: '/' })
```

## 路由範本

```ts
// router/index.ts
const router = createRouter({
  history: createWebHistory('/{app}/'),
  routes: [
    {
      path: '/',
      component: () => import('../layouts/Default.vue'),
      children: [
        {
          path: 'management/entity',
          name: '{app}-entity',
          component: () => import('../views/Management/Entity.vue'),
        },
      ],
    },
  ],
})
```

## Pinia Store 範本

```ts
// stores/auth.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useAuthStore = defineStore('auth', () => {
  const token = ref(localStorage.getItem('token') ?? '')
  const isAuthenticated = computed(() => token.value !== '')

  const setToken = (newToken: string) => {
    token.value = newToken
    localStorage.setItem('token', newToken)
  }

  return { token, isAuthenticated, setToken }
})
```
