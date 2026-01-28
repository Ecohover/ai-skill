# 大成專案開發規範

本文件定義大成 (Dachan) 內部專案的私有套件引用、架構約束與實作標準。

---

## 首次使用設定

開始開發前，請提供以下資訊：
1. **CommonUtils 專案路徑**：用於參考現有工具類別與擴充方法
2. **目前專案路徑**：用於了解專案結構

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

### Dachan.MongoRepository
* 啟動時自動掃描並註冊 `[UseRepository(...)]` 標記的實體

---

## 2. API 設計規範

* **回傳型別**：Controller 直接回傳 POCO 或 `Task<T>`，**嚴禁手動封裝 Response**
* **Response 封裝**：由 `ApiResponseMiddleware` 統一處理
* **內部通訊**：微服務呼叫必須使用 `DachanHttpClientProxy`

---

## 3. 環境變數規範

* **禁止**：禁止直接使用 `Environment.GetEnvironmentVariable()`
* **必須**：使用 `EnumEnvironmentVariable` + 擴充方法
* **新增變數**：於 `EnumEnvironmentVariable` 定義 Key

---

## 4. Entity 規範

* **繼承**：必須繼承 `SoftDeletableEntity`
* **屬性標註**：
  ```csharp
  [BsonCollection("collection_name")]
  [UseRepository(typeof(FullRepository<>))]
  public class MyEntity : SoftDeletableEntity
  {
  }
  ```

---

## 5. Repository 規範

* **注入方式**：Service 建構函式注入 `IFullRepository<TEntity>`
* **禁止**：禁止注入具體類別或手動註冊

---

## 6. 異常處理

* **業務錯誤**：拋出 `DachanServiceException`
* **錯誤碼**：搭配 `DachanCommonError` 使用
* **全域處理**：由 Middleware 統一捕捉並回傳

---

## 7. 通用邏輯處理

開發過程中若發現以下情況，請詢問是否移至 CommonUtils：
* 超過 2 個專案可能使用的工具方法
* 通用的擴充方法
* 可重用的 Helper 類別
