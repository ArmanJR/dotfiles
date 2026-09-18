# Keep non-interactive shells free of tool initialization and external commands.
# Let .zshrc run compinit -i; Ubuntu's global compinit can prompt without a TTY.
skip_global_compinit=1

typeset -U path
path=("$HOME/.local/bin" $path)
export PATH
