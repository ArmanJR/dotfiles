Notes:

- DO NOT create documentation unless explicitly asked.
- Git commits: one-liner, Conventional Commits format.
- ALWAYS implement detailed logging in the generated code. Use standard logging libraries and avoid print statements.
- Prioritize objective facts, critical analysis and honesty over validation or encouragement.
- Read the error before guessing. When something fails, read the full error message and traceback before attempting a fix. Don't blindly retry or rewrite.
- Look for and follow the existing local pattern (if any) before introducing a new pattern.

## Behavioral guidelines

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## Terminal Environment

- Do not use `python`, `python3`, or `pip` directly. Use `uv` for all Python package and project management. For standalone scripts, add inline script metadata for `uv`. Use `uv run` to execute scripts and `uv add <package>` to install packages.
- Some core tools are aliased: `ls`→`eza`, `find`→`fd`, `grep`→`rg`, `cat`→`bat`, `tree`→`eza -T`.

## Resource Guards

When writing a script that runs directly on this machine **and** is resource-heavy enough to risk exhausting system resources (large data processing, unbounded concurrency, recursive computations, etc.), add in-process resource guards. Skip this for lightweight or short-lived scripts — not every script needs guards.

Before setting limits, check the system's current resources (memory, CPU count) and choose guard values that are proportional: high enough for the script to run efficiently, but capped well below total system capacity so a runaway process cannot crash the machine. On macOS, OS-level memory limits are unreliable — enforce them inside the script. Always test on a small input first and extrapolate before going full scale.

**Python:**
```python
import resource, signal, sys

resource.setrlimit(resource.RLIMIT_RSS, (1 * 1024**3, 1 * 1024**3))  # advisory on macOS — adjust to system
resource.setrlimit(resource.RLIMIT_CPU, (60, 60))                     # CPU seconds — adjust to workload
signal.signal(signal.SIGALRM, lambda s, f: sys.exit("timeout"))
signal.alarm(120)                                                      # wall-clock timeout (most reliable on macOS)
```

**Go:**
```go
import ("context"; "runtime/debug"; "time")

func main() {
    debug.SetMemoryLimit(512 << 20)  // runtime-enforced, works on macOS — adjust to system
    ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
    defer cancel()
    run(ctx)
}
```

- Python: `signal.alarm` (wall-clock timeout) is the most reliable guard on macOS.
- Go: `debug.SetMemoryLimit` is runtime-enforced and always works.
- For other languages, apply equivalent in-process memory and timeout limits.

## Code quality

- Prefer readable and maintainable code over clever or dense code.
- Handle errors explicitly with actionable messages. Do not swallow exceptions silently.
- Never hardcode secrets. Use `.env` files. Never commit credentials, API keys, or tokens.
- Try to avoid reinventing the wheel. When an existing library or package can produce the exact result we need, propose it (while making sure it's well-maintained with clear docs and active usage). However, introducing dependencies solely for small or trivial functionality is discouraged.

## Testing

- Write unit tests when and where applicable. Single scripts, minor works, exploratory works such as information gathering and code experiments do not require tests.
- After modifying a project's code, run the project's existing tests (if any) to verify nothing broke.

## Before git commit

Before committing your work to git, check if (1) project has a README.md file AND (2) your changes would make it **outdated**. If both conditions are met, update the README.md file accordingly. Otherwise, skip.

## Ambiguity and uncertainty

- When unsure about the approach, ask before coding.
- If a task is ambiguous, clarify scope rather than guessing.
- If a dependency or an external package did not work as you expected, you are encouraged to research its docs and verify. The context7 MCP tools are available for getting the latest documentations.
