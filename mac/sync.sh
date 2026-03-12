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
#   --dotfiles    Sync other dotfiles (.zshenv, .zprofile, .gitconfig, .gitignore_global, .ripgreprc, ghostty.config)
#   --claude      Sync .claude directory
#   --init        Sync everything and run all setup scripts (for new devices)
#   --vscode      Sync VSCode settings
#   --atuin       Sync Atuin config
#   --zed         Sync Zed config
#   --prek        Sync prek hook templates
#   --all         Sync everything
#   --dry-run     Show what would change without applying anything
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
BACKUP_BASE="$HOME/.dotfiles.backups"
BACKUP_DIR="$BACKUP_BASE/sync-$(date +%Y%m%d-%H%M%S)"
BACKUP_CREATED=false

# Manifest for tracking changes: source_path|target_path|status|display_name
CHANGES_MANIFEST=$(mktemp)
trap 'rm -f "$CHANGES_MANIFEST"' EXIT

# Parse arguments
SYNC_ZSH=false
SYNC_ZSHRC=false
SYNC_DOTFILES=false
SYNC_CLAUDE=false
SYNC_VSCODE=false
SYNC_ATUIN=false
SYNC_ZED=false
SYNC_PREK=false
DRY_RUN=false
CLAUDE_INIT=false

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
        --init)
            SYNC_ZSH=true
            SYNC_ZSHRC=true
            SYNC_DOTFILES=true
            SYNC_CLAUDE=true
            SYNC_VSCODE=true
            SYNC_ATUIN=true
            SYNC_ZED=true
            SYNC_PREK=true
            CLAUDE_INIT=true
            ;;
        --vscode)
            SYNC_VSCODE=true
            ;;
        --atuin)
            SYNC_ATUIN=true
            ;;
        --zed)
            SYNC_ZED=true
            ;;
        --prek)
            SYNC_PREK=true
            ;;
        --all)
            SYNC_ZSH=true
            SYNC_ZSHRC=true
            SYNC_DOTFILES=true
            SYNC_CLAUDE=true
            SYNC_VSCODE=true
            SYNC_ATUIN=true
            SYNC_ZED=true
            SYNC_PREK=true
            ;;
        --dry-run)
            DRY_RUN=true
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
            echo "  --atuin       Sync Atuin config"
            echo "  --zed         Sync Zed config"
            echo "  --prek        Sync prek hook templates"
            echo "  --all         Sync everything"
            echo "  --init        Sync everything and run all setup scripts (for new devices)"
            echo "  --dry-run     Show what would change without applying anything"
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

# Collect changes for a directory into the manifest
collect_directory_changes() {
    local source_dir="$1"
    local target_dir="$2"
    local display_prefix="$3"

    mkdir -p "$target_dir"

    while IFS= read -r -d '' source_file; do
        relative_path="${source_file#$source_dir/}"
        target_file="$target_dir/$relative_path"

        if [[ ! -e "$target_file" ]]; then
            echo "${source_file}|${target_file}|new|${display_prefix}/${relative_path}" >> "$CHANGES_MANIFEST"
        elif ! cmp -s "$source_file" "$target_file"; then
            echo "${source_file}|${target_file}|modified|${display_prefix}/${relative_path}" >> "$CHANGES_MANIFEST"
        fi
    done < <(/usr/bin/find "$source_dir" -type f -print0)
}

# Collect changes for a single file into the manifest
collect_file_changes() {
    local source_file="$1"
    local target_file="$2"
    local display_name="$3"

    if [[ ! -e "$target_file" ]]; then
        echo "${source_file}|${target_file}|new|${display_name}" >> "$CHANGES_MANIFEST"
    elif ! cmp -s "$source_file" "$target_file"; then
        echo "${source_file}|${target_file}|modified|${display_name}" >> "$CHANGES_MANIFEST"
    fi
}

# Backup a target file if it exists and differs from the source
backup_if_changed() {
    local source_file="$1"
    local target_file="$2"

    if [[ -e "$target_file" ]] && ! cmp -s "$source_file" "$target_file"; then
        local relative_path="${target_file#$HOME/}"
        local backup_dest="$BACKUP_DIR/$relative_path"
        mkdir -p "$(dirname "$backup_dest")"
        cp "$target_file" "$backup_dest"
        BACKUP_CREATED=true
    fi
}

# Interactive review with fzf — returns path to temp file with selected entries
review_changes() {
    local selected
    selected=$(mktemp)

    local preview_cmd='
        IFS="|" read -r src tgt ftype name <<< {}
        if [[ "$ftype" == "new" ]]; then
            echo "NEW FILE: $name"
            echo "---"
            bat --color=always --style=plain "$src" 2>/dev/null || cat "$src"
        else
            echo "MODIFIED: $name"
            echo "---"
            diff -u "$tgt" "$src" | bat --color=always -l diff --style=plain 2>/dev/null || diff -u "$tgt" "$src"
        fi
    '

    local header
    header="Tab: toggle | Ctrl-A: select all | Ctrl-D: deselect all | Enter: sync selected | Esc: cancel"

    # Track whether selections are active (ctrl-d clears this)
    local has_selections
    has_selections=$(mktemp)
    echo "1" > "$has_selections"

    local fzf_exit=0
    cat "$CHANGES_MANIFEST" | fzf \
        --multi \
        --bind 'start:select-all' \
        --bind 'ctrl-a:select-all+execute-silent(echo 1 > '"$has_selections"')' \
        --bind 'ctrl-d:deselect-all+execute-silent(: > '"$has_selections"')' \
        --bind 'tab:toggle+execute-silent(echo 1 > '"$has_selections"')' \
        --with-nth=4 \
        --delimiter='|' \
        --preview "$preview_cmd" \
        --preview-window='right:65%:wrap' \
        --border=rounded \
        --border-label=" Dotfiles Review " \
        --header "$header" \
        --header-first \
        --marker='✓ ' \
        --marker-multi-line='╻ │ ╹ ' \
        --color='marker:green,fg:gray,selected-fg:white:bold' \
        --ansi \
        > "$selected" || fzf_exit=$?

    # Esc/Ctrl-C
    if [[ "$fzf_exit" -ne 0 ]]; then
        rm -f "$selected" "$has_selections"
        echo ""
        echo -e "${YELLOW}Cancelled — no files synced.${NC}"
        exit 0
    fi

    # Ctrl-D (deselect all) then Enter — flag file is empty
    if [[ ! -s "$has_selections" ]] || [[ ! -s "$selected" ]]; then
        rm -f "$selected" "$has_selections"
        echo ""
        echo -e "${YELLOW}No files selected — nothing to sync.${NC}"
        exit 0
    fi

    rm -f "$has_selections"
    echo "$selected"
}

# Sync selected files from the manifest
sync_selected() {
    local selection_file="$1"
    local count=0

    echo -e "${BLUE}=== Syncing selected files ===${NC}"
    echo ""

    while IFS='|' read -r source_file target_file status display_name; do
        mkdir -p "$(dirname "$target_file")"
        backup_if_changed "$source_file" "$target_file"
        cp "$source_file" "$target_file"

        if [[ "$status" == "new" ]]; then
            echo -e "  ${GREEN}+ $display_name${NC}"
        else
            echo -e "  ${YELLOW}~ $display_name${NC}"
        fi
        ((count++))
    done < "$selection_file"

    rm -f "$selection_file"

    echo ""
    echo -e "${GREEN}Synced $count file(s).${NC}"
}

# === Collect phase ===
echo -e "${BLUE}=== Checking for changes ===${NC}"
echo ""

if [[ "$SYNC_ZSH" == true ]]; then
    collect_directory_changes "$MAC_DIR/.zsh" "$HOME/.zsh" ".zsh"
fi

if [[ "$SYNC_ZSHRC" == true ]]; then
    collect_file_changes "$MAC_DIR/.zshrc" "$HOME/.zshrc" ".zshrc"
fi

if [[ "$SYNC_DOTFILES" == true ]]; then
    collect_file_changes "$MAC_DIR/.zshenv" "$HOME/.zshenv" ".zshenv"
    collect_file_changes "$MAC_DIR/.zprofile" "$HOME/.zprofile" ".zprofile"
    collect_file_changes "$MAC_DIR/.gitconfig" "$HOME/.gitconfig" ".gitconfig"
    collect_file_changes "$MAC_DIR/.gitignore_global" "$HOME/.gitignore_global" ".gitignore_global"
    collect_file_changes "$MAC_DIR/.ripgreprc" "$HOME/.ripgreprc" ".ripgreprc"
    collect_file_changes "$MAC_DIR/ghostty.config" "$HOME/.config/ghostty/config" "ghostty.config"
fi

if [[ "$SYNC_CLAUDE" == true ]]; then
    collect_directory_changes "$MAC_DIR/.claude" "$HOME/.claude" ".claude"
fi

if [[ "$SYNC_VSCODE" == true ]]; then
    VSCODE_TARGET="$HOME/Library/Application Support/Code/User"
    collect_file_changes "$MAC_DIR/vscode/settings.json" "$VSCODE_TARGET/settings.json" "vscode/settings.json"
fi

if [[ "$SYNC_ATUIN" == true ]]; then
    collect_file_changes "$MAC_DIR/.config/atuin/config.toml" "$HOME/.config/atuin/config.toml" "atuin/config.toml"
fi

if [[ "$SYNC_ZED" == true ]]; then
    collect_directory_changes "$MAC_DIR/.config/zed" "$HOME/.config/zed" ".config/zed"
fi

if [[ "$SYNC_PREK" == true ]]; then
    collect_directory_changes "$MAC_DIR/.config/prek" "$HOME/.config/prek" ".config/prek"
fi

# Check if there are any changes
if [[ ! -s "$CHANGES_MANIFEST" ]]; then
    echo -e "${GREEN}No changes detected — everything is up to date.${NC}"
    exit 0
fi

# === Dry-run: print manifest and exit ===
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${BLUE}Changed files:${NC}"
    while IFS='|' read -r _ _ status display_name; do
        if [[ "$status" == "new" ]]; then
            echo -e "  ${GREEN}+ $display_name (new)${NC}"
        else
            echo -e "  ${YELLOW}~ $display_name (modified)${NC}"
        fi
    done < "$CHANGES_MANIFEST"
    echo ""
    echo -e "${YELLOW}Dry run — no files were changed.${NC}"
    exit 0
fi

# === Review + sync phase ===
SELECTION_FILE=$(review_changes)
sync_selected "$SELECTION_FILE"

# Post-sync tasks
if [[ "$CLAUDE_INIT" == true ]] && [[ -f "$HOME/.claude/setup-claude.sh" ]]; then
    echo -e "${BLUE}Running Claude setup script...${NC}"
    bash "$HOME/.claude/setup-claude.sh" || {
        echo -e "${RED}Error: Failed to run setup-claude.sh${NC}"
        exit 1
    }
    echo -e "${GREEN}  Setup complete${NC}"
fi

echo ""
echo -e "${GREEN}Dotfiles synced successfully!${NC}"
if [[ "$BACKUP_CREATED" == true ]]; then
    echo -e "${CYAN}  Backup saved to $BACKUP_DIR${NC}"
fi
