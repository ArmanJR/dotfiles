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

# Show/hide hidden files in Finder
alias showfiles="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hidefiles="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Quick file operations
alias h="head"
alias t="tail"
alias tf="tail -f"

# =============================================================================
# System Information
# =============================================================================

# System monitoring
alias cpu="top -o cpu"
alias mem="top -o mem"
alias df="df -h"
alias du="du -h"
alias free="vm_stat"

# Network information
alias ip="curl -s ifconfig.me"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# =============================================================================
# Development Shortcuts
# =============================================================================

# Quick directory access
alias dev="cd ~/Developer"
alias code="cd ~/code"
alias docs="cd ~/Documents"
alias downloads="cd ~/Downloads"
alias desktop="cd ~/Desktop"

# Quick server start
alias serve="python3 -m http.server 8000"
alias serve-php="php -S localhost:8000"

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
    uuidgen | tr '[:upper:]' '[:lower:]'
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
findreplace() {
    local find_text="$1"
    local replace_text="$2"
    local file_pattern="${3:-.}"

    if [[ -z "$find_text" || -z "$replace_text" ]]; then
        echo "Usage: findreplace <find> <replace> [file_pattern]"
        return 1
    fi

    if command -v rg >/dev/null 2>&1; then
        rg -l "$find_text" "$file_pattern" | xargs sed -i '' "s/$find_text/$replace_text/g"
    else
        grep -r -l "$find_text" "$file_pattern" | xargs sed -i '' "s/$find_text/$replace_text/g"
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

# Clean system caches
cleanup() {
    echo "Cleaning system caches..."

    # Clear system caches
    sudo rm -rf /System/Library/Caches/*
    sudo rm -rf /Library/Caches/*
    rm -rf ~/Library/Caches/*

    # Clear log files
    sudo rm -rf /var/log/*.log
    rm -rf ~/Library/Logs/*

    # Clean Homebrew
    if command -v brew >/dev/null 2>&1; then
        brew cleanup
        brew autoremove
    fi

    # Empty trash
    rm -rf ~/.Trash/*

    echo "System cleanup complete!"
}

# =============================================================================
# Reload Configurations
# =============================================================================

# Reload shell configuration
alias reload="source ~/.zshrc"
alias rl="reload"

# Edit configuration files
alias ezsh="nvim ~/.zshrc"

# Dotfiles sync
alias dotsync="$HOME/code/dotfiles/mac/sync.sh"

alias parp='arp -a | awk '\''BEGIN { c[1]="\033[38;5;250m"; c[2]="\033[38;5;245m"; } { idx=(NR%2)+1; printf "%s%-30s %-20s %-17s\033[0m\n", c[idx], $1, $2, $4 }'\'''
