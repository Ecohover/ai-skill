# .NET Backend — DI / Constructor 規範

## 建構式注入

| 約束 | 說明 |
|------|------|
| MUST | 依賴透過建構式注入，不在方法內 `new` 依賴 |
| MUST | Service 使用 `partial class` + Primary Constructor |
| MUST | 注入後保存為 private 欄位時，欄位名稱使用 `_` 開頭 |
| MUST NOT | 使用 property injection |
| MUST NOT | 使用 service locator 透過 `IServiceProvider` / scope 在方法內解析依賴 |

## Primary Constructor 範例

```csharp
public partial class WarehouseService(
    ILogger<WarehouseService> _logger,
    IEventPublisher _eventPublisher,
    IWarehouseRepository _warehouseRepository,
    IProductService _productService) : IWarehouseService
{
}
```

## 傳統 Constructor 範例

若因框架限制不能使用 Primary Constructor，才使用傳統 constructor。

```csharp
public class WarehouseService : IWarehouseService
{
    private readonly ILogger<WarehouseService> _logger;
    private readonly IWarehouseRepository _warehouseRepository;

    public WarehouseService(
        ILogger<WarehouseService> logger,
        IWarehouseRepository warehouseRepository)
    {
        _logger = logger;
        _warehouseRepository = warehouseRepository;
    }
}
```

## 注入排序

多個依賴注入時，依以下順序排列：

1. 基礎設施與橫切關注：`ILogger<T>`、clock/time provider、current user/context。
2. Messaging / integration：MQ、event publisher、HTTP proxy、external client。
3. Repository / UnitOfWork。
4. 其他 domain service / application service。

## 禁止範例

### Property Injection

```csharp
public class WarehouseService
{
    public IWarehouseRepository Repository { get; set; } = default!;
}
```

問題：依賴不是建構時必要條件，物件可能處於未完成狀態，測試也不容易看出必要依賴。

### Service Locator

```csharp
public async Task UpdateAsync(string id)
{
    var repository = _serviceProvider.GetRequiredService<IWarehouseRepository>();
}
```

問題：依賴被藏在方法內，呼叫端與測試無法從建構式看出這個 class 需要哪些依賴，也容易在方法內任意解析服務。
