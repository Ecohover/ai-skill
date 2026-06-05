# .NET Backend — Controller Routing 規範

## API 路徑命名

Controller 名稱代表資源名稱，例如 `SalesOrderController` 對應 `/api/SalesOrder`。Action route 不得重複 Controller 資源名稱，也不得使用完整 method 名稱。

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
POST  /api/SalesOrder/query
GET   /api/SalesOrder/{salesOrderId}/product-prices
POST  /api/SalesOrder/product-prices/query
PATCH /api/SalesOrder/update
PATCH /api/SalesOrder/status/update
PATCH /api/SalesOrder/status/update-batch
PATCH /api/SalesOrder/items/update
POST  /api/SalesOrder/erp/forward
POST  /api/SalesOrder/erp/forward-batch
POST  /api/SalesOrder/erp/cancel
POST  /api/SalesOrder/erp/cancel-batch
POST  /api/SalesOrder/erp/sync
POST  /api/SalesOrder/lock
POST  /api/SalesOrder/unlock
GET   /api/SalesOrder/shipment-pdf
```

## Controller 範例

```csharp
[ApiController]
[Route("api/[controller]")]
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
