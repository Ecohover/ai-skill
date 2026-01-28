# MongoDB 開發規範

## 連線管理
* 使用連線池，避免頻繁建立連線。
* 連線字串必須透過環境變數配置。

## 資料模型設計
* Collection 命名使用 **snake_case**。
* 必須為常用查詢欄位建立索引。
* 避免過深的巢狀結構（建議最多 3 層）。

## 查詢優化
* 優先使用投影 (Projection) 減少資料傳輸。
* 批次操作使用 `BulkWrite`。
* 分頁查詢避免使用 `Skip`，改用 cursor-based pagination。
