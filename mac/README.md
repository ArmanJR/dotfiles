# macOS Dotfiles Setup

Modern, modular zsh configuration optimized for Apple Silicon Macs with Python, Go, Node.js development.

## Quick Setup

### 1. Install Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install Core Tools
```bash
brew install romkatv/powerlevel10k/powerlevel10k
brew install fd tree ripgrep bat exa fzf zoxide nvim git
brew install --cask ghostty font-jetbrains-mono-nerd-font
```

### 3. Setup Configuration
```bash
# Clone or copy dotfiles to ~/code/dotfiles/mac
git clone https://github.com/armanjr/dotfiles ~/code/dotfiles/

# Backup existing config
mv ~/.zshrc ~/.zshrc.backup 2>/dev/null || true

# Copy new config
cp -R ~/code/dotfiles/mac/.zsh ~/code/dotfiles/mac/.zshrc ~/code/dotfiles/mac/.ripgreprc ~/

# Reload shell
source ~/.zshrc
```

## Optional Development Tools

### Python Development
```bash
brew install python uv pyenv
```

### Go Development
```bash
brew install go
```

### Node.js Development
```bash
brew install fnm
fnm install --lts
```

### Cloud & Container Tools
```bash
brew install docker kubernetes-cli terraform
brew install --cask google-cloud-sdk
```

### Additional Productivity Tools
```bash
brew install jq httpie ncdu dust cheat
```
