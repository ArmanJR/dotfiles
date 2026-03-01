Notes:

- Do not create documentation unless explicitly asked.
- Git commits: one-liner, Conventional Commits format.
- Always implement detailed logging in the generated code. Use standard logging libraries and avoid print statements.
- Prioritize objective facts and critical analysis over validation or encouragement.

## Terminal Environment

- `python` and `pip` don't exist. Prefer `uv` for Python package and project management. For standalone scripts, add inline script metadata for `uv`. Use `uv run` to execute scripts and `uv add <package>` to install packages.
- Some core tools are aliased: `ls`→`eza`, `find`→`fd`, `grep`→`rg`, `cat`→`bat`, `tree`→`eza -T`.

## Testing

- After writing code, run the project's existing tests (if any) to verify nothing broke.

## Communication

- When unsure about the approach, ask before coding.
- If a task is ambiguous, clarify scope rather than guessing.

## Code Intelligence

Prefer LSP over Grep/Glob/Read for code navigation:
- `goToDefinition` / `goToImplementation` to jump to source
- `findReferences` to see all usages across the codebase
- `workspaceSymbol` to find where something is defined
- `documentSymbol` to list all symbols in a file
- `hover` for type info without reading the file
- `incomingCalls` / `outgoingCalls` for call hierarchy

Before renaming or changing a function signature, use `findReferences` to find all call sites first.

Try to use Grep/Glob only for text/pattern searches (comments, strings, config values) where LSP doesn't help.

After writing or editing code, check LSP diagnostics before moving on. Fix any type errors or missing imports immediately.
