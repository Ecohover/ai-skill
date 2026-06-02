# .NET Backend — Enum 規範

## 規則

| 約束 | 說明 |
|------|------|
| MUST | 分類欄位使用 Enum 定義 |
| MUST | 成員使用 PascalCase，禁止使用底線（`HalfH` 而非 `Half_H`）|
| MUST | 需要全大寫序列化的 Enum 加上 `[UpperCaseEnum]` attribute |
| MUST | 加上 `[UpperCaseEnum]` 後，JSON（API）與 BSON（MongoDB）自動序列化為全大寫字串 |
| MUST | 純量 Enum 欄位（Entity & DTO）傳輸與儲存使用 string，由序列化層自動轉換 |
| MUST | 集合型 Enum 欄位使用 Enum 集合（`IEnumerable<TempZone>`），不使用 `IEnumerable<string>` |
| MUST NOT | 用 int 表示 Enum 值 |
| MUST NOT | Enum 命名加 `In`/`Out` 前綴（`TempZone` 而非 `InTempZone`）|

> 例外：環境變數 Enum 不適用本檔 PascalCase 命名規則。環境變數 Enum 成員必須依 `dotnet/custom/env.md` 使用全大寫底線命名，並與實際環境變數名稱一致。

## 範例

```csharp
[UpperCaseEnum]
public enum TempZone { Roomtem, Cold, Chilled, Frozen }

[UpperCaseEnum]
public enum OrderStatus { Active, Inactive, Pending, Completed }
```

Entity / DTO 欄位：

```csharp
// 純量：用 string，序列化層自動轉換
public required string Status { get; set; }

// 集合：用 Enum 集合
public IEnumerable<TempZone> TempZones { get; set; } = [];
```

前端 Blazor 比對：

```csharp
entity.Status == nameof(OrderStatus.Active).ToUpperInvariant()
```
