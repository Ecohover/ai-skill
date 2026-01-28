#!/bin/bash
# Gemini Code Prompt Loader Script (Bash/Zsh)
# Version: v4.3

# ============================================
# Configuration
# ============================================
if [ -z "$GEMINI_PROMPTS_PATH" ]; then
    # Get the directory of the script, then go up two levels
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    PROMPTS_BASE_PATH="$(dirname "$(dirname "$SCRIPT_DIR")")"
else
    PROMPTS_BASE_PATH="$GEMINI_PROMPTS_PATH"
fi

CONFIG_FILE="$HOME/.gemini-prompts-config"

# Detect native gemini command
# We use 'command -v' to find it, but we need to avoid finding *this* function if it were named gemini.
# Since we renamed the function to gprompt, looking for 'gemini' is safe.
GEMINI_NATIVE="$(command -v gemini)"

# ============================================
# Config Management
# ============================================
get_prompt_config() {
    local key="$1"
    if [ -f "$CONFIG_FILE" ]; then
        grep "^$key=" "$CONFIG_FILE" | cut -d'=' -f2
    fi
}

set_prompt_config() {
    local key="$1"
    local value="$2"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        touch "$CONFIG_FILE"
    fi

    if grep -q "^$key=" "$CONFIG_FILE"; then
        # Use a temporary file for sed to be portable (macOS sed -i differences)
        sed "s|^$key=.*|$key=$value|" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    else
        echo "$key=$value" >> "$CONFIG_FILE"
    fi
}

get_extension_config() {
    local extension=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    
    case "$extension" in
        "dachan")
            local path=$(get_prompt_config "DACHAN_COMMONUTILS_PATH")
            if [ -z "$path" ]; then
                echo ""
                echo -e "\033[36m=== Dachan Extension Setup ===\033[0m"
                echo -e "\033[33mFirst time setup: CommonUtils project path is required.\033[0m"
                echo ""
                read -p "Enter CommonUtils Project Path: " path
                
                if [ -n "$path" ]; then
                    set_prompt_config "DACHAN_COMMONUTILS_PATH" "$path"
                    echo -e "\033[32mConfig saved.\033[0m"
                fi
            fi
            echo "DACHAN_COMMONUTILS_PATH=$path"
            ;; 
        *)
            echo ""
            ;; 
    esac
}

# ============================================
# Helper Functions
# ============================================
select_language() {
    echo ""
    echo -e "\033[36m=== Select Language ===\033[0m"
    
    local lang_path="$PROMPTS_BASE_PATH/languages"
    if [ ! -d "$lang_path" ]; then
        echo -e "\033[31mNo language directories found.\033[0m"
        return 1
    fi

    # Create array of directories
    local languages=($(ls -d "$lang_path"/*/ | xargs -n 1 basename))
    
    if [ ${#languages[@]} -eq 0 ]; then
        echo -e "\033[31mNo languages found.\033[0m"
        return 1
    fi

    for i in "${!languages[@]}"; do
        echo "  [$((i+1))] ${languages[$i]}"
    done
    echo -e "\033[90m  [0] Cancel\033[0m"

    read -p "Select: " choice
    
    if [ -z "$choice" ] || [ "$choice" -eq 0 ]; then
        return 1
    fi

    local index=$((choice-1))
    if [ $index -ge 0 ] && [ $index -lt ${#languages[@]} ]; then
        echo "${languages[$index]}"
        return 0
    fi
    return 1
}

select_extension() {
    local lang_path="$1"
    local ext_path="$lang_path/extensions"
    
    if [ ! -d "$ext_path" ]; then
        echo ""
        return 0
    fi

    local extensions=($(ls "$ext_path"/*.md 2>/dev/null | xargs -n 1 basename | sed 's/\.md$//'))
    
    if [ ${#extensions[@]} -eq 0 ]; then
        echo ""
        return 0
    fi

    echo ""
    echo -e "\033[36m=== Select Extension ===\033[0m"
    echo -e "\033[90m  [0] Base Only\033[0m"

    for i in "${!extensions[@]}"; do
        echo "  [$((i+1))] ${extensions[$i]}"
    done

    read -p "Select: " choice

    if [ -z "$choice" ] || [ "$choice" -eq 0 ]; then
        echo ""
        return 0
    fi

    local index=$((choice-1))
    if [ $index -ge 0 ] && [ $index -lt ${#extensions[@]} ]; then
        echo "${extensions[$index]}"
    else
        echo ""
    fi
}

select_modules() {
    local modules_path="$PROMPTS_BASE_PATH/modules"
    if [ ! -d "$modules_path" ]; then
        return 0
    fi

    local modules=($(ls "$modules_path"/*.md 2>/dev/null | xargs -n 1 basename | sed 's/\.md$//'))

    if [ ${#modules[@]} -eq 0 ]; then
        return 0
    fi

    echo ""
    echo -e "\033[36m=== Select Extra Modules (Multiple, Enter to finish) ===\033[0m"

    for i in "${!modules[@]}"; do
        echo "  [$((i+1))] ${modules[$i]}"
    done
    echo -e "\033[90m  [0] Done\033[0m"

    local selected=""

    while true; do
        read -p "Select: " choice
        
        if [ -z "$choice" ] || [ "$choice" -eq 0 ]; then
            break
        fi

        local index=$((choice-1))
        if [ $index -ge 0 ] && [ $index -lt ${#modules[@]} ]; then
            local mod="${modules[$index]}"
            # check if already selected
            if [[ ! " $selected " =~ " $mod " ]]; then
                selected="$selected $mod"
                echo -e "\033[32m   Added: $mod\033[0m"
            fi
        fi
    done

    echo "$selected"
}

build_combined_prompt() {
    local lang="$1"
    local ext="$2"
    local mods="$3"
    
    local output=""
    local separator=$'\n\n---\n\n'
    
    echo ""
    echo -e "\033[90mLoading...\033[0m"

    # Get extension config
    local config_vars=""
    if [ -n "$ext" ]; then
        config_vars=$(get_extension_config "$ext")
    fi

    # Metadata
    local mod_str="none"
    [ -n "$mods" ] && mod_str=$(echo $mods | tr ' ' ',')
    local ext_str="none"
    [ -n "$ext" ] && ext_str="$ext"
    
    output="<!-- PROMPT CONFIG
Language: $lang
Extension: $ext_str
Modules: $mod_str
Generated: $(date "+%Y-%m-%d %H:%M:%S")
-->
"

    # 1. Common
    local common_path="$PROMPTS_BASE_PATH/common"
    if [ -d "$common_path" ]; then
        for file in "$common_path"/*.md; do
            if [ -f "$file" ]; then
                output+="$separator$(cat "$file")"
                echo -e "\033[90m   [common] $(basename "$file")\033[0m"
            fi
        done
    fi

    # 2. Base
    local base_file="$PROMPTS_BASE_PATH/languages/$lang/base.md"
    if [ -f "$base_file" ]; then
        output+="$separator$(cat "$base_file")"
        echo -e "\033[90m   [base] $lang/base.md\033[0m"
    fi

    # 3. Extension
    if [ -n "$ext" ]; then
        local ext_file="$PROMPTS_BASE_PATH/languages/$lang/extensions/$ext.md"
        if [ -f "$ext_file" ]; then
            local content=$(cat "$ext_file")
            
            # Replace placeholders
            if [ -n "$config_vars" ]; then
                # Parse key=value lines
                while IFS='=' read -r key value; do
                    if [ -n "$key" ]; then
                        # Escape special chars for sed
                        local safe_val=$(echo "$value" | sed 's/[\/&]/\\&/g')
                        content=$(echo "$content" | sed "s/{{$key}}/$safe_val/g")
                    fi
                done <<< "$config_vars"
            fi
            
            output+="$separator$content"
            echo -e "\033[90m   [extension] $ext.md\033[0m"
        fi
    fi

    # 4. Modules
    for mod in $mods; do
        local mod_file="$PROMPTS_BASE_PATH/modules/$mod.md"
        if [ -f "$mod_file" ]; then
            output+="$separator$(cat "$mod_file")"
            echo -e "\033[90m   [module] $mod.md\033[0m"
        fi
    done

    echo "$output"
}

# ============================================
# Main Function: gprompt
# ============================================
gprompt() {
    local local_rules="./.geminirules"
    local global_rules="$HOME/.gemini/GEMINI.md"
    local always_ask=$(get_prompt_config "ALWAYS_ASK_PROMPT")

    local has_local=false
    [ -f "$local_rules" ] && has_local=true
    
    local has_global=false
    [ -f "$global_rules" ] && has_global=true

    # Logic: If Always Ask is true, OR if Local Rules are MISSING, show menu.
    if [ "$always_ask" = "true" ] || [ "$has_local" = false ]; then
        echo ""
        echo -e "\033[36m=== Gemini Prompt Setup ===\033[0m"
        
        if [ "$has_local" = true ]; then
            echo -e "  [0] Use Local Rules (.geminirules)\033[0m"
        fi
        
        echo -e "  [1] Select/Create New Rules"
        echo -e "  [2] No Prompt (Native Mode)"
        
        if [ "$has_global" = true ]; then
            echo -e "  [3] Use Global Config"
        fi
        echo ""

        read -p "Select: " choice

        case "$choice" in
            0)
                if [ "$has_local" = false ]; then
                    echo -e "\033[31mInvalid selection.\033[0m"
                    return 1
                else
                    echo -e "\033[90mUsing Local Rules...\033[0m"
                fi
                ;; 
            1)
                local lang=$(select_language)
                if [ $? -ne 0 ]; then
                    echo -e "\033[33mCancelled.\033[0m"
                    return 1
                fi

                local lang_path="$PROMPTS_BASE_PATH/languages/$lang"
                local ext=$(select_extension "$lang_path")
                local mods=$(select_modules)
                
                local combined=$(build_combined_prompt "$lang" "$ext" "$mods")
                echo "$combined" > "$local_rules"

                echo ""
                echo -e "\033[32mPrompt Loaded: $lang\033[0m"
                [ -n "$ext" ] && echo -e "\033[36m   Extension: $ext\033[0m"
                ;; 
            2)
                echo -e "\033[90mStarting native Gemini...\033[0m"
                if [ -n "$GEMINI_NATIVE" ]; then
                    "$GEMINI_NATIVE" "$@"
                else
                    echo -e "\033[31mError: Native gemini command not found.\033[0m"
                fi
                return
                ;; 
            3)
                if [ "$has_global" = true ]; then
                     echo -e "\033[90mUsing Global Config...\033[0m"
                     if [ -n "$GEMINI_NATIVE" ]; then
                        "$GEMINI_NATIVE" "$@"
                    fi
                    return
                else
                    echo -e "\033[31mGlobal config not found.\033[0m"
                    return 1
                fi
                ;; 
            *)
                if [ "$has_local" = true ]; then
                     echo -e "\033[90mUsing Local Rules...\033[0m"
                else
                    # Default to native if nothing selected and no local rules
                     echo -e "\033[90mStarting native Gemini...\033[0m"
                     if [ -n "$GEMINI_NATIVE" ]; then
                        "$GEMINI_NATIVE" "$@"
                    fi
                    return
                fi
                ;; 
        esac
    elif [ "$has_local" = true ]; then
        # Show info
        local lang=$(grep "^Language:" "$local_rules" | sed 's/Language:\s*//')
        local ext=$(grep "^Extension:" "$local_rules" | sed 's/Extension:\s*//')
        local mods=$(grep "^Modules:" "$local_rules" | sed 's/Modules:\s*//')
        
        echo ""
        echo -e "\033[36m=== Loading Local Prompt Context ===\033[0m"
        echo -e "  Language:  $lang"
        echo -e "  Extension: $ext"
        echo -e "  Modules:   $mods"
        echo -e "\033[90m  Path:      $local_rules\033[0m"
        echo -e "\033[36m====================================\033[0m"
    fi

    echo ""
    if [ -n "$GEMINI_NATIVE" ]; then
        "$GEMINI_NATIVE" "$@"
    else
        echo -e "\033[33m(Native gemini command not found. Prompt generated at target location.)\033[0m"
        [ -f "$local_rules" ] && echo -e "\033[90mPrompt Path: $local_rules\033[0m"
    fi
}

# ============================================
# Helpers
# ============================================
show_prompt_status() {
    echo ""
    echo -e "\033[36m=== Gemini Prompt Status ===\033[0m"
    local global_rules="$HOME/.gemini/GEMINI.md"
    local local_rules="./.geminirules"

    if [ -f "$global_rules" ]; then
        local lang=$(grep "^Language:" "$global_rules" | sed 's/Language:\s*//')
        echo -e "  [Global] $global_rules\033[0m"
        [ -n "$lang" ] && echo -e "\033[90m           $lang\033[0m"
    else
        echo -e "  [Global] Not Set\033[0m"
    fi

    if [ -f "$local_rules" ]; then
        local lang=$(grep "^Language:" "$local_rules" | sed 's/Language:\s*//')
        echo -e "  [Local]  $local_rules\033[0m"
        [ -n "$lang" ] && echo -e "\033[90m           $lang\033[0m"
    else
        echo -e "  [Local]  Not Set\033[0m"
    fi
    
    if [ -f "$CONFIG_FILE" ]; then
        echo ""
        echo -e "\033[36m=== Extension Config ===\033[0m"
        cat "$CONFIG_FILE" | while read line; do echo -e "\033[90m  $line\033[0m"; done
    fi
    echo ""
}

clear_local_prompt() {
    if [ -f "./.geminirules" ]; then
        rm "./.geminirules"
        echo -e "\033[32mCleared local .geminirules\033[0m"
    else
        echo -e "\033[33mNo local rules found.\033[0m"
    fi
}

# ============================================
# Init
# ============================================
if [ -z "$GEMINI_PROMPT_LOADED" ]; then
    export GEMINI_PROMPT_LOADED=1
    echo ""
    echo -e "\033[32mGemini Prompt System Ready (v4.3)\033[0m"
    echo ""
    echo -e "\033[36mUsage:\033[0m"
    echo "  gemini              # Run native Gemini CLI"
    echo "  gprompt             # Load prompt context & run Gemini"
    echo ""
fi
