# =============================================================================
# Modern Tool Replacements
# =============================================================================

# eza (ls replacement)
if command -v eza >/dev/null 2>&1; then
    alias l="eza -lh"
    alias ls="eza"
    alias ll="eza -l --git"
    alias la="eza -la --git"
    alias lt="eza -T"
    alias tree="eza -T"
else
    alias l="ls -lh"
fi

# fd (find replacement)
if command -v fd >/dev/null 2>&1; then
    alias find="fd"
fi

# ripgrep (grep replacement)
if command -v rg >/dev/null 2>&1; then
    alias grep="rg"
    export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
fi

# bat (cat replacement)
if command -v bat >/dev/null 2>&1; then
    alias cat="bat --paging=never"
    alias catt="bat --paging=always"
fi

# =============================================================================
# System Navigation
# =============================================================================

# Directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"
alias -- -="cd -"

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# =============================================================================
# File Operations
# =============================================================================

# Make executable
alias cx="chmod +x"

# File permissions
alias 755="chmod 755"
alias 644="chmod 644"
alias 600="chmod 600"

# Quick file operations
alias h="head"
alias t="tail"
alias tf="tail -f"

# =============================================================================
# System Information
# =============================================================================

# System monitoring
alias cpu="top -o %CPU"
alias mem="top -o %MEM"
alias df="df -h"
alias du="du -h"
alias free="free -h"

# Network information
alias ip="curl -s ifconfig.me"
alias localip="hostname -I | awk '{print \$1}'"
alias ips="hostname -I"

# =============================================================================
# Development Shortcuts
# =============================================================================

# Quick directory access
alias dev="cd ~/Developer"
alias cde="cd ~/code"
alias docs="cd ~/Documents"
alias downloads="cd ~/Downloads"

# Quick server start
alias serve="python3 -m http.server 8000"

# =============================================================================
# Text Processing
# =============================================================================

# Text manipulation
alias count="wc -l"
alias trim="awk '{\$1=\$1};1'"

# JSON formatting
if command -v jq >/dev/null 2>&1; then
    alias json-format="jq ."
    alias json-compact="jq -c ."
fi

# URL encoding/decoding
urlencode() {
    python3 -c "import urllib.parse; print(urllib.parse.quote('$1'))"
}

urldecode() {
    python3 -c "import urllib.parse; print(urllib.parse.unquote('$1'))"
}

# =============================================================================
# Archive Operations
# =============================================================================

# Extract function for various archive formats
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz) tar xzf "$1" ;;
            *.bz2) bunzip2 "$1" ;;
            *.rar) unrar x "$1" ;;
            *.gz) gunzip "$1" ;;
            *.tar) tar xf "$1" ;;
            *.tbz2) tar xjf "$1" ;;
            *.tgz) tar xzf "$1" ;;
            *.zip) unzip "$1" ;;
            *.Z) uncompress "$1" ;;
            *.7z) 7z x "$1" ;;
            *.xz) unxz "$1" ;;
            *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Create archives
mktar() { tar czf "${1%%/}.tar.gz" "${1%%/}/"; }
mkzip() { zip -r "${1%%/}.zip" "$1"; }

# =============================================================================
# Time and Date
# =============================================================================

# Date shortcuts
alias now="date +'%Y-%m-%d %H:%M:%S'"
alias nowutc="date -u +'%Y-%m-%d %H:%M:%S UTC'"
alias timestamp="date +%s"
alias week="date +%V"

# Stopwatch function
stopwatch() {
    local start=$(date +%s)
    echo "Stopwatch started. Press any key to stop..."
    read -n 1
    local end=$(date +%s)
    local duration=$((end - start))
    echo "Elapsed time: ${duration}s"
}

# =============================================================================
# Quick Utilities
# =============================================================================

# Generate random password
genpass() {
    local length=${1:-16}
    openssl rand -base64 $((length * 3 / 4)) | tr -d '\n' | head -c $length; echo
}

# Generate UUID
uuid() {
    cat /proc/sys/kernel/random/uuid
}

# Weather function
weather() {
    local city=${1:-}
    if [[ -n "$city" ]]; then
        curl -s "wttr.in/$city?format=3"
    else
        curl -s "wttr.in/?format=3"
    fi
}

# QR code generator
qr() {
    local text="$1"
    if [[ -n "$text" ]]; then
        curl -s "qr-server.com/api/v1/create-qr-code/?size=200x200&data=$text"
    else
        echo "Usage: qr <text>"
    fi
}

# =============================================================================
# Productivity Functions
# =============================================================================

# Find and replace in files
# Usage: findreplace [-n] <find> <replace> [path]
#   -n  dry-run: show matching files and lines without modifying anything
findreplace() {
    local dry_run=0
    if [[ "$1" == "-n" || "$1" == "--dry-run" ]]; then
        dry_run=1
        shift
    fi

    local find_text="$1"
    local replace_text="$2"
    local search_path="${3:-.}"

    if [[ -z "$find_text" || -z "$replace_text" ]]; then
        echo "Usage: findreplace [-n|--dry-run] <find> <replace> [path]"
        return 1
    fi

    # Escape BRE special chars and the sed delimiter (/) in the find pattern
    local escaped_find
    escaped_find=$(printf '%s' "$find_text" | sed 's/[[\.*^$\/]/\\&/g')

    # Escape & \ and / in the replacement string
    local escaped_replace
    escaped_replace=$(printf '%s' "$replace_text" | sed 's/[&\/\\]/\\&/g')

    if (( dry_run )); then
        rg -l --fixed-strings "$find_text" "$search_path" | while IFS= read -r file; do
            echo "[dry-run] $file"
            rg -n --fixed-strings "$find_text" "$file"
        done
    else
        rg -l --fixed-strings "$find_text" "$search_path" \
            | xargs sed -i "s/$escaped_find/$escaped_replace/g"
    fi
}

# Backup function
backup() {
    local source="$1"
    local backup_name="${source}_backup_$(date +%Y%m%d_%H%M%S)"

    if [[ -e "$source" ]]; then
        cp -r "$source" "$backup_name"
        echo "Backup created: $backup_name"
    else
        echo "Source not found: $source"
    fi
}

# Quick note taking
note() {
    local note_dir="$HOME/notes"
    local note_file="$note_dir/$(date +%Y-%m-%d).md"

    mkdir -p "$note_dir"

    if [[ -n "$1" ]]; then
        echo "$(date +'%H:%M:%S'): $*" >> "$note_file"
    else
        nvim "$note_file"
    fi
}

# =============================================================================
# Cleanup Functions
# =============================================================================

# Clean system caches (Linux)
cleanup() {
    echo "This will clean:"
    echo "  apt cache            (requires sudo)"
    echo "  journal logs > 3d    (requires sudo)"
    echo "  ~/.cache/*"
    echo "  /tmp old files       (requires sudo)"
    echo ""
    printf "Proceed? [y/N] "
    read -r reply
    [[ "$reply" =~ ^[Yy]$ ]] || { echo "Aborted."; return 1; }

    sudo apt autoremove -y
    sudo apt autoclean

    sudo journalctl --vacuum-time=3d

    rm -rf ~/.cache/*

    sudo find /tmp -type f -atime +7 -delete 2>/dev/null

    echo "Cleanup complete."
}

# =============================================================================
# Reload Configurations
# =============================================================================

# Reload shell configuration
alias reload="exec zsh"
alias rl="reload"

# Edit configuration files
alias ezsh="nvim ~/.zshrc"

# Dotfiles sync
alias dotsync="$HOME/code/dotfiles/linux-edge/sync.sh"

alias parp='arp -a | awk '\''BEGIN { c[1]="\033[38;5;250m"; c[2]="\033[38;5;245m"; } { idx=(NR%2)+1; printf "%s%-30s %-20s %-17s\033[0m\n", c[idx], $1, $2, $4 }'\'''
