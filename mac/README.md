# macOS Dotfiles

Zsh-based development environment for macOS Apple Silicon. Managed via `sync.sh`, which diffs local files against this repo and applies changes interactively through `fzf`.

## Structure

```
Brewfile                 # Homebrew bundle for new-device package setup
.zshrc                    # Entry point — loads modules from .zsh/
.zshenv                   # Cargo env (sourced before .zshrc)
.zprofile                 # Homebrew shellenv
.zsh/
  homebrew.zsh            # Homebrew paths, env vars
  theme.zsh               # Powerlevel10k config
  languages.zsh           # Python (uv/pyenv), Go, Node (fnm), Rust, Bun
  cloud-tools.zsh         # AWS, GCP, Terraform, Pulumi
  dev-tools.zsh           # Docker, k8s, SSH, networking
  editors.zsh             # Neovim, VSCode, Zed, fzf integration
  ai-tools.zsh            # AI tool aliases (Codex, Claude Code, OpenCode)
  aliases.zsh             # General aliases and shell utilities
  functions.zsh           # Utility functions, project scaffolding
  .p10k.zsh               # Powerlevel10k theme file
.gitignore_global         # Global gitignore
.ripgreprc                # ripgrep defaults
ghostty.config            # Ghostty terminal config
.config/
  nvim/                   # Neovim config
  opencode/               # OpenCode cloud/local config
  prek/                   # Pre-commit hook templates (default, python, go)
  zed/                    # Zed editor settings + keymap
.codex/                   # Codex CLI config
.claude/                  # Claude Code settings, statusline, custom commands
vscode/                   # VSCode settings, keybindings, extensions list
sync.sh                   # Sync script
```

## New Device Setup

```bash
# 1. Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

<<<<<<< HEAD
# 2. Core CLI tools
brew install git jq
brew install fd ripgrep bat eza fzf zoxide duf nvim uv
=======
# 2. Clone dotfiles
git clone https://github.com/ArmanJR/dotfiles ~/code/dotfiles
>>>>>>> 0354593 (chore: add brew bundle setup)

# 3. Homebrew packages
brew bundle --file ~/code/dotfiles/mac/Brewfile

# 4. Rust toolchain (needed for cargo binaries, sourced in .zshenv)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 5. Claude Code (optional)
eval "$(fnm env --shell zsh)"
fnm install --lts
fnm default lts-latest
fnm use lts-latest
npm install -g @anthropic-ai/claude-code

# 6. Sync configs
~/code/dotfiles/mac/sync.sh --all

# 7. VSCode extensions (optional)
~/code/dotfiles/mac/vscode/install-extensions.sh

# 8. Reload
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
| `--dotfiles` | `~/.zshenv`, `~/.zprofile`, `~/.gitignore_global`, `~/.ripgreprc`, `ghostty.config` |
| `--codex` | `~/.codex/` |
| `--claude` | `~/.claude/` |
| `--opencode` | `~/.config/opencode/` |
| `--vscode` | `~/Library/Application Support/Code/User/settings.json` |
| `--nvim` | `~/.config/nvim/` |
| `--zed` | `~/.config/zed/` |
| `--prek` | `~/.config/prek/` |
| `--tmux` | `~/.tmux.conf` |

Flags can be combined: `sync.sh --zsh --codex --dotfiles`.

## Notes

- Shell scripts synced via `--claude` (e.g. `statusline.sh`) must be executable in git. Fix with: `git update-index --chmod=+x <file>`.
- `--all` syncs everything. Use `--dry-run` first to preview changes on a fresh machine.
