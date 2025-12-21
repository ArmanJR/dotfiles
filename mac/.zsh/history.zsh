# =============================================================================
# Shell History Tools Configuration
# =============================================================================

# Add atuin to PATH
if [[ -f "$HOME/.atuin/bin/env" ]]; then
    source "$HOME/.atuin/bin/env"
fi

# Initialize atuin (cached for faster startup)
if command -v atuin &> /dev/null; then
    if [[ ! -f ~/.zsh/cache/atuin.zsh ]] || [[ $(which atuin) -nt ~/.zsh/cache/atuin.zsh ]]; then
        mkdir -p ~/.zsh/cache
        atuin init zsh > ~/.zsh/cache/atuin.zsh
    fi
    source ~/.zsh/cache/atuin.zsh
fi
