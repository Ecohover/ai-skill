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
| MUST NOT | 在模組內 hardcode base URL，由 `api-client.ts` 統一管理 |
| MUST NOT | 在 API module 內 unwrap `ApiResult<T>` 成裸資料；view/composable 需透過 `result.data` 取值 |
| MUST NOT | 用 `ApiResult.statusCode` 做流程控制；該欄位只作顯示/診斷資訊，可能是 `"OK"` 這類文字 |

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
