# =============================================================================
# Development Tools Configuration
# Docker, Container Tools, and Server Utilities
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
    local -a ids
    ids=("${(@f)$(docker ps -q)}")
    if (( ${#ids} )); then
        docker stop "${ids[@]}"
    else
        echo "No running containers to stop"
    fi
}

docker-remove-all() {
    docker-stop-all
    local -a ids
    ids=("${(@f)$(docker ps -aq)}")
    if (( ${#ids} )); then
        docker rm "${ids[@]}"
    else
        echo "No containers to remove"
    fi
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
alias ports="ss -tlnp"

# =============================================================================
# SSH and Remote Access
# =============================================================================

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

# Copy SSH key to clipboard (Linux)
ssh-copy-key() {
    local key_file="${1:-~/.ssh/id_ed25519.pub}"
    if [[ -f "$key_file" ]]; then
        if command -v xclip >/dev/null 2>&1; then
            xclip -selection clipboard < "$key_file"
            echo "SSH public key copied to clipboard: $key_file"
        else
            cat "$key_file"
            echo "\n(install xclip to copy to clipboard automatically)"
        fi
    else
        echo "SSH key file not found: $key_file"
    fi
}
