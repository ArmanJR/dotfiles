#!/usr/bin/env zsh

# =============================================================================
# macOS Apple Silicon .zshrc Configuration
# Optimized for Python, Go, Node.js development with productivity tools
# =============================================================================

# Performance monitoring (uncomment to debug startup time)
# zmodload zsh/zprof

# =============================================================================
# Environment Setup
# =============================================================================

# Set default editor to nvim
export EDITOR="nvim"
export VISUAL="nvim"

# Language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Zsh configuration directory
export ZDOTDIR="$HOME/.config/zsh"
ZSH_CONFIG_DIR="$HOME/.zsh"

# =============================================================================
# Module Loading
# =============================================================================

# Function to safely source files
source_if_exists() {
    [[ -f "$1" ]] && source "$1"
}

# Load all configuration modules
source_if_exists "$ZSH_CONFIG_DIR/homebrew.zsh"
source_if_exists "$ZSH_CONFIG_DIR/theme.zsh"
source_if_exists "$ZSH_CONFIG_DIR/languages.zsh"
source_if_exists "$ZSH_CONFIG_DIR/cloud-tools.zsh"
source_if_exists "$ZSH_CONFIG_DIR/dev-tools.zsh"
source_if_exists "$ZSH_CONFIG_DIR/editors.zsh"
source_if_exists "$ZSH_CONFIG_DIR/aliases.zsh"
source_if_exists "$ZSH_CONFIG_DIR/functions.zsh"

# Load local/private configurations (not tracked in git)
source_if_exists "$HOME/.zshrc.local"

# =============================================================================
# Zsh Options
# =============================================================================

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

# History options
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format
setopt INC_APPEND_HISTORY       # Write to the history file immediately, not when the shell exits
setopt SHARE_HISTORY            # Share history between all sessions
setopt HIST_EXPIRE_DUPS_FIRST   # Expire duplicate entries first when trimming history
setopt HIST_IGNORE_DUPS         # Don't record an entry that was just recorded again
setopt HIST_IGNORE_ALL_DUPS     # Delete old recorded entry if new entry is a duplicate
setopt HIST_FIND_NO_DUPS        # Do not display a line previously found
setopt HIST_IGNORE_SPACE        # Don't record an entry starting with a space
setopt HIST_SAVE_NO_DUPS        # Don't write duplicate entries in the history file
setopt HIST_REDUCE_BLANKS       # Remove superfluous blanks before recording entry
setopt HIST_VERIFY              # Don't execute immediately upon history expansion

# Directory options
setopt AUTO_PUSHD              # Push directories onto the stack automatically
setopt PUSHD_IGNORE_DUPS       # Don't push duplicate directories
setopt PUSHD_SILENT            # Don't print the directory stack after pushd/popd

# Completion options
setopt AUTO_MENU               # Show completion menu on successive tab press
setopt COMPLETE_IN_WORD        # Allow completion from within a word/phrase
setopt ALWAYS_TO_END           # Move cursor to end of word after completion
setopt PATH_DIRS               # Perform path search even on command names with slashes

# Other useful options
setopt INTERACTIVE_COMMENTS    # Allow comments even in interactive shells
setopt MULTIOS                 # Write to multiple descriptors
setopt EXTENDED_GLOB           # Use extended globbing syntax
setopt GLOB_DOTS               # Include dotfiles in globbing

# =============================================================================
# Key Bindings
# =============================================================================

# Use emacs key bindings
bindkey -e

# Better history search
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward

# Word movement (Option + arrow keys)
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# Performance monitoring output (uncomment if enabled above)
# zprof

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
