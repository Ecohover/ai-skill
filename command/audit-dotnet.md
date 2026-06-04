# .NET 提交前自審清單

提交程式碼前逐項確認：

- [ ] **Service** 是否使用 `partial class`？
- [ ] **日誌** 是否定義在獨立的 `*.Logging.cs`，使用 `[LoggerMessage]`？
- [ ] **Controller** 是否只處理 Request/Response，無商業邏輯？
- [ ] **Controller** 是否有手動封裝 Response？（必須沒有）
- [ ] **Controller** 是否沒有手動回傳 `{Project}ApiResponse` / `ApiResult` / 自訂 wrapper？（必須由專案標準 middleware 統一封裝）
- [ ] **API 路徑** 是否使用 `[Route("api/[controller]")]`，且沒有使用 `[action]`？
- [ ] **Action Route** 是否只放 `query`、`create`、`update`、子資源或特殊流程，沒有重複 Controller 資源名稱或完整 method 名稱？
- [ ] **ErrorDetail** 有上下文用 `ErrorDetail<TContext>`，無上下文用 `ErrorDetail`，兩者是否正確使用？
- [ ] **QueryOptions** Lambda 參數是否有業務語意名稱（非 `x`）？
- [ ] **Enum** 集合欄位是否用 `IEnumerable<EnumType>` 而非 `IEnumerable<string>`？
- [ ] **集合屬性** 是否用 `ICollection<T>` + `init;`（非 `List<T>` + `set;`）？
- [ ] **if/for/foreach** 是否都加了 `{}`？
- [ ] **環境變數** 是否透過 Enum + `.GetEnvironmentValue()`（非 `Environment.GetEnvironmentVariable()`）？
- [ ] **環境變數 Enum** 成員名稱是否全大寫底線且與實際環境變數一致，沒有使用 `PortalAuth__Enabled` 這類雙底線設定？
- [ ] **新建 Entity** 是否呼叫 `entity.InitializeAudit()`？
- [ ] **Audit Log Entity** 採用共用套件 audit log 且需要 recent audit log 的 entity，是否實作 `IEmbeddedAuditLogEntity` 並加上 `[AuditLogRetention(n)]`？主檔未指定時是否預設保留 5 筆？
- [ ] **Audit Log DTO** 採用共用套件 audit log 且 entity 有 recent audit log 時，輸出 DTO / Factory 是否包含 `Created*`、`LastUpdated*`、`RecentHistories` 並轉成 `AuditHistoryDto`？
- [ ] **紀錄性資料** 執行紀錄、同步紀錄是否只保留摘要/統計/關聯欄位，沒有重複保存完整 OldValue / NewValue？
- [ ] **Factory** UpdateEntity 是否用 `.IfPresent()` / `.IfNotNull()`？
- [ ] **XML Documentation** 所有 public 方法是否有繁體中文說明？
