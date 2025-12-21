# =============================================================================
# Advanced Functions and Utilities
# Complex functions for enhanced productivity
# =============================================================================

# =============================================================================
# Project Management Functions
# =============================================================================

# Create a new project with common structure
newproject() {
    local project_name="$1"
    local project_type="${2:-general}"
    
    if [[ -z "$project_name" ]]; then
        echo "Usage: newproject <name> [type]"
        echo "Types: python, go, node, web, general"
        return 1
    fi
    
    mkdir -p "$project_name"
    cd "$project_name"
    
    case "$project_type" in
        python)
            touch README.md requirements.txt .env .gitignore
            mkdir -p src tests
            echo "*.pyc\n__pycache__/\n.env\nvenv/\n.venv/" > .gitignore
            ;;
        go)
            touch README.md .gitignore
            go mod init "$project_name"
            mkdir -p cmd pkg internal
            echo "# Go\n*.exe\n*.exe~\n*.dll\n*.so\n*.dylib\n*.test\n*.out\ngo.work" > .gitignore
            ;;
        node)
            npm init -y
            touch README.md .env .gitignore
            mkdir -p src tests
            echo "node_modules/\n*.log\n.env\ndist/\nbuild/" > .gitignore
            ;;
        web)
            touch README.md index.html style.css script.js .gitignore
            mkdir -p assets css js
            echo ".DS_Store\n*.log\ndist/\nbuild/" > .gitignore
            ;;
        *)
            touch README.md .gitignore
            echo ".DS_Store\n*.log" > .gitignore
            ;;
    esac
    
    git init
    echo "Project '$project_name' created with type '$project_type'"
}

# Quick commit function
qcommit() {
    local message="$*"
    if [[ -z "$message" ]]; then
        echo "Usage: qcommit <commit message>"
        return 1
    fi
    
    git add .
    git commit -m "$message"
    
    # Ask if user wants to push
    echo -n "Push to remote? (y/N): "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        git push
    fi
}

# =============================================================================
# Development Server Functions
# =============================================================================

# Live reload development server
devserver() {
    local port="${1:-3000}"
    local dir="${2:-.}"
    
    echo "Starting development server on port $port..."
    echo "Serving directory: $dir"
    
    if command -v live-server >/dev/null 2>&1; then
        live-server --port="$port" --open="$dir"
    elif command -v python3 >/dev/null 2>&1; then
        cd "$dir" && python3 -m http.server "$port"
    else
        echo "No suitable server found. Install live-server or use Python."
    fi
}

# Port checker and killer
port() {
    local port_num="$1"
    
    if [[ -z "$port_num" ]]; then
        echo "Usage: port <port_number>"
        return 1
    fi
    
    local pid=$(lsof -ti tcp:"$port_num")
    
    if [[ -n "$pid" ]]; then
        echo "Port $port_num is in use by PID $pid"
        ps -p "$pid" -o pid,ppid,comm
        echo -n "Kill process? (y/N): "
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            kill -9 "$pid"
            echo "Process $pid killed"
        fi
    else
        echo "Port $port_num is free"
    fi
}

# =============================================================================
# File and Directory Operations
# =============================================================================

# Smart find function
smartfind() {
    local query="$1"
    local path="${2:-.}"
    
    if [[ -z "$query" ]]; then
        echo "Usage: smartfind <search_term> [path]"
        return 1
    fi
    
    if command -v fd >/dev/null 2>&1; then
        fd "$query" "$path"
    else
        find "$path" -iname "*$query*" 2>/dev/null
    fi
}

# Duplicate file finder
finddupes() {
    local directory="${1:-.}"
    
    echo "Finding duplicate files in: $directory"
    
    if command -v fdupes >/dev/null 2>&1; then
        fdupes -r "$directory"
    else
        find "$directory" -type f -exec md5 {} \; | sort | uniq -d -w 32 | cut -c 35-
    fi
}

# Disk usage analyzer
usage() {
    local path="${1:-.}"
    local depth="${2:-1}"
    
    if command -v ncdu >/dev/null 2>&1; then
        ncdu "$path"
    elif command -v dust >/dev/null 2>&1; then
        dust -d "$depth" "$path"
    else
        du -h -d "$depth" "$path" | sort -hr
    fi
}

# =============================================================================
# Network and System Functions
# =============================================================================

# Network connectivity test
nettest() {
    local hosts=("8.8.8.8" "1.1.1.1" "google.com" "github.com")
    
    for host in "${hosts[@]}"; do
        if ping -c 1 -W 1000 "$host" >/dev/null 2>&1; then
            echo "✅ $host - Connected"
        else
            echo "❌ $host - Failed"
        fi
    done
}

# Speed test
speedtest() {
    if command -v speedtest-cli >/dev/null 2>&1; then
        speedtest-cli
    else
        echo "Installing speedtest-cli..."
        pip3 install speedtest-cli
        speedtest-cli
    fi
}

# System resource monitor
resources() {
    echo "=== CPU Usage ==="
    top -l 1 -n 10 | grep "CPU usage"
    
    echo -e "\n=== Memory Usage ==="
    vm_stat | head -n 10
    
    echo -e "\n=== Disk Usage ==="
    df -h | head -n 5
    
    echo -e "\n=== Network Connections ==="
    netstat -an | grep ESTABLISHED | wc -l | awk '{print $1 " established connections"}'
    
    echo -e "\n=== Load Average ==="
    uptime
}

# =============================================================================
# Docker and Container Functions
# =============================================================================

# Docker cleanup with options
docker-nuke() {
    echo "⚠️  This will remove ALL Docker containers, images, and volumes!"
    echo -n "Are you sure? Type 'yes' to continue: "
    read -r response
    
    if [[ "$response" == "yes" ]]; then
        docker stop $(docker ps -aq) 2>/dev/null
        docker rm $(docker ps -aq) 2>/dev/null
        docker rmi $(docker images -q) 2>/dev/null
        docker volume rm $(docker volume ls -q) 2>/dev/null
        docker network rm $(docker network ls -q) 2>/dev/null
        docker system prune -af
        echo "🧹 Docker cleanup complete!"
    else
        echo "Cancelled"
    fi
}

# Container stats monitoring
docker-monitor() {
    if [[ $(docker ps -q | wc -l) -gt 0 ]]; then
        docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
    else
        echo "No running containers"
    fi
}

# =============================================================================
# Git Advanced Functions
# =============================================================================

# Git repository analysis
git-stats() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "Not a git repository"
        return 1
    fi
    
    echo "=== Repository Statistics ==="
    echo "Branch: $(git branch --show-current)"
    echo "Total commits: $(git rev-list --all --count)"
    echo "Contributors: $(git log --format='%aN' | sort -u | wc -l)"
    echo "Files tracked: $(git ls-files | wc -l)"
    
    echo -e "\n=== Recent Activity ==="
    git log --oneline -10
    
    echo -e "\n=== Top Contributors ==="
    git log --format='%aN' | sort | uniq -c | sort -nr | head -5
}

# Interactive git add
git-add-interactive() {
    if command -v fzf >/dev/null 2>&1; then
        git status --porcelain | fzf -m --preview 'git diff --color=always {2}' | awk '{print $2}' | xargs git add
    else
        git add -i
    fi
}

# =============================================================================
# Productivity and Workflow Functions
# =============================================================================

# Focus mode - block distracting websites
focus() {
    local mode="${1:-on}"
    local hosts_file="/etc/hosts"
    local focus_marker="# FOCUS MODE"
    local sites=("reddit.com" "twitter.com" "facebook.com" "youtube.com" "instagram.com")
    
    case "$mode" in
        on)
            echo "Enabling focus mode..."
            for site in "${sites[@]}"; do
                if ! grep -q "$site" "$hosts_file"; then
                    echo "127.0.0.1 $site $focus_marker" | sudo tee -a "$hosts_file" >/dev/null
                    echo "127.0.0.1 www.$site $focus_marker" | sudo tee -a "$hosts_file" >/dev/null
                fi
            done
            sudo dscacheutil -flushcache
            echo "✅ Focus mode enabled"
            ;;
        off)
            echo "Disabling focus mode..."
            sudo sed -i '' "/$focus_marker/d" "$hosts_file"
            sudo dscacheutil -flushcache
            echo "✅ Focus mode disabled"
            ;;
        *)
            echo "Usage: focus [on|off]"
            ;;
    esac
}

# Pomodoro timer (runs in background)
pomodoro() {
    local duration=${1:-25}
    (sleep $((duration * 60)) && \
        osascript -e 'display notification "Pomodoro complete!" with title "Focus Timer"' && \
        afplay /System/Library/Sounds/Glass.aiff 2>/dev/null &)
    echo "Pomodoro started for ${duration}m (running in background)"
}

# =============================================================================
# Learning and Documentation Functions
# =============================================================================

# Quick cheatsheet lookup
cheat() {
    local tool="$1"
    if [[ -z "$tool" ]]; then
        echo "Usage: cheat <tool/command>"
        return 1
    fi
    
    if command -v cheat >/dev/null 2>&1; then
        command cheat "$tool"
    else
        curl -s "cheat.sh/$tool"
    fi
}

# Man page with better formatting
man() {
    env \
        LESS_TERMCAP_mb="$(printf '\e[1;31m')" \
        LESS_TERMCAP_md="$(printf '\e[1;31m')" \
        LESS_TERMCAP_me="$(printf '\e[0m')" \
        LESS_TERMCAP_se="$(printf '\e[0m')" \
        LESS_TERMCAP_so="$(printf '\e[1;44;33m')" \
        LESS_TERMCAP_ue="$(printf '\e[0m')" \
        LESS_TERMCAP_us="$(printf '\e[1;32m')" \
        man "$@"
}