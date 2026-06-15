# CommonUtils Dachan API Key 規範

## 適用時機

當任務涉及服務間 API 驗證、shared secret、internal key、external key、OMS / TMS / Scheduler / Invoice 互相呼叫時，載入本規範。

## 標準 Header

```http
Dachan-Api-Key-Type: Internal
Dachan-Api-Key-Service: Tms
Dachan-Api-Key-Secret: <secret>
```

欄位：

- `Dachan-Api-Key-Type`：`Internal` 或 `External`；未帶時預設 `External`。
- `Dachan-Api-Key-Service`：呼叫方服務名稱，由各服務自行定義常數。
- `Dachan-Api-Key-Secret`：對應 service / type 的 secret。

舊 header 不得新增使用：

- `X-TMS-Internal-Key`
- `X-Dachan-Scheduler-Internal-Key`
- `X-OMS-External-Order-Key`

## CommonUtils 與服務邊界

CommonUtils 只提供：

- `DachanApiKeyTypeEnum`
- `DachanApiKeyHeaders`
- `DachanApiKeyRequirementAttribute`
- `DachanApiKeyAuthorizeAttribute`

CommonUtils 不定義 `Oms`、`Tms`、`Scheduler`、`ExternalOrder` 等服務名稱。

各服務必須自行定義：

- service name 常數。
- 啟動時一次讀入的 global settings / secret。
- 繼承 `DachanApiKeyRequirementAttribute` 的 allow attribute，例如 `AllowTmsApiKeyAttribute`。

Controller 應使用：

```csharp
[DachanApiKeyAuthorize]
[AllowTmsApiKey]
public IActionResult SomeApi()
```

多個 allow attribute 採 OR；任一 requirement 符合 `type + service + secret` 即通過。

## Secret 與設定

- Secret 不放在 attribute constructor。
- Secret 不在每個 request 即時讀環境變數。
- 服務啟動時一次從 `IConfiguration` / 環境變數載入到 static/global settings。
- service name 不應由環境變數設定，因為服務名稱不隨環境改變。

## 外部合約例外

若 API 是外部或跨系統既有合約，wire format 可保留對方欄位名稱；內部 Service / Domain 不得被外部命名污染。

例如 Invoice API 對 OMS 暴露的發票 DTO 可能使用 `ProductNo`、`ProductName`，這屬於 Invoice boundary 合約。OMS 內部仍使用 `ItemCode`、`ItemName`，由 adapter / client mapping 轉換。
