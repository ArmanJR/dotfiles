#!/usr/bin/env bash
# ============================================================================
# Raspberry Pi Development Environment Bootstrap Script
#
# Sets up a home server / self-hosting development environment:
# - Zsh with Powerlevel10k (no Oh My Zsh), autosuggestions, syntax highlighting
# - Neovim with LazyVim
# - Modern CLI tools (eza, fd, rg, bat, fzf, zoxide, atuin)
# - Languages: Rust, Python (uv), Go, Node.js (fnm)
# - Docker (optional)
# - JetBrainsMono Nerd Font
#
# Usage: ./bootstrap.sh [options]
# Options:
#   --minimal    : Essential packages + Zsh + modern CLI tools only
#   --full       : Everything including security tools and extras
#   --docker     : Include Docker installation
#   --no-backup  : Skip backup of existing configs
#   --help       : Show this help message
# ============================================================================

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

readonly OS_TYPE="$(uname -s)"
readonly ARCH="$(uname -m)"
readonly DISTRO="$(lsb_release -si 2>/dev/null || echo "Unknown")"

readonly DOTFILES_DIR="${DOTFILES_DIR:-$HOME/code/dotfiles}"
readonly RPI_DIR="$DOTFILES_DIR/rpi"
readonly BACKUP_DIR="$HOME/.bootstrap-backup-$(date +%Y%m%d-%H%M%S)"
readonly TEMP_DIR="/tmp/bootstrap-$$"
readonly LOCAL_BIN="$HOME/.local/bin"
readonly CONFIG_DIR="$HOME/.config"
readonly FONTS_DIR="$HOME/.local/share/fonts"
readonly ZSH_PLUGIN_DIR="$HOME/.zsh/plugins"

INSTALL_MODE="standard"
INSTALL_DOCKER=false
CREATE_BACKUP=true

readonly LOG_FILE="$HOME/bootstrap-$(date +%Y%m%d-%H%M%S).log"

# ============================================================================
# PACKAGE LISTS
# ============================================================================

readonly MINIMAL_PACKAGES=(
    # Core utilities
    curl wget git vim tmux htop btop
    zsh

    # Build essentials
    build-essential cmake make gcc g++
    python3-dev python3-venv

    # System utilities
    software-properties-common apt-transport-https
    ca-certificates gnupg lsb-release

    # Modern CLI tools (Debian package names)
    fd-find ripgrep bat
    unzip zip jq

    # Network tools
    net-tools openssh-server
)

readonly STANDARD_PACKAGES=(
    # Search and navigation
    fzf zoxide

    # Monitoring
    ncdu iotop iftop nethogs

    # Database clients
    sqlite3 postgresql-client redis-tools

    # Additional tools
    neofetch tree dnsutils
    p7zip-full tar gzip bzip2
    xclip
)

readonly FULL_PACKAGES=(
    # Archive tools
    rar unrar

    # Media
    ffmpeg

    # Security
    fail2ban ufw

    # Remote access
    mosh

    # HTTP tools
    httpie aria2

    # Monitoring
    sysstat
)

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

log() {
    local level=$1
    shift
    local message="$*"

    case $level in
        ERROR)   echo -e "${RED}[ERROR]${NC} $message" | tee -a "$LOG_FILE" ;;
        SUCCESS) echo -e "${GREEN}[OK]${NC} $message" | tee -a "$LOG_FILE" ;;
        WARNING) echo -e "${YELLOW}[WARN]${NC} $message" | tee -a "$LOG_FILE" ;;
        INFO)    echo -e "${BLUE}[INFO]${NC} $message" | tee -a "$LOG_FILE" ;;
        STEP)    echo -e "${CYAN}[STEP]${NC} $message" | tee -a "$LOG_FILE" ;;
        *)       echo "$message" | tee -a "$LOG_FILE" ;;
    esac
}

error_handler() {
    local line_no=$1
    local exit_code=$2
    log ERROR "Script failed at line $line_no with exit code $exit_code"
    cleanup
    exit "$exit_code"
}

cleanup() {
    [[ -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ============================================================================
# SYSTEM CHECKS
# ============================================================================

check_system() {
    log STEP "Checking system requirements..."

    if [[ "$OS_TYPE" != "Linux" ]]; then
        log ERROR "This script is designed for Linux systems only"
        exit 1
    fi

    log INFO "Architecture: $ARCH"
    log INFO "Distribution: $DISTRO"

    local available_space
    available_space=$(df / | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 1048576 ]]; then
        log WARNING "Less than 1GB of free space available"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] || exit 1
    fi

    if ! ping -c 1 -W 2 google.com &>/dev/null; then
        log ERROR "No internet connection detected"
        exit 1
    fi

    log SUCCESS "System checks passed"
}

create_directories() {
    log STEP "Creating directories..."
    mkdir -p "$LOCAL_BIN" "$CONFIG_DIR" "$FONTS_DIR" "$TEMP_DIR"
    mkdir -p "$HOME/.zsh/completions" "$HOME/.zsh/cache" "$ZSH_PLUGIN_DIR"
    log SUCCESS "Directories created"
}

backup_configs() {
    if [[ "$CREATE_BACKUP" == false ]]; then
        log INFO "Skipping backup"
        return
    fi

    log STEP "Backing up existing configurations..."

    local files_to_backup=(
        "$HOME/.zshrc" "$HOME/.zshenv" "$HOME/.bashrc"
        "$HOME/.vimrc" "$HOME/.tmux.conf"
        "$HOME/.config/nvim" "$HOME/.zsh"
    )

    local backup_needed=false
    for file in "${files_to_backup[@]}"; do
        [[ -e "$file" ]] && backup_needed=true && break
    done

    if [[ "$backup_needed" == true ]]; then
        mkdir -p "$BACKUP_DIR"
        for file in "${files_to_backup[@]}"; do
            [[ -e "$file" ]] && cp -r "$file" "$BACKUP_DIR/" 2>/dev/null && log INFO "Backed up: $file"
        done
        log SUCCESS "Backup at: $BACKUP_DIR"
    else
        log INFO "No existing configurations to backup"
    fi
}

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

update_system() {
    log STEP "Updating system packages..."
    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y
    log SUCCESS "System updated"
}

install_packages() {
    log STEP "Installing packages ($INSTALL_MODE mode)..."

    local packages=("${MINIMAL_PACKAGES[@]}")

    case "$INSTALL_MODE" in
        standard) packages+=("${STANDARD_PACKAGES[@]}") ;;
        full)     packages+=("${STANDARD_PACKAGES[@]}" "${FULL_PACKAGES[@]}") ;;
    esac

    sudo apt install -y "${packages[@]}" 2>&1 | tee -a "$LOG_FILE" || true

    # Handle Debian naming differences: batcat -> bat, fdfind -> fd
    if command_exists batcat && ! command_exists bat; then
        ln -sf "$(which batcat)" "$LOCAL_BIN/bat"
        log INFO "Created symlink: bat -> batcat"
    fi

    if command_exists fdfind && ! command_exists fd; then
        ln -sf "$(which fdfind)" "$LOCAL_BIN/fd"
        log INFO "Created symlink: fd -> fdfind"
    fi

    log SUCCESS "Package installation completed"
}

install_rust() {
    log STEP "Installing Rust..."

    if command_exists rustc; then
        log INFO "Rust already installed ($(rustc --version))"
        return
    fi

    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    source "$HOME/.cargo/env"

    log SUCCESS "Rust installed"
}

install_cargo_tools() {
    log STEP "Installing Rust CLI tools via cargo..."

    local tools=(eza zoxide starship)

    # Only install tools not already available (some may come from apt)
    for tool in "${tools[@]}"; do
        if ! command_exists "$tool"; then
            log INFO "Installing $tool..."
            cargo install "$tool" 2>&1 | tee -a "$LOG_FILE" || log WARNING "Failed to install $tool"
        else
            log INFO "$tool already installed"
        fi
    done

    log SUCCESS "Cargo tools installed"
}

install_uv() {
    log STEP "Installing uv (Python package manager)..."

    if command_exists uv; then
        log INFO "uv already installed ($(uv --version))"
        return
    fi

    curl -LsSf https://astral.sh/uv/install.sh | sh

    log SUCCESS "uv installed"
}

install_go() {
    log STEP "Installing Go..."

    if command_exists go; then
        log INFO "Go already installed ($(go version))"
        return
    fi

    local go_arch
    case "$ARCH" in
        aarch64|arm64) go_arch="arm64" ;;
        x86_64)        go_arch="amd64" ;;
        armv7l)        go_arch="armv6l" ;;
        *)
            log WARNING "Unsupported architecture for Go: $ARCH"
            return
            ;;
    esac

    local go_version
    go_version=$(curl -sL 'https://go.dev/VERSION?m=text' | head -1)

    log INFO "Downloading ${go_version} for linux/${go_arch}..."
    wget -q --show-progress "https://go.dev/dl/${go_version}.linux-${go_arch}.tar.gz" -O "$TEMP_DIR/go.tar.gz"

    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "$TEMP_DIR/go.tar.gz"
    export PATH="/usr/local/go/bin:$PATH"

    log SUCCESS "Go installed ($(go version))"
}

install_fnm() {
    log STEP "Installing fnm (Node.js version manager)..."

    if command_exists fnm; then
        log INFO "fnm already installed"
        return
    fi

    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell

    # Source fnm for current session
    export PATH="$HOME/.local/share/fnm:$PATH"
    if command_exists fnm; then
        eval "$(fnm env)"
        fnm install --lts
        log SUCCESS "fnm installed with latest LTS Node.js"
    else
        log WARNING "fnm installed but not in PATH yet"
    fi
}

install_neovim() {
    log STEP "Installing Neovim..."

    if command_exists nvim; then
        log INFO "Neovim already installed ($(nvim --version | head -1))"
    else
        local nvim_arch
        case "$ARCH" in
            aarch64|arm64) nvim_arch="arm64" ;;
            x86_64)        nvim_arch="x86_64" ;;
            armv7l)
                log WARNING "ARM32: installing Neovim from apt (may be older version)"
                sudo apt install -y neovim
                ;;
            *)
                log ERROR "Unsupported architecture for Neovim: $ARCH"
                return
                ;;
        esac

        if [[ "$ARCH" != "armv7l" ]]; then
            local nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${nvim_arch}.tar.gz"
            log INFO "Downloading Neovim for ${nvim_arch}..."
            wget -q --show-progress "$nvim_url" -O "$TEMP_DIR/nvim.tar.gz"

            tar xzf "$TEMP_DIR/nvim.tar.gz" -C "$TEMP_DIR"
            local nvim_dir
            nvim_dir=$(find "$TEMP_DIR" -maxdepth 1 -name "nvim-linux*" -type d | head -1)
            if [[ -n "$nvim_dir" ]]; then
                sudo cp -r "$nvim_dir"/* /usr/local/
            else
                log ERROR "Could not find Neovim directory after extraction"
                return
            fi
        fi

        log SUCCESS "Neovim installed"
    fi

    # Install LazyVim
    local nvim_config="$HOME/.config/nvim"
    if [[ ! -d "$nvim_config" ]]; then
        log INFO "Installing LazyVim starter..."
        git clone https://github.com/LazyVim/starter "$nvim_config"
        rm -rf "$nvim_config/.git"
        log SUCCESS "LazyVim installed"
    else
        log INFO "Neovim config already exists"
    fi
}

install_powerlevel10k() {
    log STEP "Installing Powerlevel10k..."

    local p10k_dir="$HOME/powerlevel10k"
    if [[ ! -d "$p10k_dir" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
        log SUCCESS "Powerlevel10k installed"
    else
        log INFO "Powerlevel10k already installed"
    fi
}

install_zsh_plugins() {
    log STEP "Installing Zsh plugins..."

    local plugins=(
        "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
        "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting"
    )

    for entry in "${plugins[@]}"; do
        local name="${entry%%:*}"
        local url="${entry#*:}"

        if [[ ! -d "$ZSH_PLUGIN_DIR/$name" ]]; then
            log INFO "Installing $name..."
            git clone --depth=1 "$url" "$ZSH_PLUGIN_DIR/$name"
        else
            log INFO "$name already installed"
        fi
    done

    log SUCCESS "Zsh plugins installed"
}

install_font() {
    log STEP "Installing JetBrainsMono Nerd Font..."

    if ls "$FONTS_DIR"/JetBrainsMonoNerd* &>/dev/null; then
        log INFO "JetBrainsMono Nerd Font already installed"
        return
    fi

    cd "$TEMP_DIR"
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

    if wget -q --show-progress "$font_url" -O JetBrainsMono.zip; then
        unzip -q -o JetBrainsMono.zip -d "$FONTS_DIR"
        rm JetBrainsMono.zip
        fc-cache -fv >/dev/null 2>&1
        log SUCCESS "JetBrainsMono Nerd Font installed"
    else
        log WARNING "Failed to download JetBrainsMono Nerd Font"
    fi
    cd - >/dev/null
}

install_atuin() {
    log STEP "Installing Atuin (shell history)..."

    if command_exists atuin; then
        log INFO "Atuin already installed"
        return
    fi

    curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh | bash

    log SUCCESS "Atuin installed"
}

install_github_cli() {
    log STEP "Installing GitHub CLI..."

    if command_exists gh; then
        log INFO "GitHub CLI already installed"
        return
    fi

    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

    sudo apt update
    sudo apt install gh -y

    log SUCCESS "GitHub CLI installed"
}

install_docker() {
    if [[ "$INSTALL_DOCKER" != true ]]; then
        return
    fi

    log STEP "Installing Docker..."

    if command_exists docker; then
        log INFO "Docker already installed"
        return
    fi

    curl -fsSL https://get.docker.com | sh

    sudo usermod -aG docker "$USER"

    log SUCCESS "Docker installed (log out and back in for group changes)"
}

# ============================================================================
# DOTFILES SETUP
# ============================================================================

link_dotfiles() {
    log STEP "Setting up dotfiles..."

    if [[ ! -d "$RPI_DIR" ]]; then
        log WARNING "Dotfiles directory not found at $RPI_DIR"
        log INFO "Clone your dotfiles repo to $DOTFILES_DIR first"
        return
    fi

    # Shell config files
    local shell_files=(".zshrc" ".zshenv" ".gitignore_global" ".ripgreprc")
    for file in "${shell_files[@]}"; do
        if [[ -f "$RPI_DIR/$file" ]]; then
            ln -sf "$RPI_DIR/$file" "$HOME/$file"
            log INFO "Linked $file"
        fi
    done

    # .zsh directory (symlink individual files to allow local overrides)
    mkdir -p "$HOME/.zsh"
    for file in "$RPI_DIR/.zsh/"*; do
        [[ -f "$file" ]] && ln -sf "$file" "$HOME/.zsh/$(basename "$file")"
    done
    log INFO "Linked .zsh/ modules"

    # Config files
    mkdir -p "$HOME/.config/atuin" "$HOME/.config/prek"

    if [[ -f "$RPI_DIR/.config/atuin/config.toml" ]]; then
        ln -sf "$RPI_DIR/.config/atuin/config.toml" "$HOME/.config/atuin/config.toml"
        log INFO "Linked atuin config"
    fi

    for file in "$RPI_DIR/.config/prek/"*; do
        [[ -f "$file" ]] && ln -sf "$file" "$HOME/.config/prek/$(basename "$file")"
    done
    log INFO "Linked prek templates"

    log SUCCESS "Dotfiles linked"
}

final_setup() {
    log STEP "Performing final setup..."

    # Set Zsh as default shell
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        log INFO "Setting Zsh as default shell..."
        chsh -s "$(which zsh)"
    fi

    # Create useful directories
    mkdir -p "$HOME/projects" "$HOME/code" "$HOME/notes"

    # Set SSH permissions
    chmod 700 "$HOME/.ssh" 2>/dev/null || true
    chmod 600 "$HOME/.ssh/config" 2>/dev/null || true

    log SUCCESS "Final setup completed"
}

# ============================================================================
# MAIN
# ============================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --minimal)   INSTALL_MODE="minimal"; shift ;;
            --full)      INSTALL_MODE="full"; shift ;;
            --docker)    INSTALL_DOCKER=true; shift ;;
            --no-backup) CREATE_BACKUP=false; shift ;;
            --help)      show_help; exit 0 ;;
            *)
                log ERROR "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

show_help() {
    cat << 'EOF'
Raspberry Pi Development Environment Bootstrap

Usage: ./bootstrap.sh [options]

Options:
    --minimal    Essential packages + Zsh + modern CLI tools only
    --full       Everything including security tools and extras
    --docker     Include Docker installation
    --no-backup  Skip backup of existing configurations
    --help       Show this help message

Default mode is 'standard' which includes monitoring, DB clients, and dev tools.

Examples:
    ./bootstrap.sh                    # Standard installation
    ./bootstrap.sh --minimal          # Minimal (lightweight)
    ./bootstrap.sh --full --docker    # Everything including Docker

EOF
}

main() {
    trap 'error_handler $LINENO $?' ERR
    trap cleanup EXIT

    echo -e "${CYAN}"
    echo "============================================="
    echo "   Raspberry Pi Dev Environment Bootstrap"
    echo "============================================="
    echo -e "${NC}"

    parse_arguments "$@"

    log INFO "Bootstrap started at $(date)"
    log INFO "Installation mode: $INSTALL_MODE"
    log INFO "Log file: $LOG_FILE"

    # Pre-flight
    check_system
    create_directories
    backup_configs

    # System packages
    update_system
    install_packages

    # Languages and tools
    install_rust
    install_cargo_tools
    install_uv
    install_go
    install_fnm
    install_neovim

    # Shell setup
    install_powerlevel10k
    install_zsh_plugins
    install_font
    install_atuin
    install_github_cli

    # Optional
    install_docker

    # Dotfiles
    link_dotfiles
    final_setup

    echo -e "${GREEN}"
    echo "============================================="
    echo "   Bootstrap Completed Successfully!"
    echo "============================================="
    echo -e "${NC}"

    log SUCCESS "Bootstrap completed at $(date)"

    echo ""
    echo "Next steps:"
    echo "1. Log out and log back in (or run: exec zsh)"
    echo "2. Run 'nvim' to complete Neovim plugin installation"
    echo "3. Configure your terminal to use JetBrainsMono Nerd Font"

    if [[ "$INSTALL_DOCKER" == true ]]; then
        echo "4. Docker installed - log out/in for group changes"
    fi

    echo ""
    echo "Backup: $BACKUP_DIR"
    echo "Log: $LOG_FILE"
}

main "$@"
