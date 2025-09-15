# =============================================================================
# Programming Languages Configuration
# Python, Go, Node.js, and related tools
# =============================================================================

# =============================================================================
# Python Configuration
# =============================================================================

# Python environment variables
export PYTHONUNBUFFERED=1
export PYTHONDONTWRITEBYTECODE=1

# UV (modern Python package installer and resolver) - preferred over pip
if command -v uv >/dev/null 2>&1; then
    export UV_PYTHON_PREFERENCE=managed
    export UV_PYTHON_DOWNLOADS=automatic
    
    # UV completion
    if [[ ! -f ~/.zsh/completions/_uv ]]; then
        mkdir -p ~/.zsh/completions
        uv generate-shell-completion zsh > ~/.zsh/completions/_uv
    fi
    fpath=(~/.zsh/completions $fpath)
fi

# Pyenv configuration (Python version management)
if command -v pyenv >/dev/null 2>&1; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    
    # Pyenv virtualenv
    if [[ -f "$PYENV_ROOT/plugins/pyenv-virtualenv/bin/pyenv-virtualenv-init" ]]; then
        eval "$(pyenv virtualenv-init -)"
    fi
fi

# Poetry configuration (Python dependency management)
if [[ -d "$HOME/.local/share/pypoetry" ]]; then
    export PATH="$HOME/.local/share/pypoetry/venv/bin:$PATH"
fi

# Pipx path (for globally installed Python tools)
if [[ -d "$HOME/.local/bin" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Python aliases
alias py="python3"
#alias pip="python3 -m pip" # REMOVED - let pyenv manage pip
alias venv="python3 -m venv"
function activate() {
    unalias activate 2>/dev/null
    unalias deactivate 2>/dev/null

    if [ -f venv/bin/activate ]; then
        source venv/bin/activate
    elif [ -f .venv/bin/activate ]; then
        source .venv/bin/activate
    else
        echo "⚠️ No virtual environment found (expected venv/ or .venv/)."
    fi
}

# UV shortcuts
if command -v uv >/dev/null 2>&1; then
    alias uvr="uv run"
    alias uvi="uv init"
    alias uvs="uv sync"
    alias uva="uv add"
    alias uvd="uv remove"
    alias uvp="uv python install"
fi

# =============================================================================
# Go Configuration
# =============================================================================

# Go environment
if command -v go >/dev/null 2>&1; then
    export GOPATH="$HOME/go"
    export GOBIN="$GOPATH/bin"
    export PATH="$GOBIN:$PATH"
    
    # Go module proxy and checksum database
    export GOPROXY=https://proxy.golang.org,direct
    export GOSUMDB=sum.golang.org
    
    # Private module configuration (uncomment and adjust if needed)
    # export GOPRIVATE="github.com/yourorg/*,gitlab.com/yourorg/*"
fi

# Go version manager (g)
if [[ -d "$HOME/.g" ]]; then
    export GOROOT="$HOME/.g/go"
    export PATH="$HOME/.g/go/bin:$PATH"
fi

# Go aliases
alias gob="go build"
alias gor="go run"
alias got="go test"
alias gotv="go test -v"
alias goc="go clean"
alias goi="go install"
alias gom="go mod"
alias gomt="go mod tidy"

# =============================================================================
# Node.js Configuration
# =============================================================================

# Node Version Manager (fnm) - faster alternative to nvm
if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env --use-on-cd)"
fi

# NVM configuration (fallback if fnm not available)
if ! command -v fnm >/dev/null 2>&1 && [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    export NVM_DIR="$HOME/.nvm"
    source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
fi

# Yarn configuration
if command -v yarn >/dev/null 2>&1; then
    export PATH="$(yarn global bin):$PATH"
fi

# pnpm configuration
if [[ -d "$HOME/.local/share/pnpm" ]]; then
    export PNPM_HOME="$HOME/.local/share/pnpm"
    export PATH="$PNPM_HOME:$PATH"
fi

# Bun configuration
if [[ -d "$HOME/.bun" ]]; then
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
fi

# Node.js aliases
alias npmi="npm install"
alias npmu="npm update"
alias npms="npm start"
alias npmt="npm test"
alias npmr="npm run"
alias npx="npx --yes"

# Yarn aliases
alias yi="yarn install"
alias ya="yarn add"
alias yr="yarn remove"
alias ys="yarn start"
alias yt="yarn test"
alias yb="yarn build"

# pnpm aliases
alias pni="pnpm install"
alias pna="pnpm add"
alias pnr="pnpm remove"
alias pns="pnpm start"
alias pnt="pnpm test"
alias pnb="pnpm build"

# =============================================================================
# Jupyter Notebook Configuration
# =============================================================================

# Jupyter environment
if command -v jupyter >/dev/null 2>&1; then
    export JUPYTER_CONFIG_DIR="$HOME/.jupyter"
    export JUPYTER_DATA_DIR="$HOME/.local/share/jupyter"
fi

# Jupyter aliases
alias jl="jupyter lab"
alias jn="jupyter notebook"
alias jc="jupyter console"

# =============================================================================
# Language-agnostic Development Tools
# =============================================================================

# Mise (asdf alternative) for version management
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi

# direnv for directory-specific environment variables
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
fi
