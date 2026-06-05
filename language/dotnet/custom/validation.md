# .NET Backend — Nullable / Validation 規範

## Nullable 與 required

| 約束 | 說明 |
|------|------|
| MUST | Nullable reference type 開啟時，必填欄位使用非 nullable 型別並搭配 `required` 或 constructor 保證初始化 |
| MUST | 可選欄位才使用 nullable 型別（如 `string? Remark`）|
| MUST | 不用 `string.Empty` 偽裝必填欄位；缺值應由 DTO validation 或建構流程阻擋 |
| MUST | 集合屬性初始化為空集合，不使用 nullable collection |
| MUST NOT | 為了消除警告而濫用 `!` null-forgiving operator |

## Validation 分層

| 層級 | 職責 |
|------|------|
| DTO / Controller Boundary | 檢查 request shape、必填欄位、格式、長度、基本範圍 |
| Service | 檢查業務規則、跨資料狀態、權限、重複性、流程狀態 |
| Domain Entity | 保護物件本身不變條件與衍生欄位 |
| Factory / Mapping | 將已驗證 DTO 轉成 Entity / OutDto，不偷偷吞掉無效資料 |

## 規則

| 約束 | 說明 |
|------|------|
| MUST | DTO 的必填欄位用 `required` 表達，不用 nullable 再於 Service 猜測 |
| MUST | Service 遇到業務規則錯誤時使用 `ErrorDetail` / `ErrorDetail<TContext>` |
| MUST | Factory 不負責查資料或呼叫外部服務，只做 mapping 與簡單欄位套用 |
| PREFER | 若專案已有 FluentValidation / DataAnnotations 標準，依專案既有 validator 放置位置實作 |
| MUST NOT | Controller 直接寫商業 validation |

```csharp
public sealed class InUpdateWarehouseDto
{
    public required string Id { get; init; }
    public string? Remark { get; init; }
}

public sealed class OutWarehouseDto
{
    public required string Id { get; init; }
    public required string Code { get; init; }
    public string? Remark { get; init; }
}
```
