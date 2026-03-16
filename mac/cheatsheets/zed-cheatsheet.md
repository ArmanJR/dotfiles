# Zed Editor Cheat Sheet (JetBrains Keymap)

Based on `"base_keymap": "JetBrains"` in settings.json.

## File Operations
```
Cmd+E / Cmd+Shift+O       # Open file finder
Cmd+N / Cmd+Alt+O         # Project symbols
Cmd+Shift+A / Shift Shift # Command palette
Cmd+S                     # Save
Cmd+Alt+S                 # Save all
Cmd+K S                   # Save without format
Cmd+W                     # Close active tab
Cmd+Shift+T               # Reopen closed tab
```

## Navigation
```
Cmd+B                     # Go to definition
Cmd+Alt+B                 # Go to implementation
Cmd+Shift+B               # Go to type definition
Cmd+[                     # Go back
Cmd+]                     # Go forward
Cmd+L                     # Go to line
Cmd+F12                   # Outline (symbols in file)
Cmd+Home / Cmd+End        # Move to file beginning/end
Cmd+Left / Cmd+Right      # Move to line start/end
Alt+Left / Alt+Right      # Move by word
Ctrl+Up / Ctrl+Down       # Move by paragraph
```

## Search & Replace
```
Cmd+F                     # Find in file
Cmd+R                     # Find and replace in file
Cmd+G / Shift+Cmd+G       # Next/previous match
Cmd+Shift+F               # Find in project
Cmd+Shift+R               # Find and replace in project
Alt+Cmd+W                 # Toggle whole word
Alt+Cmd+C                 # Toggle case sensitive
Alt+Cmd+X                 # Toggle regex
```

## Editing
```
Cmd+D                     # Duplicate line/selection
Cmd+Backspace             # Delete line
Cmd+/                     # Toggle comment
Ctrl+Shift+J              # Join lines
Shift+Enter               # New line below
Cmd+Alt+Enter             # New line above
Shift+Alt+Up/Down         # Move line up/down
Tab / Shift+Tab           # Indent/outdent
Cmd+Z / Cmd+Shift+Z       # Undo/redo
Cmd+X / Cmd+C / Cmd+V     # Cut/copy/paste
Cmd+Shift+U               # Toggle case
Cmd+Alt+L                 # Format document
Ctrl+Alt+O                # Organize imports
```

## Selection & Multi-cursor
```
Ctrl+G                    # Select next occurrence
Ctrl+Shift+G              # Undo last selection
Ctrl+Cmd+G                # Select previous occurrence
Cmd+Shift+L               # Select all occurrences
Alt+Shift+G               # Split selection into lines
Alt+Up / Alt+Down         # Select larger/smaller syntax node
Cmd+A                     # Select all
Cmd+L                     # Select line (default context)
```

## Folding
```
Cmd+- / Cmd++             # Fold/unfold at cursor
Cmd+K Cmd+0               # Fold all
Cmd+K Cmd+J               # Unfold all
Cmd+K Cmd+1-9             # Fold at level
```

## Code Intelligence (LSP)
```
Ctrl+Space                # Show completions
Alt+Enter                 # Code actions (quick fix)
Shift+F6                  # Rename symbol
Cmd+J                     # Hover documentation
Cmd+P                     # Show signature help
Alt+F7 / Cmd+Alt+F7       # Find all references
F2 / Shift+F2             # Next/previous diagnostic
Ctrl+Alt+Shift+Down/Up    # Next/previous hunk
```

## Panels (Cmd+Number)
```
Cmd+1                     # Project panel
Cmd+5                     # Debug panel
Cmd+6                     # Diagnostics
Cmd+7                     # Outline panel
Cmd+0 / Cmd+K             # Git panel
Cmd+Shift+F12             # Toggle all docks
Escape                    # Focus back to editor
Shift+Escape              # Close active dock
```

## Tabs & Panes
```
Alt+Left / Alt+Right      # Previous/next tab
Cmd+{ / Cmd+}             # Previous/next tab (alt)
Cmd+Alt+Left/Right        # Go back/forward in history
Cmd+1-9 (in pane)         # Activate pane by number
Cmd+\                     # Split right
Cmd+K Up/Down/Left/Right  # Split pane in direction
```

## Terminal
```
Alt+F12                   # Toggle terminal panel
Cmd+T                     # New terminal
Cmd+Up / Cmd+Down         # Scroll up/down
Shift+PageUp/PageDown     # Scroll page up/down
Cmd+K                     # Clear terminal
```

## Git
```
Cmd+K                     # Git panel
Cmd+~                     # Switch branch
Cmd+Shift+K               # Git push
Cmd+Alt+G B               # Git blame
Cmd+Alt+G M               # Open modified files
Cmd+Alt+G R               # Review diff
Cmd+Y / Cmd+Shift+Y       # Stage/unstage file
Cmd+Enter                 # Commit
Cmd+Shift+Enter           # Amend
```

## Debugging
```
Shift+F9 / Alt+Shift+F9   # Start debugger
Ctrl+F2                   # Stop debugger
Cmd+Shift+F5              # Rerun session
F6                        # Pause
F7                        # Step into
F8                        # Step over
Shift+F8                  # Step out
F9                        # Continue
Ctrl+F8                   # Toggle breakpoint
Ctrl+Shift+F8             # Edit log breakpoint
```

## Tasks
```
Ctrl+Alt+R / Shift+F10    # Run task
Cmd+F5                    # Rerun last task
```

## Project Panel
```
Enter                     # Open file
Cmd+Backspace / Delete     # Trash file
Shift+Delete              # Permanently delete
Shift+F6                  # Rename
Cmd+Shift+F               # Search in directory
Cmd+N                     # New file (custom binding)
```

## Appearance
```
Cmd+, / Cmd+Alt+,         # Open settings / settings file
Cmd+K Cmd+T               # Theme selector
Cmd+K Cmd+S               # Open keymap
Cmd+= / Cmd+-             # Increase/decrease font size
Cmd+0                     # Reset font size
```

## Custom Bindings (keymap.json)
```
Cmd+G                     # Copy permalink to line
Cmd+N                     # New file (workspace & project panel)
Alt+Escape                # Close item in all panes
```
