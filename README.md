# Dachan AI Prompts

各專案透過 **git submodule** 引入此規則庫，AI 按需讀取對應檔案。

> AI 請讀 `AGENT.md`，不是這份。

---

## 加入 Submodule

```bash
git submodule add <repo-url> .prompts
```

clone 後更新：

```bash
git submodule update --init
```

---

## 在各專案中連結規則庫

在專案的 `CLAUDE.md` 或 `.prompt.md` 頂部加入：

```
規則庫位於 .prompts/，需要時請先讀 .prompts/AGENT.md。
```

---

## 目錄結構

```
AGENT.md             ← AI 入口：場景 → 檔案對應表（AI 從這裡開始）
README.md            ← 本檔：給開發者的說明
core/
  principles.md      ← 通用原則（命名/設計/時間）
  api-contract.md    ← FE/BE 共用 API 合約（分頁/Searches/Enum/錯誤格式）
dotnet/
  base.md            ← .NET 基礎（格式/集合/充血模型/物件映射）
  dachan/
    structure.md     ← 目錄/Entity/DTO/Controller/Service/Factory
    error.md         ← ErrorDetail 異常處理
    query.md         ← QueryOptions / ApplyContainsSearches 模糊查詢
    logging.md       ← [LoggerMessage] 高效能日誌
    enum.md          ← [UpperCaseEnum] / Enum 規範
    env.md           ← 環境變數
typescript/
  base.md            ← TypeScript/Vue 3 基礎規則
  dachan/
    structure.md     ← Dachan Frontend 目錄/路由/Pinia/打包規範
    api-module.md    ← API 模組規範（composables/api/modules/）
    env.md           ← VITE_ 環境變數
commands/
  plan.md            ← 開發流程協議（Research→Design→Implement→Verify）
  audit-dotnet.md    ← .NET 提交前自審清單
  audit-typescript.md← TypeScript 提交前自審清單
```
