# AI Engineering Rule Pack

這是一個 **AI 泛用工程規則庫**，透過 Git Submodule 引入專案，為不同 AI agent 提供開發規範、設計模式與任務管理流程。

本檔給人類使用者與維護者閱讀，說明如何安裝、連結與維護這份 Skill。

AI agent 的啟動入口是 `SKILL.md`；實際角色路由與載入順序由 `AGENT.md` 定義。

---

## 使用方式

### 1. 安裝到專案

各專案透過 git submodule 連結：

```bash
git submodule add <repo-url> .prompts
```

在使用專案的 AI 設定檔頂部加入：

```md
規則庫位於 .prompts/。執行任務前請先使用 .prompts/SKILL.md；若工具不支援 Skill，請讀取 .prompts/AGENT.md 作為路由入口。
```

### 2. 讓 AI 開始工作

一般使用時，只要告訴 AI：

```md
請依 .prompts/SKILL.md 使用本規則庫。
```

AI 會再依任務類型進入 Planner、Builder、Reviewer 或 Code Inspector。

### 3. 工具 adapter

不同 AI 工具若需要自己的入口 md，應依 `command/adapt-agent.md` 產生 adapter。

adapter 是使用專案產物，不是本規則庫的真理來源。

---

## 核心設計理念

為了降低 Token 消耗並減少 AI 誤判，本規則庫採用以下結構：

1. **按需載入**：AI 僅讀取與當前任務角色、語言、模組相關的規範。
2. **角色分工**：Planner、Builder、Reviewer、Code Inspector 分別負責規劃、實作、審查與分批稽核。
3. **任務記錄**：簡單任務直接執行；計畫任務在 `doc/plan/` 下留下索引與詳細計畫。
4. **單一真理來源**：`AGENT.md` 是 AI 路由來源，`role/`、`core/`、`language/`、`package/`、`unit/` 與 `command/` 提供細部規則。

> `command/template/` 是本規則庫的版本化模板；`doc/plan/` 是各使用專案執行任務時產生的紀錄，應被 ignore，不提交回規則庫 repo。

---

## 維護者準則

後續修改或擴充此規則庫時，**必須**遵守以下規定：

### 1. 保持檔案細粒度 (Keep Files Granular)
- 嚴禁建立巨大的規範文件。
- 每個檔案應專注於單一職責（例如：`error.md` 僅處理異常，`query.md` 僅處理查詢）。
- 檔案大小建議保持在 100 行以內，以降低 AI 讀取成本。
- 流程參考與模板檔可略超過 100 行，但不得列入一般 Builder 必讀；應只在 Planner / Code Inspector 對應流程中按需讀取。

### 2. 遵守三階段載入架構
- **階段 1**: 全域通用原則 (`core/`)。
- **階段 2**: 語言基礎與特定模組 (`language/dotnet/`, `language/typescript/`, `language/python/`)。
- **階段 3**: 共用套件與開發單位 profile (`package/`, `unit/`)。
- **階段 4**: 流程控制與驗證 (`command/`)。
- 新增功能規範時，請按此層級歸類。

### 3. 維護任務判定邏輯
- 任何關於開發流程的修改，必須確保 `command/plan.md` 中的「簡單任務」與「計畫任務」判定邏輯清晰。
- 強制要求計畫任務使用 `doc/plan/[三位序號]-[task-name]/plan.md` 結構。

### 4. 跨語言一致性
- 當新增一種程式語言支援時，應在 `language/[語言]/` 下參照現有的 `.NET` 或 `TypeScript` 結構，建立 `base.md` 與專案自定義資料夾（`custom/`），確保使用者的開發體驗一致。

### 5. 共用套件與開發單位分離
- coding style 放在 `language/`，不要綁定公司或套件名稱。
- 共用套件行為放在 `package/[套件]/`，若改用另一組共用套件可整包替換。
- 開發單位實際名稱與 profile 放在 `unit/[開發單位]/`。

---

## 目錄結構

```text
AGENT.md             ← AI 入口：載入順序指南與路由對照表
README.md            ← 本檔：給開發者與維護者的規範
SKILL.md             ← 給 AI agent 使用的 Skill 啟動入口
core/                ← 跨語言通用參考 (Universal Principles)
language/            ← 語言專屬規範
language/dotnet/     ← .NET 語言專屬區
language/typescript/ ← 前端語言專屬區
language/python/     ← Python 語言專屬區
package/             ← 共用套件使用規範
unit/                ← 開發單位 profile
command/             ← 流程與品質控管 (Plan, Audit)
command/template/    ← 計畫文件模板
command/adapt-agent.md ← AI 工具 adapter 產生規範
doc/plan/            ← 實際任務紀錄（產物，已 ignore）
```
