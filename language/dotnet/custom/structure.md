# .NET Backend — 目錄分層 / Entity / DTO / Controller / Service / Factory

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
| MUST | 放在 `/Domain/Entities` 下 |
| MUST | Entity 只放領域狀態與物件本身可判斷的行為，不直接呼叫外部服務 |
| MUST | 有限條列式狀態或類型欄位使用 Enum source 定義，不以任意 string 表達 |
| MUST | 若採用特定 repository / audit 共用套件，套件特規放在 `package/` profile，不寫死在語言層 |

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
public string TypeDisplay => Type switch
{
    nameof(WarehouseTypeEnum.MAIN) => "主倉",
    nameof(WarehouseTypeEnum.BRANCH) => "衛星庫",
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
| MUST NOT | 手動封裝 API response wrapper / `ApiResult` / 自訂 wrapper（由專案標準 middleware 統一處理）|

路由命名、HTTP Verb 與 Controller 範例依 `language/dotnet/custom/routing.md`。

## Service 規範

| 約束 | 說明 |
|------|------|
| MUST | 使用 `partial class` + Primary Constructor；DI 細節依 `language/dotnet/custom/di.md` |
| MUST | 方法簽名含 `CancellationToken cancellationToken = default` |

| 操作 | 回傳型別 |
|------|----------|
| 新增 | `Task<(ObjectId Id, string Code)>` |
| 更新 | `Task` |
| 查詢 | `Task<PageResultDto<Out{Entity}Dto>>` |
| 狀態變更 | `Task` |

```csharp
public partial class WarehouseService(
    ILogger<WarehouseService> _logger,
    IWarehouseRepository _warehouseRepository) : IWarehouseService
{
    public async Task UpdateWarehouseAsync(
        InUpdateWarehouseDto updateDto, CancellationToken cancellationToken = default)
    {
        var warehouse = await _warehouseRepository.FindByIdAsync(
            updateDto.Id, cancellationToken);
        if (warehouse is null)
        {
            throw AppError.EntityNotFound.Exception();
        }

        MasterDataFactory.UpdateEntity(warehouse, updateDto);
        await _warehouseRepository.UpdateAsync(warehouse, cancellationToken);
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
