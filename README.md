# Dachan AI Prompts

各專案透過 **git submodule** 引入此規則庫，AI 按需讀取對應檔案。

> AI 請直接讀取 `AGENT.md` 作為路由入口，勿直接閱讀此文件。

---

## 核心設計理念：分段載入 (Token 優化)
為避免一次性灌入過多無關的 Prompt 導致 AI 幻覺與 Token 浪費，本規則庫採用**樹狀分層結構**。
AI 在執行任務時，應依循 `AGENT.md` 的指示，分為三個階段載入上下文：
1. **共用跨語言參考 (Universal)**: 載入通用原則與全域合約 (`core/`)。
2. **語言基礎 (Language Base)**: 載入該語言的基礎語法與型別規則。
3. **任務特定 (Task Specific)**: 根據具體修改的功能（如：新增 API、修改資料庫查詢），精準載入特定的模組規範。

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

在各專案的 `gemini.md`, `.prompt.md` 或 `CLAUDE.md` 頂部加入：

```markdown
規則庫位於 `.prompts/`，執行任務前請**必須**先閱讀 `.prompts/AGENT.md` 以取得路由指南。
```

---

## 目錄結構

```text
AGENT.md             ← AI 入口：載入順序指南與路由對照表（AI 唯一入口）
README.md            ← 本檔：給開發者的說明
core/                ← 跨語言通用參考 (Universal)
  principles.md      ← 通用原則（命名/目錄結構/設計/時間）
  api-contract.md    ← FE/BE 共用 API 合約（分頁/Searches/Enum/錯誤格式）
  external-contract.md ← 對接外部系統或 Mock 專用合約
dotnet/              ← .NET 語言專屬區
  base.md            ← .NET 基礎（格式/集合/充血模型/物件映射）
  dachan/
    structure.md     ← 目錄/Entity/DTO/Controller/Service/Factory
    error.md         ← ErrorDetail 異常處理
    ...
typescript/          ← 前端語言專屬區
  base.md            ← TypeScript/Vue 3 基礎規則
  dachan/
    structure.md     ← 目錄/路由/Pinia
    ...
python/              ← Python 語言專屬區
  base.md            ← Python 基礎規則 (型別/命名/Pydantic)
  fastapi.md         ← FastAPI 框架規範
commands/            ← 流程與品質控管
  plan.md            ← 開發流程協議（Research→Design→Implement→Verify）
  audit-*.md         ← 各語言提交前自審清單
```
