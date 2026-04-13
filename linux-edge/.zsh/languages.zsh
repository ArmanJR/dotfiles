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

# Pyenv configuration (Python version management) - Lazy loaded
if [[ -d "$HOME/.pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"

    # Lazy load pyenv on first use
    pyenv() {
        unfunction pyenv
        eval "$(command pyenv init --path)"
        eval "$(command pyenv init -)"
        if [[ -f "$PYENV_ROOT/plugins/pyenv-virtualenv/bin/pyenv-virtualenv-init" ]]; then
            eval "$(pyenv virtualenv-init -)"
        fi
        pyenv "$@"
    }
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

# Venv
function activate() {
    unalias activate 2>/dev/null
    unalias deactivate 2>/dev/null

    if [ -f venv/bin/activate ]; then
        source venv/bin/activate
    elif [ -f .venv/bin/activate ]; then
        source .venv/bin/activate
    else
        echo "No venv found (expected venv/ or .venv/)."
    fi
}
alias venv="python3 -m venv"
alias venva="source venv/bin/activate || source .venv/bin/activate"
alias venvd="deactivate"

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

# Node Version Manager (fnm) - faster alternative to nvm, cached for faster startup
if command -v fnm >/dev/null 2>&1; then
    if [[ ! -f ~/.zsh/cache/fnm.zsh ]] || [[ $(which fnm) -nt ~/.zsh/cache/fnm.zsh ]]; then
        mkdir -p ~/.zsh/cache
        fnm env --use-on-cd > ~/.zsh/cache/fnm.zsh
    fi
    source ~/.zsh/cache/fnm.zsh
fi

# NVM configuration (fallback if fnm not available)
# Remove any conflicting aliases before potentially defining lazy-load functions
unalias nvm node npm npx 2>/dev/null

if ! command -v fnm >/dev/null 2>&1 && [[ -d "$HOME/.nvm" ]]; then
    export NVM_DIR="$HOME/.nvm"

    # Add default node to PATH immediately (avoids slow nvm.sh sourcing)
    # Resolve alias chain (e.g. default -> lts/* -> lts/iron -> v20.x.x)
    _nvm_default=$(cat "$NVM_DIR/alias/default" 2>/dev/null)
    # Follow alias indirections (up to 5 hops) until we get a plain version string
    local _hops=0
    while [[ -n "$_nvm_default" && "$_nvm_default" != v* && $_hops -lt 5 ]]; do
        _nvm_default=$(cat "$NVM_DIR/alias/${_nvm_default//\//_}" 2>/dev/null \
                       || cat "$NVM_DIR/alias/$_nvm_default" 2>/dev/null)
        (( _hops++ ))
    done
    if [[ "$_nvm_default" == v* ]]; then
        _nvm_dir=$(ls -d "$NVM_DIR/versions/node/${_nvm_default}"* 2>/dev/null | sort -V | tail -1)
        [[ -d "$_nvm_dir/bin" ]] && export PATH="$_nvm_dir/bin:$PATH"
    fi
    unset _nvm_default _nvm_dir _hops

    # Lazy load nvm command itself (for nvm use, nvm install, etc.)
    nvm() {
        unfunction nvm 2>/dev/null
        source "$NVM_DIR/nvm.sh"
        [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
        nvm "$@"
    }
fi

# Yarn configuration (guard against cmdtest's yarn on Debian/Ubuntu)
if command -v yarn >/dev/null 2>&1; then
    _yarn_bin=$(yarn global bin 2>/dev/null) && export PATH="$_yarn_bin:$PATH"
    unset _yarn_bin
fi

# pnpm configuration
if [[ -d "$HOME/.local/share/pnpm" ]]; then
    export PNPM_HOME="$HOME/.local/share/pnpm"
    export PATH="$PNPM_HOME:$PATH"
fi

# Node.js aliases
alias npmi="npm install"
alias npmu="npm update"
alias npms="npm start"
alias npmt="npm test"
alias npmr="npm run"
# npx alias only if not using nvm lazy-load (which defines npx as a function)
if ! typeset -f npx > /dev/null; then
    alias npx="npx --yes"
fi

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
# Rust Configuration
# =============================================================================

# Cargo binaries (env sourced in .zshenv, PATH additions here as fallback)
if [[ -d "$HOME/.cargo/bin" ]]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Rust aliases
alias cr="cargo run"
alias cb="cargo build"
alias ct="cargo test"
alias cck="cargo check"
alias cf="cargo fmt"
alias cl="cargo clippy"

# =============================================================================
# Language-agnostic Development Tools
# =============================================================================

# direnv for directory-specific environment variables
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
fi
