# Keep non-interactive shells free of tool initialization and external commands.
typeset -U path
path=("$HOME/.local/bin" $path)
export PATH
