# .NET 基礎開發規範

## 1. 專案目錄結構
* **/deploy**：CI/CD 腳本、Docker 配置、環境變數定義檔
* **/doc**：API 規格書、資料庫 Schema、技術選型文件
* **/src**：
    * **Controllers**：API 進入點，Request 驗證與回應封裝
    * **Services**：業務邏輯層
    * **Infrastructure**：技術實作（DataAccess、External Services）
    * **Extensions**：全域通用擴充方法

## 2. 環境變數管理
* **常數化 Key**：在專屬類別定義 `public const string` 作為 Key
* **啟動時載入**：於 `Program.cs` 讀取並映射至強型別設定物件
* **全域常數**：載入後作為常數使用，運行期間不可變更
* **禁止**：禁止在程式碼中直接呼叫 `Environment.GetEnvironmentVariable()`

## 3. 程式碼風格
* **私有欄位**：`_camelCase`
* **禁止 `this.`**：存取成員時不使用 this 關鍵字
* **禁止 AutoMapper**：採用顯式手動映射
* **充血模型**：行為封裝於實體中，非貧血模型
* **JSON 處理**：使用 Newtonsoft.Json
* **非同步**：IO 操作必須使用 Async/Await

## 4. Enum 規範
* **定義**：分類欄位必須使用 Enum
* **傳輸**：API Request/Response 使用 string
* **儲存**：資料庫儲存使用 string
* **禁止**：禁止用 int 表示 Enum 值

## 5. OpenAPI 規範
* **工具**：使用 `Microsoft.AspNetCore.OpenApi`
* **文件**：對外 Action 與 DTO 必須有 `<summary>` 繁體中文說明

## 6. XML Documentation
* **範圍**：所有 `public` 方法
* **語言**：繁體中文
* **格式**：
  ```csharp
  /// <summary>
  /// 簡單說明
  /// </summary>
  /// <param name="id">參數說明</param>
  /// <returns>回傳說明</returns>
  ```
