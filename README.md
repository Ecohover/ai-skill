# Claude Code Prompt 管理系統

用於管理與 AI 協作開發時的 prompt 規則，支援分層疊加。

## 安裝

### Windows (PowerShell)

```powershell
# 1. Clone 到任意位置
git clone https://github.com/Ecohover/claude-prompts.git
cd claude-prompts

# 2. 執行安裝腳本
.\install.ps1

# 3. 重新開啟 PowerShell
```

### Mac / Linux (Bash/Zsh)

```bash
# 1. Clone 到任意位置
git clone https://github.com/Ecohover/claude-prompts.git
cd claude-prompts

# 2. 執行安裝腳本
chmod +x install.sh
./install.sh

# 3. 重新開啟終端機，或執行
source ~/.zshrc  # 或 ~/.bashrc
```

### 解除安裝

```powershell
# Windows
.\install.ps1 -Uninstall
```

```bash
# Mac/Linux
./install.sh --uninstall
```

## 目錄結構

```
C:\prompts\
├── README.md                 # 本說明文件
├── loader.ps1                # PowerShell 載入腳本
│
├── common/                   # 跨語言通用規則
│   └── collaboration.md      # AI 協作基本原則
│
├── languages/                # 語言專屬規則
│   ├── dotnet/
│   │   ├── base.md           # .NET 基礎規範
│   │   └── extensions/       # 專案擴展
│   │       └── dachan.md     # 大成專案規範
│   │
│   └── python/
│       ├── base.md           # Python 基礎規範
│       └── extensions/
│
└── modules/                  # 可選模組（套件/框架規則）
    └── mongodb.md
```

## 載入順序

```
common/* → languages/{lang}/base.md → extensions/{project}.md → modules/*
```

## 使用方式

### 1. 啟動指令

```powershell
# 互動式選擇並啟動 claude
ccp

# 快速啟動 .NET
ccpd

# 快速啟動 Python
ccpp

# 指定完整配置
ccp -Language dotnet -Extension dachan -Modules mongodb
```

### 3. 設定/切換 Prompt（不啟動 claude）

```powershell
# 互動式切換 prompt
csp

# 查看目前設定
Show-PromptStatus

# 清除全域設定
Clear-GlobalPrompt
```

### 4. 全域設定

```powershell
# 設定 .NET 為全域預設（所有專案共用）
ccpd -Global

# 本地 .clauderules 會覆蓋全域設定
```

### 5. 輸出位置

- **本地**：當前目錄的 `.clauderules`
- **全域**：`~/.claude/CLAUDE.md`

Claude Code 啟動時會自動讀取。

### 6. 識別目前 Prompt

組合後的 prompt 開頭會有 metadata：

```markdown
<!-- PROMPT CONFIG
Language: dotnet
Extension: dachan
Modules: mongodb
Generated: 2026-01-28 12:00:00
-->
```

## 新增規則

### 新增語言

1. 在 `languages/` 下建立語言目錄
2. 建立 `base.md` 定義基礎規範
3. 可選：建立 `extensions/` 目錄放置專案擴展

### 新增模組

在 `modules/` 下建立 `{module-name}.md`，模組可跨語言共用。

## 命名規範

| 類型 | 路徑格式 | 範例 |
|------|----------|------|
| 通用規則 | `common/{name}.md` | `common/collaboration.md` |
| 語言基礎 | `languages/{lang}/base.md` | `languages/dotnet/base.md` |
| 專案擴展 | `languages/{lang}/extensions/{project}.md` | `languages/dotnet/extensions/dachan.md` |
| 模組 | `modules/{module}.md` | `modules/mongodb.md` |
