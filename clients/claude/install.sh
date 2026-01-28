#!/bin/bash
# Claude Prompts 安裝腳本 (Mac/Linux)
# 用途：設定環境變數並加入 shell profile

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOADER_PATH="$SCRIPT_DIR/loader.sh"
ENV_VAR_NAME="CLAUDE_PROMPTS_PATH"
CONFIG_FILE="$HOME/.claude-prompts-config"

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# ============================================
# 偵測 Shell 類型
# ============================================
detect_shell_profile() {
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
        echo "$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == *"bash"* ]]; then
        if [[ "$(uname)" == "Darwin" ]]; then
            # macOS 預設使用 .bash_profile
            echo "$HOME/.bash_profile"
        else
            echo "$HOME/.bashrc"
        fi
    else
        echo "$HOME/.profile"
    fi
}

SHELL_PROFILE=$(detect_shell_profile)

# ============================================
# 解除安裝
# ============================================
if [[ "$1" == "--uninstall" ]] || [[ "$1" == "-u" ]]; then
    echo ""
    echo -e "${CYAN}=== 解除安裝 Claude Prompts ===${NC}"
    echo ""

    # 移除設定檔
    if [[ -f "$CONFIG_FILE" ]]; then
        rm "$CONFIG_FILE"
        echo -e "${GREEN}  已移除設定檔: $CONFIG_FILE${NC}"
    fi

    # 從 Profile 移除
    if [[ -f "$SHELL_PROFILE" ]]; then
        # 建立備份
        cp "$SHELL_PROFILE" "$SHELL_PROFILE.bak"

        # 移除相關行
        sed -i.tmp '/# Claude Prompts Loader/d' "$SHELL_PROFILE"
        sed -i.tmp "/export $ENV_VAR_NAME=/d" "$SHELL_PROFILE"
        sed -i.tmp "/source.*loader\.sh/d" "$SHELL_PROFILE"
        rm -f "$SHELL_PROFILE.tmp"

        echo -e "${GREEN}  已從 Profile 移除載入腳本${NC}"
        echo -e "${GRAY}  備份檔案: $SHELL_PROFILE.bak${NC}"
    fi

    echo ""
    echo -e "${GREEN}解除安裝完成！請重新開啟終端機。${NC}"
    echo ""
    exit 0
fi

# ============================================
# 安裝
# ============================================
echo ""
echo -e "${CYAN}=== 安裝 Claude Prompts ===${NC}"
echo ""

# 1. 確認 loader.sh 存在且可執行
echo -e "${WHITE}[1/3] 檢查檔案...${NC}"
if [[ ! -f "$LOADER_PATH" ]]; then
    echo -e "${RED}  錯誤: 找不到 loader.sh${NC}"
    exit 1
fi
chmod +x "$LOADER_PATH"
chmod +x "$SCRIPT_DIR/install.sh"
echo -e "${GREEN}  檔案檢查完成${NC}"

# 2. 建立 Profile（如果不存在）
echo ""
echo -e "${WHITE}[2/3] 設定 Shell Profile...${NC}"
echo -e "${GRAY}  Profile: $SHELL_PROFILE${NC}"

if [[ ! -f "$SHELL_PROFILE" ]]; then
    touch "$SHELL_PROFILE"
    echo -e "${GRAY}  已建立 Profile${NC}"
fi

# 3. 加入環境變數和 loader（如果尚未加入）
EXPORT_LINE="export $ENV_VAR_NAME=\"$SCRIPT_DIR\""
SOURCE_LINE="source \"$LOADER_PATH\""

if grep -q "$ENV_VAR_NAME" "$SHELL_PROFILE" 2>/dev/null; then
    echo -e "${YELLOW}  Profile 已包含設定，跳過${NC}"
else
    echo "" >> "$SHELL_PROFILE"
    echo "# Claude Prompts Loader" >> "$SHELL_PROFILE"
    echo "$EXPORT_LINE" >> "$SHELL_PROFILE"
    echo "$SOURCE_LINE" >> "$SHELL_PROFILE"
    echo -e "${GREEN}  已加入 Profile${NC}"
fi

# 完成
echo ""
echo -e "${WHITE}[3/3] 安裝完成！${NC}"
echo ""
echo -e "${CYAN}========================================${NC}"
echo ""
echo -e "${YELLOW}請重新開啟終端機，或執行：${NC}"
echo -e "${GRAY}  source $SHELL_PROFILE${NC}"
echo ""
echo -e "${YELLOW}然後使用：${NC}"
echo ""
echo -e "${WHITE}  claude              # 自動詢問是否載入 prompt${NC}"
echo -e "${WHITE}  claude -s           # 跳過 prompt，使用原生模式${NC}"
echo -e "${WHITE}  claude -p           # 強制重新選擇 prompt${NC}"
echo ""
echo -e "${CYAN}========================================${NC}"
echo ""
