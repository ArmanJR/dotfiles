# macOS Dotfiles

Zsh-based development environment for macOS Apple Silicon. Managed via `sync.sh`, which diffs local files against this repo and applies changes interactively through `fzf`.

## Structure

```
.zshrc                    # Entry point — loads modules from .zsh/
.zshenv                   # Cargo env (sourced before .zshrc)
.zprofile                 # Homebrew shellenv
.zsh/
  homebrew.zsh            # Homebrew paths, env vars
  theme.zsh               # Powerlevel10k config
  history.zsh             # Atuin shell history
  languages.zsh           # Python (uv/pyenv), Go, Node (fnm), Rust, Bun
  cloud-tools.zsh         # AWS, GCP, Terraform, Pulumi
  dev-tools.zsh           # Docker, k8s, SSH, networking
  editors.zsh             # Neovim, VSCode, Zed, fzf integration
  ai-tools.zsh            # Claude Code aliases
  aliases.zsh             # General aliases (eza, fd, rg, bat replacements)
  functions.zsh           # Utility functions, project scaffolding
  .p10k.zsh               # Powerlevel10k theme file
.gitconfig                # Git core config (editor: zed)
.gitignore_global         # Global gitignore
.ripgreprc                # ripgrep defaults
ghostty.config            # Ghostty terminal config
.config/
  atuin/config.toml       # Atuin history config
  prek/                   # Pre-commit hook templates (default, python, go)
  zed/                    # Zed editor settings + keymap
.claude/                  # Claude Code settings, statusline, custom commands
vscode/                   # VSCode settings, keybindings, extensions list
sync.sh                   # Sync script
```

## New Device Setup

```bash
# 1. Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. Core CLI tools
brew install git jq
brew install fd ripgrep bat eza fzf zoxide nvim uv

# 3. Shell theme & font
brew install romkatv/powerlevel10k/powerlevel10k
brew install --cask font-jetbrains-mono-nerd-font

# 4. Terminal emulator
brew install --cask ghostty

# 5. Shell history
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

# 6. Rust toolchain (needed for cargo binaries, sourced in .zshenv)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 7. Node.js (fnm, preferred over nvm)
brew install fnm

# 8. Go
brew install go

# 9. Editors (optional, install what you use)
brew install --cask visual-studio-code
brew install --cask zed

# 10. Claude Code (optional)
npm install -g @anthropic-ai/claude-code

# 11. Clone & sync
git clone https://github.com/ArmanJR/dotfiles ~/code/dotfiles
~/code/dotfiles/mac/sync.sh --all

# 12. VSCode extensions (optional)
~/code/dotfiles/mac/vscode/install-extensions.sh

# 13. Reload
exec zsh
```

## Syncing

`sync.sh` pulls the latest repo, compares files against their targets, shows diffs via `fzf`, and applies selected changes with backups.

```
sync.sh --all          # Sync all configs
sync.sh --dry-run      # Preview changes without applying
sync.sh --agentic      # Non-interactive JSON manifest for AI agents
sync.sh --apply PATH --ids 1,3  # Apply specific changes from a manifest
```

Individual targets:

| Flag | What it syncs |
|------|---------------|
| `--zsh` | `~/.zsh/` |
| `--zshrc` | `~/.zshrc` |
| `--dotfiles` | `~/.zshenv`, `~/.zprofile`, `~/.gitconfig`, `~/.gitignore_global`, `~/.ripgreprc`, `ghostty.config` |
| `--claude` | `~/.claude/` |
| `--vscode` | `~/Library/Application Support/Code/User/settings.json` |
| `--atuin` | `~/.config/atuin/config.toml` |
| `--zed` | `~/.config/zed/` |
| `--prek` | `~/.config/prek/` |

Flags can be combined: `sync.sh --zsh --zshrc --dotfiles`.

## Notes

- Shell scripts synced via `--claude` (e.g. `statusline.sh`) must be executable in git. Fix with: `git update-index --chmod=+x <file>`.
- `--all` syncs everything. Use `--dry-run` first to preview changes on a fresh machine.
