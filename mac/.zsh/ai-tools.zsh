# =============================================================================
# AI Tools Configuration
# =============================================================================

# MCP aliases: name -> configured server, with optional command/argument overrides.
# Other configured MCP server names can be passed directly to --mcp.
typeset -gA AI_MCP_SERVERS=(chrome chrome-devtools chrome-anon chrome-devtools blender blender)
typeset -gA AI_MCP_COMMANDS=(chrome npx chrome-anon npx blender uvx)
# blender: needs the MCP for Blender addon running in Blender (socket on localhost:9876).
typeset -gA AI_MCP_ARGS=(
  chrome '["-y", "chrome-devtools-mcp@latest", "--autoConnect"]'
  chrome-anon '["-y", "chrome-devtools-mcp@latest", "--isolated"]'
  blender '["mcp-for-blender@latest"]'
)

# Usage: ai [--mcp NAME]... [Claude Code arguments]
# Runs Claude Code with permission checks skipped (YOLO mode).
# Only the default servers (Context7) and those picked with --mcp are loaded;
# all other configured servers, plugin servers and claude.ai connectors stay off.
# Use -- before a prompt containing literal --mcp. Set AI_DEBUG=1 for diagnostics.
typeset -ga AI_MCP_DEFAULTS=(context7)
if (( ${+aliases[ai]} )); then
  unalias ai
fi
function ai {
  emulate -L zsh
  setopt localoptions pipefail
  local claude_bin=$HOME/.local/bin/claude
  local user_config=$HOME/.claude.json project_config=$PWD/.mcp.json
  local -a selected forwarded servers sources
  local name server listing value spec config
  local -A chosen

  while (( $# )); do
    case "$1" in
      --mcp)
        if (( $# < 2 )) || [[ -z "$2" || "$2" == -* ]]; then
          print -u2 'ai: --mcp requires a server name (e.g. chrome, chrome-anon or blender).'
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
      *) forwarded+=("$1"); shift ;;
    esac
  done

  # Discover configured servers with Claude's scope precedence:
  # user (~/.claude.json) < project (./.mcp.json) < local (~/.claude.json, this dir).
  # Never print the JSON: it may contain MCP credentials.
  if [[ ! -r $user_config ]]; then
    print -u2 "ai: cannot read Claude configuration at $user_config."
    return 1
  fi
  sources=("$user_config")
  [[ -r $project_config ]] && sources+=("$project_config")
  if ! listing=$(command jq -cen --arg cwd "$PWD" '
    [inputs] as [$user, $project] |
    ($user.mcpServers // {}) + ($project.mcpServers // {}) + ($user.projects[$cwd].mcpServers // {})
  ' "${sources[@]}"); then
    print -u2 'ai: could not read Claude MCP configuration; check that jq is installed.'
    return 1
  fi
  value=$(print -r -- "$listing" | command jq -r 'keys[]') || return 1
  servers=("${(@f)value}")
  [[ -n $AI_DEBUG ]] && print -u2 "ai: configured MCP servers (${(j:, :)sources}): ${(j:, :)servers}"

  # Spec of servers to enable: [{name, command?, args?}]. Holds no secrets.
  spec='[]'
  for server in "${AI_MCP_DEFAULTS[@]}"; do
    if (( ! ${servers[(Ie)$server]} )); then
      print -u2 "ai: default MCP '$server' is not configured in Claude Code (see ccmcp)."
      return 1
    fi
    spec=$(command jq -cn --argjson spec "$spec" --arg name "$server" '$spec + [{name: $name}]') || return 1
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
    if ! spec=$(command jq -cn --argjson spec "$spec" --arg name "$server" \
        --arg command "${AI_MCP_COMMANDS[$name]}" --argjson args "${AI_MCP_ARGS[$name]:-null}" '
      $spec + [{name: $name}
        + (if $command != "" then {command: $command} else {} end)
        + (if $args != null then {args: $args} else {} end)]
    '); then
      print -u2 "ai: invalid AI_MCP_ARGS for '$name' (must be a JSON array)."
      return 1
    fi
  done

  # A command override turns the entry into a stdio server, keeping only its env.
  if ! config=$(print -r -- "$listing" | command jq -ce --argjson spec "$spec" '
    . as $all | {mcpServers: (reduce $spec[] as $s ({}; .[$s.name] = (
      ($all[$s.name] // {}) as $base |
      if $s.command then
        {type: "stdio", command: $s.command, args: ($s.args // $base.args // [])}
          + (if $base.env then {env: $base.env} else {} end)
      elif $s.args then $base + {args: $s.args}
      else $base end
    )))}
  '); then
    print -u2 'ai: could not build the MCP configuration.'
    return 1
  fi
  [[ -n $AI_DEBUG ]] && print -u2 "ai: enabled MCP servers: $(command jq -cn --argjson spec "$spec" '$spec')"

  # =(...) is a private (0600) temp file, removed when Claude exits; this keeps
  # credentials out of the process list. --mcp-config is variadic, so another
  # option must follow it before any forwarded prompt.
  command "$claude_bin" --mcp-config =(print -r -- "$config") --strict-mcp-config \
    --dangerously-skip-permissions "${forwarded[@]}"
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

# Skip approvals and sandbox (use with caution)
alias codexskip="codex --dangerously-bypass-approvals-and-sandbox"

# =============================================================================
# OpenCode
# =============================================================================

# Separating Cloud-based usage and Local running models usage
alias oc="export OPENCODE_CONFIG_DIR=$HOME/.config/opencode/cloud opencode"
alias ocl="export OPENCODE_CONFIG_DIR=$HOME/.config/opencode/local opencode"
