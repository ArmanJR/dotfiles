# =============================================================================
# Editor and Terminal Configuration
# Neovim (LazyVim), VSCode, and Terminal Tools
# =============================================================================

# =============================================================================
# Neovim Configuration
# =============================================================================

# Neovim aliases
alias v="nvim"
alias vi="nvim"
alias vim="nvim"
alias nv="nvim"

# LazyVim specific aliases
alias lv="nvim"
alias lvim="nvim"

# Neovim functions
nvim-config() {
    nvim "$HOME/.config/nvim"
}

nvim-update() {
    echo "Updating Neovim plugins..."
    nvim --headless -c "autocmd User LazyUpdate quitall" -c "Lazy! update"
}

nvim-health() {
    nvim -c "checkhealth"
}

# Quick edit configuration files
alias nvimrc="nvim ~/.config/nvim/init.lua"
alias zshrc="nvim ~/.zshrc"
alias zshconfig="nvim ~/code/dotfiles/mac/.zsh"

# =============================================================================
# VSCode Configuration
# =============================================================================

# VSCode aliases (if installed)
if command -v code >/dev/null 2>&1; then
    alias co="code"

    # VSCode functions
    code-extensions() {
        code --list-extensions --show-versions
    }

    code-install-ext() {
        if [[ -n "$1" ]]; then
            code --install-extension "$1"
        else
            echo "Usage: code-install-ext <extension-id>"
        fi
    }

    code-settings() {
        code "$HOME/Library/Application Support/Code/User/settings.json"
    }

    code-keybindings() {
        code "$HOME/Library/Application Support/Code/User/keybindings.json"
    }
fi

# =============================================================================
# Font and Color Configuration
# =============================================================================

# JetBrains Mono Nerd Font configuration
export FONT_NAME="JetBrainsMono Nerd Font"

# Color schemes for terminal tools
export BAT_THEME="TwoDark"  # bat (cat replacement)
export DELTA_PAGER="less -R"  # git delta pager
export MANPAGER="sh -c 'col -bx | bat -l man -p'"  # colored man pages

# =============================================================================
# File Managers and Navigation
# =============================================================================

# Modern replacements for common tools
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

# catc (copy into clipboard with the filename)
catc() {
    if [ -z "$1" ]; then
        echo "Usage: catc <filename>"
        return 1
    fi

    if [ ! -f "$1" ]; then
        echo "Error: File '$1' not found"
        return 1
    fi

    {
        echo "$ cat $1"
        cat "$1"
    } | pbcopy
}

# catingest (runs gitingest then copy into clipboard)
catingest() {
    echo "🔄 Running gitingest on current directory with common ignore patterns..."

    # Define common ignore patterns
    local patterns=(
        # OS files
        "*.log" "logs/" "*.tmp" "*.temp" "tmp/" "temp/"
        ".DS_Store" "Thumbs.db" ".AppleDouble" ".LSOverride"
        "ehthumbs.db" "Desktop.ini" "\$RECYCLE.BIN/" ".directory"

        # Editor/IDE
        ".vscode/" ".idea/" "*.swp" "*.swo" "*~" "*.iml" "*.iws"
        "*.sublime-project" "*.sublime-workspace" ".atom/"
        "*.elc" ".emacs.desktop" ".emacs.desktop.lock" "*.code-workspace"

        # Environment & config
        ".env" ".env.local" ".env.*.local" ".local"
        "config.local.*" "settings.local.*"

        # Dependencies & build
        "node_modules/" "vendor/" "packages/"
        "build/" "dist/" "out/" "target/"

        # Cache & coverage
        "coverage/" "*.coverage" ".cache/" "*.cache" ".sass-cache/"

        # Backup & temporary
        "*.bak" "*.backup" "*.old"

        # Security
        "*.key" "*.pem" "*.p12" "*.pfx" "*.crt" "*.cer" "*.der"

        # Database
        "*.sqlite" "*.sqlite3" "*.db"

        # Generated docs
        "docs/_build/" "site/"

        # Runtime
        "pids/" "*.pid" "*.seed"
    )

    local exclude_patterns=$(IFS=','; echo "${patterns[*]}")

    if gitingest ./ --exclude-pattern "$exclude_patterns"; then
        if [[ -f "digest.txt" ]]; then
            cat digest.txt | pbcopy
            rm digest.txt
        else
            echo "❌ Error: digest.txt was not created"
            return 1
        fi
    else
        echo "❌ Error: gitingest command failed"
        return 1
    fi
}

# =============================================================================
# Git Integration
# =============================================================================

# Git aliases for better workflow
alias g="git"
alias ga="git add"
alias gaa="git add ."
alias gc="git commit"
alias gcm="git commit -m"
alias gca="git commit -am"
alias gp="git push"
alias gpl="git pull"
alias gs="git status"
alias gd="git diff"
alias gdc="git diff --cached"
alias gl="git log --oneline --graph"
alias gla="git log --oneline --graph --all"
alias gb="git branch"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gm="git merge"
alias gr="git rebase"
alias gst="git stash"
alias gstp="git stash pop"

# Git functions
git-clean-branches() {
    echo "Cleaning up merged branches..."
    git branch --merged main | grep -v "main\|master" | xargs -n 1 git branch -d
    echo "Cleaned up merged branches!"
}

git-recent-branches() {
    git for-each-ref --count=10 --sort=-committerdate refs/heads/ --format="%(refname:short)"
}

# =============================================================================
# Productivity Tools
# =============================================================================

# FZF (fuzzy finder) configuration
if command -v fzf >/dev/null 2>&1; then
    # FZF configuration
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --margin=1"
    export FZF_DEFAULT_COMMAND="fd --type f --strip-cwd-prefix --hidden --follow --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fd --type d --strip-cwd-prefix --hidden --follow --exclude .git"

    # FZF key bindings and completion
    source <(fzf --zsh)

    # Custom FZF functions
    fzf-cd() {
        local dir
        dir=$(fd --type d --strip-cwd-prefix --hidden --follow --exclude .git | fzf +m) && cd "$dir"
    }

    fzf-edit() {
        local file
        file=$(fd --type f --strip-cwd-prefix --hidden --follow --exclude .git | fzf +m) && nvim "$file"
    }

    fzf-git-branch() {
        local branch
        branch=$(git branch --all | grep -v HEAD | sed "s/^[[:space:]]*\*[[:space:]]*//" | sed "s/remotes\/origin\///" | sort -u | fzf +m) && git checkout "$branch"
    }

    # FZF aliases
    alias cdf="fzf-cd"
    alias vf="fzf-edit"
    alias gbf="fzf-git-branch"
fi

# Zoxide (better cd)
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# =============================================================================
# Copy/Paste Integration (macOS)
# =============================================================================

# pbcopy/pbpaste aliases and functions
alias clip="pbcopy"
alias paste="pbpaste"

# Copy current directory path
alias pwd-copy="pwd | pbcopy"

# Copy file contents
copy-file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        pbcopy < "$file"
        echo "File contents copied to clipboard: $file"
    else
        echo "File not found: $file"
    fi
}

# Paste to file
paste-file() {
    local file="$1"
    if [[ -n "$file" ]]; then
        pbpaste > "$file"
        echo "Clipboard contents pasted to: $file"
    else
        echo "Usage: paste-file <filename>"
    fi
}
