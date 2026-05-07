# Python 基礎規則

## 格式與型別

| 約束 | 說明 |
|------|------|
| MUST | 強制使用 **Type Hints**（型別標註），包含方法參數與回傳值 |
| MUST | 使用 `mypy` 或 `pyright` 進行靜態型別檢查 |
| MUST | 縮排使用 4 個空格（PEP 8） |
| MUST | 所有的 IO 操作必須使用 `async/await` |
| MUST | 啟用 `strict` 模式處理 Nullable 型別（使用 `Optional` 或 `| None`） |

## 命名規範

對齊專案通用原則，但符合 Python 慣例：

| 類型 | 格式 | 範例 |
|------|------|------|
| 類別 (Class) | **PascalCase** | `WarehouseService` |
| 函式/方法 | **snake_case** | `create_warehouse` |
| 變數/參數 | **snake_case** | `warehouse_code` |
| 常數 | **UPPER_SNAKE_CASE** | `MAX_RETRY_COUNT` |
| 布林值 | 以 `is_/has_/can_` 開頭 | `is_active` |

## DTO (Pydantic Schemas)

Python 專案使用 **Pydantic** 取代 .NET DTO，命名格式需與 .NET 一致：

| 類型 | 命名格式 | 範例 |
|------|----------|------|
| 新增輸入 | `InCreate{Entity}Dto` | `InCreateWarehouseDto` |
| 更新輸入 | `InUpdate{Entity}Dto` | `InUpdateWarehouseDto` |
| 查詢輸入 | `InQuery{Entity}Dto` | `InQueryWarehouseDto` |
| 輸出 | `Out{Entity}Dto` | `OutWarehouseDto` |

```python
from pydantic import BaseModel, Field
from typing import Optional

class InCreateWarehouseDto(BaseModel):
    code: str = Field(..., min_length=2)
    name: str
    remark: Optional[str] = None

    class Config:
        anystr_strip_whitespace = True
```

## 物件映射 (Mapping)

Python 專案強調「顯性勝於隱性」，不使用自動映射工具：

| 約束 | 說明 |
|------|------|
| MUST | 使用 Pydantic 的 `model_validate` (v2) 或 `from_orm` (v1) 進行轉換。 |
| MUST | 複雜邏輯使用顯性的建構子傳參：`MyModel(field=dto.field, ...)`。 |
| PREFER | 若需要處理外部 API (Mock)，使用 `Field(alias="ExternalName")` 來橋接外部命名與內部規範。 |

## 文件化

| 約束 | 說明 |
|------|------|
| MUST | 所有的 Public 方法與類別必須包含 **Google Style Docstrings** |
| MUST | 註解說明使用 **繁體中文** |

```python
def get_warehouse_by_code(code: str) -> Optional[Warehouse]:
    """
    依據編號取得倉庫資料。

    Args:
        code: 倉庫編號。

    Returns:
        Warehouse: 倉庫實體，找不到時回傳 None。
    """
```
