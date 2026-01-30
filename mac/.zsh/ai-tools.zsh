# =============================================================================
# AI Tools Configuration
# =============================================================================

# =============================================================================
# Claude Code
# =============================================================================

# Claude ignition script - removes all aliases from Claude's Bash commands
export CLAUDE_ENV_FILE="$HOME/.claude/ignition.sh"

# Claude Code aliases
alias claude='~/.local/bin/claude'
alias claudeskip='~/.local/bin/claude --dangerously-skip-permissions'

# Short aliases
alias cc='claude'
alias ccskip='claudeskip'

# =============================================================================
# Codex
# =============================================================================

# Skip approvals and sandbox (use with caution)
alias codexskip="codex --dangerously-bypass-approvals-and-sandbox"
