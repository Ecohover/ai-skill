# .NET Backend — QueryOptions / 模糊查詢

## QueryOptions 規則

| 約束 | 說明 |
|------|------|
| MUST | 實例化與分頁配置分兩行撰寫 |
| MUST | 使用 `Add...IfProvided` 系列方法，配合具名參數 |
| MUST | Lambda 使用業務語意名稱（`warehouse => warehouse.Code`，非 `x => x.Code`）|
| MUST | Enum 欄位使用 `AddEqualsEnumIfProvided`，禁止在呼叫端手動 `.ToString()`、`nameof()` 或字串常數比對 |

```csharp
var queryOptions = new QueryOptions<Warehouse>();
queryOptions.ApplyPaging(queryDto);
queryOptions.AddStartsWithIfProvided(value: queryDto.Code, targetField: warehouse => warehouse.Code);
queryOptions.AddEqualsEnumIfProvided(value: queryDto.Status, targetField: warehouse => warehouse.Status);
```

## 模糊查詢（Searches）

接受 `searches: ["FieldName:value"]` 格式，條件間 AND 連接。

### Service 宣告可搜尋欄位

```csharp
private static readonly IReadOnlyList<(string Field, Expression<Func<Location, string?>> Selector)>
    _containsSearchFields =
    [
        ("Code",    location => location.Code),
        ("Name",    location => location.Name),
        ("Remark",  location => location.Remark),
    ];
```

### BuildQueryOptions 使用

```csharp
queryOptions.ApplyContainsSearches(queryDto.Searches, _containsSearchFields);
```

### ApplyContainsSearches 規則

| 約束 | 說明 |
|------|------|
| MUST | `_containsSearchFields` 定義在 Service 的 `private static readonly` 欄位 |
| MUST | 欄位名稱（`Field`）大小寫需與 `core/api-contract.md` Searches 格式一致 |
| MUST NOT | 使用舊的 `IReadOnlyDictionary<string, Action<...>>` 模式 |
| MUST NOT | 在 DTO 定義可搜尋欄位（如 `SearchableFields` static HashSet）|
