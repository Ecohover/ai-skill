#!/bin/bash
# Gemini Prompts install script (Bash/Zsh)

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
LOADER_PATH="$SCRIPT_DIR/loader.sh"
ENV_VAR_NAME="GEMINI_PROMPTS_PATH"

# Detect shell profile
if [ -n "$ZSH_VERSION" ]; then
    PROFILE_FILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bash_profile" ]; then
        PROFILE_FILE="$HOME/.bash_profile"
    else
        PROFILE_FILE="$HOME/.bashrc"
    fi
else
    PROFILE_FILE="$HOME/.profile"
fi

if [ "$1" == "-u" ] || [ "$1" == "--uninstall" ]; then
    echo -e "\033[36mUninstalling Gemini Prompts...\033[0m"
    
    # Remove config
    if [ -f "$HOME/.gemini-prompts-config" ]; then
        rm "$HOME/.gemini-prompts-config"
    fi

    # Remove from profile
    if [ -f "$PROFILE_FILE" ]; then
        # Create temp file without the lines
        grep -v "Gemini Prompts Loader" "$PROFILE_FILE" | grep -v "source \"$LOADER_PATH\"" > "$PROFILE_FILE.tmp"
        mv "$PROFILE_FILE.tmp" "$PROFILE_FILE"
        echo -e "\033[32mRemoved from $PROFILE_FILE\033[0m"
    fi
    
    echo -e "\033[32mDone.\033[0m"
    exit 0
fi

echo -e "\033[36mInstalling Gemini Prompts...\033[0m"

# 1. Set Environment Variable
export GEMINI_PROMPTS_PATH="$PROJECT_ROOT"

# 2. Add to profile
if grep -q "$LOADER_PATH" "$PROFILE_FILE"; then
    echo -e "\033[33mProfile already contains loader.\033[0m"
else
    echo "" >> "$PROFILE_FILE"
    echo "# Gemini Prompts Loader" >> "$PROFILE_FILE"
    echo "export GEMINI_PROMPTS_PATH=\"$PROJECT_ROOT\"" >> "$PROFILE_FILE"
    echo "source \"$LOADER_PATH\"" >> "$PROFILE_FILE"
    echo -e "\033[32mAdded to Profile: $PROFILE_FILE\033[0m"
fi

# 3. Make loader executable
chmod +x "$LOADER_PATH"

echo -e "\033[32mInstallation complete! Please restart your terminal or run:\033[0m"
echo "source $PROFILE_FILE"
