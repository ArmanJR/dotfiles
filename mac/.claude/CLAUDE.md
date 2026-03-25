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

## Before git commit

Before committing your work to git, check if (1) project has a README.md file AND (2) your changes would make it **outdated**. If both conditions are met, update the README.md file accordingly. Otherwise, skip.

## Communication

- When unsure about the approach, ask before coding.
- If a task is ambiguous, clarify scope rather than guessing.
