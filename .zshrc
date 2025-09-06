# ===========================================================
#                    Global Environment
# ===========================================================

# Path order: user bins first
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"

# Editor setup
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Locale (ensure proper encoding)
export LANG="${LANG:-en_US.UTF-8}"

# -----------------------------------------------------------
# History Settings
# -----------------------------------------------------------
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
setopt appendhistory          # append to history, don't overwrite
setopt incappendhistory       # write history incrementally
setopt sharehistory           # share history across terminals
setopt histignoredups         # ignore duplicates
setopt histignorespace        # ignore commands starting with space

# -----------------------------------------------------------
# Zsh Options
# -----------------------------------------------------------
setopt autocd                # cd without typing 'cd'
setopt autounset             # unset variables when empty
setopt correct               # spell correction for commands
setopt notify                # asynchronous job notifications
setopt interactivecomments   # allow comments in interactive shell

# ===========================================================
#                   Oh My Zsh Setup
# ===========================================================

export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="essembeh"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
  zsh-completions
  autojump
)

# Load Oh My Zsh
if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# -----------------------------------------------------------
# Plugin-specific keybindings or config
# -----------------------------------------------------------
bindkey '^F' autosuggest-accept  # Accept autosuggestions with Ctrl+F

# Interactive-only sources (avoid slowing scripts)
if [[ $- == *i* ]]; then
  # zsh-history-substring-search
  if [[ -f ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
    source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
  fi
fi

# ===========================================================
#                     Aliases & Functions
# ===========================================================

# Load external aliases file if exists
[ -f ~/.zsh/aliases.zsh ] && source ~/.zsh/aliases.zsh

# Example personal aliases
alias cls='clear'
alias ll='ls -lah --color=auto'
alias la='ls -A'
alias l='ls -CF'

# Python virtual environment helpers
alias venv-create="python3 -m venv .venv"
alias venv-activate="source .venv/bin/activate"

# Project navigation helper
cdp() {
  if [[ -d "$HOME/projects/$1" ]]; then
    cd "$HOME/projects/$1" || return
  else
    echo "Project '$1' not found in ~/projects"
  fi
}

# Claude aliases
alias claude="/home/$USER/.claude/local/claude"
alias vibe="claude --dangerously-skip-permissions"

# Git convenience functions
gco() { git checkout "$1"; }
gbr() { git branch "$1"; }

# ===========================================================
#                     Autojump Initialization
# ===========================================================
if command -v autojump >/dev/null 2>&1; then
  [[ -s /usr/share/autojump/autojump.sh ]] && source /usr/share/autojump/autojump.sh
  [[ -s /usr/share/autojump/autojump.zsh ]] && source /usr/share/autojump/autojump.zsh
fi

# ===========================================================
#                     Platform-specific tweaks
# ===========================================================

# macOS specific
if [[ "$OSTYPE" == "darwin"* ]]; then
  export BROWSER="open"
  alias ls="ls -G"           # macOS color
  export CLICOLOR=1
fi

# Linux specific
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  export BROWSER="xdg-open"
  alias ls="ls --color=auto"
fi

# ===========================================================
#                     Final Interactive Checks
# ===========================================================

# Load fzf keybindings if installed
if [[ -f ~/.fzf.zsh ]]; then
  source ~/.fzf.zsh
fi

# Prompt final message for interactive shells
if [[ $- == *i* ]]; then
  echo "Welcome, $USER! Zsh environment loaded."
fi
