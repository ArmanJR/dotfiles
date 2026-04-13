# =============================================================================
# Editor and Terminal Configuration
# Neovim (LazyVim) and Terminal Tools
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
alias zshconfig="nvim ~/code/dotfiles/linux-server/.zsh"

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
# Clipboard Integration (Linux)
# =============================================================================

if command -v xclip >/dev/null 2>&1; then
    alias clip="xclip -selection clipboard"
    alias paste="xclip -selection clipboard -o"
fi

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

# Merge conflict resolution
alias gct="git checkout --theirs . && git add -A"
alias gcours="git checkout --ours . && git add -A"

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
    # fzf --zsh was added in 0.48.0; fall back to system files for older versions
    if fzf --zsh >/dev/null 2>&1; then
        source <(fzf --zsh)
    elif [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
        source /usr/share/doc/fzf/examples/key-bindings.zsh
        source /usr/share/doc/fzf/examples/completion.zsh 2>/dev/null
    fi

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

# Zoxide (better cd) - cached for faster startup
if command -v zoxide >/dev/null 2>&1; then
    if [[ ! -f ~/.zsh/cache/zoxide.zsh ]] || [[ $(which zoxide) -nt ~/.zsh/cache/zoxide.zsh ]]; then
        mkdir -p ~/.zsh/cache
        zoxide init zsh > ~/.zsh/cache/zoxide.zsh
    fi
    source ~/.zsh/cache/zoxide.zsh
fi
