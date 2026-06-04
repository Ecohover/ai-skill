# .NET 基礎規則

## 格式

| 約束 | 說明 |
|------|------|
| MUST | 使用 File-scoped namespace（`namespace Foo.Bar;`，不帶大括號）|
| MUST | 縮排使用 4 個空格 |
| MUST | `if`/`for`/`foreach` 等控制流程必須加 `{}`，即使只有一行 |
| MUST | 一個 `.cs` 檔案只定義一個主要 `class` / `record` / `struct` / `interface` / `enum` |
| MUST | IO 操作使用 Async/Await |
| MUST NOT | namespace 宣告帶大括號 |

> 例外：小型 private nested type 可保留在所屬 class 內；若型別會被其他檔案引用，必須獨立成檔。

## 集合與封裝（CA1002/CA2227）

| 約束 | 說明 |
|------|------|
| MUST | 集合屬性設為唯讀或使用 `init;`，防止外部替換整個集合實例 |
| MUST NOT | 公開 `List<T>`，應使用 `ICollection<T>`、`IEnumerable<T>` 或 `IReadOnlyCollection<T>` |

```csharp
public ICollection<OrderDetail> Details { get; init; } = new List<OrderDetail>();
```

## 充血模型

| 約束 | 說明 |
|------|------|
| MUST | 僅限處理物件本身參數的內部邏輯（狀態驗證、欄位計算）|
| MUST NOT | 牽扯外部資料、外部服務、或跨物件邏輯 |

```csharp
public class Order
{
    public decimal Total => Items.Sum(item => item.Price * item.Quantity);
    public bool CanCancel => Status == OrderStatus.Pending;
}
```

## 物件映射

| 約束 | 說明 |
|------|------|
| MUST NOT | 使用 AutoMapper 等自動映射套件 |
| MUST | 簡單轉換直接寫在使用處 |
| PREFER | 重複超過 3 次才抽取至 `Infrastructure/Factories` 工廠類別 |

## XML Documentation

| 約束 | 說明 |
|------|------|
| MUST | 所有 `public` 方法與類別包含繁體中文 XML Documentation |

```csharp
/// <summary>
/// 簡單說明
/// </summary>
/// <param name="id">參數說明</param>
/// <returns>回傳說明</returns>
```
