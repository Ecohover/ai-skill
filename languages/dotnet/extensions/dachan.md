# 大成專案開發規範

本文件定義了大成 (Dachan) 內部專案的**私有套件引用**、**架構約束**與**實作標準**。

## 1. 私有套件與依賴管理
所有新功能開發必須優先使用公司核心套件，**嚴禁造輪子**。

* **Web 整合層 (`Dachan.CommonUtils.Web`)**：
    * **Middleware**：負責 API 自動封裝 (`ApiResponseMiddleware`)、JWT 身份識別、全域日誌。
    * **HTTP Proxy (`DachanHttpClientProxy`)**：**專用於內部微服務對接**，自動轉發 Context Headers (TraceId, UserContext)。
* **資料存取包 (`Dachan.MongoRepository`)**：
    * **自動化**：啟動時自動掃描並註冊標記了 `[UseRepository(...)]` 的實體。
* **核心工具包 (`Dachan.CommonUtils`)**：
    * **環境變數擴充**：提供 `EnumEnvironmentVariable` 的強型別讀取方法。

## 2. Kiro 模式擴充

### Phase 1: 需求與依賴分析
* **依賴檢查**：確認 `Program.cs` 是否已註冊 `AddMongoRepository`。
* **環境變數盤點**：若需新增設定，請於 `EnumEnvironmentVariable` 定義 Key。

### Phase 2: 設計與物件行為
* **API 設計 (Zero-Boilerplate)**：
    * **回傳型別**：Controller 直接回傳 POCO 或 `Task<T>`，**嚴禁手動封裝 Response**。
    * **通訊規範**：內部服務呼叫必須使用 `DachanHttpClientProxy`。
* **環境變數存取**：
    * **嚴禁**使用 `Environment.GetEnvironmentVariable`。
    * **必須**對 `EnumEnvironmentVariable` 使用擴充方法 (`.GetRequiredString()`)。
* **資料實體 (Entity) 規範**：
    * **繼承**：必須繼承 `SoftDeletableEntity`。
    * **屬性標註**：
        1.  **`[BsonCollection("集合名稱")]`**：定義 MongoDB Collection。
        2.  **`[UseRepository(typeof(FullRepository<>))]`**：**必須指定實作型別**。

### Phase 3: 任務與實作細節
* **Repository 注入**：Service 建構函式**必須注入 `IFullRepository<TEntity>`**。
* **異常處理**：業務錯誤拋出 `DachanServiceException` (搭配 `DachanCommonError`)。
