# AI 協作通用原則

## Clean Code 原則

### 結構
* **方法長度**：建議 50 行內，特殊情況可彈性處理（如複雜演算法、不適合拆分的邏輯）
* **早期返回 (Early Return)**：先處理錯誤/邊界條件，減少嵌套
* **避免深層嵌套**：最多 2-3 層，超過應抽取方法
* **單一職責 (SRP)**：一個類別/方法只做一件事
* **SOLID 原則**：遵循 SRP、OCP、LSP、ISP、DIP

### 命名
* **禁止縮寫**：除非是公認縮寫（如 HTTP、JSON、API、URL、ID、DTO）
* **有意義命名**：禁止 `temp`、`data`、`info`、`obj` 等模糊名稱
* **布林命名**：使用 `is`、`has`、`can`、`should` 開頭
* **方法命名**：動詞開頭，表達行為（Get、Create、Update、Delete、Validate）

### 語意命名規範
| 名稱 | 用途 | 格式 |
|------|------|------|
| `Id` | 機器識別（UUID/GUID） | 人類不可讀 |
| `Code` | 人類識別 | 英數、日期、簡單符號混合 |
| `Type` | 分類標記 | 必須用 Enum，傳輸/儲存用 string |

### 設計
* **DRY**：重複邏輯超過 2 次就抽取
* **KISS**：優先選擇簡單方案
* **依賴注入**：透過建構函式注入，禁止在方法內 `new` 依賴
* **避免魔術數字**：數字必須用 const 或 enum 命名

### 防禦
* **Guard Clauses**：方法開頭驗證參數有效性
* **Fail Fast**：錯誤早發現早拋出，不要吞掉異常
* **Null 安全**：啟用 Nullable Reference Types，明確處理 null
