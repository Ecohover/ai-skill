# CommonUtils 類共用套件規範

本規範描述「CommonUtils 類共用套件」的使用方式，不綁定公司或專案名稱。

實際套件名稱、API response 型別名稱、前端 shared package 名稱，應由 `unit/[開發單位]/package-profile.md` 定義。

## 套件職責

| 套件類型 | 用途 |
|----------|------|
| `{Project}.CommonUtils` | 環境變數、擴充方法 |
| `{Project}.CommonUtils.Web` | API response middleware、HttpClientProxy |
| `{Project}.Common.EventDriven` | 異步領域事件、RabbitMQ 訊息整合 |
| `{Project}.MongoRepository` | 資料存取，自動掃描 `[UseRepository]` |

## 載入原則

- 只有專案明確採用 CommonUtils 類共用套件時，才載入本目錄規範。
- 若專案改用另一組共用套件，應替換整個 `package/common-utils/` profile，而不是修改 `language/dotnet/` coding style。
- 語言層只保留通用 C# / .NET coding style；共用套件 API、middleware、audit log 行為放在本層。

## MongoRepository

- 採用 `{Project}.MongoRepository` 的 entity 使用 `[UseRepository]` 標註 repository 型別。
- 不採用 `{Project}.MongoRepository` 的專案，不套用 `[UseRepository]` 規則。

```csharp
[BsonCollection("MyEntities")]
[UseRepository(typeof(FullRepository<>))]
public class MyEntity : AuditableEntityBase, IAggregateRoot
{
    [BsonId]
    public ObjectId Id { get; set; }
}
```

## 服務啟動設定

```csharp
builder.Services.AddCommonUtils();
builder.Services.AddMongoDB(typeof(Program).Assembly);
app.UseProjectMiddlewares();
```
