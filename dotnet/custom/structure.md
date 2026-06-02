# .NET Backend — 目錄分層 / Entity / DTO / Controller / Service / Factory

## 私有套件（範例）

| 套件 | 用途 |
|------|------|
| `{Project}.CommonUtils` | 環境變數、擴充方法 |
| `{Project}.CommonUtils.Web` | ApiResponseMiddleware、HttpClientProxy |
| `{Project}.Common.EventDriven` | 異步領域事件、RabbitMQ 訊息整合 |
| `{Project}.MongoRepository` | 資料存取，自動掃描 `[UseRepository]` |

## 目錄職責

| 路徑 | 職責 |
|------|------|
| `/Controllers` | API 進入點，僅處理 Request/Response |
| `/Interfaces` | 業務邏輯介面層（Service Interfaces）|
| `/Services` | 業務邏輯實作層，必須使用 `partial class` |
| `/Domain/Entities` | 核心領域實體 |
| `/Domain/Events` | 領域事件定義 |
| `/Domain/IRepositories` | 倉儲介面定義 |
| `/Event` | 事件處理器（DomainEventHandlers、RabbitMqEventHandle）|
| `/Infrastructure/Factories` | 靜態工廠，負責 DTO ↔ Entity 物件映射 |

## Entity 規範

| 約束 | 說明 |
|------|------|
| MUST | 繼承 `AuditableEntityBase` 或實作 `ISoftDeletable` |
| MUST | 放在 `/Domain/Entities` 下 |
| MUST | 包含 `[BsonCollection("PascalCase")]` 與 `[UseRepository]` 標註 |
| MUST | 新建實體後呼叫 `entity.InitializeAudit()` |
| PREFER | 若專案採用 `Dachan.MongoRepository`，主檔 audit 欄位優先使用 CommonUtils 提供的 `IAuditFields` / `AuditBase` |
| MUST NOT | 因為有 `Dachan.MongoRepository` 就假設所有 entity 都必須啟用完整 audit log |
| MUST | 只有需要 recent audit log + 獨立 audit record 雙寫的 entity，才實作 `IEmbeddedAuditLogEntity` 並加上 `[AuditLogRetention(n)]` |

### CommonUtils Audit Log 使用原則

- 只需要主檔 audit 欄位：
  - 使用 `IAuditFields` 或 `AuditBase`
  - repository 自動寫入 `Created*` / `LastUpdated*`
- 需要 recent audit log：
  - entity 實作 `IEmbeddedAuditLogEntity`
  - class 加上 `[AuditLogRetention(10|20|100)]`
  - repository 在 `Create / Update / HardDelete(entity)` 自動 append `RecentHistories`、trim 最舊紀錄、同步寫入 `AuditRecord`
- 不需要 audit log 的 entity：
  - 不要硬套 `IEmbeddedAuditLogEntity`

```csharp
[BsonCollection("MyEntities")]
[UseRepository(typeof(FullRepository<>))]
public class MyEntity : AuditableEntityBase, IAggregateRoot
{
    [BsonId]
    public ObjectId Id { get; set; }
    public required string Code { get; set; }
    public required string Status { get; set; }
    public string? Remark { get; set; }
}
```

```csharp
[AuditLogRetention(20)]
[BsonCollection("OutboundOrders")]
[UseRepository(typeof(FullRepository<>))]
public class OutboundOrder : AuditBase, IAggregateRoot, IEmbeddedAuditLogEntity
{
    [BsonId]
    public ObjectId Id { get; set; }

    public required string OrderNo { get; set; }
}
```

## DTO 命名規則

| 類型 | 命名格式 | 範例 |
|------|----------|------|
| 新增輸入 | `InCreate{Entity}Dto` | `InCreateWarehouseDto` |
| 更新輸入 | `InUpdate{Entity}Dto` | `InUpdateWarehouseDto` |
| 查詢輸入 | `InQuery{Entity}Dto` | `InQueryWarehouseDto` |
| 狀態變更 | `InUpdate{Entity}StatusDto` | `InUpdateWarehouseStatusDto` |
| 輸出 | `Out{Entity}Dto` | `OutWarehouseDto` |

查詢 DTO 繼承 `PageQueryDto`，可選欄位加 `[JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]`。

輸出 DTO 的 Display 屬性（轉中文）定義在 DTO 內，**不進** Shared：

```csharp
public string TypeDisplay => Type?.ToLowerInvariant() switch
{
    "main" => "主倉",
    "branch" => "衛星庫",
    _ => Type ?? string.Empty
};
```

## Controller 規範

| 約束 | 說明 |
|------|------|
| MUST | Controller base route 使用 `[Route("api/[controller]")]` |
| MUST | Action route 只放短動作、子資源或特殊流程 |
| MUST NOT | 使用 `[Route("api/[controller]/[action]")]` |
| MUST NOT | 在 path 重複 Controller 資源名稱或完整 method 名稱 |
| MUST | 僅處理 Request/Response，不含商業邏輯 |
| MUST NOT | 手動封裝 `DachanApiResponse` / `ApiResult` / 自訂 wrapper（由 `ApiResponseMiddleware` 統一處理）|

### API 路徑命名

Controller 名稱已代表資源名稱，例如 `SalesOrderController` 對應 `/api/SalesOrder`。Action route 不得再重複 `SalesOrder` 或完整 method 名稱。

| 情境 | Route 命名 |
|------|------------|
| 查詢 | `query` |
| 新增 | `create` |
| 更新 | `update` |
| 子資源更新 | `{sub-resource}/update` |
| 批次操作 | 動作後加 `-batch` |
| 外部系統流程 | 以子路徑分組，例如 `erp/forward` |
| 特殊檔案或文件 | 使用明確名詞，例如 `shipment-pdf` |

| 範例 | 說明 |
|------|------|
| `POST /api/SalesOrder/query` | 主資源查詢 |
| `GET /api/SalesOrder/{salesOrderId}/product-prices` | 指定單據的子資源 |
| `POST /api/SalesOrder/product-prices/query` | 子資源查詢 |
| `PATCH /api/SalesOrder/update` | 主資源更新 |
| `PATCH /api/SalesOrder/status/update` | 狀態更新 |
| `PATCH /api/SalesOrder/status/update-batch` | 狀態批次更新 |
| `PATCH /api/SalesOrder/items/update` | 明細更新 |
| `POST /api/SalesOrder/erp/forward` | 外部系統流程 |
| `POST /api/SalesOrder/erp/forward-batch` | 外部系統批次流程 |
| `POST /api/SalesOrder/erp/cancel` | 外部系統取消 |
| `POST /api/SalesOrder/erp/cancel-batch` | 外部系統批次取消 |
| `POST /api/SalesOrder/erp/sync` | 外部系統同步 |
| `POST /api/SalesOrder/lock` | 特殊動作 |
| `POST /api/SalesOrder/unlock` | 特殊動作 |
| `GET /api/SalesOrder/shipment-pdf` | 文件 API |

HTTP Verb：查詢/新增/匯入/流程操作用 `[HttpPost]`；更新（含狀態變更、子資源更新）用 `[HttpPatch]`；指定資源或文件讀取用 `[HttpGet]`；刪除才用 `[HttpDelete]`。

```csharp
[ApiController]
[Route("api/[controller]")]
public class WarehouseController(IWarehouseService _warehouseService) : Controller
{
    [HttpPost("query")]
    [ProducesResponseType<PageResultDto<OutWarehouseDto>>((int)HttpStatusCode.OK)]
    public async Task<IActionResult> QueryAsync(InQueryWarehouseDto queryDto)
    {
        var result = await _warehouseService.QueryAsync(queryDto, default);
        return Ok(result);
    }
}
```

## Service 規範

| 約束 | 說明 |
|------|------|
| MUST | 使用 `partial class` + Primary Constructor |
| MUST | 方法簽名含 `CancellationToken cancellationToken = default` |

| 操作 | 回傳型別 |
|------|----------|
| 新增 | `Task<(ObjectId Id, string Code)>` |
| 更新 | `Task` |
| 查詢 | `Task<PageResultDto<Out{Entity}Dto>>` |
| 狀態變更 | `Task` |

```csharp
public partial class WarehouseService(
    IFullRepository<Warehouse> _repository,
    ILogger<WarehouseService> logger) : IWarehouseService
{
    public async Task UpdateWarehouseAsync(
        InUpdateWarehouseDto updateDto, CancellationToken cancellationToken = default)
    {
        var warehouse = await _repository.FindOneAsync(
            entity => entity.Id == ObjectId.Parse(updateDto.Id), cancellationToken);
        if (warehouse is null)
        {
            throw AppError.EntityNotFound.Exception();
        }

        MasterDataFactory.UpdateEntity(warehouse, updateDto);
        await _repository.UpdateAsync(warehouse, cancellationToken);
    }
}
```

## Factory 規範

靜態工廠，每個領域分組一個（`MasterDataFactory`、`InboundOrderFactory` …）：

| 方法命名 | 說明 |
|----------|------|
| `Create{Entity}(dto)` | DTO → Entity |
| `UpdateEntity(entity, dto)` | 套用更新，用 `.IfPresent()` / `.IfNotNull()` |
| `CreateOutDto(entity)` | Entity → OutDto |
| `CreatePagedResult(result, queryDto)` | 轉換分頁結果 |

```csharp
public static void UpdateEntity(Warehouse entity, InUpdateWarehouseDto dto)
{
    dto.Code.IfPresent(value => entity.Code = value);
    dto.Name.IfPresent(value => entity.Name = value);
    dto.TempZones.IfNotNull(value => entity.TempZones = value);
}
```

## 服務啟動設定

```csharp
builder.Services.AddCommonUtils();
builder.Services.AddMongoDB(typeof(Program).Assembly);
app.UseProjectMiddlewares();
```
