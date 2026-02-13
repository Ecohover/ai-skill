# 大成專案開發規範

本文件定義大成 (Dachan) 內部專案的私有套件引用、架構約束與實作標準。

---

## 專案參考路徑

* **CommonUtils 路徑**：`{{DACHAN_COMMONUTILS_PATH}}`

> 開發過程中若發現可通用的邏輯，會詢問是否需要調整至 CommonUtils。

---

## 1. 私有套件與依賴管理

所有新功能開發必須優先使用公司核心套件，**嚴禁重複造輪**。

### Dachan.CommonUtils
* 核心工具包，包含通用擴充方法
* **環境變數**：使用 `EnumEnvironmentVariable` + `.GetRequiredString()`

### Dachan.CommonUtils.Web
* **Middleware**：API 自動封裝 (`ApiResponseMiddleware`)、JWT 身份識別、全域日誌
* **HTTP Proxy**：`DachanHttpClientProxy` 用於內部微服務對接，自動轉發 Headers

### Dachan.Common.EventDriven
* 處理異步領域事件、RabbitMQ 訊息整合

### Dachan.MongoRepository
* 啟動時自動掃描並註冊 `[UseRepository(...)]` 標記的實體

---

## 2. 目錄分層 (Clean Architecture)

* `/src/Dachan.Wms/Controllers`：API 進入點，僅處理 Request/Response，不含商業邏輯
* `/src/Dachan.Wms/Interfaces`：業務邏輯介面層 (Service Interfaces)
* `/src/Dachan.Wms/Services`：業務邏輯實作層 (Application Layer)，**必須使用 partial class** 以支援高效能日誌
* `/src/Dachan.Wms/Domain/Entities`：核心領域實體 (Domain Entities)
* `/src/Dachan.Wms/Domain/Events`：領域事件定義 (Domain Events)
* `/src/Dachan.Wms/Domain/IRepositories`：倉儲介面定義 (Repository Interfaces)
* `/src/Dachan.Wms/Event`：事件處理器，包含領域事件 (DomainEventHandlers) 與外部訊息 (RabbitMqEventHandle)
* `/src/Dachan.Wms/Infrastructure/Factories`：靜態工廠，負責 DTO 與 Entity 之間的物件映射

---

## 3. 職責分離

* **Shared DTO**：僅負責資料結構定義，**禁止**包含 UI 顯示邏輯（如轉中文、格式化）
* **Client Extensions**：所有顯示轉換（Enum 轉中文等）必須定義在前端的擴充方法中（如 `DisplayExtensions.cs`）

---

## 4. API 設計規範

* **回傳型別**：Controller 直接回傳 POCO 或 `Task<T>`，**嚴禁手動封裝 Response**
* **Response 封裝**：由 `ApiResponseMiddleware` 統一處理
* **內部通訊**：微服務呼叫必須使用 `DachanHttpClientProxy`

---

## 5. 環境變數規範

* **禁止**：禁止直接使用 `Environment.GetEnvironmentVariable()`
* **必須**：使用 `EnumEnvironmentVariable` + 擴充方法
* **新增變數**：於 `EnumEnvironmentVariable` 定義 Key

---

## 6. Entity 規範

* **繼承**：必須繼承 `AuditableEntityBase` 或 `SoftDeletableEntity`
* **存放位置**：必須放在 `/src/Dachan.Wms/Domain/Entities` 下
* **屬性標註**：
  ```csharp
  [BsonCollection("collection_name")]
  [UseRepository(typeof(FullRepository<>))]
  public class MyEntity : SoftDeletableEntity
  {
  }
  ```

---

## 7. Repository 規範

* **注入方式**：Service 建構函式注入 `IFullRepository<TEntity>`
* **禁止**：禁止注入具體類別或手動註冊

---

## 8. 異常處理

* **業務錯誤**：拋出 `DachanServiceException`
* **錯誤碼**：搭配 `WmsError` 或 `DachanCommonError` 使用
* **集中定義**：WMS 專屬錯誤必須定義在 `WmsError` 靜態類別中，比照 `ApiClientError` 風格
* **全域處理**：若不需要自定義錯誤，則不要撰寫 `try-catch`，讓異常自然向上拋出給全域 Middleware 處理
* **禁止行為**：禁止在 Service 或 Controller 中撰寫僅為了記錄 Log 而重新 throw 的冗餘代碼

---

## 9. 高效能日誌 (CA1848)

* **Source Generators**：優先使用 **`[LoggerMessage]`** 屬性定義日誌方法，以提升效能並減少裝箱損耗
* **檔案拆分**：日誌定義應放在與主程式隔離的 **`*.Logging.cs`** 檔案中
* **泛型處理**：在泛型類別中若無法使用 Source Generator，則應改用 `LoggerMessage.Define`

---

## 10. 查詢與過濾 (Fluent API 模式)

* **兩行式初始化**：建立查詢選項時，將實例化與分頁配置分開
    ```csharp
    var queryOptions = new QueryOptions<Warehouse>();
    queryOptions.ApplyPaging(queryDto);
    ```
* **描述性過濾**：使用 `QueryOptionsExtensions` 提供的 `Add...IfProvided` 系列方法，並配合「具名參數」提升識別度
    ```csharp
    queryOptions.AddStartsWithIfProvided(value: queryDto.Code, targetField: warehouse => warehouse.Code);
    ```

---

## 11. 前端 (Blazor) 開發規範

* **元件庫**：UI 開發優先使用 **MudBlazor** 組件
* **魔術字串處理**：進行 Enum 類型比對或賦值時，應使用 **`nameof(EnumType.Value).ToLowerInvariant()`**
* **選單管理**：導覽選單必須透過 `SideBarHelper` 與 `SideBarNode` 邏輯產生

---

## 12. 通用邏輯處理

開發過程中若發現以下情況，請詢問是否移至 CommonUtils：
* 超過 2 個專案可能使用的工具方法
* 通用的擴充方法
* 可重用的 Helper 類別
