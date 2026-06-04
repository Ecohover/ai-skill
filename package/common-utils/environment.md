# CommonUtils Environment 規範

本檔補充 CommonUtils 類共用套件的環境變數整合方式。語言層的基本命名規則仍以 `language/dotnet/custom/env.md` 為準。

## 原則

- 使用各套件/服務提供的環境變數 Enum。
- 透過 `.GetEnvironmentValue()` 讀取。
- 必要變數不加 `[OptionalEnvironment]`，讓缺值在啟動或取值時直接失敗。
- 可選變數才加 `[OptionalEnvironment]`。

## Enum 對照（範例）

| 套件/服務 | Enum |
|----------|------|
| `{Project}.MongoRepository` | `MongoRepositoryEnvironmentVariables` |
| `{Project}.Common.EventDriven` | `EventEnvironmentVariable` |

## 範例

```csharp
var host = EventEnvironmentVariable.RABBIT_MQ_HOST.GetEnvironmentValue()!;
```
