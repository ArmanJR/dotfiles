# tmux cheatsheet

Prefix: **`C-a`** (Ctrl+a). Press before any binding.

## Sessions

| Command | What it does |
|---|---|
| `tmux new -s name` | Create named session |
| `tmux ls` | List sessions |
| `tmux attach -t name` | Attach to session |
| `C-a d` | Detach from session |
| `C-a $` | Rename session |

## Windows (tabs)

| Command | What it does |
|---|---|
| `C-a c` | New window (in current path) |
| `C-a ,` | Rename window |
| `C-a n` / `C-a p` | Next / previous window |
| `C-a 1-9` | Jump to window by number |
| `C-a &` | Kill window |

## Panes (splits)

| Command | What it does |
|---|---|
| `C-a \|` | Split vertical |
| `C-a -` | Split horizontal |
| `C-a h/j/k/l` | Navigate panes (vim-style) |
| `C-a H/J/K/L` | Resize panes (repeatable) |
| `C-a z` | Toggle pane zoom (fullscreen) |
| `C-a x` | Kill pane |
| `C-a q` | Show pane numbers (press number to jump) |

## Copy mode

| Command | What it does |
|---|---|
| `C-a [` | Enter copy mode (scroll/search) |
| `v` | Start selection |
| `y` | Copy to clipboard |
| `/` | Search forward |
| `q` | Exit copy mode |

## Other

| Command | What it does |
|---|---|
| `C-a r` | Reload config |
| `C-a ?` | List all keybindings |
| `C-a :` | Command prompt |

## Day-to-day workflow

```
tmux new -s project       # start working
# ... split panes, open editors, run servers ...
C-a d                     # detach when done (session stays alive)
tmux attach -t project    # pick up where you left off
```
