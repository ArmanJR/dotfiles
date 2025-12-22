# Source the main zprofile from home directory first
if [[ -f "$HOME/.zprofile" ]]; then
  source "$HOME/.zprofile"
fi

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
