# Dachan WMS — 目錄分層 / Entity / DTO / Controller / Service / Factory

## 私有套件

| 套件 | 用途 |
|------|------|
| `Dachan.CommonUtils` | 環境變數、擴充方法 |
| `Dachan.CommonUtils.Web` | ApiResponseMiddleware、DachanHttpClientProxy |
| `Dachan.Common.EventDriven` | 異步領域事件、RabbitMQ 訊息整合 |
| `Dachan.MongoRepository` | 資料存取，自動掃描 `[UseRepository]` |

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
| MUST | 路由格式：`[Route("api/[controller]/[action]")]` |
| MUST | 僅處理 Request/Response，不含商業邏輯 |
| MUST NOT | 手動封裝 Response（由 `ApiResponseMiddleware` 統一處理）|

HTTP Verb：查詢/新增/匯入用 `[HttpPost]`，更新（含狀態變更）用 `[HttpPatch]`。

```csharp
[ApiController]
[Route("api/[controller]/[action]")]
public class WarehouseController(IWarehouseService _warehouseService) : Controller
{
    [HttpPost]
    [ProducesResponseType<PageResultDto<OutWarehouseDto>>((int)HttpStatusCode.OK)]
    public async Task<IActionResult> GetWarehouseAsync(InQueryWarehouseDto queryDto)
    {
        var result = await _warehouseService.GetWarehouseAsync(queryDto, default);
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
            throw WmsError.WarehouseNotFound.Exception();
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
builder.Services.AddDachanCommonUtils();
builder.Services.AddDachanMongoDB(typeof(Program).Assembly);
app.UseDachanMiddlewares();
```
