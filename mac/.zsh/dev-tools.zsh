# =============================================================================
# Development Tools Configuration
# Docker, Kubernetes, and Container Development Tools
# =============================================================================

# =============================================================================
# Docker Configuration
# =============================================================================

# Docker environment variables
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Docker aliases
alias d="docker"
alias di="docker images"
alias dps="docker ps"
alias dpsa="docker ps -a"
alias drm="docker rm"
alias drmi="docker rmi"
alias drmf="docker rm -f"
alias drmif="docker rmi -f"
alias dsp="docker system prune"
alias dspf="docker system prune -f"
alias dspa="docker system prune -a"
alias dspaf="docker system prune -af"

# Docker Compose aliases
alias dc="docker compose"
alias dcu="docker compose up"
alias dcud="docker compose up -d"
alias dcd="docker compose down"
alias dcb="docker compose build"
alias dcl="docker compose logs"
alias dclf="docker compose logs -f"
alias dce="docker compose exec"
alias dcr="docker compose restart"
alias dcp="docker compose pull"
alias dcs="docker compose ps"

# Docker functions
docker-clean() {
    echo "Cleaning up Docker resources..."
    docker system prune -f
    docker volume prune -f
    docker network prune -f
    echo "Docker cleanup complete!"
}

docker-stop-all() {
    docker stop $(docker ps -q) 2>/dev/null || echo "No running containers to stop"
}

docker-remove-all() {
    docker-stop-all
    docker rm $(docker ps -aq) 2>/dev/null || echo "No containers to remove"
}

docker-logs() {
    local container="$1"
    if [[ -n "$container" ]]; then
        docker logs -f "$container"
    else
        echo "Usage: docker-logs <container-name-or-id>"
    fi
}

docker-shell() {
    local container="$1"
    local shell="${2:-bash}"
    if [[ -n "$container" ]]; then
        docker exec -it "$container" "$shell"
    else
        echo "Usage: docker-shell <container-name-or-id> [shell]"
    fi
}

# =============================================================================
# Kubernetes Configuration
# =============================================================================

# Kubectl completion and aliases
if command -v kubectl >/dev/null 2>&1; then
    source <(kubectl completion zsh)
    
    # Kubectl aliases
    alias k="kubectl"
    alias kg="kubectl get"
    alias kd="kubectl describe"
    alias ka="kubectl apply"
    alias kdel="kubectl delete"
    alias kl="kubectl logs"
    alias klf="kubectl logs -f"
    alias ke="kubectl exec"
    alias kei="kubectl exec -it"
    alias kp="kubectl port-forward"
    alias kc="kubectl config"
    alias kcc="kubectl config current-context"
    alias kcg="kubectl config get-contexts"
    alias kcu="kubectl config use-context"
    alias kns="kubectl config set-context --current --namespace"
    
    # Common resource aliases
    alias kgp="kubectl get pods"
    alias kgs="kubectl get services"
    alias kgd="kubectl get deployments"
    alias kgn="kubectl get nodes"
    alias kgns="kubectl get namespaces"
    alias kgi="kubectl get ingress"
    alias kgc="kubectl get configmaps"
    alias kgsec="kubectl get secrets"
    
    # Watch aliases
    alias kgpw="kubectl get pods -w"
    alias kgsw="kubectl get services -w"
    alias kgdw="kubectl get deployments -w"
    
    # Describe aliases
    alias kdp="kubectl describe pod"
    alias kds="kubectl describe service"
    alias kdd="kubectl describe deployment"
    alias kdn="kubectl describe node"
fi

# Kubernetes functions
kshell() {
    local pod="$1"
    local container="$2"
    local shell="${3:-bash}"
    
    if [[ -z "$pod" ]]; then
        echo "Usage: kshell <pod> [container] [shell]"
        return 1
    fi
    
    if [[ -n "$container" ]]; then
        kubectl exec -it "$pod" -c "$container" -- "$shell"
    else
        kubectl exec -it "$pod" -- "$shell"
    fi
}

klog() {
    local pod="$1"
    local container="$2"
    
    if [[ -z "$pod" ]]; then
        echo "Usage: klog <pod> [container]"
        return 1
    fi
    
    if [[ -n "$container" ]]; then
        kubectl logs -f "$pod" -c "$container"
    else
        kubectl logs -f "$pod"
    fi
}

kctx() {
    if [[ -n "$1" ]]; then
        kubectl config use-context "$1"
    else
        kubectl config get-contexts
    fi
}

# =============================================================================
# Container Registry Tools
# =============================================================================

# Docker Hub functions
docker-search() {
    local query="$1"
    if [[ -n "$query" ]]; then
        docker search "$query" --limit=10
    else
        echo "Usage: docker-search <search-term>"
    fi
}

# =============================================================================
# Development Server Tools
# =============================================================================

# HTTPie (better curl)
if command -v http >/dev/null 2>&1; then
    alias get="http GET"
    alias post="http POST"
    alias put="http PUT"
    alias delete="http DELETE"
    alias patch="http PATCH"
fi

# JSON processing with jq
if command -v jq >/dev/null 2>&1; then
    alias json="jq ."
    alias jsonc="jq -C ."
fi

# =============================================================================
# Database Tools
# =============================================================================

# PostgreSQL aliases (if installed)
if command -v psql >/dev/null 2>&1; then
    alias pg="psql"
    alias pgdump="pg_dump"
    alias pgrestore="pg_restore"
fi

# MongoDB aliases (if installed)
if command -v mongosh >/dev/null 2>&1; then
    alias mongo="mongosh"
fi

# Redis aliases (if installed)
if command -v redis-cli >/dev/null 2>&1; then
    alias redis="redis-cli"
fi

# =============================================================================
# Monitoring and Debugging Tools
# =============================================================================

# Process monitoring
alias psg="ps aux | grep"
alias topcpu="ps aux --sort=-%cpu | head"
alias topmem="ps aux --sort=-%mem | head"

# Network tools
alias ports="lsof -i -P -n | grep LISTEN"
alias netstat="netstat -tuln"

# System info
alias sysinfo="system_profiler SPSoftwareDataType SPHardwareDataType"

# =============================================================================
# SSH and Remote Access
# =============================================================================

# SSH configuration
export SSH_AUTH_SOCK="$HOME/.ssh/ssh_auth_sock"

# SSH agent management
ssh-add-keys() {
    ssh-add ~/.ssh/id_rsa 2>/dev/null
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
    echo "SSH keys added to agent"
}

# SSH tunnel function
ssh-tunnel() {
    local local_port="$1"
    local remote_host="$2"
    local remote_port="$3"
    local ssh_host="$4"
    
    if [[ -z "$4" ]]; then
        echo "Usage: ssh-tunnel <local-port> <remote-host> <remote-port> <ssh-host>"
        return 1
    fi
    
    ssh -L "$local_port:$remote_host:$remote_port" "$ssh_host" -N
}

# Copy SSH key to clipboard (macOS)
ssh-copy-key() {
    local key_file="${1:-~/.ssh/id_ed25519.pub}"
    if [[ -f "$key_file" ]]; then
        pbcopy < "$key_file"
        echo "SSH public key copied to clipboard: $key_file"
    else
        echo "SSH key file not found: $key_file"
    fi
}