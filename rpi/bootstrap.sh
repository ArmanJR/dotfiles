#!/usr/bin/env bash
# bootstrap.sh
# Sets up Zsh, Neovim, Nerd Fonts, and plugins on a fresh Raspberry Pi OS.

set -euo pipefail

# -----------------------------------
# CONFIGURATION
# -----------------------------------
DOTFILES_DIR="$HOME/dotfiles"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
FONTS_DIR="$HOME/.local/share/fonts"
NEOVIM_APPIMAGE="$HOME/nvim.appimage"

# List of packages to install via apt
APT_PACKAGES=(
    zsh git curl wget unzip fzf python3-pip nodejs npm fonts-dejavu fontconfig autojump
)

# Nerd Font to install
NERD_FONT_ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip" 
NERD_FONT_NAME="JetBrainsMono Nerd Font"

# -----------------------------------
# FUNCTIONS
# -----------------------------------

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install apt packages
install_apt_packages() {
    echo "Installing packages..."
    sudo apt update
    for pkg in "${APT_PACKAGES[@]}"; do
        if ! dpkg -s "$pkg" >/dev/null 2>&1; then
            echo "Installing $pkg..."
            sudo apt install -y "$pkg"
        else
            echo "$pkg already installed, skipping..."
        fi
    done
}

# Setup Oh My Zsh
setup_oh_my_zsh() {
    if [ ! -d "$OH_MY_ZSH_DIR" ]; then
        echo "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "Oh My Zsh already installed."
    fi
}

# Install zsh plugins
install_zsh_plugins() {
    local plugin_dir="$OH_MY_ZSH_DIR/custom/plugins"
    mkdir -p "$plugin_dir"

    # Autosuggestions
    if [ ! -d "$plugin_dir/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions.git "$plugin_dir/zsh-autosuggestions"
    fi

    # Syntax highlighting
    if [ ! -d "$plugin_dir/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugin_dir/zsh-syntax-highlighting"
    fi

    # History substring search
    if [ ! -d "$plugin_dir/zsh-history-substring-search" ]; then
        git clone https://github.com/zsh-users/zsh-history-substring-search.git "$plugin_dir/zsh-history-substring-search"
    fi

    # Completions
    if [ ! -d "$plugin_dir/zsh-completions" ]; then
        git clone https://github.com/zsh-users/zsh-completions.git "$plugin_dir/zsh-completions"
    fi
}

# Symlink dotfiles
link_dotfiles() {
    echo "Linking dotfiles from $DOTFILES_DIR..."
    # Example: adjust according to your repo structure
    ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    ln -sf "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
    mkdir -p "$NVIM_CONFIG_DIR"
    ln -sf "$DOTFILES_DIR/nvim/init.lua" "$NVIM_CONFIG_DIR/init.lua"
}

# Install Nerd Fonts
install_nerd_font() {
    mkdir -p "$FONTS_DIR"
    cd "$FONTS_DIR"
    echo "Downloading Nerd Font: $NERD_FONT_NAME"
    wget -q --show-progress "$NERD_FONT_ZIP_URL" -O nerd-font.zip
    unzip -o nerd-font.zip
    rm nerd-font.zip
    fc-cache -fv
    echo "Nerd Font installed."
}

# Install Neovim AppImage
install_neovim() {
    if [ ! -f "/usr/local/bin/nvim" ]; then
        echo "Downloading Neovim AppImage..."
        wget -q --show-progress https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.appimage -O "$NEOVIM_APPIMAGE"
        chmod +x "$NEOVIM_APPIMAGE"
        sudo mv "$NEOVIM_APPIMAGE" /usr/local/bin/nvim
    else
        echo "Neovim already installed."
    fi
}

# LazyVim setup
install_lazyvim() {
    if [ ! -d "$NVIM_CONFIG_DIR" ]; then
        echo "Installing LazyVim starter config..."
        git clone https://github.com/LazyVim/starter "$NVIM_CONFIG_DIR"
        rm -rf "$NVIM_CONFIG_DIR/.git"
    else
        echo "LazyVim config already exists."
    fi
}

# -----------------------------------
# MAIN
# -----------------------------------
echo "Starting bootstrap..."

install_apt_packages
setup_oh_my_zsh
install_zsh_plugins
link_dotfiles
install_nerd_font
install_neovim
install_lazyvim

echo "Bootstrap completed! Restart and enjoy your Raspberry Pi, captain."
