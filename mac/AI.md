# My agentic coding setup

*last update: Oct 2, 2026*

I code on a Mac. I used Claude Code before moving to Codex a few months ago; both configurations live here. This is a walkthrough of the settings that shape how I work.

Some settings reflect my personal preferences, not a right or wrong way to code with AI.

## Coding Mode

I use “YOLO mode” in both Claude Code (`--dangerously-skip-permissions`) and Codex (`--dangerously-bypass-approvals-and-sandbox`), alongside [CC Safety Net](https://github.com/kenryu42/cc-safety-net), a pre-execution guard that blocks destructive commands before the agent runs them.

> [!CAUTION]
> **This is risky, especially when working on sensitive projects or systems. Safety Net does not replace a sandbox or eliminate the risks of bypassing permissions. Be careful.**

## MCP Tools

[Chrome DevTools MCP](https://github.com/ChromeDevTools/chrome-devtools-mcp) is one of the most important tools in my setup. It lets the agent:

- Perform visual QA and verify its work in the browser.
- Connect to my running Chrome profile with `--auto-connect` (`--autoConnect` in my config), using my existing signed-in sessions to browse websites and carry out tasks on my behalf. This requires remote debugging to be enabled in Chrome.

[Context7](https://github.com/upstash/context7) is another key tool. It fetches current, version-specific documentation and examples for services and packages, giving the agent context beyond the model's training cutoff. I usually use it during planning. My [`CLAUDE.md`](.claude/CLAUDE.md) and [`AGENTS.md`](.codex/AGENTS.md) explain when to consult it, particularly when choosing dependencies or resolving uncertain API behavior.

For terminal sessions, I wrote my own way of enabling MCP servers in [`.zsh/ai-tools.zsh`](.zsh/ai-tools.zsh). I wanted to choose which servers the agent gets for each session and pass the right arguments for the task. That way, I don't flood its context with MCP tools it won't use, and I don't have to manually change the server configuration every time I need a different browser setup.

The command I use is `ai`, my terminal shortcut for whichever coding agent I'm currently using. It used to point to `claude`; after I migrated, I changed it to launch `codex`. Today it's a shell function that wraps Codex and handles the MCP selection. Context7 stays enabled by default, and I opt into other configured MCP servers with `--mcp`.

For example, if the agent has built a webpage and needs to do visual QA, it usually doesn't need my personal Chrome profile or any of my signed-in accounts. I launch it with:

```sh
ai --mcp chrome-anon
```

This opens Codex with Chrome DevTools MCP configured to use `--isolated`. Chrome gets a temporary profile without my existing logins, which is enough for checking the page and verifying the agent's work. This provides the fresh browser session I want for QA; technically, it uses a temporary profile rather than Chrome's Incognito mode.

If I want the agent to do something on my behalf that needs my login, such as opening a LinkedIn profile using my account, I launch it with:

```sh
ai --mcp chrome
```

This opens Codex with the same Chrome DevTools MCP server, but passes `--autoConnect` so it connects to my already running Chrome session. The agent can then use the websites I'm already signed into. Both commands select the same MCP server; the wrapper chooses the browser arguments for the workflow.

## Claude Code

> [!WARNING]
> These Claude settings and model choices may be outdated, as I moved to Codex a while ago.

[`.claude/CLAUDE.md`](.claude/CLAUDE.md) holds my global coding instructions: inspect the existing code before changing it, read errors before guessing, keep changes focused, use proper logging, and run tests and project checks. Commits and branch changes require an explicit request. Python work goes through `uv`, and one-off tools use `uvx` or `npx` instead of global installs.

The main choices in [`.claude/settings.json`](.claude/settings.json):

- **Model and reasoning:** `opus`, high effort, thinking enabled, and thinking summaries visible.
- **Long-running work:** a 64,000-token output limit, tool concurrency set to 15, a 20-minute maximum Bash timeout, and a 15-minute API timeout. These are configured limits, not guarantees that every model or operation uses them.
- **Explicit context:** automatic memory is disabled. Persistent instructions live in `CLAUDE.md`. The LSP tool and the Python, TypeScript, and Go LSP plugins are also disabled.
- **Permissions:** an allowlist covers common inspection commands, tests, builds, and formatters. Read denials cover `.env` files, `secrets/`, `.claudeignore`, and the local telemetry credentials file. Some allowed commands can modify files; this is not a read-only setup. **`.claudeignore` is my custom folder convention for keeping files in a project while excluding them from the AI’s context.**
- **Plugins and attribution:** Safety Net is enabled; automatic commit and PR attribution is blank.

Telemetry exports metrics and logs through OpenTelemetry using OTLP over HTTP/JSON. [`otel-config.example`](.claude/otel-config.example) shows the endpoint/token variables, and [`otel-headers.sh`](.claude/otel-headers.sh) reads the local `~/.claude/otel-config` to supply a bearer header. The example contains placeholders; the real credentials are not included here.

I wanted to hear when the agent finished a task while I was away from my Mac, so I set up [Chatterbox TTS](https://github.com/resemble-ai/chatterbox) locally with an HTTP endpoint. With the hook enabled, the agent reads its response aloud even when I'm not at the computer.

The [`Stop` hook](.claude/hooks/tts-on-stop.sh) sends the final response to that service on port 8855 when `~/.claude/tts-enabled` exists. The service itself is separate from these dotfiles.

[`/kermit`](.claude/commands/kermit.md) is my explicit commit-and-push command. It checks changes for secrets, updates an outdated README, stages specific files, writes a Conventional Commit, and handles hook failures. It can also commit small unrelated leftovers under its thresholds, so its scope extends beyond the current task.

## Codex

[`.codex/AGENTS.md`](.codex/AGENTS.md) carries forward the same engineering rules, with more emphasis on completing authorized work, testing observable behavior, and avoiding unnecessary approval loops. It also limits frontend work to the requested scope and asks for concise, useful documentation.

[`.codex/config.toml`](.codex/config.toml) is deliberately small:

- **Model and reasoning:** `gpt-6-astra`, medium effort for normal work, and `xhigh` in Plan mode.
- **Long tasks:** `prevent_idle_sleep` keeps the Mac awake while a turn runs.
- **Enabled plugins:** GitHub, Safety Net, Browser, PDF, and Computer Use. Documents, Spreadsheets, Presentations, and Template Creator are disabled.
- **Browser debugging:** Chrome DevTools MCP runs through `npx` with `--autoConnect`.
