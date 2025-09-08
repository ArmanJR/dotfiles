# =============================================================================
# Powerlevel10k Theme Configuration
# =============================================================================

# Install powerlevel10k if not already installed
P10K_PATH="$HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme"
P10K_FALLBACK_PATH="$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme"

# Source powerlevel10k from homebrew installation first, then fallback to oh-my-zsh
if [[ -f "$P10K_PATH" ]]; then
    source "$P10K_PATH"
elif [[ -f "$P10K_FALLBACK_PATH" ]]; then
    source "$P10K_FALLBACK_PATH"
else
    echo "⚠️  Powerlevel10k not found. Install with: brew install romkatv/powerlevel10k/powerlevel10k"
fi

# Enable Powerlevel10k instant prompt (should stay close to the top of .zshrc)
# Initialization code that may require console input should go above this block
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Powerlevel10k configuration (you can customize this or run `p10k configure`)
# This is a minimal configuration optimized for development workflow

# Enable instant prompt
typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose

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
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh