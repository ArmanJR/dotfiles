#!/usr/bin/env zsh
# ===========================================================
#                    Enhanced Zsh Configuration
#                    Last Updated: 2025
# ===========================================================

# -----------------------------------------------------------
# Performance Profiling (uncomment to debug slow startup)
# -----------------------------------------------------------
# zmodload zsh/zprof

# ===========================================================
#                    Environment Variables
# ===========================================================

# Path configuration (deduplicated)
typeset -U path PATH
path=(
  $HOME/.local/bin
  $HOME/bin
  $HOME/.cargo/bin
  $HOME/.go/bin
  $HOME/.npm-global/bin
  $HOME/.poetry/bin
  /usr/local/bin
  /usr/local/sbin
  $path
)
export PATH

# Core environment
export EDITOR="${EDITOR:-nvim}"
export VISUAL="$EDITOR"
export PAGER="${PAGER:-less}"
export BROWSER="${BROWSER:-firefox}"
export TERMINAL="${TERMINAL:-alacritty}"

# Locale settings
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
export LC_CTYPE="${LC_CTYPE:-en_US.UTF-8}"

# XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Development environments
export PROJECTS_DIR="${PROJECTS_DIR:-$HOME/projects}"
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
export NOTES_DIR="${NOTES_DIR:-$HOME/notes}"

# Less configuration (better pager experience)
export LESS="-R -F -X -i -P ?f%f:(stdin). ?lb%lb?L/%L.. [?eEOF:?pb%pb\%..]"
export LESSCHARSET="utf-8"
export LESSHISTFILE="${XDG_CACHE_HOME}/less/history"

# Man pages with color
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
export LESS_TERMCAP_me=$'\E[0m'        # reset
export LESS_TERMCAP_so=$'\E[01;33m'    # begin standout
export LESS_TERMCAP_se=$'\E[0m'        # reset standout
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

# ===========================================================
#                    History Configuration
# ===========================================================

HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=50000
SAVEHIST=50000

# History options
setopt EXTENDED_HISTORY          # Write timestamp to history
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first
setopt HIST_IGNORE_DUPS          # Don't record duplicates
setopt HIST_IGNORE_ALL_DUPS      # Delete old duplicate
setopt HIST_FIND_NO_DUPS         # Don't display duplicates
setopt HIST_IGNORE_SPACE         # Don't record lines starting with space
setopt HIST_SAVE_NO_DUPS         # Don't write duplicates to file
setopt HIST_REDUCE_BLANKS        # Remove extra blanks
setopt HIST_VERIFY               # Show command before executing from history
setopt INC_APPEND_HISTORY        # Add commands immediately
setopt SHARE_HISTORY             # Share history between sessions

# ===========================================================
#                    Zsh Options
# ===========================================================

# Directory navigation
setopt AUTO_CD                   # cd without typing cd
setopt AUTO_PUSHD                # Push directories onto stack
setopt PUSHD_IGNORE_DUPS         # Don't push duplicates
setopt PUSHD_SILENT              # Don't print directory stack
setopt PUSHD_TO_HOME             # pushd with no args goes home
setopt CDABLE_VARS              # cd to variable values
setopt MULTIOS                   # Multiple redirections

# Completion
setopt ALWAYS_TO_END             # Move cursor to end after completion
setopt AUTO_MENU                 # Show menu after second tab
setopt AUTO_PARAM_SLASH          # Add slash after directory
setopt COMPLETE_IN_WORD          # Complete from cursor position
setopt MENU_COMPLETE             # Cycle through completions
setopt LIST_AMBIGUOUS            # List ambiguous completions
setopt LIST_PACKED               # Compact completion list

# Job control
setopt AUTO_RESUME               # Resume jobs by name
setopt NOTIFY                    # Report job status immediately
setopt LONG_LIST_JOBS            # List jobs in long format
setopt CHECK_JOBS                # Check jobs before exiting

# Other useful options
setopt INTERACTIVE_COMMENTS      # Allow comments in shell
setopt CORRECT                   # Spelling correction for commands
setopt CORRECT_ALL               # Spelling correction for arguments
setopt NO_BEEP                   # No beeping
setopt EXTENDED_GLOB             # Extended globbing
setopt NUMERIC_GLOB_SORT         # Sort numeric filenames numerically
setopt RC_QUOTES                 # Allow 'Henry''s Garage'

# ===========================================================
#                    Oh My Zsh Configuration
# ===========================================================

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="essembeh"  # Consider: powerlevel10k, starship

# Plugin configuration
plugins=(
  git
  git-extras
  github
  gitignore
  docker
  docker-compose
  kubectl
  terraform
  aws
  gcloud
  npm
  yarn
  python
  pip
  golang
  rust
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
  zsh-completions
  fzf
  colored-man-pages
  command-not-found
  extract
  sudo
  web-search
  jsontools
  encode64
)

# Oh My Zsh settings
DISABLE_MAGIC_FUNCTIONS=true     # Fix paste issues
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=50

# Load Oh My Zsh
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# ===========================================================
#                    Completion System
# ===========================================================

# Initialize completion system
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qNmh+24) ]]; then
  compinit
else
  compinit -C
fi

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"

# ===========================================================
#                    Key Bindings
# ===========================================================

# Use emacs key bindings
bindkey -e

# Common key bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^F' autosuggest-accept
bindkey '^E' autosuggest-execute
bindkey '^[[1;5C' forward-word       # Ctrl+Right
bindkey '^[[1;5D' backward-word      # Ctrl+Left
bindkey '^[[3~' delete-char          # Delete key
bindkey '^U' backward-kill-line      # Ctrl+U
bindkey '^K' kill-line               # Ctrl+K
bindkey '^W' backward-kill-word      # Ctrl+W
bindkey '^R' history-incremental-search-backward

# ===========================================================
#                    Aliases - Core
# ===========================================================

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

# Enhanced ls
alias ls='ls --color=auto --group-directories-first'
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -alFht'  # Sort by time
alias lS='ls -alFhS'  # Sort by size
alias lr='ls -R'      # Recursive

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# Clear and reload
alias cls='clear'
alias reload='exec $SHELL -l'
alias path='echo -e ${PATH//:/\\n}'

# System monitoring
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias top='htop || top'
alias ps='ps auxf'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'

# Network
alias ports='netstat -tulanp'
alias listening='lsof -P -i -n'
alias ipinfo='curl -s ipinfo.io | jq .'
alias myip='curl -s ifconfig.me'
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'

# ===========================================================
#                    Aliases - Development
# ===========================================================

# Git (beyond oh-my-zsh)
alias gs='git status -sb'
alias gd='git diff'
alias gdc='git diff --cached'
alias gl='git log --oneline --graph --decorate -20'
alias gla='git log --oneline --graph --decorate --all -20'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gundo='git reset --soft HEAD~1'
alias gclean='git clean -fd'
alias gbranches='git for-each-ref --sort=-committerdate refs/heads/ --format="%(refname:short)|%(committerdate:relative)|%(authorname)" | column -t -s "|"'

# Docker
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpsa='docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dimg='docker images'
alias dexec='docker exec -it'
alias dlogs='docker logs -f'
alias dprune='docker system prune -af'
alias dstop='docker stop $(docker ps -q)'
alias drm='docker rm $(docker ps -aq)'
alias drmi='docker rmi $(docker images -q)'

# Python
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
alias vactivate='source .venv/bin/activate 2>/dev/null || source venv/bin/activate'
alias vdeactivate='deactivate'
alias pipreq='pip freeze > requirements.txt'
alias pipinstall='pip install -r requirements.txt'
alias jupyter='jupyter lab'

# Node.js
alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install -g'
alias ns='npm start'
alias nt='npm test'
alias nr='npm run'
alias nrb='npm run build'
alias nrd='npm run dev'

# Yarn
alias yi='yarn install'
alias ya='yarn add'
alias yad='yarn add --dev'
alias yr='yarn run'
alias ys='yarn start'
alias yt='yarn test'
alias yb='yarn build'

# Claude
alias claude="${CLAUDE_PATH:-$HOME/.claude/local/claude}"
alias vibe="claude --dangerously-skip-permissions"

# Kubernetes
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kaf='kubectl apply -f'
alias kdel='kubectl delete'
alias klog='kubectl logs -f'
alias kexec='kubectl exec -it'
alias kctx='kubectl config current-context'

# Terraform
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfv='terraform validate'
alias tff='terraform fmt -recursive'

# ===========================================================
#                    Functions - Utilities
# ===========================================================

# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract any archive
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)           echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Find in files
fif() {
  if [ ! "$#" -gt 0 ]; then
    echo "Usage: fif <search_term>"
    return 1
  fi
  rg --files-with-matches --no-messages "$1" | fzf --preview "rg --ignore-case --pretty --context 10 '$1' {}"
}

# Quick backup
backup() {
  cp -r "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
}

# Weather
weather() {
  curl -s "wttr.in/${1:-$(curl -s ipinfo.io/city)}"
}

# Cheatsheet
cheat() {
  curl -s "cheat.sh/$1"
}

# ===========================================================
#                    Functions - Development
# ===========================================================

# Project navigation
proj() {
  local proj_dir="${PROJECTS_DIR:-$HOME/projects}"
  if [[ -z "$1" ]]; then
    cd "$proj_dir" || return
  elif [[ -d "$proj_dir/$1" ]]; then
    cd "$proj_dir/$1" || return
  else
    echo "Project '$1' not found in $proj_dir"
    echo "Available projects:"
    ls -1 "$proj_dir" 2>/dev/null | sed 's/^/  - /'
  fi
}

# Git worktree helper
# gwt() {
#   case "$1" in
#     add)
#       if [[ -z "$2" || -z "$3" ]]; then
#         echo "Usage: gwt add <branch> <path>"
#         return 1
#       fi
#       git worktree add "$3" "$2"
#       ;;
#     list|ls)
#       git worktree list
#       ;;
#     remove|rm)
#       if [[ -z "$2" ]]; then
#         echo "Usage: gwt remove <path>"
#         return 1
#       fi
#       git worktree remove "$2"
#       ;;
#     *)
#       echo "Usage: gwt {add|list|remove} [args]"
#       ;;
#   esac
# }

# Docker cleanup
docker-cleanup() {
  echo "Cleaning up Docker..."
  docker stop $(docker ps -aq) 2>/dev/null
  docker rm $(docker ps -aq) 2>/dev/null
  docker rmi $(docker images -qf "dangling=true") 2>/dev/null
  docker volume rm $(docker volume ls -qf dangling=true) 2>/dev/null
  docker network rm $(docker network ls -q) 2>/dev/null
  docker system prune -af --volumes
  echo "Docker cleanup complete!"
}

# Python virtual environment with auto-activation
venv-init() {
  local venv_name="${1:-.venv}"
  python3 -m venv "$venv_name" && \
  source "$venv_name/bin/activate" && \
  pip install --upgrade pip setuptools wheel
}

# Quick HTTP server
serve() {
  local port="${1:-8000}"
  python3 -m http.server "$port"
}

# JSON pretty print
json() {
  if [[ -t 0 ]]; then
    python3 -m json.tool <<< "$*"
  else
    python3 -m json.tool
  fi
}

# URL encode/decode
urlencode() {
  python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))" "$1"
}

urldecode() {
  python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))" "$1"
}

# ===========================================================
#                    FZF Configuration
# ===========================================================

if command -v fzf >/dev/null 2>&1; then
  # FZF settings
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
  export FZF_DEFAULT_OPTS='
    --height 40%
    --layout=reverse
    --border
    --inline-info
    --color=dark
    --color=fg:#c0c5ce,bg:#212733,hl:#5e81ac
    --color=fg+:#c0c5ce,bg+:#3b4252,hl+:#5e81ac
    --color=info:#4c566a,prompt:#5e81ac,pointer:#bf616a
    --color=marker:#bf616a,spinner:#4c566a,header:#4c566a
    --bind="ctrl-d:preview-down,ctrl-u:preview-up"
  '
  
  # Load FZF key bindings
  [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
  
  # FZF functions
  # Find and edit file
  fe() {
    local file
    file=$(fzf --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}' --preview-window=right:60%)
    [[ -n "$file" ]] && ${EDITOR:-vim} "$file"
  }
  
  # Find and cd to directory
  fd() {
    local dir
    dir=$(find ${1:-.} -type d 2>/dev/null | fzf +m)
    [[ -n "$dir" ]] && cd "$dir"
  }
  
  # Git branch selector
  fbr() {
    local branches branch
    branches=$(git branch --all | grep -v HEAD) &&
    branch=$(echo "$branches" | fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
  }
  
  # Kill process
  fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    if [ "x$pid" != "x" ]; then
      echo "$pid" | xargs kill -${1:-9}
    fi
  }
fi

# ===========================================================
#                    Language-specific Settings
# ===========================================================

# Node.js - NVM
export NVM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use  # Lazy load
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Lazy load NVM
nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm "$@"
}

# Python - Pyenv
if command -v pyenv >/dev/null 2>&1; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

# Go
export GOPATH="${GOPATH:-$HOME/.go}"
export GOBIN="${GOBIN:-$GOPATH/bin}"
export PATH="$GOBIN:$PATH"

# Rust
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Ruby - RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# Java
export JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/default}"
export PATH="$JAVA_HOME/bin:$PATH"

# ===========================================================
#                    Tool Integrations
# ===========================================================

# Starship prompt (alternative to Oh My Zsh themes)
# command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# Zoxide (better cd)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# Direnv
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# Thefuck
command -v thefuck >/dev/null 2>&1 && eval "$(thefuck --alias)"

# Autojump
#if command -v autojump >/dev/null 2>&1; then
#  [[ -s /usr/share/autojump/autojump.sh ]] && source /usr/share/autojump/autojump.sh
#  [[ -s /usr/share/autojump/autojump.zsh ]] && source /usr/share/autojump/autojump.zsh
#  [[ -s /opt/homebrew/etc/profile.d/autojump.sh ]] && source /opt/homebrew/etc/profile.d/autojump.sh
#fi

# AWS CLI completion
[[ -f /usr/local/bin/aws_zsh_completer.sh ]] && source /usr/local/bin/aws_zsh_completer.sh

# Google Cloud SDK
if [[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]]; then
  source "$HOME/google-cloud-sdk/path.zsh.inc"
  source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

# ===========================================================
#                    Platform-specific Settings
# ===========================================================

case "$OSTYPE" in
  darwin*)
    # macOS specific
    export BROWSER="open"
    export CLICOLOR=1
    export LSCOLORS=GxFxCxDxBxegedabagaced
    
    # Homebrew
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    # macOS aliases
    alias ls="ls -G"
    alias finder="open -a Finder"
    alias preview="open -a Preview"
    alias flushdns="sudo dscacheutil -flushcache"
    ;;
    
  linux*)
    # Linux specific
    export BROWSER="xdg-open"
    
    # Linux aliases
    alias ls="ls --color=auto"
    alias open="xdg-open"
    alias pbcopy="xclip -selection clipboard"
    alias pbpaste="xclip -selection clipboard -o"
    
    # System update aliases
    if command -v apt >/dev/null 2>&1; then
      alias update="sudo apt update && sudo apt upgrade"
      alias install="sudo apt install"
    elif command -v pacman >/dev/null 2>&1; then
      alias update="sudo pacman -Syu"
      alias install="sudo pacman -S"
    elif command -v dnf >/dev/null 2>&1; then
      alias update="sudo dnf update"
      alias install="sudo dnf install"
    fi
    ;;
esac

# ===========================================================
#                    Local Configuration
# ===========================================================

# Load local config if exists (for machine-specific settings)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Load private/secret environment variables
[[ -f ~/.secrets ]] && source ~/.secrets

# ===========================================================
#                    Auto-activate Virtual Environments
# ===========================================================

# Auto-activate Python virtual environments
auto_activate_venv() {
  if [[ -f ".venv/bin/activate" ]]; then
    source .venv/bin/activate
  elif [[ -f "venv/bin/activate" ]]; then
    source venv/bin/activate
  elif [[ -f ".env" ]]; then
    set -a
    source .env
    set +a
  fi
}

# Hook into directory changes
autoload -U add-zsh-hook
add-zsh-hook chpwd auto_activate_venv

# ===========================================================
#                    Performance Optimization
# ===========================================================

# Compile zsh files for faster loading
if [[ ! -f ~/.zshrc.zwc || ~/.zshrc -nt ~/.zshrc.zwc ]]; then
  zcompile ~/.zshrc
fi

# Cleanup duplicate PATH entries
typeset -U PATH path

# ===========================================================
#                    Welcome Message
# ===========================================================

# Only show in interactive shells
if [[ $- == *i* ]] && [[ -z "$INSIDE_EMACS" ]]; then
  
  # Color definitions
  local -A colors
  colors[reset]='\033[0m'
  colors[bold]='\033[1m'
  colors[dim]='\033[2m'
  colors[blue]='\033[34m'
  colors[cyan]='\033[36m'
  colors[green]='\033[32m'
  colors[yellow]='\033[33m'
  colors[magenta]='\033[35m'
  colors[red]='\033[31m'
  colors[white]='\033[37m'
  
  # System info gathering
  local hostname=$(hostname -s)
  local kernel=$(uname -sr)
  local shell_info="Zsh $ZSH_VERSION"
  local current_time=$(date '+%H:%M:%S')
  local current_date=$(date '+%A, %B %d %Y')
  local uptime_info=""
  
  # Get uptime (cross-platform)
  if command -v uptime >/dev/null 2>&1; then
    uptime_info=$(uptime | sed 's/.*up \([^,]*\).*/\1/')
  fi
  
  # Get current directory info
  local pwd_info=$(pwd)
  local git_branch=""
  if git rev-parse --git-dir >/dev/null 2>&1; then
    git_branch=" ($(git branch --show-current 2>/dev/null || echo 'detached'))"
  fi
  
  # Try modern info tools first, fallback to custom
  if command -v fastfetch >/dev/null 2>&1; then
    fastfetch --config none --logo none --structure "Title:OS:Kernel:Uptime:Shell:Terminal:CPU:Memory:Disk (/):LocalIP:Users:Date" 2>/dev/null
  elif command -v neofetch >/dev/null 2>&1; then
    neofetch --off --disable gpu theme icons --stdout 2>/dev/null | head -10
  else
    # Custom welcome message
    echo
    printf "${colors[green]}${colors[bold]}🚀 Welcome back, ${colors[yellow]}$USER${colors[green]}!${colors[reset]}\n"
    echo
    
    # System information in a nice format
    printf "${colors[dim]}┌── System Information ──────────────────────────────────┐${colors[reset]}\n"
    printf "${colors[dim]}│${colors[reset]} ${colors[blue]}󰌢 Host:${colors[reset]}     ${colors[white]}$hostname${colors[reset]}\n"
    printf "${colors[dim]}│${colors[reset]} ${colors[blue]} Kernel:${colors[reset]}   ${colors[white]}$kernel${colors[reset]}\n"
    printf "${colors[dim]}│${colors[reset]} ${colors[blue]} Shell:${colors[reset]}    ${colors[white]}$shell_info${colors[reset]}\n"
    
    if [[ -n "$uptime_info" ]]; then
      printf "${colors[dim]}│${colors[reset]} ${colors[blue]}󰅐 Uptime:${colors[reset]}   ${colors[white]}$uptime_info${colors[reset]}\n"
    fi
    
    printf "${colors[dim]}│${colors[reset]} ${colors[blue]}󰃭 Time:${colors[reset]}     ${colors[white]}$current_time${colors[reset]}\n"
    printf "${colors[dim]}│${colors[reset]} ${colors[blue]}󰸗 Date:${colors[reset]}     ${colors[white]}$current_date${colors[reset]}\n"
    printf "${colors[dim]}└────────────────────────────────────────────────────────┘${colors[reset]}\n"
    
    echo
    
    # Current location
    printf "${colors[magenta]}📍 Current Location:${colors[reset]} ${colors[cyan]}$pwd_info${colors[yellow]}$git_branch${colors[reset]}\n"
    
    # Quick tips
    echo
    printf "${colors[dim]}💡 Quick tips: Use 'proj <name>' to navigate projects, 'fe' to find files, 'fbr' for git branches${colors[reset]}\n"
    
    echo
  fi
fi

# ===========================================================
#                    End of Configuration
# ===========================================================

# Performance profiling result (uncomment if profiling enabled)
# zprof
