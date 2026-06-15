# Vue Frontend — API 模組規範

## 規則

| 約束 | 說明 |
|------|------|
| MUST | 每個模組頂部定義所有涉及的 interface（Query / Request / Response）|
| MUST | 方法命名與後端 Controller action 對應（`GetWarehouse`、`CreateWarehouse`）|
| MUST | 每個方法有明確泛型回傳型別（`Promise<ApiResult<T>>`）|
| MUST | 清單回應型別使用 `PagedResult<T>`，與後端 `PagedResult<T>` 命名一致 |
| MUST | 使用 shared API helper（如 `apiResult` / `apiVoid`）保留完整標準 response |
| MUST | HTTP 狀態判斷使用 shared API client 提供的原生 HTTP status（如 `error.status`），不得使用 envelope 內的 `ApiResult.statusCode` |
| MUST | 多服務 token 依 scope 分開保存，例如 `auth.identity`、`auth.portal`、`auth.oms`、`auth.scheduler` |
| MUST | 需要呼叫附屬服務 API 時，使用 identity token 換取目標服務 scoped token，並只在該目標 API client 使用 |
| MUST NOT | 在模組內 hardcode base URL，由 `api-client.ts` 統一管理 |
| MUST NOT | 在 API module 內 unwrap `ApiResult<T>` 成裸資料；view/composable 需透過 `result.data` 取值 |
| MUST NOT | 用 `ApiResult.statusCode` 做流程控制；該欄位只作顯示/診斷資訊，可能是 `"OK"` 這類文字 |
| MUST NOT | 用 Portal scoped token 呼叫 OMS / Scheduler API，或用 OMS scoped token 呼叫 Scheduler API |
| MUST NOT | 換取 Scheduler 等附屬服務 token 時覆蓋目前 app 的 token，例如不得用 `auth.scheduler` 覆蓋 `auth.oms` |

## 兩層 Token / 跨服務 API

登入後第一層 token 存為 `auth.identity`。Portal 頁面啟動時以 `auth.identity` 換取 `auth.portal`；進入 OMS 時以 `auth.identity` 換取 `auth.oms`；OMS 內若需要呼叫 Scheduler 管理 API，再以 `auth.identity` 換取 `auth.scheduler`。

`auth.scheduler` 是 OMS 內特定 HTTP client 使用的 token，不代表使用者跳轉到 Scheduler 獨立頁，也不得覆蓋 `auth.oms`。

## 大型 Payload 前端載入

MB 等級原始內容不得在列表或 detail 初始化時載入，例如完整 `RequestJson`、`ResponseJson`、外部 API 原文、排程 step response。

| 約束 | 說明 |
|------|------|
| MUST | 列表 API 使用 summary type，不依賴大型 payload 欄位 |
| MUST | Detail 頁先顯示 metadata；使用者展開「Request JSON」「Response JSON」或點擊查看時才呼叫 payload endpoint |
| MUST | Payload 首次讀取後暫存在 component state 或 query cache；收合再展開不得重複呼叫，除非使用者明確刷新 |
| MUST | 展開區需有 loading、空內容與錯誤狀態；可顯示原始大小或壓縮前大小協助判斷等待時間 |
| SHOULD | 對 MB 級 JSON 避免同步 `JSON.parse` 與完整 pretty render；優先使用純文字、lazy render 或 virtualized JSON viewer |
| MUST NOT | 讓前端處理 DB 內部壓縮格式；前端只接收後端解壓後的標準 JSON 或文字 |

## Searches 組合方式

```ts
// 模糊查詢欄位組合成 "FieldName:value" 陣列
const searches: string[] = []
if (code.value) { searches.push(`Code:${code.value}`) }
if (name.value) { searches.push(`Name:${name.value}`) }

await api.GetWarehouse({ page: 1, pageSize: 20, searches })
```

## API 模組範本

```ts
// composables/api/modules/Warehouse.ts
import { useApiClient } from '../api-client'
import { apiResult, apiVoid } from '@{project}/shared'
import type { ApiResult, PagedResult } from '@{project}/shared'

export interface Warehouse {
  id: string
  code: string
  name: string
  status: string
}

export interface QueryWarehouse {
  page: number
  pageSize: number
  searches?: string[]
}

export interface CreateWarehouseRequest {
  code: string
  name: string
  type: string
}

export const useWarehouse = () => {
  const client = useApiClient()

  return {
    GetWarehouse: (query: QueryWarehouse): Promise<ApiResult<PagedResult<Warehouse>>> =>
      apiResult(client.post<ApiResult<PagedResult<Warehouse>>>('/api/Warehouse/GetWarehouse', query)),

    CreateWarehouse: (payload: CreateWarehouseRequest): Promise<ApiResult<{ id: string; code: string }>> =>
      apiResult(client.post<ApiResult<{ id: string; code: string }>>('/api/Warehouse/CreateWarehouse', payload)),

    UpdateWarehouse: (payload: Partial<Warehouse> & { id: string }): Promise<ApiResult<void>> =>
      apiVoid(client.patch<ApiResult<void>>('/api/Warehouse/UpdateWarehouse', payload)),
  }
}
```

## View 使用範本

```vue
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useWarehouse } from '@/composables/api/modules/Warehouse'
import type { Warehouse } from '@/composables/api/modules/Warehouse'

const warehouseList = ref<Warehouse[]>([])
const isLoading = ref(false)
const searchCode = ref('')

const api = useWarehouse()

const loadWarehouseList = async () => {
  isLoading.value = true
  const searches: string[] = []
  if (searchCode.value) { searches.push(`Code:${searchCode.value}`) }

  const result = await api.GetWarehouse({ page: 1, pageSize: 20, searches })
  if (result.success) {
    warehouseList.value = result.data.list
  }
  isLoading.value = false
}

onMounted(loadWarehouseList)
</script>
```
