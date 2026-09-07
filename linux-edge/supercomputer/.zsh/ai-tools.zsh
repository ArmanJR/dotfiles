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
alias ccx='claudeskip'

# MCP tool installer
# Usage: ccmcp <tool> <api-key>
ccmcp() {
  local tool="$1"
  local key="$2"
  case "$tool" in
    c7)
      claude mcp add --header "CONTEXT7_API_KEY: ${key}" --transport http context7 https://mcp.context7.com/mcp
      ;;
    *)
      echo "Unknown MCP tool: ${tool}" >&2
      echo "Available: c7" >&2
      return 1
      ;;
  esac
}

# =============================================================================
# Codex
# =============================================================================

# Skip approvals and sandbox (use with caution)
alias codexskip="codex --dangerously-bypass-approvals-and-sandbox"
