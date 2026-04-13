#!/bin/bash

# Dotfiles sync script (Linux Edge)
# Pulls latest dotfiles from GitHub and syncs them to the local system
#
# Usage:
#   sync.sh [options]
#
# Options:
#   --zsh         Sync .zsh directory
#   --zshrc       Sync .zshrc file
#   --dotfiles    Sync other dotfiles (.zshenv, .gitignore_global, .ripgreprc)
#   --atuin       Sync Atuin config
#   --prek        Sync prek hook templates
#   --tmux        Sync .tmux.conf
#   --all         Sync everything
#   --agentic     Non-interactive mode for AI agents (outputs JSON manifest to stdout)
#   --apply PATH  Apply changes from a manifest file (used after --agentic)
#   --ids LIST    Comma-separated IDs to apply (required with --apply)
#   --dry-run     Show what would change without applying anything
#   --help        Show this help message
#
# For agent mode, tell the agent to:
#   We want to sync our local configs with remote. Run `sync.sh --agentic --all` and follow its instructions.

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

DOTFILES_DIR="$HOME/code/dotfiles"
EDGE_DIR="$DOTFILES_DIR/linux-edge"
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
SYNC_ATUIN=false
SYNC_PREK=false
SYNC_TMUX=false
DRY_RUN=false
AGENTIC=false
APPLY_MANIFEST=""
APPLY_IDS=""

# === Functions ===

# Status output — stderr in agentic/apply mode so stdout stays clean for JSON
log_info() {
    if [[ "$AGENTIC" == true ]]; then
        echo -e "$@" >&2
    else
        echo -e "$@"
    fi
}

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
    done < <(find "$source_dir" -type f -print0)
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
            (bat --color=always --style=plain "$src" 2>/dev/null || batcat --color=always --style=plain "$src" 2>/dev/null || cat "$src")
        else
            echo "MODIFIED: $name"
            echo "---"
            diff -u "$tgt" "$src" | (bat --color=always -l diff --style=plain 2>/dev/null || batcat --color=always -l diff --style=plain 2>/dev/null || cat)
        fi
    '

    local header
    header="Tab: toggle | Ctrl-A: select all | Ctrl-D: deselect all | Enter: sync selected | Esc: cancel"

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
        --marker='* ' \
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

# Non-interactive JSON output for AI agents — writes manifest file, outputs JSON to stdout
agentic_output() {
    local manifest_file
    manifest_file=$(mktemp /tmp/dotfiles-sync-XXXXXX)
    cp "$CHANGES_MANIFEST" "$manifest_file"

    local script_path
    script_path="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

    # Print agent instructions before JSON data
    cat <<AGENT_INSTRUCTIONS
<dotfiles-sync>

You are helping the user sync their dotfiles from the repo to the local system.
The repo has been pulled and the changes below were detected.

## Instructions

1. Present each change to the user one at a time.
2. For modified files, analyze the diff and briefly explain what changed.
   For new files, briefly describe what the file contains.
3. Ask the user whether to apply or skip this change.
4. If accepted, apply it immediately by running:
     bash $script_path --apply $manifest_file --ids <id>
5. If skipped, move on to the next change.
6. After all changes have been reviewed, print a short summary of what was applied and what was skipped.

## Changes

AGENT_INSTRUCTIONS

    # Build JSON output using jq for safe escaping
    local json
    json=$(jq -n --arg manifest "$manifest_file" '{"manifest": $manifest, "changes": []}')

    local id=0
    while IFS='|' read -r source_file target_file status display_name; do
        ((++id))

        if [[ "$status" == "new" ]]; then
            local content
            content=$(<"$source_file")
            json=$(echo "$json" | jq \
                --argjson id "$id" \
                --arg name "$display_name" \
                --arg status "$status" \
                --arg content "$content" \
                '.changes += [{"id": $id, "display_name": $name, "status": $status, "content": $content}]')
        else
            local diff_text
            diff_text=$(diff -u "$target_file" "$source_file" || true)
            json=$(echo "$json" | jq \
                --argjson id "$id" \
                --arg name "$display_name" \
                --arg status "$status" \
                --arg diff "$diff_text" \
                '.changes += [{"id": $id, "display_name": $name, "status": $status, "diff": $diff}]')
        fi
    done < "$CHANGES_MANIFEST"

    echo "$json" | jq .
    echo ""
    echo "</dotfiles-sync>"
}

# Apply selected IDs from a manifest file (backup + copy handled internally)
apply_from_manifest() {
    local manifest_path="$1"
    local ids_str="$2"

    if [[ -z "$ids_str" ]]; then
        echo -e "${RED}Error: --ids is required with --apply${NC}" >&2
        exit 1
    fi
    if [[ ! -f "$manifest_path" ]]; then
        echo -e "${RED}Error: Manifest file not found: $manifest_path${NC}" >&2
        exit 1
    fi

    local id_search=",$(echo "$ids_str" | tr -d ' '),"

    local line_num=0
    local applied=0

    while IFS='|' read -r source_file target_file status display_name; do
        ((++line_num))

        if [[ "$id_search" == *",$line_num,"* ]]; then
            mkdir -p "$(dirname "$target_file")"
            backup_if_changed "$source_file" "$target_file"
            cp "$source_file" "$target_file"

            if [[ "$status" == "new" ]]; then
                echo -e "${GREEN}+ $display_name${NC}"
            else
                echo -e "${YELLOW}~ $display_name${NC}"
            fi
            ((++applied))
        fi
    done < "$manifest_path"

    if [[ "$applied" -eq 0 ]]; then
        echo -e "${YELLOW}No matching IDs found in manifest.${NC}"
    fi
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
        ((++count))
    done < "$selection_file"

    rm -f "$selection_file"

    echo ""
    echo -e "${GREEN}Synced $count file(s).${NC}"
}

# === Argument parsing ===

if [[ $# -eq 0 ]]; then
    echo -e "${RED}Error: No sync target specified${NC}"
    echo "Use --help to see available options"
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        --zsh)
            SYNC_ZSH=true
            ;;
        --zshrc)
            SYNC_ZSHRC=true
            ;;
        --dotfiles)
            SYNC_DOTFILES=true
            ;;
        --atuin)
            SYNC_ATUIN=true
            ;;
        --prek)
            SYNC_PREK=true
            ;;
        --tmux)
            SYNC_TMUX=true
            ;;
        --all)
            SYNC_ZSH=true
            SYNC_ZSHRC=true
            SYNC_DOTFILES=true
            SYNC_ATUIN=true
            SYNC_PREK=true
            SYNC_TMUX=true
            ;;
        --agentic)
            AGENTIC=true
            ;;
        --apply)
            APPLY_MANIFEST="$2"
            shift
            ;;
        --ids)
            APPLY_IDS="$2"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        --help)
            echo "Dotfiles sync script (Linux Edge)"
            echo ""
            echo "Usage: sync.sh [options]"
            echo ""
            echo "Options:"
            echo "  --zsh         Sync .zsh directory"
            echo "  --zshrc       Sync .zshrc file"
            echo "  --dotfiles    Sync other dotfiles (.zshenv, .gitignore_global, .ripgreprc)"
            echo "  --atuin       Sync Atuin config"
            echo "  --prek        Sync prek hook templates"
            echo "  --tmux        Sync .tmux.conf"
            echo "  --all         Sync everything"
            echo "  --agentic     Non-interactive mode for AI agents (outputs JSON manifest)"
            echo "  --apply PATH  Apply changes from a manifest file (used after --agentic)"
            echo "  --ids LIST    Comma-separated IDs to apply (required with --apply)"
            echo "  --dry-run     Show what would change without applying anything"
            echo "  --help        Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help to see available options"
            exit 1
            ;;
    esac
    shift
done

# === Dependency checks ===
missing=()
if ! command -v git &>/dev/null; then
    missing+=("git")
fi
if [[ "$AGENTIC" == true ]] && ! command -v jq &>/dev/null; then
    missing+=("jq")
fi
if [[ "$AGENTIC" != true ]] && [[ -z "$APPLY_MANIFEST" ]] && [[ "$DRY_RUN" != true ]]; then
    if ! command -v fzf &>/dev/null; then
        missing+=("fzf")
    fi
fi
if [[ ${#missing[@]} -gt 0 ]]; then
    echo -e "${RED}Error: Missing required dependencies: ${missing[*]}${NC}" >&2
    exit 1
fi

# === Apply mode: read manifest and apply selected IDs ===
if [[ -n "$APPLY_MANIFEST" ]]; then
    apply_from_manifest "$APPLY_MANIFEST" "$APPLY_IDS"

    if [[ "$BACKUP_CREATED" == true ]]; then
        echo -e "${CYAN}Backup saved to $BACKUP_DIR${NC}"
    fi
    exit 0
fi

# === Collect mode (normal, dry-run, or agentic) ===

log_info "${BLUE}Starting dotfiles sync...${NC}"

cd "$DOTFILES_DIR" || {
    echo -e "${RED}Error: Could not find dotfiles directory at $DOTFILES_DIR${NC}" >&2
    exit 1
}

log_info "${BLUE}Pulling latest changes from GitHub...${NC}"
if [[ "$AGENTIC" == true ]]; then
    git pull origin main >&2 || {
        echo -e "${RED}Error: Failed to pull from GitHub${NC}" >&2
        exit 1
    }
else
    git pull origin main || {
        echo -e "${RED}Error: Failed to pull from GitHub${NC}" >&2
        exit 1
    }
fi

log_info ""

# === Collect phase ===
log_info "${BLUE}=== Checking for changes ===${NC}"
log_info ""

if [[ "$SYNC_ZSH" == true ]]; then
    collect_directory_changes "$EDGE_DIR/.zsh" "$HOME/.zsh" ".zsh"
fi

if [[ "$SYNC_ZSHRC" == true ]]; then
    collect_file_changes "$EDGE_DIR/.zshrc" "$HOME/.zshrc" ".zshrc"
fi

if [[ "$SYNC_DOTFILES" == true ]]; then
    collect_file_changes "$EDGE_DIR/.zshenv" "$HOME/.zshenv" ".zshenv"
    collect_file_changes "$EDGE_DIR/.gitignore_global" "$HOME/.gitignore_global" ".gitignore_global"
    collect_file_changes "$EDGE_DIR/.ripgreprc" "$HOME/.ripgreprc" ".ripgreprc"
fi

if [[ "$SYNC_ATUIN" == true ]]; then
    collect_file_changes "$EDGE_DIR/.config/atuin/config.toml" "$HOME/.config/atuin/config.toml" "atuin/config.toml"
fi

if [[ "$SYNC_PREK" == true ]]; then
    collect_directory_changes "$EDGE_DIR/.config/prek" "$HOME/.config/prek" ".config/prek"
fi

if [[ "$SYNC_TMUX" == true ]]; then
    collect_file_changes "$EDGE_DIR/.tmux.conf" "$HOME/.tmux.conf" ".tmux.conf"
fi

# Check if there are any changes
if [[ ! -s "$CHANGES_MANIFEST" ]]; then
    log_info "${GREEN}No changes detected — everything is up to date.${NC}"
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

# === Agentic mode: output JSON manifest for AI agent ===
if [[ "$AGENTIC" == true ]]; then
    agentic_output
    exit 0
fi

# === Review + sync phase ===
SELECTION_FILE=$(review_changes)
sync_selected "$SELECTION_FILE"

echo ""
echo -e "${GREEN}Dotfiles synced successfully!${NC}"
if [[ "$BACKUP_CREATED" == true ]]; then
    echo -e "${CYAN}  Backup saved to $BACKUP_DIR${NC}"
fi
