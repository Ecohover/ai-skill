# Python 提交前自審清單

提交程式碼前逐項確認：

- [ ] **型別標註**：所有方法是否有明確的 `args` 與 `return` 型別定義？
- [ ] **DTO 命名**：是否遵循 `InCreate...Dto`、`Out...Dto` 格式？
- [ ] **FastAPI Router**：是否僅負責輸入解析與輸出封裝，無複雜商業邏輯？
- [ ] **依賴注入**：是否透過 `Depends` 注入 Service，而非在 Router 內實例化？
- [ ] **異步 IO**：資料庫、外部 API 呼叫是否均使用 `await`？
- [ ] **布林值命名**：是否以 `is_`、`has_`、`can_` 開頭？
- [ ] **命名空間**：Lambda 參數是否具有業務語意（非 `x`, `i`）？
- [ ] **錯誤處理**：是否拋出自定義 Exception，且訊息組合邏輯已封裝？
- [ ] **Docstring**：所有的 Public 類別與方法是否有繁體中文 Google Style Docstring？
- [ ] **環境變數**：是否透過 Enum 或 `BaseSettings` 讀取，而非 `os.getenv` 直取字串？
- [ ] **格式化**：是否已通過 `ruff` 或 `black` 格式化處理？
