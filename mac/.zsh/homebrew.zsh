# =============================================================================
# Homebrew Configuration for macOS Apple Silicon
# =============================================================================

# Homebrew path for Apple Silicon Macs
export HOMEBREW_PREFIX="/opt/homebrew"

# Add Homebrew to PATH if it exists
if [[ -x "$HOMEBREW_PREFIX/bin/brew" ]]; then
    eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
    
    # Homebrew environment variables for better performance
    export HOMEBREW_NO_AUTO_UPDATE=1           # Don't auto-update during install
    export HOMEBREW_NO_INSTALL_CLEANUP=1       # Don't cleanup old versions automatically
    export HOMEBREW_NO_ANALYTICS=1             # Disable analytics
    export HOMEBREW_NO_INSECURE_REDIRECT=1     # Only use HTTPS
    export HOMEBREW_CASK_OPTS="--require-sha"  # Require SHA for casks
fi

# Add common homebrew binary locations to PATH
if [[ -d "$HOMEBREW_PREFIX/bin" ]]; then
    export PATH="$HOMEBREW_PREFIX/bin:$PATH"
fi

if [[ -d "$HOMEBREW_PREFIX/sbin" ]]; then
    export PATH="$HOMEBREW_PREFIX/sbin:$PATH"
fi

# Add completions for Homebrew (if zsh completions are installed)
if [[ -d "$HOMEBREW_PREFIX/share/zsh-completions" ]]; then
    FPATH="$HOMEBREW_PREFIX/share/zsh-completions:$FPATH"
fi

# Completion settings (compinit is called once in .zshrc)
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true

# Package manager shortcuts
alias brews="brew list"
alias brewu="brew update && brew upgrade"
alias brewc="brew cleanup"
alias brewd="brew doctor"