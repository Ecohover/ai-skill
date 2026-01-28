#!/bin/bash
# Claude Code Prompt 載入腳本 (Mac/Linux)
# 版本：v3.0 (可攜式)

# ============================================
# 配置區（動態路徑）
# ============================================
if [[ -n "$CLAUDE_PROMPTS_PATH" ]]; then
    PROMPTS_BASE_PATH="$CLAUDE_PROMPTS_PATH"
else
    # 取得腳本所在目錄
    PROMPTS_BASE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

# ============================================
# 選擇語言
# ============================================
_select_language() {
    echo ""
    echo -e "${CYAN}=== 選擇開發語言 ===${NC}"

    local lang_path="$PROMPTS_BASE_PATH/languages"
    local languages=($(ls -d "$lang_path"/*/ 2>/dev/null | xargs -n1 basename))

    if [[ ${#languages[@]} -eq 0 ]]; then
        echo -e "${RED}找不到任何語言目錄${NC}"
        return 1
    fi

    for i in "${!languages[@]}"; do
        echo -e "  [$(($i + 1))] ${languages[$i]}"
    done
    echo -e "${GRAY}  [0] 取消${NC}"

    read -p "請選擇: " choice

    if [[ "$choice" == "0" ]] || [[ -z "$choice" ]]; then
        return 1
    fi

    local index=$(($choice - 1))
    if [[ $index -ge 0 ]] && [[ $index -lt ${#languages[@]} ]]; then
        echo "${languages[$index]}"
        return 0
    fi

    return 1
}

# ============================================
# 選擇擴展
# ============================================
_select_extension() {
    local lang_path="$1"
    local ext_path="$lang_path/extensions"

    if [[ ! -d "$ext_path" ]]; then
        echo ""
        return 0
    fi

    local extensions=($(ls "$ext_path"/*.md 2>/dev/null | xargs -n1 basename | sed 's/\.md$//'))

    if [[ ${#extensions[@]} -eq 0 ]]; then
        echo ""
        return 0
    fi

    echo "" >&2
    echo -e "${CYAN}=== 選擇專案擴展 ===${NC}" >&2
    echo -e "${GRAY}  [0] 僅使用基礎規範${NC}" >&2

    for i in "${!extensions[@]}"; do
        echo -e "  [$(($i + 1))] ${extensions[$i]}" >&2
    done

    read -p "請選擇: " choice

    if [[ "$choice" == "0" ]] || [[ -z "$choice" ]]; then
        echo ""
        return 0
    fi

    local index=$(($choice - 1))
    if [[ $index -ge 0 ]] && [[ $index -lt ${#extensions[@]} ]]; then
        echo "${extensions[$index]}"
        return 0
    fi

    echo ""
    return 0
}

# ============================================
# 選擇模組
# ============================================
_select_modules() {
    local modules_path="$PROMPTS_BASE_PATH/modules"

    if [[ ! -d "$modules_path" ]]; then
        echo ""
        return 0
    fi

    local modules=($(ls "$modules_path"/*.md 2>/dev/null | xargs -n1 basename | sed 's/\.md$//'))

    if [[ ${#modules[@]} -eq 0 ]]; then
        echo ""
        return 0
    fi

    echo "" >&2
    echo -e "${CYAN}=== 選擇額外模組 (多選，空白結束) ===${NC}" >&2

    for i in "${!modules[@]}"; do
        echo -e "  [$(($i + 1))] ${modules[$i]}" >&2
    done
    echo -e "${GRAY}  [0] 完成選擇${NC}" >&2

    local selected=()

    while true; do
        read -p "請選擇: " choice

        if [[ "$choice" == "0" ]] || [[ -z "$choice" ]]; then
            break
        fi

        local index=$(($choice - 1))
        if [[ $index -ge 0 ]] && [[ $index -lt ${#modules[@]} ]]; then
            local module_name="${modules[$index]}"
            if [[ ! " ${selected[@]} " =~ " ${module_name} " ]]; then
                selected+=("$module_name")
                echo -e "${GREEN}   已加入: $module_name${NC}" >&2
            fi
        fi
    done

    echo "${selected[*]}"
}

# ============================================
# 組合 Prompt
# ============================================
_build_prompt() {
    local language="$1"
    local extension="$2"
    local modules="$3"

    local separator=$'\n\n---\n\n'
    local result=""

    echo "" >&2
    echo -e "${GRAY}載入中...${NC}" >&2

    # Metadata
    local modules_str="${modules:-none}"
    local extension_str="${extension:-none}"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    result="<!-- PROMPT CONFIG
Language: $language
Extension: $extension_str
Modules: $modules_str
Generated: $timestamp
-->

"

    # 1. 載入 common
    local common_path="$PROMPTS_BASE_PATH/common"
    if [[ -d "$common_path" ]]; then
        for file in "$common_path"/*.md; do
            if [[ -f "$file" ]]; then
                result+="$(cat "$file")"
                result+="$separator"
                echo -e "${GRAY}   [common] $(basename "$file")${NC}" >&2
            fi
        done
    fi

    # 2. 載入語言基礎
    local base_path="$PROMPTS_BASE_PATH/languages/$language/base.md"
    if [[ -f "$base_path" ]]; then
        result+="$(cat "$base_path")"
        result+="$separator"
        echo -e "${GRAY}   [base] $language/base.md${NC}" >&2
    fi

    # 3. 載入擴展
    if [[ -n "$extension" ]]; then
        local ext_path="$PROMPTS_BASE_PATH/languages/$language/extensions/$extension.md"
        if [[ -f "$ext_path" ]]; then
            result+="$(cat "$ext_path")"
            result+="$separator"
            echo -e "${GRAY}   [extension] $extension.md${NC}" >&2
        fi
    fi

    # 4. 載入模組
    for module in $modules; do
        local module_path="$PROMPTS_BASE_PATH/modules/$module.md"
        if [[ -f "$module_path" ]]; then
            result+="$(cat "$module_path")"
            result+="$separator"
            echo -e "${GRAY}   [module] $module.md${NC}" >&2
        fi
    done

    echo "$result"
}

# ============================================
# 設定全域 Prompt
# ============================================
_set_global_prompt() {
    local prompt="$1"
    local global_dir="$HOME/.claude"
    local global_file="$global_dir/CLAUDE.md"

    mkdir -p "$global_dir"
    echo "$prompt" > "$global_file"

    echo -e "${GRAY}   已寫入: $global_file${NC}"
}

# ============================================
# 主函數：啟動 Claude Code
# ============================================
ccp() {
    local language=""
    local extension=""
    local modules=""
    local global_mode=false

    # 解析參數
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -l|--language)
                language="$2"
                shift 2
                ;;
            -e|--extension)
                extension="$2"
                shift 2
                ;;
            -m|--modules)
                modules="$2"
                shift 2
                ;;
            -g|--global)
                global_mode=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    # 互動模式
    if [[ -z "$language" ]]; then
        language=$(_select_language)
        if [[ -z "$language" ]]; then
            echo -e "${RED}已取消${NC}"
            return 1
        fi

        extension=$(_select_extension "$PROMPTS_BASE_PATH/languages/$language")
        modules=$(_select_modules)
    fi

    # 檢查語言目錄
    local lang_path="$PROMPTS_BASE_PATH/languages/$language"
    if [[ ! -d "$lang_path" ]]; then
        echo -e "${RED}找不到語言目錄: $lang_path${NC}"
        return 1
    fi

    # 組合 Prompt
    local combined_prompt
    combined_prompt=$(_build_prompt "$language" "$extension" "$modules")

    if [[ -z "$combined_prompt" ]]; then
        echo -e "${RED}無法建立 Prompt${NC}"
        return 1
    fi

    if [[ "$global_mode" == true ]]; then
        _set_global_prompt "$combined_prompt"
        echo ""
        echo -e "${GREEN}已設定全域 Prompt:${NC}"
        echo -e "${CYAN}   語言: $language${NC}"
        [[ -n "$extension" ]] && echo -e "${CYAN}   擴展: $extension${NC}"
        [[ -n "$modules" ]] && echo -e "${CYAN}   模組: $modules${NC}"
        echo ""
        echo -e "${YELLOW}此設定將套用於所有專案（除非有本地 .clauderules）${NC}"
    else
        local rules_file="$(pwd)/.clauderules"
        echo "$combined_prompt" > "$rules_file"

        echo ""
        echo -e "${GREEN}已載入 Prompt 規則:${NC}"
        echo -e "${CYAN}   語言: $language${NC}"
        [[ -n "$extension" ]] && echo -e "${CYAN}   擴展: $extension${NC}"
        [[ -n "$modules" ]] && echo -e "${CYAN}   模組: $modules${NC}"
        echo -e "${GRAY}   檔案: $rules_file${NC}"
        echo ""

        # 啟動 Claude Code
        claude
    fi
}

# ============================================
# 快速啟動函數
# ============================================
ccpd() {
    local extension=""
    local modules=""
    local global_mode=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -e|--extension) extension="$2"; shift 2 ;;
            -m|--modules) modules="$2"; shift 2 ;;
            -g|--global) global_mode=true; shift ;;
            *) shift ;;
        esac
    done

    if [[ -z "$extension" ]] && [[ "$global_mode" == false ]]; then
        ccp -l dotnet
    else
        local args="-l dotnet"
        [[ -n "$extension" ]] && args="$args -e $extension"
        [[ -n "$modules" ]] && args="$args -m $modules"
        [[ "$global_mode" == true ]] && args="$args -g"
        ccp $args
    fi
}

ccpp() {
    local extension=""
    local modules=""
    local global_mode=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -e|--extension) extension="$2"; shift 2 ;;
            -m|--modules) modules="$2"; shift 2 ;;
            -g|--global) global_mode=true; shift ;;
            *) shift ;;
        esac
    done

    if [[ -z "$extension" ]] && [[ "$global_mode" == false ]]; then
        ccp -l python
    else
        local args="-l python"
        [[ -n "$extension" ]] && args="$args -e $extension"
        [[ -n "$modules" ]] && args="$args -m $modules"
        [[ "$global_mode" == true ]] && args="$args -g"
        ccp $args
    fi
}

# ============================================
# 切換 Prompt（不啟動 claude）
# ============================================
csp() {
    local global_mode=false

    [[ "$1" == "-g" ]] || [[ "$1" == "--global" ]] && global_mode=true

    local language=$(_select_language)
    if [[ -z "$language" ]]; then
        echo -e "${RED}已取消${NC}"
        return 1
    fi

    local extension=$(_select_extension "$PROMPTS_BASE_PATH/languages/$language")
    local modules=$(_select_modules)

    local combined_prompt
    combined_prompt=$(_build_prompt "$language" "$extension" "$modules")

    if [[ "$global_mode" == true ]]; then
        _set_global_prompt "$combined_prompt"
        echo ""
        echo -e "${GREEN}已更新全域 Prompt${NC}"
    else
        echo "$combined_prompt" > "$(pwd)/.clauderules"
        echo ""
        echo -e "${GREEN}已更新本地 .clauderules${NC}"
        echo -e "${YELLOW}請在 Claude 中輸入 /refresh 重新載入規則${NC}"
    fi
}

# ============================================
# 顯示目前設定狀態
# ============================================
show_prompt_status() {
    echo ""
    echo -e "${CYAN}=== Prompt 設定狀態 ===${NC}"

    local global_file="$HOME/.claude/CLAUDE.md"
    if [[ -f "$global_file" ]]; then
        local first_line=$(head -n 1 "$global_file")
        echo -e "${GREEN}  [全域] $global_file${NC}"
        echo -e "${GRAY}         $first_line${NC}"
    else
        echo -e "${YELLOW}  [全域] 未設定${NC}"
    fi

    local local_file="$(pwd)/.clauderules"
    if [[ -f "$local_file" ]]; then
        local first_line=$(head -n 1 "$local_file")
        echo -e "${GREEN}  [本地] $local_file${NC}"
        echo -e "${GRAY}         $first_line${NC}"
    else
        echo -e "${YELLOW}  [本地] 未設定${NC}"
    fi

    echo ""
}

# ============================================
# 清除全域設定
# ============================================
clear_global_prompt() {
    local global_file="$HOME/.claude/CLAUDE.md"
    if [[ -f "$global_file" ]]; then
        rm "$global_file"
        echo -e "${GREEN}已清除全域 Prompt 設定${NC}"
    else
        echo -e "${YELLOW}沒有全域設定${NC}"
    fi
}

# ============================================
# 歡迎訊息
# ============================================
echo ""
echo -e "${GREEN}Claude Prompt 系統已就緒 (v3.0)${NC}"
echo -e "${GRAY}  路徑: $PROMPTS_BASE_PATH${NC}"
echo ""
echo -e "${CYAN}啟動指令：${NC}"
echo -e "${WHITE}  ccp                   # 互動式選擇並啟動${NC}"
echo -e "${WHITE}  ccpd                  # 快速啟動 .NET${NC}"
echo -e "${WHITE}  ccpp                  # 快速啟動 Python${NC}"
echo ""
echo -e "${CYAN}設定指令：${NC}"
echo -e "${WHITE}  csp                   # 切換 prompt 設定${NC}"
echo -e "${WHITE}  show_prompt_status    # 查看目前設定${NC}"
echo -e "${WHITE}  clear_global_prompt   # 清除全域設定${NC}"
echo ""
echo -e "${CYAN}全域設定：${NC}"
echo -e "${GRAY}  ccpd -g               # 設定 .NET 為全域預設${NC}"
echo ""
