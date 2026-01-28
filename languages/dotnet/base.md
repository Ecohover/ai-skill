# .NET 基礎開發規範

## 1. 專案目錄結構
* **/deploy**：CI/CD 腳本、Docker 配置、環境變數定義檔
* **/doc**：API 規格書、資料庫 Schema、技術選型文件
* **/src**：
    * **Controllers**：API 進入點，僅處理 Request/Response，不含商業邏輯
    * **Services**：業務邏輯層
    * **Models**：
        * **Entities**：資料庫實體
        * **DTO**：資料傳輸物件
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
* **JSON 處理**：使用 Newtonsoft.Json
* **JSON Casing**：API Request/Response 使用 **camelCase**
* **非同步**：IO 操作必須使用 Async/Await

## 4. 物件映射規範
* **禁止 AutoMapper**：不使用自動映射套件
* **手動映射**：簡單轉換直接寫在使用處
* **重複轉換**：超過 3 次的重複映射，抽取至**自定義工廠類別**處理

## 5. 充血模型規範
* **適用範圍**：僅限處理**物件本身參數**的內部邏輯
* **禁止**：不得牽扯外部資料、外部服務、或跨物件邏輯
* **範例**：狀態驗證、欄位計算、格式轉換

```csharp
// 正確：內部邏輯
public class Order
{
    public decimal Total => Items.Sum(x => x.Price * x.Quantity);
    public bool CanCancel => Status == OrderStatus.Pending;
}

// 錯誤：牽扯外部
public class Order
{
    public void Cancel(INotificationService service) // 不應該
}
```

## 6. Enum 規範
* **定義**：分類欄位必須使用 Enum
* **傳輸**：API Request/Response 使用 string
* **儲存**：資料庫儲存使用 string
* **禁止**：禁止用 int 表示 Enum 值

## 7. 異常處理
* **簡易標準**：使用 .NET 內建 Exception 類型
* **拋出時機**：商業邏輯錯誤、驗證失敗、資源不存在
* **全域處理**：透過 Middleware 統一捕捉並回傳格式化錯誤

## 8. HTTP Status Code
使用標準語意：
| 狀態碼 | 用途 |
|--------|------|
| 200 | 成功 |
| 201 | 建立成功 |
| 400 | 請求格式錯誤、驗證失敗 |
| 401 | 未授權 |
| 403 | 無權限 |
| 404 | 資源不存在 |
| 500 | 伺服器內部錯誤 |

## 9. OpenAPI 規範
* **工具**：使用 `Microsoft.AspNetCore.OpenApi`
* **文件**：對外 Action 與 DTO 必須有 `<summary>` 繁體中文說明

## 10. XML Documentation
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
