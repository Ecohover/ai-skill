# FastAPI 框架規範

## 目錄結構 (src/)

Python 專案內部的 `src/` 目錄採用類 Clean Architecture 的結構：

| 目錄/路徑 | 職責 | 對應 .NET |
|------|------|----------|
| `src/api/routers/` | 定義 Endpoint，僅負責 Request/Response | `src/*/Controllers/` |
| `src/services/` | 業務邏輯實作（Performer） | `src/*/Services/` |
| `src/models/` | 資料庫實體（SQLAlchemy / Motor） | `src/*/Domain/Entities/` |
| `src/schemas/` | Pydantic DTO 定義 | `src/*/Models/DTOs/` |
| `src/core/` | 設定、環境變數、日誌配置 | `src/*/Extensions/` |
| `src/factories/` | 物件映射工廠 | `src/*/Infrastructure/Factories/` |

## API 合約與回應

### 規則優先級：Mock 模式

**當本服務作為 Mock 使用時，必須遵循 `core/external-contract.md`**：

1. **路徑與欄位**：完全對齊外部系統，打破大成內部 `In...Dto` 規範。
2. **橋接**：使用 Pydantic 的 `alias` 或 `validation_alias` 來保持內部開發的可讀性。

### 統一回應格式 (Internal Standard)

必須遵循 `core/api-contract.md` 定義。Python 實作範例：

```python
class ApiResult(BaseModel, Generic[T]):
    success: bool
    data: Optional[T] = None
    errorCode: Optional[str] = None
    message: Optional[str] = None

# 在 Router 中使用
@router.post("/get_warehouse", response_model=ApiResult[PageResult[OutWarehouseDto]])
async def get_warehouse(query: InQueryWarehouseDto):
    # logic...
```

### 錯誤處理

| 約束 | 說明 |
|------|------|
| MUST | 定義自定義 Exception 類別（如 `AdjustmentError`） |
| MUST | 使用 FastAPI 的 `exception_handler` 統一處理錯誤並轉換為 `ApiResult` 格式 |
| MUST | 錯誤碼格式：`{系統}-{領域}-{代碼}` |

## 依賴注入 (DI)

FastAPI 使用 `Depends` 進行依賴注入：

```python
# services/warehouse_service.py
class WarehouseService:
    def __init__(self, repo: WarehouseRepository):
        self.repo = repo

# api/deps.py
def get_warehouse_service() -> WarehouseService:
    return WarehouseService(repo=WarehouseRepository())

# api/routers/warehouse.py
@router.post("/")
async def create(
    dto: InCreateWarehouseDto,
    service: WarehouseService = Depends(get_warehouse_service)
):
    return await service.create_warehouse(dto)
```

## 異步資料庫存取 (MongoDB)

本 Mock Service 使用 **Motor** (Async MongoDB) 作為資料存取層。

| 約束 | 說明 |
|------|------|
| MUST | 所有的資料庫操作必須是 `async` |
| MUST | 使用 Pydantic 的 `AliasPath` 或 `populated_by_name` 處理 `_id` ↔ `id` 的映射 |
| PREFER | 封裝成 Repository Pattern 供 Service 呼叫 |
