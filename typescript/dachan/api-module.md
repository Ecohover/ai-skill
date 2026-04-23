# Dachan Frontend — API 模組規範

## 規則

| 約束 | 說明 |
|------|------|
| MUST | 每個模組頂部定義所有涉及的 interface（Query / Request / Response）|
| MUST | 方法命名與後端 Controller action 對應（`GetWarehouse`、`CreateWarehouse`）|
| MUST | 每個方法有明確泛型回傳型別（`Promise<ApiResult<T>>`）|
| MUST NOT | 在模組內 hardcode base URL，由 `api-client.ts` 統一管理 |

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
import type { ApiResult, PageResult } from '@dachan/shared'

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
    GetWarehouse: (query: QueryWarehouse): Promise<ApiResult<PageResult<Warehouse>>> =>
      client.post('/api/Warehouse/GetWarehouse', query),

    CreateWarehouse: (payload: CreateWarehouseRequest): Promise<ApiResult<{ id: string; code: string }>> =>
      client.post('/api/Warehouse/CreateWarehouse', payload),

    UpdateWarehouse: (payload: Partial<Warehouse> & { id: string }): Promise<ApiResult<void>> =>
      client.patch('/api/Warehouse/UpdateWarehouse', payload),
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
    warehouseList.value = result.data.items
  }
  isLoading.value = false
}

onMounted(loadWarehouseList)
</script>
```
