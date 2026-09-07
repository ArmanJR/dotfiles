#!/usr/bin/env bash
# Install the SBC shell files from this checkout, preserving previous configs.
set -euo pipefail

log() { printf '[%s] %s\n' "$1" "$2" >&2; }
trap 'log ERROR "Sync failed at line $LINENO (exit $?). Check file permissions and the backup path above."' ERR

DRY_RUN=false
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --all) ;; # Both shell files are always synced.
        --help)
            printf 'Usage: bash linux-edge/sbc/sync.sh [--all] [--dry-run]\nInstalls .zshrc and .zshenv from this checkout, with backups. Does not pull Git.\n'
            exit 0
            ;;
        *) log ERROR "Unknown option: $arg (use --help)"; exit 1 ;;
    esac
done

SBC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR=''
TEMP_FILE=''
trap 'if [[ -n "$TEMP_FILE" ]]; then rm -f -- "$TEMP_FILE"; fi' EXIT

# Validate all inputs before changing anything.
for file in .zshenv .zshrc; do
    if [[ ! -f "$SBC_DIR/$file" || -d "$HOME/$file" ]]; then
        log ERROR "Cannot sync $file: source missing or destination is a directory."
        exit 1
    fi
done

for file in .zshenv .zshrc; do
    source_file="$SBC_DIR/$file"
    target_file="$HOME/$file"
    if [[ -f "$target_file" ]] && cmp -s "$source_file" "$target_file"; then
        log INFO "$file is up to date"
        continue
    fi
    if [[ "$DRY_RUN" == true ]]; then
        log INFO "Would install $file"
        continue
    fi

    TEMP_FILE=$(mktemp "$HOME/.sbc-sync.XXXXXX")
    cp -- "$source_file" "$TEMP_FILE"
    if [[ -e "$target_file" || -L "$target_file" ]]; then
        if [[ -z "$BACKUP_DIR" ]]; then
            mkdir -p "$HOME/.dotfiles.backups"
            BACKUP_DIR=$(mktemp -d "$HOME/.dotfiles.backups/sbc-XXXXXXXX")
            log INFO "Backing up existing configs to $BACKUP_DIR"
        fi
        cp -P -- "$target_file" "$BACKUP_DIR/$file"
    fi
    # Replace symlinks themselves instead of overwriting another profile's source.
    mv -f -- "$TEMP_FILE" "$target_file"
    TEMP_FILE=''
    log OK "Installed $file"
done

log OK 'SBC sync complete. Start a fresh shell with: exec zsh'
