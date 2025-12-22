# macOS Dotfiles

Modular zsh configuration for Apple Silicon Macs.

## First-Time Setup

```bash
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. Install core tools
brew install git
brew install romkatv/powerlevel10k/powerlevel10k
brew install fd ripgrep bat eza fzf zoxide nvim
brew install --cask ghostty font-jetbrains-mono-nerd-font

# 3. Install shell history (optional but recommended)
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

# 4. Clone dotfiles
git clone https://github.com/ArmanJR/dotfiles ~/code/dotfiles

# 5. Sync all configs
~/code/dotfiles/mac/sync.sh --all

# 6. Reload shell
source ~/.zshrc
```

## Syncing Dotfiles

After setup, use `dotsync` to pull and sync:

```bash
dotsync --all          # Sync everything
dotsync --zsh          # .zsh directory
dotsync --zshrc        # .zshrc file
dotsync --dotfiles     # git, ripgrep, ghostty configs
dotsync --claude       # Claude Code settings
dotsync --vscode       # VSCode settings.json
```
