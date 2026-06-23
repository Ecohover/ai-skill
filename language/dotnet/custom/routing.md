# .NET Backend — Controller Routing 規範

## API 路徑命名

Controller 名稱代表資源名稱，例如 `SalesOrderController` 對應 `/SalesOrder`。Action route 不得重複 Controller 資源名稱，也不得使用完整 method 名稱。

`api` 前綴由 K8s/Ingress 統一處理，Controller route 不包含 `api/`。

| 情境 | Route 命名 |
|------|------------|
| 查詢 | `query` |
| 新增 | `create` |
| 更新 | `update` |
| 子資源更新 | `{sub-resource}/update` |
| 批次操作 | 動作後加 `-batch` |
| 外部系統流程 | 以子路徑分組，例如 `erp/forward` |
| 特殊檔案或文件 | 使用明確名詞，例如 `shipment-pdf` |

## HTTP Verb

| 情境 | Verb |
|------|------|
| 查詢 / 新增 / 匯入 / 流程操作 | `POST` |
| 更新 / 狀態變更 / 子資源更新 | `PATCH` |
| 指定資源或文件讀取 | `GET` |
| 刪除 | `DELETE` |

## 範例

```text
POST  /SalesOrder/query
GET   /SalesOrder/{salesOrderId}/product-prices
POST  /SalesOrder/product-prices/query
PATCH /SalesOrder/update
PATCH /SalesOrder/status/update
PATCH /SalesOrder/status/update-batch
PATCH /SalesOrder/items/update
POST  /SalesOrder/erp/forward
POST  /SalesOrder/erp/forward-batch
POST  /SalesOrder/erp/cancel
POST  /SalesOrder/erp/cancel-batch
POST  /SalesOrder/erp/sync
POST  /SalesOrder/lock
POST  /SalesOrder/unlock
GET   /SalesOrder/shipment-pdf
```

## Controller 範例

```csharp
[ApiController]
[Route("[controller]")]
public class WarehouseController(IWarehouseService _warehouseService) : Controller
{
    [HttpPost("query")]
    [ProducesResponseType<PageResultDto<OutWarehouseDto>>((int)HttpStatusCode.OK)]
    public async Task<IActionResult> QueryAsync(
        InQueryWarehouseDto queryDto,
        CancellationToken cancellationToken)
    {
        var result = await _warehouseService.QueryAsync(queryDto, cancellationToken);
        return Ok(result);
    }
}
```
