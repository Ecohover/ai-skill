# .NET 提交前自審清單

提交程式碼前逐項確認：

- [ ] **Service** 是否使用 `partial class`？
- [ ] **DI 建構式** 是否使用 constructor injection / Primary Constructor，private 欄位是否 `_` 開頭，且沒有 property injection / service locator？
- [ ] **DI 排序** 多個依賴是否依 logger/context、MQ/event/external client、repository、其他 service 的順序排列？
- [ ] **日誌** 是否定義在獨立的 `*.Logging.cs`，使用 `[LoggerMessage]`？
- [ ] **Controller** 是否只處理 Request/Response，無商業邏輯？
- [ ] **CancellationToken** Controller 是否接收 `CancellationToken` 並傳遞到 Service / Repository，而非傳 `default`？
- [ ] **Controller** 是否有手動封裝 Response？（必須沒有）
- [ ] **Controller** 是否沒有手動回傳 `{Project}ApiResponse` / `ApiResult` / 自訂 wrapper？（必須由專案標準 middleware 統一封裝）
- [ ] **RequestContext** 採用 CommonUtils auth 的服務，是否沒有在 Controller 直接 `User.FindFirstValue(...)` 解析目前使用者？
- [ ] **API 路徑** 是否使用 `[Route("api/[controller]")]`，且沒有使用 `[action]`？
- [ ] **Action Route** 是否只放 `query`、`create`、`update`、子資源或特殊流程，沒有重複 Controller 資源名稱或完整 method 名稱？
- [ ] **ErrorDetail** 有上下文用 `ErrorDetail<TContext>`，無上下文用 `ErrorDetail`，兩者是否正確使用？
- [ ] **QueryOptions** Lambda 參數是否有業務語意名稱（非 `x`）？
- [ ] **Enum 比對** 程式內邏輯與查詢條件是否直接用 enum 型別比對，沒有先 `.ToString()` / `nameof()` 轉成 string 比對？
- [ ] **Enum** 集合欄位是否用 `IEnumerable<EnumType>` 而非 `IEnumerable<string>`？
- [ ] **Enum 字串值** 進出資料庫、內部服務、自家前端 API 的 Enum member 是否使用全大寫 snake_case，且有序列化機制確保傳輸/儲存為 enum member 名稱字串？外部合作 API 是否依 `core/external-contract.md` 明確標記例外？
- [ ] **有限條列式字串** 狀態、類型、階段、來源、處理結果等欄位是否有 Enum source，且沒有手寫 magic string？
- [ ] **Nullable / required** DTO / Entity 必填欄位是否用非 nullable + `required`，可選欄位才使用 nullable？
- [ ] **Validation 分層** DTO 是否只做 shape/格式驗證，Service 是否處理業務規則，Controller 是否沒有商業 validation？
- [ ] **測試** 高風險變更是否依風險導向 TDD 補測試，測試是否使用 Arrange / Act / Assert 並驗證行為？
- [ ] **一檔一 Class** 每個 `.cs` 檔案是否只定義一個主要 class / record / struct / interface / enum？
- [ ] **列表 DTO** 是否沒有把大型明細集合、完整 response body、audit trail 或 step results 放進列表查詢 response？
- [ ] **資料夾檔案數** 新增檔案後同資料夾是否超過 10 個檔案？若超過，是否已先詢問使用者確認分層方式？
- [ ] **控制流程可讀性** builder / update definition / query definition / mapper 等複合建構是否避免 inline return 與多行 ternary，改用明確區域變數、`if/else` 賦值、最後統一 return？
- [ ] **集合屬性** 是否用 `ICollection<T>` + `init;`（非 `List<T>` + `set;`）？
- [ ] **if/for/foreach** 是否都加了 `{}`？
- [ ] **環境變數** 是否透過 Enum + `.GetEnvironmentValue()`（非 `Environment.GetEnvironmentVariable()`）？
- [ ] **環境變數 Enum** 成員名稱是否全大寫底線且與實際環境變數一致，沒有使用 `PortalAuth__Enabled` 這類雙底線設定？
- [ ] **Auth 命名** Token / UserInfo 是否使用 `userId`、`employeeCode`、`permissions`，沒有新增 `mongo_id`、`AD`、`employee_id`、`permission`？
- [ ] **服務代碼與權限** 是否使用 `PORTAL`、`OMS`、`SCHEDULER` 等清楚服務代碼與四段 grant `{SERVICE}::{RESOURCE}::{GRANT_TYPE}::{VALUE}`？
- [ ] **新建 Entity** 採用共用套件 audit 欄位時，是否呼叫 `entity.InitializeAudit()`？
- [ ] **Audit Log Entity** 採用共用套件 audit log 且需要 recent audit log 的 entity，是否實作 `IEmbeddedAuditLogEntity` 並加上 `[AuditLogRetention(n)]`？主檔未指定時是否預設保留 5 筆？
- [ ] **Audit Log DTO** 採用共用套件 audit log 且 entity 有 recent audit log 時，輸出 DTO / Factory 是否包含 `Created*`、`LastUpdated*`、`RecentHistories` 並轉成 `AuditHistoryDto`？
- [ ] **紀錄性資料** 執行紀錄、同步紀錄是否只保留摘要/統計/關聯欄位，沒有重複保存完整 OldValue / NewValue？
- [ ] **Factory** UpdateEntity 是否用 `.IfPresent()` / `.IfNotNull()`？
- [ ] **XML Documentation** 所有 public 方法是否有繁體中文說明？
