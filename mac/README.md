# macOS Dotfiles

## New Device Setup

```bash
# 1. Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. Core tools
brew install git romkatv/powerlevel10k/powerlevel10k
brew install fd ripgrep bat eza fzf zoxide nvim uv
brew install --cask ghostty font-jetbrains-mono-nerd-font

# 3. Shell history
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

# 4. Clone & sync everything (including Claude setup)
git clone https://github.com/ArmanJR/dotfiles ~/code/dotfiles
~/code/dotfiles/mac/sync.sh --init

# 5. VSCode extensions (optional)
~/code/dotfiles/mac/vscode/install-extensions.sh

# 6. Reload shell
source ~/.zshrc
```

## Syncing

```bash
sync.sh --all          # Sync everything (no setup scripts)
sync.sh --init         # Sync everything + run setup scripts (new device)
sync.sh --zsh          # .zsh directory
sync.sh --zshrc        # .zshrc
sync.sh --dotfiles     # .gitconfig, .gitignore_global, .ripgreprc, ghostty.config
sync.sh --claude       # .claude directory
sync.sh --vscode       # VSCode settings.json
sync.sh --atuin        # Atuin config
sync.sh --zed          # Zed config
sync.sh --prek         # prek hook templates
sync.sh --dry-run      # Preview changes without applying
```

## Notes

- Shell scripts synced via `--claude` (e.g. `statusline.sh`) must be marked executable in git (`100755`) so `rsync -a` preserves the `+x` bit. Fix with: `git update-index --chmod=+x <file>`.

## What's Managed

| Path | Flag |
|------|------|
| `~/.zsh/` | `--zsh` |
| `~/.zshrc` | `--zshrc` |
| `~/.gitconfig`, `~/.gitignore_global`, `~/.ripgreprc`, `~/.config/ghostty/config` | `--dotfiles` |
| `~/.claude/` | `--claude` |
| `~/Library/Application Support/Code/User/settings.json` | `--vscode` |
| `~/.config/atuin/config.toml` | `--atuin` |
| `~/.config/zed/` | `--zed` |
| `~/.config/prek/` | `--prek` |
