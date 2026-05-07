# .NET Backend — 高效能日誌（CA1848）

## 規則

| 約束 | 說明 |
|------|------|
| MUST | 優先使用 `[LoggerMessage]` Source Generator |
| MUST | 日誌定義放在獨立的 `{ServiceName}.Logging.cs` 檔案 |
| MUST | 定義方法為 `private static partial void` |
| PREFER | 泛型類別無法使用 Source Generator 時改用 `LoggerMessage.Define` |

## 範例

```csharp
// WarehouseService.Logging.cs
public partial class WarehouseService
{
    [LoggerMessage(Level = LogLevel.Information, Message = "倉庫 {Code} 已成功建立")]
    private static partial void LogWarehouseCreated(ILogger logger, string code);

    [LoggerMessage(Level = LogLevel.Warning, Message = "找不到倉庫 {WarehouseId}")]
    private static partial void LogWarehouseNotFound(ILogger logger, string warehouseId);
}
```

```csharp
// WarehouseService.cs — 呼叫端
LogWarehouseCreated(logger, warehouse.Code);
```
