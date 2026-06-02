# .NET Backend — 環境變數

## 規則

| 約束 | 說明 |
|------|------|
| MUST | 使用各套件/服務的環境變數 Enum + `.GetEnvironmentValue()` |
| MUST | 服務自有變數定義在自己專案的 Enum（如 `{App}EnvironmentVariable`）|
| MUST | 環境變數 Enum 成員名稱使用全大寫底線命名，且與實際環境變數名稱一致（如 `RABBIT_MQ_HOST`、`PORTAL_AUTH_ENABLED`）|
| MUST | 本地開發變數值定義在 `launchSettings.json` 的 `environmentVariables` |
| MUST NOT | 直接呼叫 `Environment.GetEnvironmentVariable()` |
| MUST NOT | 從 `IConfiguration` 讀取設定 |
| MUST NOT | 在 `appsettings.json` / `appsettings.Development.json` 存放任何設定 |
| MUST NOT | 使用 .NET configuration section 的雙底線環境變數命名（如 `PortalAuth__Enabled`、`Authentication__SkipAuthorization`）|
| MUST NOT | 讓 Enum 成員使用 PascalCase 再用 `[Display(Name = "...")]` 對應環境變數；環境變數 Enum 是 Enum 命名規則的例外 |

## Enum 對照（範例）

| 套件/服務 | Enum |
|----------|------|
| `{Project}.MongoRepository` | `MongoRepositoryEnvironmentVariables` |
| `{Project}.Common.EventDriven` | `EventEnvironmentVariable` |
| 服務自有 | `{App}EnvironmentVariable` |

## 範例

```csharp
// {App}EnvironmentVariable.cs
public enum AppEnvironmentVariable
{
    REDIS_SYNC_SERVICE_URL,
    SOME_OTHER_VARIABLE,
}

// 取值
var url = AppEnvironmentVariable.REDIS_SYNC_SERVICE_URL.GetEnvironmentValue()!;
```

## 命名原則

環境變數 Enum 的成員名稱就是環境變數名稱本身。不要為了符合一般 Enum PascalCase 規則而寫成 `RabbitMqHost`、`PortalAuthEnabled`，也不要用 `[Display(Name = "RABBIT_MQ_HOST")]` 轉換。

```csharp
// Good
public enum EventEnvironmentVariable
{
    RABBIT_MQ_HOST,
    RABBIT_MQ_PORT,
    RABBIT_MQ_USER_NAME,
}

// Bad
public enum EventEnvironmentVariable
{
    [Display(Name = "RABBIT_MQ_HOST")]
    RabbitMqHost,
}
```

若環境變數可選，才加上 `[OptionalEnvironment]`；必要變數不加，讓 `.GetEnvironmentValue()` 在缺值時直接失敗。
