# .NET 基礎開發規範

## 1. 專案目錄結構與職責
* **/deploy**：CI/CD 腳本、Docker 配置、環境變數定義檔（.env）。
* **/doc**：API 規格書、資料庫 Schema 說明、技術選型文件。
* **/src**：
    * **Controllers**：API 進入點，負責 Request 驗證與格式封裝。
    * **Infrastructure**：技術實作（DataAccess、External Services）。
    * **Extensions**：全域通用 C# 擴充方法與工具。

## 2. 環境變數與設定管理
* **常數化管理**：必須在專屬類別定義 `public const string` 作為環境變數的 Key。
* **強型別映射**：啟動時將環境變數映射至強型別設定物件。
* **全域啟動加載**：於 `Program.cs` 完成初始化，提供全域安全存取。

## 3. 程式碼風格
* **私有欄位**：`_camelCase` 且 **禁止使用 `this.`**。
* **禁止使用 AutoMapper**：採顯式手動映射。
* **充血模型**：行為封裝於實體中。
* **技術標準**：使用 **Newtonsoft.Json**、**Async/Await**。

## 4. OpenAPI 規範
* **工具**：使用 .NET 10 推薦的 `Microsoft.AspNetCore.OpenApi`。
* **說明**：對外的 Action 與 DTO 必須具備明確的 `<summary>` 繁體中文說明。

## 5. XML Documentation 規範
* **對外方法**：所有 `public` 方法必須包含繁體中文簡單註解。
* **格式標準**：
  ```csharp
  /// <summary>
  /// 簡單說明
  /// </summary>
  /// <param name="id">參數說明</param>
  /// <returns>回傳說明</returns>
  ```
