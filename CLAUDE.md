# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 專案說明

用於 AI 協作開發的 Prompt 規則庫。透過分層疊加 (Layered Stacking) 組合 Markdown 規則檔，供任何 AI 工具直接閱讀使用，不依賴特定 AI 工具的配置機制。

## 架構（分層疊加）

| 層級 | 路徑 | 說明 |
|------|------|------|
| Level 1 | `common/*.md` | 通用規則，所有專案都載入 |
| Level 2 | `languages/<lang>/base.md` | 語言基礎規範 |
| Level 3 | `languages/<lang>/extensions/<name>.md` | 專案特定架構覆蓋規則（選用）|
| Level 4 | `modules/*.md` | 可選技術模組（選用）|

## 新增規則

- **新語言**：建立 `languages/<語言>/base.md`
- **新專案擴展**：建立 `languages/<語言>/extensions/<名稱>.md`
- **新功能模組**：建立 `modules/<名稱>.md`（可跨語言複用）
- **通用規則**：修改 `common/collaboration.md`

設計原則：若規則可通用於多種語言，放 `modules/`；若語言特定，放 `languages/`。

## 外部專案路徑慣例

規則檔中不硬編碼任何本機路徑。若涉及私有套件或外部專案（如 `Dachan.CommonUtils`），在規則中統一使用「請詢問使用者實際路徑」的提示方式。
