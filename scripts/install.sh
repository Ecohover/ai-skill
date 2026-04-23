#!/usr/bin/env bash
# AI Prompt 產生工具 - 安裝腳本 (Mac/Linux)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GENERATE_SCRIPT="$SCRIPT_DIR/generate.sh"

MARKER_BEGIN="# BEGIN AI Prompt Generator"
MARKER_END="# END AI Prompt Generator"

# 偵測 shell rc 檔
detect_rc() {
    if [ -n "$ZSH_VERSION" ] || [ "$(basename "$SHELL")" = "zsh" ]; then
        echo "$HOME/.zshrc"
    else
        echo "$HOME/.bashrc"
    fi
}

RC_FILE="$(detect_rc)"

PROFILE_BLOCK="$MARKER_BEGIN
export PROMPTS_PATH=\"$PROJECT_ROOT\"
aprompt() { \"$GENERATE_SCRIPT\" \"\$@\"; }
$MARKER_END"

# ============================================
# 解除安裝
# ============================================
if [ "$1" = "--uninstall" ]; then
    echo ""
    echo "=== 解除安裝 AI Prompt 產生工具 ==="

    if [ -f "$RC_FILE" ] && grep -q "$MARKER_BEGIN" "$RC_FILE"; then
        # 移除標記區塊
        sed -i.bak "/^$MARKER_BEGIN$/,/^$MARKER_END$/d" "$RC_FILE"
        rm -f "$RC_FILE.bak"
        echo "  已從 $RC_FILE 移除 aprompt 指令"
    else
        echo "  $RC_FILE 中未找到安裝記錄，略過。"
    fi

    echo ""
    echo "解除安裝完成！請重新載入 Shell 或開啟新終端。"
    echo ""
    exit 0
fi

# ============================================
# 安裝
# ============================================
echo ""
echo "=== 安裝 AI Prompt 產生工具 ==="
echo ""

chmod +x "$GENERATE_SCRIPT"

# 寫入 rc 檔
echo "[1/1] 設定 $RC_FILE ..."

if grep -q "$MARKER_BEGIN" "$RC_FILE" 2>/dev/null; then
    echo "  aprompt 已安裝，略過。"
else
    printf "\n%s\n" "$PROFILE_BLOCK" >> "$RC_FILE"
    echo "  已加入 aprompt 指令至 $RC_FILE"
fi

echo ""
echo "========================================"
echo ""
echo "安裝完成！請執行以下指令套用，然後在任意專案目錄下執行 aprompt："
echo ""
echo "  source $RC_FILE"
echo ""
echo "  aprompt"
echo ""
echo "========================================"
echo ""
