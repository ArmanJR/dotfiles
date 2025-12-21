# =============================================================================
# Shell History Tools Configuration
# =============================================================================

# Add atuin to PATH
if [[ -f "$HOME/.atuin/bin/env" ]]; then
    source "$HOME/.atuin/bin/env"
fi

# Initialize atuin
if command -v atuin &> /dev/null; then
    eval "$(atuin init zsh)"
fi
