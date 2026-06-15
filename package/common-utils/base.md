# CommonUtils 類共用套件規範

本規範描述「CommonUtils 類共用套件」的使用方式，不綁定公司或專案名稱。

實際套件名稱、API response 型別名稱、前端 shared package 名稱，應由 `unit/[開發單位]/package-profile.md` 定義。

## 套件職責

| 套件類型 | 用途 |
|----------|------|
| `{Project}.CommonUtils` | 環境變數、擴充方法 |
| `{Project}.CommonUtils.Web` | API response middleware、Dachan API key filter、HttpClientProxy |
| `{Project}.Common.EventDriven` | 異步領域事件、RabbitMQ 訊息整合 |
| `{Project}.MongoRepository` | 資料存取，自動掃描 `[UseRepository]` |

## 載入原則

- 只有專案明確採用 CommonUtils 類共用套件時，才載入本目錄規範。
- 若專案改用另一組共用套件，應替換整個 `package/common-utils/` profile，而不是修改 `language/dotnet/` coding style。
- 語言層只保留通用 C# / .NET coding style；共用套件 API、middleware、audit log 行為放在本層。

## MongoRepository

- 採用 `{Project}.MongoRepository` 的 entity 使用 `[UseRepository]` 標註 repository 型別。
- MongoDB entity 包含 `[BsonCollection("PascalCase")]` 標註。
- Entity 可依專案資料生命週期繼承 `AuditableEntityBase`、`AuditBase` 或實作 `ISoftDeletable`。
- 新建 entity 後，若 entity 採用共用套件 audit 欄位，需呼叫 `entity.InitializeAudit()`。
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

## Compressed Payload Storage

- 大型 request / response 原文應拆到獨立 payload collection，不直接放在列表或一般明細 DTO。
- 壓縮 / 解壓縮使用 `{Project}.CommonUtils` 的 payload compression helper，不在各服務自行實作 GZip。
- Mongo payload 文件應繼承 `{Project}.MongoRepository` 的 compressed payload base，並由各服務自行指定 `[BsonCollection]`。
- 各服務可在 payload 文件上補自己的查詢欄位，例如 Scheduler 的 `StepCode`；CommonUtils 不定義業務查詢語意。
- Payload API 由後端解壓後回傳 JSON / text，前端不得直接處理 Mongo binary 或 GZip。

```csharp
[BsonCollection("MyRunPayloads")]
[UseRepository(typeof(FullRepository<>))]
public class MyRunPayload : CompressedPayloadDocumentBase, IAggregateRoot
{
    public string StepCode { get; set; } = string.Empty;
}
```

## 服務啟動設定

```csharp
builder.Services.AddCommonUtils();
builder.Services.AddMongoDB(typeof(Program).Assembly);
app.UseProjectMiddlewares();
```

## 服務間 API 驗證

- 服務間 API key 使用 `package/common-utils/api-key.md`。
- CommonUtils 只提供 header 常數、key type enum、requirement attribute 與 authorize filter。
- 各服務自行定義 service name 常數、secret global settings 與 allow attribute。
- 不新增舊式 shared secret header 或每個服務自製驗證 filter。
