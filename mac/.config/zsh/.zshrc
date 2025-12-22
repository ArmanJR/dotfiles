# Source the main zsh configuration from home directory
# This ensures all aliases, functions, and tools are loaded
if [[ -f "$HOME/.zshrc" ]]; then
  source "$HOME/.zshrc"
fi

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

. "$HOME/.local/share/../bin/env"


# bun completions
[ -s "/Users/arman/.bun/_bun" ] && source "/Users/arman/.bun/_bun"
export PATH=$PATH:$HOME/.maestro/bin

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"
