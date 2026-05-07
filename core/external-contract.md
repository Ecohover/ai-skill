# 外部合約對齊協議 (Mock / Integration)

當任務涉及 **Mock 外部服務** 或 **對接外部 API** 時，本協議權限高於專案通用規範。

## 核心原則：完美偽裝 (Contract is King)

| 約束 | 說明 |
|------|------|
| MUST | **API 路由** 必須完全符合外部系統定義（如：使用 `/GetUserInfo` 而非 `/api/user/get_user`）。 |
| MUST | **欄位命名** 必須完全對齊外部系統（如：外部用 `UserName`，則 Schema 不可改為 `user_name`）。 |
| MUST | **資料型別** 必須模擬外部系統（如：外部用字串表示日期，則 Schema 需宣告為 `str`）。 |
| MUST | **錯誤回應** 必須模擬外部錯誤格式（HTTP Status Code 與 Body 結構）。 |

## 規則衝突處理 (Conflict Handling)

當專案規範與外部合約衝突時：

1. **Schema 層 (DTO/Router)**：**打破規範**，以外部合約為準。
2. **Service 層 (Business Logic)**：**保持規範**。若外部欄位命名極差，可在 Service 層將其轉為規範命名處理。
3. **命名對照**：在 `schemas/` 中使用 Pydantic 的 `alias` 功能，對外符合合約，對內符合規範。

## 實作前置步驟：合約清單 (Manifest Extension)

在執行「Mock」或「外部對接」任務的 Design 階段，除了 YAML 檔案清單外，必須額外產出 **Contract Mapping**：

```yaml
# 範例
external_api: "POST /v1/remote-api/login"
mapping:
  external_field: "UserUID" -> internal_field: "user_id"
  external_field: "PWD"     -> internal_field: "password"
rules_broken:
  - "Path naming convention (external requires camelCase)"
  - "Field naming convention (external requires PascalCase)"
```
