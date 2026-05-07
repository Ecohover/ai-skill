# AI Engineering Rule Pack

這是一個 **AI 泛用工程規則庫**，透過 Git Submodule 引入專案，為不同 AI agent 提供開發規範、設計模式與任務管理流程。

本規則庫不綁定特定 AI 工具。任何可讀取檔案的 AI agent 都可以依 `AGENT.md` 的路由規則擔任 Planner、Builder 或 Reviewer。

> **AI 指引**：請直接讀取 `AGENT.md` 作為路由入口，嚴禁一次性讀取所有文件。

---

## 🛠 核心設計理念：精準、分段、可追蹤

為了極大化 Token 效率並減少 AI 幻覺，本規則庫採用以下結構：
1. **分段載入 (On-demand Loading)**：AI 僅讀取與當前任務語言、模組相關的規範。
2. **兩層式任務記錄**：簡單任務直接執行，計畫任務必須在 `doc/` 下留下索引與詳細計畫。
3. **單一真理來源 (Single Source of Truth)**：所有的開發邏輯與自審清單皆定義於此，確保跨專案的一致性。

> `command/template/` 是本規則庫的版本化模板；`doc/plan/` 是各使用專案執行任務時產生的紀錄，應被 ignore，不提交回規則庫 repo。

> 不同 AI 工具若需要自己的入口 md，應依 `command/adapt-agent.md` 產生 adapter；adapter 是使用專案產物，不是本規則庫的真理來源。

---

## 📜 維護者準則 (Maintenance Rules)

後續修改或擴充此規則庫時，**必須**遵守以下規定：

### 1. 保持檔案細粒度 (Keep Files Granular)
- 嚴禁建立巨大的規範文件。
- 每個檔案應專注於單一職責（例如：`error.md` 僅處理異常，`query.md` 僅處理查詢）。
- 檔案大小建議保持在 100 行以內，以降低 AI 讀取成本。

### 2. 遵守三階段載入架構
- **階段 1**: 全域通用原則 (`core/`)。
- **階段 2**: 語言基礎與特定模組 (`dotnet/`, `typescript/`, `python/`)。
- **階段 3**: 流程控制與驗證 (`command/`)。
- 新增功能規範時，請按此層級歸類。

### 3. 維護任務判定邏輯
- 任何關於開發流程的修改，必須確保 `command/plan.md` 中的「簡單任務」與「計畫任務」判定邏輯清晰。
- 強制要求計畫任務使用 `[三位數序號]-[task-name].md` 命名規範。

### 4. 跨語言一致性
- 當新增一種程式語言支援時，應參照現有的 `.NET` 或 `TypeScript` 結構，建立 `base.md` 與專案自定義資料夾（`custom/`），確保使用者的開發體驗一致。

---

## 📂 目錄結構

```text
AGENT.md             ← AI 入口：載入順序指南與路由對照表
README.md            ← 本檔：給開發者與維護者的規範
SKILL.md             ← 泛用 Skill 入口
core/                ← 跨語言通用參考 (Universal Principles)
dotnet/              ← .NET 語言專屬區
typescript/          ← 前端語言專屬區
python/              ← Python 語言專屬區
command/             ← 流程與品質控管 (Plan, Audit)
command/template/    ← 計畫文件模板
command/adapt-agent.md ← AI 工具 adapter 產生規範
doc/plan/            ← 實際任務紀錄（產物，已 ignore）
```

## 📥 安裝與連結

各專案透過 **git submodule** 連結：

```bash
git submodule add <repo-url> .prompts
```

在各專案的 AI 設定檔頂部加入：
`規則庫位於 .prompts/，執行任務前請必讀 .prompts/AGENT.md。`
