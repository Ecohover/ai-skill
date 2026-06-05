# 外部合約對齊協議 (Mock / Integration)

當任務涉及 **Mock 外部服務** 或 **對接外部 API** 時，本協議權限高於專案通用規範。

## 核心原則：外部偽裝、內部一致

| 約束 | 說明 |
|------|------|
| MUST | **API 路由** 必須完全符合外部系統定義（如：使用 `/GetUserInfo` 而非 `/api/user/get_user`）。 |
| MUST | **Wire 欄位名稱** 必須完全對齊外部系統（如：外部用 `UserName`，對外 JSON 欄位就必須是 `UserName`）。 |
| MUST | **內部程式命名** 必須維持專案命名規範，使用 alias / mapping / adapter 橋接外部欄位，不得讓外部命名污染 Service、Domain、Factory。 |
| MUST | **資料型別** 必須模擬外部系統（如：外部用字串表示日期，則 Schema 需宣告為 `str`）。 |
| MUST | **錯誤回應** 必須模擬外部錯誤格式（HTTP Status Code 與 Body 結構）。 |

## 規則衝突處理 (Conflict Handling)

當專案規範與外部合約衝突時：

1. **Boundary 層 (DTO/Router/Adapter)**：對外 wire format 以外部合約為準；程式碼屬性與變數命名仍維持內部規範。
2. **Mapping 層**：必須明確記錄外部欄位與內部欄位的對照，使用 alias / attribute / adapter 轉換。
3. **Service 層 (Business Logic)**：只使用內部標準命名與標準 enum 格式，不直接流入外部欄位命名。
4. **Domain / DB 層**：不受外部合約污染，仍符合專案內部規範。

## 命名橋接範例

### .NET

```csharp
public sealed class ExternalLoginDto
{
    [JsonPropertyName("UserUID")]
    public required string UserId { get; init; }

    [JsonPropertyName("PWD")]
    public required string Password { get; init; }
}
```

### Python

```python
class ExternalLoginDto(BaseModel):
    user_id: str = Field(alias="UserUID")
    password: str = Field(alias="PWD")
```

## 實作前置步驟：合約清單 (Manifest Extension)

在執行「Mock」或「外部對接」任務的 Design 階段，除了 YAML 檔案清單外，必須額外產出 **Contract Mapping**：

```yaml
# 範例
external_api: "POST /v1/remote-api/login"
mapping:
  external_field: "UserUID" -> internal_field: "user_id"
  external_field: "PWD"     -> internal_field: "password"
wire_contract_exceptions:
  - "Route uses external path casing"
  - "JSON field names use external names via alias/attribute"
```
