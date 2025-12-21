#!/bin/bash

# Dotfiles sync script
# This script pulls the latest dotfiles from GitHub and syncs them to the local system
#
# Usage:
#   sync.sh [options]
#
# Options:
#   --zsh         Sync .zsh directory
#   --zshrc       Sync .zshrc file
#   --dotfiles    Sync other dotfiles (.gitconfig, .gitignore_global, .ripgreprc, ghostty.config)
#   --claude      Sync .claude directory
#   --vscode      Sync VSCode settings
#   --all         Sync everything
#   --help        Show this help message

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

DOTFILES_DIR="$HOME/code/dotfiles"
MAC_DIR="$DOTFILES_DIR/mac"

# Parse arguments
SYNC_ZSH=false
SYNC_ZSHRC=false
SYNC_DOTFILES=false
SYNC_CLAUDE=false
SYNC_VSCODE=false

if [[ $# -eq 0 ]]; then
    echo -e "${RED}Error: No sync target specified${NC}"
    echo "Use --help to see available options"
    exit 1
fi

for arg in "$@"; do
    case $arg in
        --zsh)
            SYNC_ZSH=true
            ;;
        --zshrc)
            SYNC_ZSHRC=true
            ;;
        --dotfiles)
            SYNC_DOTFILES=true
            ;;
        --claude)
            SYNC_CLAUDE=true
            ;;
        --vscode)
            SYNC_VSCODE=true
            ;;
        --all)
            SYNC_ZSH=true
            SYNC_ZSHRC=true
            SYNC_DOTFILES=true
            SYNC_CLAUDE=true
            SYNC_VSCODE=true
            ;;
        --help)
            echo "Dotfiles sync script"
            echo ""
            echo "Usage: sync.sh [options]"
            echo ""
            echo "Options:"
            echo "  --zsh         Sync .zsh directory"
            echo "  --zshrc       Sync .zshrc file"
            echo "  --dotfiles    Sync other dotfiles (.gitconfig, .gitignore_global, .ripgreprc, ghostty.config)"
            echo "  --claude      Sync .claude directory"
            echo "  --vscode      Sync VSCode settings"
            echo "  --all         Sync everything"
            echo "  --help        Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $arg${NC}"
            echo "Use --help to see available options"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}Starting dotfiles sync...${NC}"

# Navigate to dotfiles directory
cd "$DOTFILES_DIR" || {
    echo -e "${RED}Error: Could not find dotfiles directory at $DOTFILES_DIR${NC}"
    exit 1
}

echo -e "${BLUE}Pulling latest changes from GitHub...${NC}"
git pull origin main || {
    echo -e "${RED}Error: Failed to pull from GitHub${NC}"
    exit 1
}

echo ""

# Function to compare and display changes for a directory
compare_directory() {
    local source_dir="$1"
    local target_dir="$2"
    local display_name="$3"

    local new_files=()
    local modified_files=()
    local deleted_files=()
    local unchanged_files=()

    echo -e "${MAGENTA}Checking $display_name...${NC}"

    # Create target directory if it doesn't exist
    mkdir -p "$target_dir"

    # Check for new and modified files
    while IFS= read -r -d '' source_file; do
        relative_path="${source_file#$source_dir/}"
        target_file="$target_dir/$relative_path"

        if [[ ! -e "$target_file" ]]; then
            new_files+=("$relative_path")
        elif ! cmp -s "$source_file" "$target_file"; then
            modified_files+=("$relative_path")
        else
            unchanged_files+=("$relative_path")
        fi
    done < <(find "$source_dir" -type f -print0)

    # Check for deleted files
    if [[ -d "$target_dir" ]]; then
        while IFS= read -r -d '' target_file; do
            relative_path="${target_file#$target_dir/}"
            source_file="$source_dir/$relative_path"

            if [[ ! -e "$source_file" ]]; then
                deleted_files+=("$relative_path")
            fi
        done < <(find "$target_dir" -type f -print0)
    fi

    # Display changes
    if [[ ${#new_files[@]} -eq 0 && ${#modified_files[@]} -eq 0 && ${#deleted_files[@]} -eq 0 ]]; then
        echo -e "${GREEN}  No changes${NC}"
    else
        if [[ ${#new_files[@]} -gt 0 ]]; then
            echo -e "${GREEN}  New files (${#new_files[@]}):${NC}"
            for file in "${new_files[@]}"; do
                echo -e "    ${GREEN}+ $file${NC}"
            done
        fi

        if [[ ${#modified_files[@]} -gt 0 ]]; then
            echo -e "${YELLOW}  Modified files (${#modified_files[@]}):${NC}"
            for file in "${modified_files[@]}"; do
                echo -e "    ${YELLOW}~ $file${NC}"
                echo -e "${CYAN}      Changes:${NC}"
                diff -u "$target_dir/$file" "$source_dir/$file" | tail -n +3 | head -n 15 | sed 's/^/      /' || true

                diff_lines=$(diff -u "$target_dir/$file" "$source_dir/$file" | tail -n +3 | wc -l | tr -d ' ')
                if [[ $diff_lines -gt 15 ]]; then
                    echo -e "${CYAN}      ... (${diff_lines} total lines changed, showing first 15)${NC}"
                fi
            done
        fi

        if [[ ${#deleted_files[@]} -gt 0 ]]; then
            echo -e "${RED}  Files to be deleted (${#deleted_files[@]}):${NC}"
            for file in "${deleted_files[@]}"; do
                echo -e "    ${RED}- $file${NC}"
            done
        fi
    fi
    echo ""
}

# Function to compare and display changes for a single file
compare_file() {
    local source_file="$1"
    local target_file="$2"
    local display_name="$3"

    echo -e "${MAGENTA}Checking $display_name...${NC}"

    if [[ ! -e "$target_file" ]]; then
        echo -e "${GREEN}  New file${NC}"
    elif ! cmp -s "$source_file" "$target_file"; then
        echo -e "${YELLOW}  Modified${NC}"
        echo -e "${CYAN}    Changes:${NC}"
        diff -u "$target_file" "$source_file" | tail -n +3 | head -n 15 | sed 's/^/    /' || true

        diff_lines=$(diff -u "$target_file" "$source_file" | tail -n +3 | wc -l | tr -d ' ')
        if [[ $diff_lines -gt 15 ]]; then
            echo -e "${CYAN}    ... (${diff_lines} total lines changed, showing first 15)${NC}"
        fi
    else
        echo -e "${GREEN}  No changes${NC}"
    fi
    echo ""
}

# Function to sync directory
sync_directory() {
    local source_dir="$1"
    local target_dir="$2"
    local display_name="$3"

    echo -e "${BLUE}Syncing $display_name to $target_dir...${NC}"
    mkdir -p "$target_dir"
    rsync -a --delete "$source_dir/" "$target_dir/" || {
        echo -e "${RED}Error: Failed to sync $display_name${NC}"
        return 1
    }
    echo -e "${GREEN}  ✓ Synced${NC}"
}

# Function to sync file
sync_file() {
    local source_file="$1"
    local target_file="$2"
    local display_name="$3"

    echo -e "${BLUE}Syncing $display_name to $target_file...${NC}"
    mkdir -p "$(dirname "$target_file")"
    cp "$source_file" "$target_file" || {
        echo -e "${RED}Error: Failed to sync $display_name${NC}"
        return 1
    }
    echo -e "${GREEN}  ✓ Synced${NC}"
}

# Compare phase
echo -e "${BLUE}=== Comparing files ===${NC}"
echo ""

if [[ "$SYNC_ZSH" == true ]]; then
    compare_directory "$MAC_DIR/.zsh" "$HOME/.zsh" ".zsh directory"
fi

if [[ "$SYNC_ZSHRC" == true ]]; then
    compare_file "$MAC_DIR/.zshrc" "$HOME/.zshrc" ".zshrc"
fi

if [[ "$SYNC_DOTFILES" == true ]]; then
    compare_file "$MAC_DIR/.gitconfig" "$HOME/.gitconfig" ".gitconfig"
    compare_file "$MAC_DIR/.gitignore_global" "$HOME/.gitignore_global" ".gitignore_global"
    compare_file "$MAC_DIR/.ripgreprc" "$HOME/.ripgreprc" ".ripgreprc"
    compare_file "$MAC_DIR/ghostty.config" "$HOME/.config/ghostty/config" "ghostty.config"
fi

if [[ "$SYNC_CLAUDE" == true ]]; then
    compare_directory "$MAC_DIR/.claude" "$HOME/.claude" ".claude directory"
fi

if [[ "$SYNC_VSCODE" == true ]]; then
    VSCODE_TARGET="$HOME/Library/Application Support/Code/User"
    compare_file "$MAC_DIR/vscode/settings.json" "$VSCODE_TARGET/settings.json" "VSCode settings.json"
fi

# Sync phase
echo -e "${BLUE}=== Syncing files ===${NC}"
echo ""

if [[ "$SYNC_ZSH" == true ]]; then
    sync_directory "$MAC_DIR/.zsh" "$HOME/.zsh" ".zsh directory"
fi

if [[ "$SYNC_ZSHRC" == true ]]; then
    sync_file "$MAC_DIR/.zshrc" "$HOME/.zshrc" ".zshrc"
fi

if [[ "$SYNC_DOTFILES" == true ]]; then
    sync_file "$MAC_DIR/.gitconfig" "$HOME/.gitconfig" ".gitconfig"
    sync_file "$MAC_DIR/.gitignore_global" "$HOME/.gitignore_global" ".gitignore_global"
    sync_file "$MAC_DIR/.ripgreprc" "$HOME/.ripgreprc" ".ripgreprc"
    sync_file "$MAC_DIR/ghostty.config" "$HOME/.config/ghostty/config" "ghostty.config"
fi

if [[ "$SYNC_CLAUDE" == true ]]; then
    sync_directory "$MAC_DIR/.claude" "$HOME/.claude" ".claude directory"
fi

if [[ "$SYNC_VSCODE" == true ]]; then
    VSCODE_TARGET="$HOME/Library/Application Support/Code/User"
    sync_file "$MAC_DIR/vscode/settings.json" "$VSCODE_TARGET/settings.json" "VSCode settings.json"
fi

echo ""
echo -e "${GREEN}✓ Dotfiles synced successfully!${NC}"
