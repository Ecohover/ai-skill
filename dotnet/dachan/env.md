# Dachan WMS — 環境變數

## 規則

| 約束 | 說明 |
|------|------|
| MUST | 使用各套件/服務的環境變數 Enum + `.GetEnvironmentValue()` |
| MUST | 服務自有變數定義在自己專案的 Enum（如 `WmsEnvironmentVariable`）|
| MUST | 本地開發變數值定義在 `launchSettings.json` 的 `environmentVariables` |
| MUST NOT | 直接呼叫 `Environment.GetEnvironmentVariable()` |
| MUST NOT | 從 `IConfiguration` 讀取設定 |
| MUST NOT | 在 `appsettings.json` / `appsettings.Development.json` 存放任何設定 |

## Enum 對照

| 套件/服務 | Enum |
|----------|------|
| `Dachan.MongoRepository` | `MongoRepositoryEnvironmentVariables` |
| `Dachan.Common.EventDriven` | `EventEnvironmentVariable` |
| WMS 服務自有 | `WmsEnvironmentVariable` |

## 範例

```csharp
// WmsEnvironmentVariable.cs
public enum WmsEnvironmentVariable
{
    RedisSyncServiceUrl,
    SomeOtherVariable,
}

// 取值
var url = WmsEnvironmentVariable.RedisSyncServiceUrl.GetEnvironmentValue()!;
```
