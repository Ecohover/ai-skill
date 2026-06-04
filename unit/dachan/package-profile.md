# 大成開發單位 Package Profile

本檔只定義大成目前採用的具體套件與型別名稱。通用使用規範放在 `package/common-utils/`。

## CommonUtils Profile

| 抽象名稱 | 大成目前實作 |
|----------|--------------|
| `{Project}.CommonUtils` | `Dachan.CommonUtils` 或專案對應命名 |
| `{Project}.CommonUtils.Web` | `Dachan.CommonUtils.Web` 或專案對應命名 |
| `{Project}.Common.EventDriven` | `Dachan.Common.EventDriven` 或專案對應命名 |
| `{Project}.MongoRepository` | `Dachan.MongoRepository` |
| `{Project}ApiResponse<T>` | `DachanApiResponse<T>` |
| API response middleware | `ApiResponseMiddleware` |
| 前端 shared package | `@dachan/shared` |

## 載入建議

大成 .NET 專案若採用 CommonUtils 類共用套件，除 `language/dotnet/` 規範外，需載入：

- `package/common-utils/base.md`
- `package/common-utils/api-response.md`
- `package/common-utils/audit-log.md`
- `package/common-utils/environment.md`
- `unit/dachan/package-profile.md`
