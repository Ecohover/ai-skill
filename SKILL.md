---
name: ai-engineering-workflow
description: Generic AI engineering skill and rule-pack router for planning, building, reviewing, and chunked rule-based code inspection. Use when an AI agent needs to follow this repository's Planner/Builder/Reviewer/Code Inspector workflow, load language-specific engineering rules from core/dotnet/typescript/python, manage plan documents under doc/plan, generate tool-specific adapter markdown, or audit code changes with command/audit-*.md and command/audit-chunked.md.
---

# AI 工程協作 Skill

本檔是給 AI agent 使用的 Skill 啟動入口，不綁定特定 AI 工具。

人類使用說明在 `README.md`。AI agent 不應把 `README.md` 當作任務路由來源。

任何 AI agent 使用本規則庫時，都必須先讀取 `AGENT.md`，再依任務角色與技術棧按需載入其他文件。

## 使用順序

1. 讀取 `AGENT.md`。
2. 判斷任務應由 Planner、Builder、Reviewer 或 Code Inspector 處理。
3. 只載入該角色、語言、流程與模組需要的文件。
4. 依角色文件執行任務，不得混用其他角色責任。
5. 若目前 AI 工具需要自己的入口 md，依 `command/adapt-agent.md` 產生 adapter。

## 目錄對照

- `AGENT.md`：通用路由入口與真理來源。
- `README.md`：給人類使用者與維護者閱讀，不作為 AI 路由來源。
- `role/`：角色責任與交接規則。
- `core/`：跨語言工程原則與合約。
- `dotnet/`、`typescript/`、`python/`：語言專屬規範。
- `command/`：計畫、審查、分批稽核與 adapter 產生流程。
- `command/template/`：計畫文件模板。
- `doc/plan/`：實際任務紀錄產物。

## 核心原則

採用按需載入。不要把所有規則文件合併成單一大型提示；先讀 `AGENT.md` 路由，再讀必要規範。

角色邊界以 `role/*.md` 為準：

- Planner 只規劃，不寫程式碼。
- Builder 只實作，不執行 audit。
- Reviewer 只審查，不修改程式碼。
- Code Inspector 只做分批規則稽核，不修改程式碼。
