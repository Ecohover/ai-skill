# FE/BE API Routing 合約

## HTTP Verb 慣例

| 操作 | Verb | 說明 |
|------|------|------|
| 查詢（含分頁/篩選）| `POST` | Body 傳遞查詢條件 |
| 新增 | `POST` | |
| 匯入 | `POST` | |
| 更新（含狀態變更）| `PATCH` | |
| 刪除 | `DELETE` | |

## 路由格式

Controller 名稱代表資源名稱，base route 固定為：

```csharp
[Route("api/[controller]")]
```

禁止使用：

```csharp
[Route("api/[controller]/[action]")]
```

Action route 只放短動作、子資源或特殊流程，不重複 Controller 資源名稱，也不使用完整 method 名稱。

| 情境 | Route 命名 |
|------|------------|
| 查詢 | `query` |
| 新增 | `create` |
| 更新 | `update` |
| 子資源更新 | `{sub-resource}/update` |
| 批次操作 | 動作後加 `-batch` |
| 外部系統流程 | 以子路徑分組，例如 `erp/forward` |
| 特殊檔案或文件 | 使用明確名詞，例如 `shipment-pdf` |

```text
/api/SalesOrder/query
/api/SalesOrder/{salesOrderId}/product-prices
/api/SalesOrder/product-prices/query
/api/SalesOrder/update
/api/SalesOrder/status/update
/api/SalesOrder/status/update-batch
/api/SalesOrder/items/update
/api/SalesOrder/erp/forward
/api/SalesOrder/erp/forward-batch
/api/SalesOrder/erp/cancel
/api/SalesOrder/erp/cancel-batch
/api/SalesOrder/erp/sync
/api/SalesOrder/create
/api/SalesOrder/lock
/api/SalesOrder/unlock
/api/SalesOrder/shipment-pdf
```
