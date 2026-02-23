## Bootstrap (new machine)

```bash
brew install chezmoi          # macOS
# or: sh -c "$(curl -fsLS get.chezmoi.io)"  # Linux

chezmoi init --source ~/code/dotfiles --apply
# Prompts: is_server, has_gui, machine_type
```

---

## Daily workflow

### Pull changes from another machine

```bash
cd ~/code/dotfiles && git pull
chezmoi diff        # review what will change
chezmoi apply
```

### Edit a file and push

Two paths depending on where you start:

**A. Edited the live file on disk (e.g. tweaked `~/.zsh/.p10k.zsh` directly):**
```bash
chezmoi re-add ~/.zsh/.p10k.zsh      # copies live → source
cd ~/code/dotfiles
git add -p && git commit -m "..." && git push
```

**B. Edit via chezmoi (opens source file directly):**
```bash
chezmoi edit ~/.zsh/.p10k.zsh        # opens home/dot_zsh/dot_p10k.zsh
chezmoi apply ~/.zsh/.p10k.zsh       # apply just that file
cd ~/code/dotfiles
git add -p && git commit -m "..." && git push
```

> **Template files** (`.tmpl`) must always be edited in the source — `chezmoi edit` or directly in `home/`. You cannot `re-add` a template.
> Preview a template: `chezmoi execute-template < home/dot_zsh/aliases.zsh.tmpl`

---

## Add a new dotfile

```bash
chezmoi add ~/.somerc                # plain file
chezmoi add --template ~/.somerc    # if it needs OS conditionals

cd ~/code/dotfiles
git add home/ && git commit -m "feat: add somerc"
git push
```

## Remove a managed dotfile

```bash
chezmoi forget ~/.somerc             # stops tracking; leaves file on disk
# or to also delete from disk:
chezmoi destroy ~/.somerc

cd ~/code/dotfiles
git rm home/<chezmoi-name> && git commit -m "chore: remove somerc"
git push
```

---

## Useful commands

| Command | What it does |
|---|---|
| `chezmoi diff` | Preview what `apply` would change |
| `chezmoi apply` | Apply source → disk |
| `chezmoi apply ~/.zshrc` | Apply one file only |
| `chezmoi re-add ~/.zshrc` | Sync live file back into source |
| `chezmoi edit ~/.zshrc` | Open source file in `$EDITOR` |
| `chezmoi managed` | List all managed files |
| `chezmoi verify` | Check if disk matches source (exit 0 = in sync) |
| `chezmoi cd` | `cd` into the source directory |

---

## Repo layout

```
dotfiles/
├── .chezmoiroot           # tells chezmoi the source root is home/
├── rpi/bootstrap.sh       # one-time system bootstrap (not managed by chezmoi)
└── home/                  # chezmoi source state
    ├── .chezmoi.yaml.tmpl # machine config prompts (is_server, has_gui, machine_type)
    ├── .chezmoiignore     # OS/GUI conditional exclusions
    ├── dot_zsh/           # ~/.zsh/ modules (*.tmpl = OS-conditional)
    ├── private_dot_claude/ # ~/.claude/ (chmod 700)
    ├── private_dot_config/ # ~/.config/
    ├── dot_obsidian/      # ~/.obsidian/ (GUI machines only)
    └── vscode/            # VSCode settings (applied via run scripts)
```

Files named `private_` get `chmod 700`. Files named `executable_` get `chmod +x`. Files named `exact_` remove untracked files in that directory.
