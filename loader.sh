#!/bin/bash
# Claude Code Prompt 載入腳本 (Mac/Linux)
# 版本：v4.0 (自動載入)

# ============================================
# 配置區（動態路徑）
# ============================================
if [[ -n "$CLAUDE_PROMPTS_PATH" ]]; then
    PROMPTS_BASE_PATH="$CLAUDE_PROMPTS_PATH"
else
    PROMPTS_BASE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# 儲存原生 claude 指令路徑
CLAUDE_NATIVE="$(which claude 2>/dev/null)"

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
    echo "" >&2
    echo -e "${CYAN}=== 選擇開發語言 ===${NC}" >&2

    local lang_path="$PROMPTS_BASE_PATH/languages"
    local languages=($(ls -d "$lang_path"/*/ 2>/dev/null | xargs -n1 basename))

    if [[ ${#languages[@]} -eq 0 ]]; then
        echo -e "${RED}找不到任何語言目錄${NC}" >&2
        return 1
    fi

    for i in "${!languages[@]}"; do
        echo -e "  [$(($i + 1))] ${languages[$i]}" >&2
    done
    echo -e "${GRAY}  [0] 取消${NC}" >&2

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
    echo -e "${CYAN}=== 選擇額外模組 (多選，Enter 結束) ===${NC}" >&2

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
# 主函數：覆蓋 claude 指令
# ============================================
claude() {
    local skip_prompt=false
    local force_prompt=false
    local args=()

    # 解析參數
    for arg in "$@"; do
        case "$arg" in
            -s|--skip)
                skip_prompt=true
                ;;
            -p|--prompt)
                force_prompt=true
                ;;
            *)
                args+=("$arg")
                ;;
        esac
    done

    # 跳過 prompt
    if [[ "$skip_prompt" == true ]]; then
        echo -e "${GRAY}啟動原生 Claude...${NC}"
        "$CLAUDE_NATIVE" "${args[@]}"
        return
    fi

    # 檢查本地是否已有 .clauderules
    local local_rules="$(pwd)/.clauderules"
    local has_local_rules=false
    [[ -f "$local_rules" ]] && has_local_rules=true

    # 檢查全域是否已有設定
    local global_rules="$HOME/.claude/CLAUDE.md"
    local has_global_rules=false
    [[ -f "$global_rules" ]] && has_global_rules=true

    # 決定是否需要選擇 prompt
    if [[ "$force_prompt" == true ]] || [[ "$has_local_rules" == false && "$has_global_rules" == false ]]; then
        echo ""
        echo -e "${CYAN}=== Claude Prompt 設定 ===${NC}"
        echo -e "  [1] 選擇 Prompt 規則"
        echo -e "  [2] 不使用 Prompt（原生模式）"
        if [[ "$has_global_rules" == true ]]; then
            echo -e "  [3] 使用全域設定"
        fi
        echo ""

        read -p "請選擇: " choice

        case "$choice" in
            1)
                local language=$(_select_language)
                if [[ -z "$language" ]]; then
                    echo -e "${YELLOW}已取消，啟動原生 Claude...${NC}"
                    "$CLAUDE_NATIVE" "${args[@]}"
                    return
                fi

                local extension=$(_select_extension "$PROMPTS_BASE_PATH/languages/$language")
                local modules=$(_select_modules)

                local combined_prompt=$(_build_prompt "$language" "$extension" "$modules")
                echo "$combined_prompt" > "$local_rules"

                echo ""
                echo -e "${GREEN}已載入 Prompt: $language${NC}"
                [[ -n "$extension" ]] && echo -e "${CYAN}   擴展: $extension${NC}"
                ;;
            2)
                echo -e "${GRAY}啟動原生 Claude...${NC}"
                "$CLAUDE_NATIVE" "${args[@]}"
                return
                ;;
            3)
                if [[ "$has_global_rules" == true ]]; then
                    echo -e "${GRAY}使用全域設定...${NC}"
                else
                    echo -e "${GRAY}啟動原生 Claude...${NC}"
                fi
                "$CLAUDE_NATIVE" "${args[@]}"
                return
                ;;
            *)
                echo -e "${GRAY}啟動原生 Claude...${NC}"
                "$CLAUDE_NATIVE" "${args[@]}"
                return
                ;;
        esac
    elif [[ "$has_local_rules" == true ]]; then
        local lang_line=$(grep "^Language:" "$local_rules" 2>/dev/null | head -1)
        if [[ -n "$lang_line" ]]; then
            echo -e "${GRAY}使用本地 Prompt: ${lang_line#Language: }${NC}"
        fi
    elif [[ "$has_global_rules" == true ]]; then
        echo -e "${GRAY}使用全域 Prompt 設定${NC}"
    fi

    echo ""
    "$CLAUDE_NATIVE" "${args[@]}"
}

# ============================================
# 輔助指令
# ============================================

# 清除本地 prompt
clear_local_prompt() {
    local local_rules="$(pwd)/.clauderules"
    if [[ -f "$local_rules" ]]; then
        rm "$local_rules"
        echo -e "${GREEN}已清除本地 .clauderules${NC}"
    else
        echo -e "${YELLOW}沒有本地設定${NC}"
    fi
}

# 清除全域 prompt
clear_global_prompt() {
    local global_file="$HOME/.claude/CLAUDE.md"
    if [[ -f "$global_file" ]]; then
        rm "$global_file"
        echo -e "${GREEN}已清除全域 Prompt 設定${NC}"
    else
        echo -e "${YELLOW}沒有全域設定${NC}"
    fi
}

# 顯示目前設定狀態
show_prompt_status() {
    echo ""
    echo -e "${CYAN}=== Prompt 設定狀態 ===${NC}"

    local global_file="$HOME/.claude/CLAUDE.md"
    if [[ -f "$global_file" ]]; then
        local lang_line=$(grep "^Language:" "$global_file" 2>/dev/null | head -1)
        echo -e "${GREEN}  [全域] $global_file${NC}"
        [[ -n "$lang_line" ]] && echo -e "${GRAY}         $lang_line${NC}"
    else
        echo -e "${YELLOW}  [全域] 未設定${NC}"
    fi

    local local_file="$(pwd)/.clauderules"
    if [[ -f "$local_file" ]]; then
        local lang_line=$(grep "^Language:" "$local_file" 2>/dev/null | head -1)
        echo -e "${GREEN}  [本地] $local_file${NC}"
        [[ -n "$lang_line" ]] && echo -e "${GRAY}         $lang_line${NC}"
    else
        echo -e "${YELLOW}  [本地] 未設定${NC}"
    fi

    echo ""
}

# 設定全域 prompt（互動）
set_global_claude_prompt() {
    local language=$(_select_language)
    if [[ -z "$language" ]]; then
        echo -e "${RED}已取消${NC}"
        return 1
    fi

    local extension=$(_select_extension "$PROMPTS_BASE_PATH/languages/$language")
    local modules=$(_select_modules)

    local combined_prompt=$(_build_prompt "$language" "$extension" "$modules")

    local global_dir="$HOME/.claude"
    mkdir -p "$global_dir"
    echo "$combined_prompt" > "$global_dir/CLAUDE.md"

    echo ""
    echo -e "${GREEN}已設定全域 Prompt: $language${NC}"
    echo -e "${YELLOW}此設定將套用於所有專案（除非有本地 .clauderules）${NC}"
}

# ============================================
# 歡迎訊息（僅首次顯示）
# ============================================
if [[ -z "$CLAUDE_PROMPT_LOADED" ]]; then
    export CLAUDE_PROMPT_LOADED=1
    echo ""
    echo -e "${GREEN}Claude Prompt 系統已就緒 (v4.0)${NC}"
    echo ""
    echo -e "${CYAN}使用方式：${NC}"
    echo -e "${WHITE}  claude              # 自動詢問是否載入 prompt${NC}"
    echo -e "${WHITE}  claude -s           # 跳過 prompt，使用原生模式${NC}"
    echo -e "${WHITE}  claude -p           # 強制重新選擇 prompt${NC}"
    echo ""
    echo -e "${CYAN}輔助指令：${NC}"
    echo -e "${GRAY}  show_prompt_status       # 查看目前設定${NC}"
    echo -e "${GRAY}  set_global_claude_prompt # 設定全域 prompt${NC}"
    echo -e "${GRAY}  clear_local_prompt       # 清除本地設定${NC}"
    echo -e "${GRAY}  clear_global_prompt      # 清除全域設定${NC}"
    echo ""
fi
