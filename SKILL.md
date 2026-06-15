---
name: ai-engineering-workflow
description: Use when an AI agent works with this prompt rule pack, needs Planner/Builder/Reviewer/Code Inspector routing, must load engineering rules from AGENT.md, core, role, language, package, or unit folders, or needs plan docs, adapter markdown, or rule-based audits.
---

# AI 工程協作 Skill

本檔是 AI agent 使用本規則庫時的 Skill 啟動入口，只負責路由與按需載入，不取代實際規範。

`AGENT.md` 是 AI 路由的真理來源。`README.md` 是人類維護說明，不作為 AI 任務路由依據。

## 啟動流程

1. 讀取 `AGENT.md`。
2. 判斷任務應由 Planner、Builder、Reviewer 或 Code Inspector 處理。
3. 只載入該角色、語言、流程與模組需要的文件。
4. 除非正在處理計畫任務，搜尋或讀取規則庫時排除 `doc/plan/`，避免任務產物污染判斷。
5. 依角色文件執行任務，不得混用其他角色責任。
6. 若 AI 工具需要專屬入口 md，依 `command/adapt-agent.md` 產生 adapter。

## 測試任務必讀

當任務涉及新增、修改、審查或修復 .NET 測試時，必須載入 `language/dotnet/custom/testing.md`。尤其要遵守單元測試依賴邊界：

- 單元測試不得連外部 API、MQ、Portal、SAP、TMS、WMS 或其他服務。
- 單元測試不得直接讀寫 MongoDB、SQL、Redis 或任何真實資料庫/cache。
- 外部依賴必須以 mock、fake、in-memory test double、mock `HttpMessageHandler` 或 in-memory `TestServer` 隔離。
- 需要真實 API 或資料庫的測試必須歸類為 integration test，不得混在一般 unit test 流程。

## 排程同步與 Audit 任務必讀

當任務涉及排程同步、ERP 同步、主檔同步或 audit log 時，必須載入 `package/common-utils/audit-log.md`。尤其要注意：客戶主檔與商品主檔若外部來源管理欄位沒有實際異動，不得呼叫 repository update / patch 造成沒有業務變更的 audit log；可在 sync run processing records 記 `SKIPPED`。

## 服務間 API Key 與共用回應任務必讀

當任務涉及 OMS、TMS Adapter、Scheduler、Invoice 或其他服務間 API 呼叫、shared secret、internal/external API key、CommonUtils response middleware、`DachanApiResponse`、`ApiResult`、或 API response envelope 時，必須載入：

- `package/common-utils/api-key.md`
- `package/common-utils/api-response.md`
- `core/api-contract.md`
- `core/external-contract.md`（若涉及 Invoice、SAP、金財通或其他外部 / 既有合約）

尤其要注意：CommonUtils 不定義服務名稱；各服務自行定義 allow attribute 與 service constants。OMS 內部品項使用 `ItemCode` / `ItemName`；Invoice 或其他 boundary 合約若使用 `ProductNo` / `ProductName`，不得未盤點就直接改名。

## Enum Metadata 任務必讀

當任務涉及後端 enum option、`I18nKeyEnum`、`Enum/options`、前端 enum 下拉或 enum metadata 時，必須載入 `language/dotnet/custom/enum.md` 與 `core/api-contract.md`。尤其要注意 enum metadata 的隱性反射機制：

- enum option 只暴露掛 `[I18nKeyEnum]` 的 enum。
- `metadata` 只由 enum value attribute 中掛 `[EnumMetadataField("metadataKey")]` 的 public property 輸出。
- enum value 上的業務設定 attribute 必須使用 named argument，例如 `[OrderSetting(printDescription: "...")]`、`[ErpSetting(erpDocType: "...")]`，避免位置參數隱藏語意。
- enum metadata service 不得 hardcode 特定業務欄位，例如 ERP key。
- 沒有 metadata attribute 的 enum value，`metadata` 應為空物件，不得補領域預設值。
- 若 attribute 只供後端內部使用，不要在 property 掛 `[EnumMetadataField]`；例如訂單列印描述不應混入 ERP metadata。
- 多個 attribute 輸出同名 metadata key 時，服務啟動應失敗。
- enum metadata 通常在服務啟動時組合並快取；新增 attribute 或 metadata key 時仍須補單元測試確認 response shape。

## 目錄對照

- `AGENT.md`：通用路由入口與真理來源。
- `README.md`：給人類使用者與維護者閱讀，不作為 AI 路由來源。
- `role/`：角色責任與交接規則。
- `core/`：跨語言工程原則與合約。
- `language/`：語言專屬規範，依語言分為 `dotnet/`、`typescript/`、`python/` 等子目錄。
- `package/`：共用套件使用規範，可依套件整包替換。
- `unit/`：開發單位 profile，定義具體套件名稱與單位特規。
- `command/`：計畫、審查、分批稽核與 adapter 產生流程。
- `command/template/`：計畫文件模板。
- `doc/plan/`：實際任務紀錄產物。

## 核心原則

採用按需載入。不要一次讀完整個規則庫，也不要把所有規則合併成單一大型提示。

AI 協作時，程式碼優先服務人類檢核，而不是追求最短寫法。除非語言慣例明確要求，實作應偏好直白、可逐步閱讀的控制流程與中間變數；避免過度語法糖、多行 ternary、複合 builder inline return，或其他讓人類需要額外反推執行流程的簡略寫法。

角色邊界以 `role/*.md` 為準：

- Planner 只規劃，不寫程式碼。
- Builder 只實作，不執行 audit。
- Reviewer 只審查，不修改程式碼。
- Code Inspector 只做分批規則稽核，不修改程式碼。
