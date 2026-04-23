#!/usr/bin/env bash
# AI Prompt 產生工具（核心腳本）
# 用途：選擇語言/擴展/模組，組合成 .prompt.md 輸出至當前目錄

# 支援透過環境變數或相對路徑取得 Repo 根目錄
if [ -n "$PROMPTS_PATH" ]; then
    PROMPTS_BASE="$PROMPTS_PATH"
else
    PROMPTS_BASE="$(cd "$(dirname "$0")/.." && pwd)"
fi

# ============================================
# 輔助函數
# ============================================

get_languages() {
    ls -d "$PROMPTS_BASE/languages"/*/  2>/dev/null | xargs -I{} basename {}
}

get_extensions() {
    local lang="$1"
    local ext_path="$PROMPTS_BASE/languages/$lang/extensions"
    if [ -d "$ext_path" ]; then
        ls "$ext_path"/*.md 2>/dev/null | xargs -I{} basename {} .md
    fi
}

get_modules() {
    ls "$PROMPTS_BASE/modules"/*.md 2>/dev/null | xargs -I{} basename {} .md
}

# 單選選單，stdout 輸出選中名稱（空字串表示跳過/取消）
show_menu() {
    local title="$1"
    local allow_skip="$2"
    shift 2
    local options=("$@")

    echo "" >&2
    echo "  $title" >&2
    printf "  %0.s-" $(seq 1 ${#title}) >&2; echo "" >&2

    for i in "${!options[@]}"; do
        echo "  [$((i+1))] ${options[$i]}" >&2
    done
    [ "$allow_skip" = "1" ] && echo "  [0] 跳過" >&2
    echo "" >&2

    read -rp "  選項: " raw <&2 || true
    [ -z "$raw" ] || [ "$raw" = "0" ] && return

    if [[ "$raw" =~ ^[0-9]+$ ]]; then
        local idx=$((raw - 1))
        if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#options[@]}" ]; then
            echo "${options[$idx]}"
        fi
    fi
}

# 複選選單，stdout 輸出以空格分隔的選項
show_multiselect() {
    local title="$1"
    shift
    local options=("$@")

    echo "" >&2
    echo "  $title" >&2
    printf "  %0.s-" $(seq 1 ${#title}) >&2; echo "" >&2

    for i in "${!options[@]}"; do
        echo "  [$((i+1))] ${options[$i]}" >&2
    done
    echo "  [0] 跳過" >&2
    echo "" >&2

    read -rp "  選項（多個用逗號分隔，0 跳過）: " raw <&2 || true
    [ -z "$raw" ] || [ "$raw" = "0" ] && return

    local result=()
    IFS=',' read -ra parts <<< "$raw"
    for part in "${parts[@]}"; do
        part="${part// /}"
        if [[ "$part" =~ ^[0-9]+$ ]]; then
            local idx=$((part - 1))
            if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#options[@]}" ]; then
                result+=("${options[$idx]}")
            fi
        fi
    done
    echo "${result[*]}"
}

# 從源文件中提取 <!-- RULES --> 區塊（到 <!-- PATTERNS --> 或檔尾）
# 若無標記，將整份內容視為規則
extract_rules() {
    local file="$1"
    if ! grep -q '<!-- RULES -->' "$file"; then
        cat "$file"
        return
    fi
    awk '/<!-- RULES -->/{found=1; next} /<!-- PATTERNS -->/{found=0} found{print}' "$file"
}

# 從源文件中提取 <!-- PATTERNS --> 區塊（到檔尾）
extract_patterns() {
    local file="$1"
    awk '/<!-- PATTERNS -->/{found=1; next} found{print}' "$file"
}

build_prompt() {
    local lang="$1"
    local ext="$2"
    local mods="$3"

    local ext_display="${ext:-none}"
    local mod_display="${mods:-none}"
    local generated
    generated=$(date "+%Y-%m-%d %H:%M:%S")

    # 依層序收集源文件路徑
    local source_files=()
    local f="$PROMPTS_BASE/common/collaboration.md"
    [ -f "$f" ] && source_files+=("$f")

    f="$PROMPTS_BASE/languages/$lang/base.md"
    [ -f "$f" ] && source_files+=("$f")

    if [ -n "$ext" ]; then
        f="$PROMPTS_BASE/languages/$lang/extensions/$ext.md"
        [ -f "$f" ] && source_files+=("$f")
    fi

    for mod in $mods; do
        f="$PROMPTS_BASE/modules/$mod.md"
        [ -f "$f" ] && source_files+=("$f")
    done

    # 兩段式收集：先收 RULES，再收 PATTERNS
    local rules_blocks=()
    local patterns_blocks=()

    for file in "${source_files[@]}"; do
        local rules
        rules=$(extract_rules "$file" | sed '/^[[:space:]]*$/d' | head -1 && extract_rules "$file")
        rules=$(extract_rules "$file")
        rules="${rules#"${rules%%[![:space:]]*}"}"  # trim leading whitespace
        if [ -n "$rules" ]; then
            rules_blocks+=("$rules")
        fi

        local patterns
        patterns=$(extract_patterns "$file")
        patterns="${patterns#"${patterns%%[![:space:]]*}"}"  # trim leading whitespace
        if [ -n "$patterns" ]; then
            patterns_blocks+=("$patterns")
        fi
    done

    # META 只放 ASCII（動態值），避免腳本編碼問題
    printf "<!-- PROMPT_META\nLanguage: %s\nExtension: %s\nModules: %s\nGenerated: %s\n-->\n\n" \
        "$lang" "$ext_display" "$mod_display" "$generated"

    # 靜態 header（含中文）從檔案讀取，保留 UTF-8
    local header_file="$PROMPTS_BASE/templates/prompt-header.md"
    if [ -f "$header_file" ]; then
        cat "$header_file"
    fi

    printf "\n\n---\n\n# RULES\n"

    # 輸出所有 RULES 區塊
    for block in "${rules_blocks[@]}"; do
        printf "\n---\n\n%s\n" "$block"
    done

    # 輸出所有 PATTERNS 區塊（若有）
    if [ "${#patterns_blocks[@]}" -gt 0 ]; then
        printf "\n---\n\n# PATTERNS\n"
        for block in "${patterns_blocks[@]}"; do
            printf "\n---\n\n%s\n" "$block"
        done
    fi
}

# ============================================
# Main
# ============================================

echo "" >&2
echo "========================================" >&2
echo "        AI Prompt 產生工具"              >&2
echo "========================================" >&2

# 1. 語言
mapfile -t langs < <(get_languages)
if [ "${#langs[@]}" -eq 0 ]; then echo "找不到任何語言定義。" >&2; exit 1; fi
lang=$(show_menu "選擇語言" "0" "${langs[@]}")
if [ -z "$lang" ]; then echo "已取消。" >&2; exit 0; fi

# 2. 專案擴展（選用）
mapfile -t exts < <(get_extensions "$lang")
ext=""
if [ "${#exts[@]}" -gt 0 ]; then
    ext=$(show_menu "選擇專案擴展（選用）" "1" "${exts[@]}")
fi

# 3. 功能模組（選用，複選）
mapfile -t all_mods < <(get_modules)
selected_mods=""
if [ "${#all_mods[@]}" -gt 0 ]; then
    selected_mods=$(show_multiselect "選擇功能模組（選用，可複選）" "${all_mods[@]}")
fi

# 4. 產生並寫出至當前目錄
output_file="$(pwd)/.prompt.md"
build_prompt "$lang" "$ext" "$selected_mods" > "$output_file"

echo "" >&2
echo "========================================" >&2
echo "  已產生：$output_file"                   >&2
echo "  語言　：$lang"                           >&2
[ -n "$ext" ]           && echo "  擴展　：$ext"             >&2
[ -n "$selected_mods" ] && echo "  模組　：$selected_mods"   >&2
echo "========================================" >&2
echo "" >&2
