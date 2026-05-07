# AI 工具適配檔產生規範

本文件用於讓不同 AI 工具依本規則庫產生自己的入口設定檔。

## 原則

- `AGENT.md` 是唯一通用入口與真理來源。
- 各 AI 工具產生的專屬 md 只是 adapter，不是新的規則來源。
- adapter 可以改寫格式與摘要，但不得改變 Planner / Builder / Reviewer 的職責、流程與禁止事項。
- adapter 應保留按需載入原則，不得把所有規則文件合併成一份大型提示。

## 產生步驟

1. 讀取 `AGENT.md`。
2. 依工具需要的入口檔名稱與格式產生 adapter。
3. 在 adapter 中要求 AI 先回到 `.prompts/AGENT.md` 判斷角色。
4. 在 adapter 中只放路由摘要，不複製完整語言規範。
5. 若工具支援角色或模式，分別對應 Planner、Builder、Reviewer。

## 建議內容

adapter 至少包含：

- 規則庫位置：`.prompts/`
- 通用入口：`.prompts/AGENT.md`
- 任務角色：Planner、Builder、Reviewer
- 載入策略：按需載入
- 禁止事項：不得跨語言載入、不得跳過計畫任務 handoff

## 產物位置

adapter 應建立在使用專案需要的位置，例如專案根目錄或工具指定目錄。

這些 adapter 是使用專案的本機產物，不應提交回本規則庫，除非該 adapter 是刻意維護的範本。
