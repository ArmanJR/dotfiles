# =============================================================================
# Package Manager Configuration for Linux (apt)
# =============================================================================

# Add local bin to PATH
if [[ -d "$HOME/.local/bin" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# =============================================================================
# Completion Settings
# =============================================================================

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true

# =============================================================================
# APT Aliases
# =============================================================================

alias apti="sudo apt install"
alias aptu="sudo apt update && sudo apt upgrade -y"
alias apts="apt search"
alias aptr="sudo apt remove"
alias aptl="apt list --installed"
alias aptc="sudo apt autoremove -y && sudo apt autoclean"
alias aptf="apt show"
