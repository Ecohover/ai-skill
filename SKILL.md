---
name: ai-engineering-workflow
description: Use when an AI agent works with this prompt rule pack, needs Planner/Builder/Reviewer/Code Inspector routing, must load engineering rules from AGENT.md, core, role, or language folders, or needs plan docs, adapter markdown, or rule-based audits.
---

# AI 工程協作 Skill

本檔是 AI agent 使用本規則庫時的 Skill 啟動入口，只負責路由與按需載入，不取代實際規範。

`AGENT.md` 是 AI 路由的真理來源。`README.md` 是人類維護說明，不作為 AI 任務路由依據。

## 啟動流程

1. 讀取 `AGENT.md`。
2. 判斷任務應由 Planner、Builder、Reviewer 或 Code Inspector 處理。
3. 只載入該角色、語言、流程與模組需要的文件。
4. 依角色文件執行任務，不得混用其他角色責任。
5. 若 AI 工具需要專屬入口 md，依 `command/adapt-agent.md` 產生 adapter。

## 目錄對照

- `AGENT.md`：通用路由入口與真理來源。
- `README.md`：給人類使用者與維護者閱讀，不作為 AI 路由來源。
- `role/`：角色責任與交接規則。
- `core/`：跨語言工程原則與合約。
- `language/`：語言專屬規範，依語言分為 `dotnet/`、`typescript/`、`python/` 等子目錄。
- `command/`：計畫、審查、分批稽核與 adapter 產生流程。
- `command/template/`：計畫文件模板。
- `doc/plan/`：實際任務紀錄產物。

## 核心原則

採用按需載入。不要一次讀完整個規則庫，也不要把所有規則合併成單一大型提示。

角色邊界以 `role/*.md` 為準：

- Planner 只規劃，不寫程式碼。
- Builder 只實作，不執行 audit。
- Reviewer 只審查，不修改程式碼。
- Code Inspector 只做分批規則稽核，不修改程式碼。
