# AI Code Prompt 管理系統

用於 AI 協作開發的 Prompt 規則庫。透過分層疊加 (Layered Stacking) 組合出完整的開發規範，供任何 AI 工具直接閱讀使用。

## 使用方式

將需要的規則檔按順序合併後，交給 AI 閱讀即可。AI 會依據內容自行轉化為開發規範。

## 架構（分層疊加）

```
common/                         # Level 1：通用規則（所有專案都載入）
  collaboration.md

languages/                      # Level 2：語言基礎規範
  dotnet/
    base.md
    extensions/                 # Level 3：專案特定架構（選用）
      dachan.md
  python/
    base.md

modules/                        # Level 4：技術模組（選用）
  mongodb.md
```

## 如何新增規則

| 類型 | 路徑 | 說明 |
|------|------|------|
| 新語言 | `languages/<語言>/base.md` | 命名慣例、目錄結構、推薦套件 |
| 新專案擴展 | `languages/<語言>/extensions/<名稱>.md` | 特定架構約束、私有套件規範 |
| 新功能模組 | `modules/<名稱>.md` | 可跨語言複用的技術規範 |
| 通用規則 | `common/collaboration.md` | 所有專案共用的編碼標準 |

> 若規則可通用於多種語言，放 `modules/`；若語言特定，放 `languages/`。

## 外部專案參考

如有私有套件或外部專案路徑（如 `Dachan.CommonUtils`），規則檔中會提示 AI 向使用者詢問本機實際路徑，不硬編碼任何路徑。
