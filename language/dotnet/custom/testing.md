# .NET Backend — 測試規範

## 測試策略

| 約束 | 說明 |
|------|------|
| MUST | 依 `core/agent-mandates.md` 採用風險導向 TDD，不要求所有變更都先測試 |
| MUST | Bug fix 先新增或確認失敗測試，再修正，再確認測試通過 |
| MUST | 核心商業邏輯、API contract、DTO / Entity / Factory mapping、權限、同步、排程、環境設定優先補測試 |
| MUST | 測試案例使用 Arrange / Act / Assert 三段式，段落之間以空白行分隔 |
| MUST | 測試名稱描述行為與預期結果，不只描述方法名稱 |
| PREFER | 測試 method identifier 使用英文 ASCII，並用中文 `DisplayName` / attribute / 註解補充人類可讀情境 |
| MUST NOT | 測試只驗證 private implementation detail；應驗證外部可觀察行為 |

## 單元測試依賴邊界

單元測試必須可在開發機與 CI 穩定重複執行，不依賴外部環境狀態。

| 約束 | 說明 |
|------|------|
| MUST | 外部 API、HTTP service、MQ、檔案傳輸、第三方 SDK、Portal / SAP / TMS / WMS 等跨服務依賴必須 mock、fake 或以可控 test double 取代 |
| MUST | Repository、資料庫、cache、Redis、MongoDB、SQL 等資料存取必須 mock 或 fake；單元測試不得直接連線或讀寫真實資料庫 |
| MUST | 測試外部 HTTP request 組成時，使用自訂 `HttpMessageHandler`、mock `IHttpClientFactory` 或既有 HTTP test double 攔截 request，不得讓 `HttpClient` 發出真實網路連線 |
| MUST | 測試資料庫序列化規則時，只允許使用 BSON / serializer / convention 註冊等純記憶體驗證，不得註冊完整 repository 或建立真實 DB connection |
| MUST | 需要啟動 ASP.NET pipeline 時，使用 in-memory `TestServer` 並只註冊本測試需要的 middleware / endpoint / service；不得用 `WebApplicationFactory<Program>` 啟動完整服務後碰到外部設定 |
| MUST | 若測試確實需要真實 API、MQ 或資料庫，必須歸類為 integration test，預設不得在 unit test 專案與一般 `dotnet test` 流程中執行 |
| MUST NOT | 單元測試中設定 `localhost`、正式/測試站 URL、真實 connection string 或真實 API key 來滿足依賴 |
| MUST NOT | 用 `Thread.Sleep`、等待外部排程、讀取目前環境資料等方式驗證非決定性行為 |

允許的例外：

- 使用 `.invalid`、`example` 等保留測試網域作為 `HttpClient.BaseAddress`，且 request 已被 mock handler 完全攔截，不會發出網路連線。
- 使用 `ToBsonDocument()` / serializer 註冊驗證 MongoDB wire shape，前提是不建立 `MongoClient`、不呼叫 repository、也不讀寫資料庫。
- 以 in-memory fake repository 驗證 service 行為，前提是 fake 的資料完全由測試 Arrange 階段提供。

## 命名建議

若測試框架支援顯示名稱，優先用中文描述業務情境：

```csharp
[Fact(DisplayName = "庫存不足時應拋出庫存不足錯誤")]
public async Task UpdateAsync_WhenInventoryIsInsufficient_ShouldThrowInventoryError()
{
    // Arrange
    var service = CreateServiceWithInventory(available: 1);

    // Act
    var act = () => service.UpdateAsync(CreateRequest(required: 2));

    // Assert
    await act.Should().ThrowAsync<InvalidOperationException>();
}
```

若框架不支援顯示名稱，可在測試 method 上方用繁體中文註解補充情境。
