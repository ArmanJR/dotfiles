# =============================================================================
# AI Tools Configuration
# =============================================================================

# MCP aliases: name -> configured server, with optional command/argument overrides.
# Other configured MCP server names can be passed directly to --mcp.
typeset -gA AI_MCP_SERVERS=(chrome chrome-devtools chrome-anon chrome-devtools)
typeset -gA AI_MCP_COMMANDS=(chrome npx chrome-anon npx)
typeset -gA AI_MCP_ARGS=(
  chrome '["-y", "chrome-devtools-mcp@latest", "--autoConnect"]'
  chrome-anon '["-y", "chrome-devtools-mcp@latest", "--isolated"]'
)

# Usage: ai [--mcp NAME]... [Codex arguments]
# Context7 stays enabled.
# Use -- before a prompt containing literal --mcp.
if (( ${+aliases[ai]} )); then
  unalias ai
fi
function ai {
  emulate -L zsh
  setopt localoptions pipefail
  local -a selected forwarded discovery overrides servers
  local name server key listing value
  local -A chosen

  while (( $# )); do
    case "$1" in
      --mcp)
        if (( $# < 2 )) || [[ -z "$2" || "$2" == -* ]]; then
          print -u2 'ai: --mcp requires a server name (e.g. chrome or chrome-anon).'
          return 2
        fi
        selected+=("$2")
        shift 2
        ;;
      --mcp=*)
        selected+=("${1#*=}")
        shift
        ;;
      --)
        forwarded+=("$@")
        break
        ;;
      -C|--cd|-p|--profile|-c|--config)
        if (( $# < 2 )); then
          print -u2 "ai: $1 requires a value."
          return 2
        fi
        discovery+=("$1" "$2")
        forwarded+=("$1" "$2")
        shift 2
        ;;
      --cd=*|--profile=*|--config=*)
        discovery+=("$1")
        forwarded+=("$1")
        shift
        ;;
      *) forwarded+=("$1"); shift ;;
    esac
  done

  # Discover effective configuration, including trusted project overrides.
  # Never print the JSON: it may contain MCP credentials.
  if ! listing=$(command codex "${discovery[@]}" mcp list --json); then
    print -u2 'ai: could not read Codex MCP configuration.'
    return 1
  fi
  if ! value=$(print -r -- "$listing" | command jq -er 'map(.name) | .[]'); then
    print -u2 'ai: could not read MCP server names; check that jq and Context7 are configured.'
    return 1
  fi
  servers=("${(@f)value}")
  for server in "${servers[@]}"; do
    if [[ "$server" == *[^a-zA-Z0-9_-]* ]]; then
      print -u2 "ai: unsupported MCP server name '$server'. Use letters, numbers, underscores, or hyphens."
      return 1
    fi
    key=$server
    overrides+=(-c "mcp_servers.${key}.enabled=false")
  done
  for server in context7; do
    if (( ! ${servers[(Ie)$server]} )); then
      print -u2 "ai: default MCP '$server' is not configured in Codex."
      return 1
    fi
    overrides+=(-c "mcp_servers.${server}.enabled=true")
  done

  for name in "${selected[@]}"; do
    if [[ -z "$name" ]]; then
      print -u2 'ai: --mcp requires a nonempty server name.'
      return 2
    fi
    server=${AI_MCP_SERVERS[$name]:-$name}
    if (( ! ${servers[(Ie)$server]} )) && [[ -z ${AI_MCP_COMMANDS[$name]} ]]; then
      print -u2 "ai: unknown MCP '$name'. Configured servers: ${(j:, :)servers}; aliases: ${(j:, :)${(k)AI_MCP_SERVERS}}"
      return 2
    fi
    if [[ -n ${chosen[$server]} && ${chosen[$server]} != "$name" ]]; then
      print -u2 "ai: '$name' conflicts with '${chosen[$server]}' (both select $server)."
      return 2
    fi
    chosen[$server]=$name
    if [[ "$server" == *[^a-zA-Z0-9_-]* ]]; then
      print -u2 "ai: unsupported MCP server name '$server'."
      return 2
    fi
    key=$server
    overrides+=(-c "mcp_servers.${key}.enabled=true")
    if [[ -n ${AI_MCP_COMMANDS[$name]} ]]; then
      value=$(print -rn -- "${AI_MCP_COMMANDS[$name]}" | command jq -Rs .) || return 1
      overrides+=(-c "mcp_servers.${key}.command=$value")
    fi
    if [[ -n ${AI_MCP_ARGS[$name]} ]]; then
      overrides+=(-c "mcp_servers.${key}.args=${AI_MCP_ARGS[$name]}")
    fi
  done
  command codex "${overrides[@]}" "${forwarded[@]}"
}

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

# Explicit full-access override; disables the configured .agentignore protection.
alias codexskip='codex --dangerously-bypass-approvals-and-sandbox'

# =============================================================================
# OpenCode
# =============================================================================

# Separating Cloud-based usage and Local running models usage
alias oc="export OPENCODE_CONFIG_DIR=$HOME/.config/opencode/cloud opencode"
alias ocl="export OPENCODE_CONFIG_DIR=$HOME/.config/opencode/local opencode"
