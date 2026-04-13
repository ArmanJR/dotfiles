# =============================================================================
# Powerlevel10k Theme Configuration
# =============================================================================

# Source powerlevel10k from git clone location
P10K_PATH="$HOME/powerlevel10k/powerlevel10k.zsh-theme"

if [[ -f "$P10K_PATH" ]]; then
    source "$P10K_PATH"
else
    echo "Powerlevel10k not found. Install with: git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k"
fi

# Powerlevel10k configuration
# Font settings (JetBrains Mono Nerd Font)
typeset -g POWERLEVEL9K_MODE='nerdfont-complete'

# Left prompt elements
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir                         # Current directory
    vcs                        # Git status
    newline                    # Line break
    prompt_char                # Prompt character
)

# Right prompt elements
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status                     # Exit code of last command
    command_execution_time     # Duration of last command
    background_jobs           # Background jobs indicator
    virtualenv                # Python virtual environment
    pyenv                     # Python version from pyenv
    goenv                     # Go version from goenv
    nodeenv                   # Node.js version
    context                   # User@hostname
    time                      # Current time
)

# Directory configuration
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=false
typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=4

# Git status configuration
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=green
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=yellow
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=red

# Command execution time
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=1

# Context (user@hostname) - only show when relevant
typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=
typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND=144
typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=1

# Prompt character
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=green
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=red

# Python virtual environment
typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=blue
typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=false

# Load custom p10k configuration if it exists
[[ ! -f "$HOME/.zsh/.p10k.zsh" ]] || source "$HOME/.zsh/.p10k.zsh"
