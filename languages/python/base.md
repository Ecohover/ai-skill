# Python 基礎開發規範

## 1. 專案結構
* **/src**：主要程式碼
* **/tests**：測試程式碼
* **/docs**：文件
* **pyproject.toml**：專案配置

## 2. 程式碼風格
* 遵循 **PEP 8** 規範。
* 使用 **Type Hints**。
* 私有變數使用 `_prefix`。

## 3. 依賴管理
* 使用 **Poetry** 或 **uv** 管理依賴。
* 固定版本號，避免使用 `*`。

## 4. 文件註解
* 使用 **Google Style Docstring**。
* 公開函數必須包含說明。
