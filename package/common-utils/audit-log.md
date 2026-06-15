# CommonUtils Audit Log 規範

## Entity 使用原則

| 約束 | 說明 |
|------|------|
| PREFER | 若專案採用 `{Project}.MongoRepository`，主檔 audit 欄位優先使用 CommonUtils 提供的 `IAuditFields` / `AuditBase` |
| MUST NOT | 因為有 `{Project}.MongoRepository` 就假設所有 entity 都必須啟用完整 audit log |
| MUST | 只有需要 recent audit log + 獨立 audit record 雙寫的 entity，才實作 `IEmbeddedAuditLogEntity` 並加上 `[AuditLogRetention(n)]` |

## 使用情境

- 只需要主檔 audit 欄位：
  - 使用 `IAuditFields` 或 `AuditBase`
  - repository 自動寫入 `Created*` / `LastUpdated*`
- 需要 recent audit log：
  - entity 實作 `IEmbeddedAuditLogEntity`
  - class 加上 `[AuditLogRetention(10|20|100)]`
  - repository 在 `Create / Update / HardDelete(entity)` 自動 append `RecentHistories`、trim 最舊紀錄、同步寫入 `AuditRecord`
  - 主檔一般預設保留最近 5 筆，除非業務明確要求更多筆數
  - 對外 DTO 需輸出 `Created*`、`LastUpdated*` 與 `RecentHistories`
  - Factory 需將 entity 的 `RecentHistories` 轉為前端可呈現的 `AuditHistoryDto`
  - 前端 detail 頁需能透過 AuditLog API 查詢完整紀錄，不在主檔 DTO 內塞完整歷程
- 不需要 audit log 的 entity：
  - 不要硬套 `IEmbeddedAuditLogEntity`

## 紀錄性 Entity

- 同步執行紀錄、排程觸發紀錄等「紀錄性資料」主要保存事件摘要、統計、狀態、關聯識別與重跑來源。
- 若紀錄性資料本身需要被修改或重打，仍可使用一般 audit 欄位或 audit log 記錄修改行為。
- 執行紀錄不應重複保存完整 OldValue / NewValue；異動明細應透過 `AuditRecordId`、目標 entity id 或其他關聯欄位連回 audit log。

## 排程同步與 Audit

- 排程或 ERP 同步處理主檔時，必須先比對外部來源管理欄位是否真的異動。
- 若客戶主檔或商品主檔的 SAP / ERP 管理欄位完全相同，不得呼叫 repository `UpdateAsync` / `PatchAsync` 寫回 entity，避免產生沒有業務變更的 audit log。
- 未異動資料可在 sync run processing records 中記 `SKIPPED`，但 entity audit log 只應記錄真正新增或異動的資料。

```csharp
[AuditLogRetention(20)]
[BsonCollection("OutboundOrders")]
[UseRepository(typeof(FullRepository<>))]
public class OutboundOrder : AuditBase, IAggregateRoot, IEmbeddedAuditLogEntity
{
    [BsonId]
    public ObjectId Id { get; set; }

    public required string OrderNo { get; set; }
}
```
