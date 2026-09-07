# Lightweight interactive Zsh for Raspberry Pi and other single-board computers.
[[ -o interactive ]] || return

export EDITOR="${EDITOR:-vi}"
export VISUAL="${VISUAL:-$EDITOR}"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=5000
SAVEHIST=5000
setopt EXTENDED_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST HIST_REDUCE_BLANKS HIST_VERIFY
setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
setopt AUTO_MENU COMPLETE_IN_WORD ALWAYS_TO_END INTERACTIVE_COMMENTS

# Standard completion with a cached dump; ignore insecure completion directories
# without prompting. No third-party completion directories are added.
autoload -Uz compinit
compinit -i
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

bindkey -e
bindkey '^?' backward-delete-char
bindkey '^H' backward-delete-char
bindkey '^R' history-incremental-search-backward
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward
bindkey '^[[1;3C' forward-word
bindkey '^[[1;3D' backward-word

# Zsh expands these escapes itself: no subprocesses, VCS queries, or hooks.
unsetopt PROMPT_SUBST
PROMPT='%n@%m:%~ %(?.%#.%F{red}%?%f %#) '
RPROMPT=''

alias l='ls -lh'
alias ll='ls -lh'
alias la='ls -lah'
alias ..='cd ..'
alias ...='cd ../..'
alias -- -='cd -'
alias cde='cd ~/code'
alias g='git'
alias gs='git status --short'
alias gd='git diff'
alias gl='git log --oneline -20'
alias tf='tail -f'
alias reload='exec zsh'
alias dotsync='bash "$HOME/code/dotfiles/linux-edge/sbc/sync.sh"'

# Opt in explicitly; legacy ~/.zshrc.local and ~/.zsh modules stay unloaded.
if [[ -r "$HOME/.zshrc.sbc.local" ]]; then
    source "$HOME/.zshrc.sbc.local"
fi
