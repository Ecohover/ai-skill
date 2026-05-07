# .NET 提交前自審清單

提交程式碼前逐項確認：

- [ ] **Service** 是否使用 `partial class`？
- [ ] **日誌** 是否定義在獨立的 `*.Logging.cs`，使用 `[LoggerMessage]`？
- [ ] **Controller** 是否只處理 Request/Response，無商業邏輯？
- [ ] **Controller** 是否有手動封裝 Response？（必須沒有）
- [ ] **ErrorDetail** 有上下文用 `ErrorDetail<TContext>`，無上下文用 `ErrorDetail`，兩者是否正確使用？
- [ ] **QueryOptions** Lambda 參數是否有業務語意名稱（非 `x`）？
- [ ] **Enum** 集合欄位是否用 `IEnumerable<EnumType>` 而非 `IEnumerable<string>`？
- [ ] **集合屬性** 是否用 `ICollection<T>` + `init;`（非 `List<T>` + `set;`）？
- [ ] **if/for/foreach** 是否都加了 `{}`？
- [ ] **環境變數** 是否透過 Enum + `.GetEnvironmentValue()`（非 `Environment.GetEnvironmentVariable()`）？
- [ ] **新建 Entity** 是否呼叫 `entity.InitializeAudit()`？
- [ ] **Factory** UpdateEntity 是否用 `.IfPresent()` / `.IfNotNull()`？
- [ ] **XML Documentation** 所有 public 方法是否有繁體中文說明？
