# .NET Backend — Enum 規範

## 規則

| 約束 | 說明 |
|------|------|
| MUST | 分類欄位使用 Enum 定義 |
| MUST | 有限條列式字串欄位必須使用 Enum source 定義，例如狀態、類型、階段、來源、處理結果 |
| MUST NOT | 對有限條列式值直接手寫 magic string；boundary / mapping / 初始化字串可用 `nameof(SomeEnum.SOME_VALUE)`、converter、factory 或明確 mapping 產生 |
| MUST | Enum type 使用 PascalCase，可依專案既有慣例使用 `Enum` 後綴（如 `ErpSyncStatusEnum`）|
| MUST | Enum member 使用全大寫 snake_case，單字之間用底線（如 `NOT_SYNCED`、`SENT_TO_ERP_SUCCESS`）|
| MUST | API / DB / 內部服務看到 enum 字串時，必須能明確辨識這是受控 enum 值，而不是任意 string |
| MUST | 需要人類可讀中文顯示文字時，使用 `[Description("...")]` 標註 enum member |
| MUST | 會進出資料庫、內部服務或自家前端 API 的 Enum 必須有明確序列化機制，確保 JSON（API）與 BSON（MongoDB）使用 enum member 名稱字串 |
| MUST | 資料庫進出、內部服務傳遞、自家前端溝通時，Enum 值一律使用全大寫字串 |
| MUST | 程式內邏輯判斷與查詢條件比對時，使用 enum 型別直接比對，不先轉成 string |
| PREFER | 若專案既有使用 `[UpperCaseEnum]`，可繼續使用；若已由全域 converter 或共用套件保證 enum string 序列化，則不強制加 `[UpperCaseEnum]` |
| MUST | 純量 Enum 欄位（Entity & DTO）傳輸與儲存使用 string，由序列化層自動轉換 |
| MUST | 集合型 Enum 欄位使用 Enum 集合（`IEnumerable<TempZone>`），不使用 `IEnumerable<string>` |
| MUST NOT | 用 int 表示 Enum 值 |
| MUST NOT | Enum 命名加 `In`/`Out` 前綴（`TempZone` 而非 `InTempZone`）|
| MUST | 需要提供給前端的 enum option，enum type 必須掛專案的 `[I18nKeyEnum]` 類 marker，並透過標準 enum metadata API 輸出 |
| MUST | enum metadata 額外欄位必須透過 attribute property 上的 `[EnumMetadataField("metadataKey")]` 宣告，不得在 metadata service 內針對特定業務 hardcode |
| MUST | enum value 上的業務設定 attribute 必須使用 named argument，例如 `[OrderSetting(printDescription: "...")]`、`[ErpSetting(erpDocType: "...")]`，不得使用只有位置語意的寫法 |
| MUST NOT | 沒有 metadata attribute 的 enum value 不得補領域預設值 |
| MUST | 多個 metadata attribute 輸出同名 key 時必須啟動失敗，避免前端接收不穩定資料 |

> 補充：環境變數 Enum 同樣使用全大寫底線命名，且必須依 `language/dotnet/custom/env.md` 與實際環境變數名稱一致。

> 例外：外部合作 API 的 enum wire format 必須依 `core/external-contract.md` 對齊外部合約；若外部 API 不使用全大寫字串，Boundary 層（DTO/Controller/Adapter）負責轉換，Service 層之後一律回到內部標準全大寫格式。

## 範例

```csharp
public enum ErpSyncStatusEnum
{
    [Description("尚未同步")]
    NOT_SYNCED,

    [Description("已轉送ERP")]
    SENT_TO_ERP_SUCCESS,
}
```

Entity / DTO 欄位：

```csharp
// 純量：用 string，資料庫、內部服務、自家前端 API 進出由序列化層保存 enum member 名稱
public required string Status { get; set; } = nameof(ErpSyncStatusEnum.NOT_SYNCED);

// 集合：用 Enum 集合
public IEnumerable<TempZoneEnum> TempZones { get; set; } = [];
```

程式內比對：

```csharp
order.SyncStatus == ErpSyncStatusEnum.NOT_SYNCED
```

若欄位因 API / DB boundary 必須是 string，只能在 boundary / mapping / query helper 轉換；Service / Domain / Query 條件不得手動 `.ToString()` 或 `nameof()` 後比對：

```csharp
// Good
queryOptions.AddEqualsEnumIfProvided(
    value: queryDto.SyncStatus,
    targetField: order => order.SyncStatus);

// Bad
order.SyncStatus == ErpSyncStatusEnum.NOT_SYNCED.ToString()
order.SyncStatus == nameof(ErpSyncStatusEnum.NOT_SYNCED)
```

## Enum Metadata

Enum metadata API 只在服務啟動時組合一次並快取，因此可以使用反射，但反射規則必須清楚宣告：

```csharp
public class ErpSettingAttribute : Attribute
{
    [EnumMetadataField("erpDocType")]
    public string ErpDocType { get; }
}

public class OrderSettingAttribute : Attribute
{
    public string PrintDescription { get; }
}
```

Enum value 上使用這類 attribute 時必須寫出參數名稱，讓語意留在呼叫點：

```csharp
[OrderSetting(printDescription: "出貨單")]
[ErpSetting(erpDocType: "ZOR2")]
STANDARD,

[OrderSetting(printDescription: "")]
SERVICE
```

只有掛 `[EnumMetadataField]` 的 public property 會被輸出到前端 `metadata`。新增 metadata 類型時，新增 attribute 並標記要暴露的 property；不要修改 enum metadata service 追加業務判斷。若 attribute 只供後端內部使用，例如訂單列印描述，property 不要掛 `[EnumMetadataField]`。
