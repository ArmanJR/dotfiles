# =============================================================================
# Zsh Plugin Loader
# Sources standalone plugins cloned by bootstrap.sh
# Must be loaded last in .zshrc (zsh-syntax-highlighting requirement)
# =============================================================================

ZSH_PLUGIN_DIR="$HOME/.zsh/plugins"

# Autosuggestions (fish-like suggestions)
[[ -f "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
    source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Syntax highlighting (must be sourced last)
[[ -f "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
    source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
