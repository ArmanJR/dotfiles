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
brew install fd ripgrep bat exa fzf zoxide nvim git
brew install --cask ghostty font-jetbrains-mono-nerd-font
```

### 3. Setup Configuration
```bash
# Clone or copy dotfiles to ~/code/dotfiles/mac
git clone <your-repo> ~/code/dotfiles/mac

# Backup existing config
mv ~/.zshrc ~/.zshrc.backup 2>/dev/null || true

# Symlink new config
ln -sf ~/code/dotfiles/mac/.zshrc ~/.zshrc

# Reload shell
source ~/.zshrc
```

### 4. Configure Powerlevel10k
```bash
p10k configure
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

## Features

- **Modular Configuration**: Organized in `.zsh/` directory
- **Fast Loading**: Optimized for quick shell startup
- **200+ Aliases**: Comprehensive command shortcuts
- **Modern Tools**: Integration with fd, ripgrep, bat, fzf
- **Development Ready**: Python (UV), Go, Node.js, Docker, K8s
- **Cloud Tools**: GCloud, AWS, Terraform support
- **Productivity**: Focus mode, Pomodoro timer, project templates

## Customization

- Edit modules in `.zsh/` directory
- Add private config to `~/.zshrc.local`
- Use `reload` command to apply changes

## Cheat Sheet

Print `zsh-cheatsheet.md` for quick reference of all available commands.

## Troubleshooting

- Run `brew doctor` if tools aren't found
- Use `which <command>` to verify installation paths
- Check `~/.zshrc.local` for local overrides
