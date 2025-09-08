# LazyVim Cheat Sheet

## 🚀 Essential Navigation

### File Operations
```
<leader>ff          # Find files (Telescope)
<leader>fg          # Live grep search
<leader>fb          # Find buffers
<leader>fr          # Recent files
<leader>fc          # Find config files
<leader><leader>    # Switch between last two files
:w                  # Save file
:wa                 # Save all files
:q                  # Quit
:qa                 # Quit all
:wq                 # Save and quit
```

### Buffer Management
```
<S-h>               # Previous buffer
<S-l>               # Next buffer
<leader>bd          # Delete buffer
<leader>bD          # Delete buffer (force)
<leader>bp          # Pin/unpin buffer
```

### Window Management
```
<C-h/j/k/l>            # Navigate windows
<C-Up/Down/Left/Right> # Resize windows
<leader>wd             # Delete window
<leader>w-             # Split window below
<leader>w|             # Split window right
<leader>wm             # Maximize toggle
```

## 📁 File Explorer (Neo-tree)

### Toggle & Navigation
```
<leader>fe          # Toggle file explorer
<leader>fE          # Toggle explorer (float)
<leader>be          # Toggle buffers in explorer
<leader>ge          # Toggle git explorer
```

### Inside Neo-tree
```
<Space>             # Toggle node
<Enter>             # Open file
<C-s>               # Open horizontal split
<C-v>               # Open vertical split
a                   # Add file/folder
d                   # Delete
r                   # Rename
c                   # Copy
x                   # Cut
p                   # Paste
R                   # Refresh
H                   # Toggle hidden files
```

## 🔍 Search & Replace

### Telescope (Fuzzy Finder)
```
<leader>ff          # Find files
<leader>fg          # Live grep
<leader>fw          # Grep word under cursor
<leader>fb          # Find buffers
<leader>fo          # Find old files
<leader>fh          # Find help tags
<leader>fk          # Find keymaps
<leader>fc          # Find commands
<leader>f"          # Find registers
<leader>fm          # Find marks
```

### Search in File
```
/pattern            # Search forward
?pattern            # Search backward
n                   # Next match
N                   # Previous match
*                   # Search word under cursor (forward)
#                   # Search word under cursor (backward)
<leader>nh          # Clear search highlight
```

### Search & Replace
```
:%s/old/new/g       # Replace all in file
:%s/old/new/gc      # Replace all with confirm
:s/old/new/g        # Replace in current line
<leader>sr          # Spectre search/replace
```

## ✏️ Editing & Text Objects

### Basic Editing
```
i                   # Insert before cursor
I                   # Insert at beginning of line
a                   # Insert after cursor
A                   # Insert at end of line
o                   # New line below
O                   # New line above
<Esc>               # Exit insert mode
```

### Movement
```
h/j/k/l             # Left/Down/Up/Right
w/b                 # Next/previous word
W/B                 # Next/previous WORD
e/ge                # End of word
0/^                 # Beginning of line
$                   # End of line
gg/G                # Beginning/end of file
{/}                 # Previous/next paragraph
f/F + char          # Find character forward/backward
t/T + char          # Till character forward/backward
```

### Text Objects & Motions
```
yy                  # Yank line
dd                  # Delete line
cc                  # Change line
dw                  # Delete word
cw                  # Change word
diw                 # Delete inner word
ciw                 # Change inner word
di"/ci"             # Delete/change inside quotes
da"/ca"             # Delete/change around quotes
dip/cip             # Delete/change inner paragraph
```

### Multi-cursor (vim-visual-multi)
```
<C-n>               # Select word, add next occurrence
<C-Down/Up>         # Add cursor above/below
<Tab>               # Switch between cursor and extend mode
q                   # Skip current match
Q                   # Remove current cursor
```

## 💻 LSP (Language Server)

### Code Navigation
```
gd                  # Go to definition
gD                  # Go to declaration
gr                  # Go to references
gi                  # Go to implementation
gy                  # Go to type definition
K                   # Hover documentation
<C-k>               # Signature help (insert mode)
<leader>ca          # Code actions
<leader>cr          # Rename symbol
<leader>cf          # Format document
<leader>cd          # Line diagnostics
```

### Diagnostics
```
]d                  # Next diagnostic
[d                  # Previous diagnostic
]e                  # Next error
[e                  # Previous error
<leader>cd          # Line diagnostics
<leader>cD          # Workspace diagnostics
```

## 🐛 Debugging (nvim-dap)

### Debug Controls
```
<leader>dB          # Toggle breakpoint
<leader>db          # Toggle breakpoint (condition)
<leader>dc          # Continue
<leader>dC          # Run to cursor
<leader>dg          # Go to line (no execute)
<leader>di          # Step into
<leader>dj          # Down
<leader>dk          # Up
<leader>dl          # Run last
<leader>do          # Step out
<leader>dO          # Step over
<leader>dp          # Pause
<leader>dr          # REPL toggle
<leader>ds          # Session
<leader>dt          # Terminate
<leader>dw          # Widgets
```

## 📦 Plugin Management (Lazy)

### Lazy Commands
```
<leader>l           # Open Lazy UI
:Lazy               # Open Lazy
:Lazy update        # Update all plugins
:Lazy sync          # Sync plugins
:Lazy clean         # Clean unused plugins
:Lazy health        # Health check
```

## 🌳 Git Integration (LazyGit)

### Git Operations
```
<leader>gg          # LazyGit
<leader>gf          # LazyGit (current file)
<leader>gl          # LazyGit log
<leader>gL          # LazyGit log (current file)
```

### Inside LazyGit
```
<Space>             # Stage/unstage
c                   # Commit
C                   # Commit (verbose)
P                   # Push
p                   # Pull
R                   # Refresh
q                   # Quit
<Tab>               # Switch panels
```

## 🔧 Terminal Integration

### Terminal
```
<leader>ft          # Terminal (root dir)
<leader>fT          # Terminal (cwd)
<C-/>               # Terminal toggle
<C-_>               # Terminal toggle (alternative)
```

### In Terminal Mode
```
<C-h/j/k/l>         # Navigate to windows
<Esc><Esc>          # Enter normal mode
```

## 📋 Clipboard & Registers

### Clipboard Operations
```
y                   # Yank (copy)
d                   # Delete (cut)
p                   # Paste after cursor
P                   # Paste before cursor
"+y                 # Yank to system clipboard
"+p                 # Paste from system clipboard
```

### Registers
```
"ay                 # Yank to register 'a'
"ap                 # Paste from register 'a'
:reg                # Show all registers
<leader>f"          # Find registers (Telescope)
```

## ⚡ Quick Actions

### Folding
```
za                  # Toggle fold
zc                  # Close fold
zo                  # Open fold
zR                  # Open all folds
zM                  # Close all folds
```

### Macros
```
qa                  # Start recording macro 'a'
q                   # Stop recording
@a                  # Play macro 'a'
@@                  # Repeat last macro
```

### Marks
```
ma                  # Set mark 'a'
'a                  # Go to mark 'a'
''                  # Go to previous position
<leader>fm          # Find marks (Telescope)
```

## 🎨 UI & Appearance

### Notifications & Messages
```
<leader>un          # Dismiss notifications
<leader>sn          # Noice (messages)
```

### Which-key
```
<leader>wk          # Open which-key
<leader>wK          # Open which-key (buffer)
```


