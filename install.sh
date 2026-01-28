#!/bin/bash
# Claude Prompts 安裝腳本 (Mac/Linux)
# 用途：設定環境變數並加入 shell profile

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOADER_PATH="$SCRIPT_DIR/loader.sh"
ENV_VAR_NAME="CLAUDE_PROMPTS_PATH"

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
    echo -e "${YELLOW}請手動編輯 $SHELL_PROFILE 移除以下行：${NC}"
    echo -e "${GRAY}  export $ENV_VAR_NAME=\"...\"${NC}"
    echo -e "${GRAY}  source \"$LOADER_PATH\"${NC}"
    echo ""
    echo -e "${YELLOW}執行以下指令開啟：${NC}"
    echo -e "${GRAY}  nano $SHELL_PROFILE${NC}"
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
echo -e "${WHITE}  ccp     # 互動式選擇並啟動 Claude${NC}"
echo -e "${WHITE}  ccpd    # 快速啟動 .NET${NC}"
echo -e "${WHITE}  ccpp    # 快速啟動 Python${NC}"
echo ""
echo -e "${CYAN}========================================${NC}"
echo ""
