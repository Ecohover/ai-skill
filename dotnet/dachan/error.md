# Dachan WMS — ErrorDetail 異常處理

## 核心規則

| 約束 | 說明 |
|------|------|
| MUST | 業務錯誤依領域分類，定義在對應靜態錯誤類別 |
| MUST | 有上下文用 `ErrorDetail<TContext>`，無上下文用 `ErrorDetail`，兩者不混用 |
| MUST | 系統代號透過 `ErrorDetail.RegisterSystemPrefix("WMS")` 一次性註冊 |
| MUST | `Prefix` 使用領域縮寫，不超過 5 個英文字 |
| MUST | `InnerExceptionFactory` 內組合錯誤訊息字串，call site 只傳值 |
| MUST NOT | catch 只為記錄 Log 再 re-throw |
| MUST NOT | call site 組合錯誤訊息字串 |

## 錯誤類別對照

| 類別 | Prefix | 適用範圍 |
|------|--------|---------|
| `DachanCommonError` | `"Common"` | 跨系統通用 |
| `WmsError` | `"COM"` | WMS 通用 |
| `InventoryError` | `"INV"` | 庫存領域 |
| `TaskError` | `"TSK"` | 任務領域 |

錯誤碼格式：`{系統代號}-{Prefix}-{Code}`，例如 `WMS-INV-40005`。

## 無上下文錯誤

```csharp
// 定義
public static ErrorDetail InvalidWarehouseId { get; }
    = new ErrorDetail
    {
        Prefix = "COM", Code = "40002",
        Message = "無效的倉庫 ID。",
    };

// 呼叫
throw WmsError.InvalidWarehouseId.Exception();
```

## 有上下文錯誤

```csharp
// 上下文 record（放在 Exceptions 目錄）
public record InsufficientInventoryContext(
    string MaterialCode, string LocationCode,
    decimal Required, decimal Available);

// 定義
public static ErrorDetail<InsufficientInventoryContext> InsufficientInventory { get; }
    = new ErrorDetail<InsufficientInventoryContext>
    {
        Prefix = "INV", Code = "40005",
        Message = "庫存數量不足。",
        InnerExceptionFactory = ctx => new InvalidOperationException(
            $"料號 '{ctx.MaterialCode}' 在 {ctx.LocationCode} 可用 {ctx.Available}，需求 {ctx.Required}。"),
    };

// 呼叫（只傳值，禁止在此組合字串）
throw InventoryError.InsufficientInventory.Exception(
    new InsufficientInventoryContext(
        MaterialCode: detail.MaterialCode,
        LocationCode: detail.LocationCode,
        Required:     requiredAmount,
        Available:    inventory.UsableQuantity));
```

## Exception overload 三種用法

```csharp
// 1. 無上下文
throw WmsError.SomeError.Exception();

// 2. 有上下文物件
throw InventoryError.InsufficientInventory.Exception(contextObject);

// 3. 帶附加資料回呼叫端（放入 response Data）
throw WmsError.SomeError.Exception(errorObject: new { Invalid = items });
```
