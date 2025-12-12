#!/usr/bin/env bash
# ============================================================================
# Raspberry Pi Development Environment Bootstrap Script
# 
# Sets up a complete development environment including:
# - Zsh with Oh My Zsh and plugins
# - Neovim with LazyVim
# - Development tools and languages
# - Nerd Fonts
# - Docker (optional)
# - Various CLI utilities
#
# Usage: ./bootstrap.sh [options]
# Options:
#   --minimal    : Install only essential packages
#   --full       : Install everything including optional packages
#   --docker     : Include Docker installation
#   --no-backup  : Skip backup of existing configs
#   --help       : Show this help message
# ============================================================================

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# System detection
readonly OS_TYPE="$(uname -s)"
readonly ARCH="$(uname -m)"
readonly DISTRO="$(lsb_release -si 2>/dev/null || echo "Unknown")"
readonly CODENAME="$(lsb_release -sc 2>/dev/null || echo "unknown")"

# Directories
readonly DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
readonly BACKUP_DIR="$HOME/.bootstrap-backup-$(date +%Y%m%d-%H%M%S)"
readonly NVIM_CONFIG_DIR="$HOME/.config/nvim"
readonly OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
readonly FONTS_DIR="$HOME/.local/share/fonts"
readonly LOCAL_BIN="$HOME/.local/bin"
readonly CONFIG_DIR="$HOME/.config"
readonly TEMP_DIR="/tmp/bootstrap-$$"

# Installation flags
INSTALL_MODE="standard"
INSTALL_DOCKER=false
CREATE_BACKUP=true
VERBOSE=false

# Log file
readonly LOG_FILE="$HOME/bootstrap-$(date +%Y%m%d-%H%M%S).log"

# ============================================================================
# PACKAGE LISTS
# ============================================================================

# Essential packages
readonly ESSENTIAL_PACKAGES=(
    # Core utilities
    curl wget git vim tmux screen htop btop
    zsh fish bash-completion
    
    # Build essentials
    build-essential cmake make gcc g++ 
    python3-dev python3-pip python3-venv
    
    # System utilities
    software-properties-common apt-transport-https
    ca-certificates gnupg lsb-release
    
    # File management
    tree ncdu fd-find ripgrep silversearcher-ag
    unzip zip p7zip-full tar gzip bzip2
    
    # Network tools
    net-tools dnsutils iputils-ping traceroute
    openssh-client openssh-server
    
    # Text processing
    jq yq sed gawk grep
)

# Standard packages (includes essential)
readonly STANDARD_PACKAGES=(
    # Development tools
    nodejs npm yarn
    golang rustc cargo
    sqlite3 postgresql-client mysql-client
    redis-tools
    
    # Python extras
    python3-setuptools python3-wheel
    pipx virtualenv
    
    # Monitoring & Performance
    iotop iftop nethogs bmon
    sysstat dstat
    
    # Modern CLI tools
    fzf bat exa zoxide
    autojump z
    neofetch fastfetch
    
    # Archive tools
    rar unrar
    
    # Media tools
    ffmpeg imagemagick
    
    # Fonts
    fonts-powerline fonts-firacode
    fonts-dejavu fontconfig
)

# Full installation packages
readonly FULL_PACKAGES=(
    # Additional languages
    ruby ruby-dev
    php php-cli
    lua5.4
    
    # Database clients
    mongodb-clients
    
    # Additional tools
    ansible terraform
    httpie aria2
    mosh eternal-terminal
    
    # Security tools
    fail2ban ufw
    gnupg2 pass
    
    # System tools
    cockpit cockpit-pcp
    webmin
)

# Python packages to install via pip
readonly PYTHON_PACKAGES=(
    # Development
    ipython jupyter
    black flake8 pylint mypy
    pytest pytest-cov
    
    # Utilities
    httpie glances
    speedtest-cli
    youtube-dl yt-dlp
    thefuck
    
    # Data science (optional)
    numpy pandas matplotlib
)

# Node.js global packages
readonly NODE_PACKAGES=(
    # Package managers
    pnpm
    
    # Development tools
    nodemon pm2
    eslint prettier
    typescript ts-node
    
    # CLI tools
    gtop blessed-contrib
    tldr how-2
    npm-check-updates
)

# Go packages
readonly GO_PACKAGES=(
    # Development tools
    github.com/jesseduffield/lazygit@latest
    github.com/jesseduffield/lazydocker@latest
    github.com/golang/tools/gopls@latest
    
    # CLI tools
    github.com/junegunn/fzf@latest
    github.com/gokcehan/lf@latest
)

# Rust packages
readonly RUST_PACKAGES=(
    # Modern alternatives to Unix tools
    bat exa ripgrep fd-find
    procs dust tokei hyperfine
    bottom zoxide starship
    
    # Development tools
    cargo-edit cargo-watch
    cargo-expand cargo-outdated
)

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Logging functions
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        ERROR)
            echo -e "${RED}[ERROR]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        SUCCESS)
            echo -e "${GREEN}[SUCCESS]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        WARNING)
            echo -e "${YELLOW}[WARNING]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        INFO)
            echo -e "${BLUE}[INFO]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        STEP)
            echo -e "${CYAN}[STEP]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        *)
            echo "[$timestamp] $message" | tee -a "$LOG_FILE"
            ;;
    esac
}

# Error handler
error_handler() {
    local line_no=$1
    local exit_code=$2
    log ERROR "Script failed at line $line_no with exit code $exit_code"
    cleanup
    exit "$exit_code"
}

# Cleanup function
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Check if running with sudo (and advise against it)
check_sudo() {
    if [[ $EUID -eq 0 ]]; then
        log WARNING "This script should not be run as root!"
        log WARNING "It will request sudo privileges when needed."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Check system requirements
check_system() {
    log STEP "Checking system requirements..."
    
    # Check OS
    if [[ "$OS_TYPE" != "Linux" ]]; then
        log ERROR "This script is designed for Linux systems only"
        exit 1
    fi
    
    # Check architecture
    log INFO "Detected architecture: $ARCH"
    log INFO "Detected distribution: $DISTRO $CODENAME"
    
    # Check available space
    local available_space=$(df / | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 1048576 ]]; then  # Less than 1GB
        log WARNING "Less than 1GB of free space available"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Check internet connectivity
    if ! ping -c 1 google.com &> /dev/null; then
        log ERROR "No internet connection detected"
        exit 1
    fi
    
    log SUCCESS "System checks passed"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Create necessary directories
create_directories() {
    log STEP "Creating necessary directories..."
    mkdir -p "$LOCAL_BIN"
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$FONTS_DIR"
    mkdir -p "$TEMP_DIR"
    mkdir -p "$HOME/.local/state/zsh"
    mkdir -p "$HOME/.cache/zsh"
    log SUCCESS "Directories created"
}

# Backup existing configurations
backup_configs() {
    if [[ "$CREATE_BACKUP" == false ]]; then
        log INFO "Skipping backup as requested"
        return
    fi
    
    log STEP "Backing up existing configurations..."
    
    local files_to_backup=(
        "$HOME/.zshrc"
        "$HOME/.bashrc"
        "$HOME/.vimrc"
        "$HOME/.tmux.conf"
        "$HOME/.gitconfig"
        "$NVIM_CONFIG_DIR"
        "$HOME/.config/fish"
    )
    
    local backup_needed=false
    for file in "${files_to_backup[@]}"; do
        if [[ -e "$file" ]]; then
            backup_needed=true
            break
        fi
    done
    
    if [[ "$backup_needed" == true ]]; then
        mkdir -p "$BACKUP_DIR"
        for file in "${files_to_backup[@]}"; do
            if [[ -e "$file" ]]; then
                cp -r "$file" "$BACKUP_DIR/" 2>/dev/null || true
                log INFO "Backed up: $file"
            fi
        done
        log SUCCESS "Backup completed at: $BACKUP_DIR"
    else
        log INFO "No existing configurations to backup"
    fi
}

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

# Update system
update_system() {
    log STEP "Updating system packages..."
    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y
    sudo apt autoclean
    log SUCCESS "System updated"
}

# Install packages based on mode
install_packages() {
    log STEP "Installing packages ($INSTALL_MODE mode)..."
    
    local packages=()
    
    case "$INSTALL_MODE" in
        minimal)
            packages=("${ESSENTIAL_PACKAGES[@]}")
            ;;
        standard)
            packages=("${ESSENTIAL_PACKAGES[@]}" "${STANDARD_PACKAGES[@]}")
            ;;
        full)
            packages=("${ESSENTIAL_PACKAGES[@]}" "${STANDARD_PACKAGES[@]}" "${FULL_PACKAGES[@]}")
            ;;
    esac
    
    # Install packages in batches to avoid command line length issues
    local batch_size=10
    local total=${#packages[@]}
    
    for ((i=0; i<$total; i+=batch_size)); do
        local batch=("${packages[@]:i:batch_size}")
        log INFO "Installing batch $((i/batch_size + 1))..."
        sudo apt install -y "${batch[@]}" 2>&1 | tee -a "$LOG_FILE" || true
    done
    
    log SUCCESS "Package installation completed"
}

# Install Zsh and Oh My Zsh
install_zsh() {
    log STEP "Setting up Zsh..."
    
    # Install Oh My Zsh
    if [[ ! -d "$OH_MY_ZSH_DIR" ]]; then
        log INFO "Installing Oh My Zsh..."
        RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || {
            log ERROR "Failed to install Oh My Zsh"
            return 1
        }
    else
        log INFO "Oh My Zsh already installed"
    fi
    
    # Install plugins
    local custom_plugins="$OH_MY_ZSH_DIR/custom/plugins"
    mkdir -p "$custom_plugins"
    
    # Plugin list with their repos
    declare -A plugins=(
        ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
        ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
        ["zsh-history-substring-search"]="https://github.com/zsh-users/zsh-history-substring-search"
        ["zsh-completions"]="https://github.com/zsh-users/zsh-completions"
        ["fzf-tab"]="https://github.com/Aloxaf/fzf-tab"
        ["zsh-vi-mode"]="https://github.com/jeffreytse/zsh-vi-mode"
    )
    
    for plugin in "${!plugins[@]}"; do
        if [[ ! -d "$custom_plugins/$plugin" ]]; then
            log INFO "Installing $plugin..."
            git clone --depth=1 "${plugins[$plugin]}" "$custom_plugins/$plugin"
        else
            log INFO "$plugin already installed"
        fi
    done
    
    # Install Powerlevel10k theme
    local custom_themes="$OH_MY_ZSH_DIR/custom/themes"
    mkdir -p "$custom_themes"
    
    if [[ ! -d "$custom_themes/powerlevel10k" ]]; then
        log INFO "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$custom_themes/powerlevel10k"
    fi
    
    log SUCCESS "Zsh setup completed"
}

# Install Neovim
install_neovim() {
    log STEP "Installing Neovim..."
    
    local nvim_path="/usr/local/bin/nvim"
    
    if [[ ! -f "$nvim_path" ]]; then
        cd "$TEMP_DIR"
        
        # Determine download URL based on architecture
        local nvim_url=""
        case "$ARCH" in
            aarch64|arm64)
                nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
                ;;
            x86_64)
                nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
                ;;
            armv7l)
                log WARNING "ARM32 detected. Building from source might be required."
                nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
                ;;
            *)
                log ERROR "Unsupported architecture: $ARCH"
                return 1
                ;;
        esac
        
        log INFO "Downloading Neovim..."
        wget -q --show-progress "$nvim_url" -O nvim.tar.gz
        
        log INFO "Extracting Neovim..."
        tar xzf nvim.tar.gz
        
        # Find and move the nvim binary
        local nvim_dir=$(find . -name "nvim-linux64" -type d 2>/dev/null | head -1)
        if [[ -n "$nvim_dir" ]]; then
            sudo cp -r "$nvim_dir"/* /usr/local/
        else
            log ERROR "Could not find Neovim directory"
            return 1
        fi
        
        cd - > /dev/null
        log SUCCESS "Neovim installed"
    else
        log INFO "Neovim already installed"
    fi
    
    # Install Neovim Python support
    pip3 install --user pynvim neovim
    
    # Install LazyVim
    if [[ ! -d "$NVIM_CONFIG_DIR" ]]; then
        log INFO "Installing LazyVim..."
        git clone https://github.com/LazyVim/starter "$NVIM_CONFIG_DIR"
        rm -rf "$NVIM_CONFIG_DIR/.git"
    else
        log INFO "Neovim config already exists"
    fi
    
    log SUCCESS "Neovim setup completed"
}

# Install Nerd Fonts
install_fonts() {
    log STEP "Installing Nerd Fonts..."
    
    cd "$TEMP_DIR"
    
    # List of fonts to install
    local fonts=(
        "JetBrainsMono"
        "FiraCode"
        "Hack"
        "RobotoMono"
        "SourceCodePro"
    )
    
    for font in "${fonts[@]}"; do
        log INFO "Installing $font Nerd Font..."
        
        local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip"
        
        if wget -q --show-progress "$font_url" -O "${font}.zip"; then
            unzip -q -o "${font}.zip" -d "$FONTS_DIR"
            rm "${font}.zip"
            log SUCCESS "$font installed"
        else
            log WARNING "Failed to download $font"
        fi
    done
    
    # Update font cache
    fc-cache -fv > /dev/null 2>&1
    
    cd - > /dev/null
    log SUCCESS "Fonts installation completed"
}

# Install Docker
install_docker() {
    if [[ "$INSTALL_DOCKER" != true ]]; then
        return
    fi
    
    log STEP "Installing Docker..."
    
    if command_exists docker; then
        log INFO "Docker already installed"
        return
    fi
    
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Add Docker repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Add user to docker group
    sudo usermod -aG docker "$USER"
    
    # Install Docker Compose v2
    sudo apt install -y docker-compose-plugin
    
    log SUCCESS "Docker installed (restart required for group changes)"
}

# Install programming languages
install_languages() {
    log STEP "Installing programming language tools..."
    
    # Python packages
    if command_exists pip3; then
        log INFO "Installing Python packages..."
        pip3 install --user --upgrade pip setuptools wheel
        
        for package in "${PYTHON_PACKAGES[@]}"; do
            pip3 install --user "$package" || log WARNING "Failed to install $package"
        done
    fi
    
    # Node packages
    if command_exists npm; then
        log INFO "Installing Node.js packages..."
        
        # Set npm prefix for global packages
        npm config set prefix "$HOME/.npm-global"
        export PATH="$HOME/.npm-global/bin:$PATH"
        
        for package in "${NODE_PACKAGES[@]}"; do
            npm install -g "$package" || log WARNING "Failed to install $package"
        done
    fi
    
    # Go packages
    if command_exists go; then
        log INFO "Installing Go packages..."
        export GOPATH="$HOME/.go"
        export PATH="$GOPATH/bin:$PATH"
        
        for package in "${GO_PACKAGES[@]}"; do
            go install "$package" || log WARNING "Failed to install $package"
        done
    fi
    
    # Rust packages
    if command_exists cargo; then
        log INFO "Installing Rust packages..."
        
        for package in "${RUST_PACKAGES[@]}"; do
            cargo install "$package" || log WARNING "Failed to install $package"
        done
    fi
    
    log SUCCESS "Programming languages setup completed"
}

# Install additional tools
install_additional_tools() {
    log STEP "Installing additional tools..."
    
    # Install Starship prompt
    if ! command_exists starship; then
        log INFO "Installing Starship prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
    
    # Install GitHub CLI
    if ! command_exists gh; then
        log INFO "Installing GitHub CLI..."
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install gh -y
    fi
    
    # Install Terraform
    if ! command_exists terraform && [[ "$INSTALL_MODE" == "full" ]]; then
        log INFO "Installing Terraform..."
        wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update && sudo apt install terraform -y
    fi
    
    # Install kubectl
    if ! command_exists kubectl; then
        log INFO "Installing kubectl..."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl"
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin/
    fi
    
    log SUCCESS "Additional tools installed"
}

# Configure Git
configure_git() {
    log STEP "Configuring Git..."

    if [[ ! -d "$DOTFILES_DIR/rpi/git" ]]; then
        log WARNING "Git configs directory not found. Skipping..."
        return
    fi

    # Link git config files
    if [[ -f "$DOTFILES_DIR/rpi/git/.gitconfig" ]]; then
        ln -sf "$DOTFILES_DIR/rpi/git/.gitconfig" "$HOME/.gitconfig"
        log INFO "Linked .gitconfig"
    fi

    if [[ -f "$DOTFILES_DIR/rpi/git/.gitignore_global" ]]; then
        ln -sf "$DOTFILES_DIR/rpi/git/.gitignore_global" "$HOME/.gitignore_global"
        log INFO "Linked .gitignore_global"
    fi

    log SUCCESS "Git configured"
}

# Link dotfiles
link_dotfiles() {
    log STEP "Setting up dotfiles..."
    
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        log INFO "Dotfiles directory not found. Skipping..."
        return
    fi
    
    # Link common dotfiles
    local dotfiles=(
        ".zshrc"
        ".bashrc"
        ".tmux.conf"
        ".vimrc"
    )
    
    for file in "${dotfiles[@]}"; do
        if [[ -f "$DOTFILES_DIR/$file" ]]; then
            ln -sf "$DOTFILES_DIR/$file" "$HOME/$file"
            log INFO "Linked $file"
        fi
    done
    
    # Link Neovim config
    if [[ -d "$DOTFILES_DIR/nvim" ]]; then
        ln -sf "$DOTFILES_DIR/nvim" "$NVIM_CONFIG_DIR"
        log INFO "Linked Neovim config"
    fi
    
    log SUCCESS "Dotfiles linked"
}

# Final setup
final_setup() {
    log STEP "Performing final setup..."
    
    # Set Zsh as default shell
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        log INFO "Setting Zsh as default shell..."
        chsh -s "$(which zsh)"
    fi
    
    # Create useful directories
    mkdir -p "$HOME/projects"
    mkdir -p "$HOME/scripts"
    mkdir -p "$HOME/notes"
    
    # Set proper permissions
    chmod 700 "$HOME/.ssh" 2>/dev/null || true
    chmod 600 "$HOME/.ssh/config" 2>/dev/null || true
    
    log SUCCESS "Final setup completed"
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --minimal)
                INSTALL_MODE="minimal"
                shift
                ;;
            --full)
                INSTALL_MODE="full"
                shift
                ;;
            --docker)
                INSTALL_DOCKER=true
                shift
                ;;
            --no-backup)
                CREATE_BACKUP=false
                shift
                ;;
            --verbose)
                VERBOSE=true
                set -x
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                log ERROR "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Show help message
show_help() {
    cat << EOF
Raspberry Pi Development Environment Bootstrap Script

Usage: $0 [options]

Options:
    --minimal    Install only essential packages
    --full       Install everything including optional packages
    --docker     Include Docker installation
    --no-backup  Skip backup of existing configurations
    --verbose    Enable verbose output
    --help       Show this help message

Default mode is 'standard' which includes most common development tools.

Examples:
    $0                    # Standard installation
    $0 --minimal          # Minimal installation
    $0 --full --docker    # Everything including Docker

EOF
}

# Main function
main() {
    # Set up error handling
    trap 'error_handler $LINENO $?' ERR
    trap cleanup EXIT
    
    # Show banner
    echo -e "${CYAN}"
    echo "============================================="
    echo "   Raspberry Pi Dev Environment Bootstrap"
    echo "============================================="
    echo -e "${NC}"
    
    # Parse arguments
    parse_arguments "$@"
    
    # Start logging
    log INFO "Bootstrap started at $(date)"
    log INFO "Installation mode: $INSTALL_MODE"
    log INFO "Log file: $LOG_FILE"
    
    # Run setup steps
    check_sudo
    check_system
    create_directories
    backup_configs
    update_system
    install_packages
    install_zsh
    install_neovim
    install_fonts
    install_docker
    install_languages
    install_additional_tools
    configure_git
    link_dotfiles
    final_setup
    
    # Success message
    echo -e "${GREEN}"
    echo "============================================="
    echo "   Bootstrap Completed Successfully!"
    echo "============================================="
    echo -e "${NC}"
    
    log SUCCESS "Bootstrap completed at $(date)"
    
    echo ""
    echo "Next steps:"
    echo "1. Log out and log back in (or restart) to apply all changes"
    echo "2. Run 'nvim' to complete Neovim plugin installation"
    echo "3. Configure your terminal to use a Nerd Font"
    
    if [[ "$INSTALL_DOCKER" == true ]]; then
        echo "4. Docker was installed - restart to apply group changes"
    fi
    
    echo ""
    echo "Backup location: $BACKUP_DIR"
    echo "Log file: $LOG_FILE"
    echo ""
    echo "Enjoy your new development environment! 🚀"
}

# Run main function
main "$@"
