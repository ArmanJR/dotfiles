## Important Notes

- ALWAYS implement detailed logging in the generated code. Use standard logging libraries and avoid print statements.
- Prioritize objective facts, critical analysis and honesty over validation or encouragement.
- Read the error before guessing. When something fails, read the full error message and traceback before attempting a fix. Don't blindly retry or rewrite.
- Use Git deliberately: do not automatically commit every change, but do create a commit when the completed work is coherent, tested or reasonably verified, and represents a meaningful checkpoint. 
- Write unit tests when and where applicable. Single scripts, minor works, exploratory works such as information gathering and code experiments do not require tests.
- After modifying a project's code, run the project's existing tests (if any) to verify nothing broke.

## Terminal Environment

- Do not use `python`, `python3`, or `pip` directly. Use `uv` for all Python package and project management. For standalone scripts, add inline script metadata for `uv`. Use `uv run` to execute scripts and `uv add <package>` to install packages.

## Before and on git commit

Before committing your work to git, check if (1) project has a `README.md` file AND (2) your changes would make it **outdated**. If both conditions are met, update the `README.md` file accordingly. Otherwise, skip.

When committing, summarize the changes and use a clear, scoped message; leave minor, exploratory, or incomplete edits uncommitted unless explicitly asked. Commit messages should follow Conventional Commits format.

## Other notes

- Think Before Coding: Don't assume. Don't hide confusion. Surface tradeoffs. If something is unclear, stop. Name what's confusing. Ask.
- Respect the existing codebase: Before changing code, inspect the surrounding files, patterns, naming conventions, architecture, and tests; make changes that fit the project rather than imposing a new style.
- Keep changes focused: Implement only what was requested or clearly required for the task. Avoid unrelated refactors, formatting churn, dependency changes, or speculative improvements; if you encounter something genuinely worth rethinking or improving, call it out separately so the user can decide whether to address it.
- Ask only when blocked: Make reasonable assumptions when the intent is clear, but ask for clarification when a decision would materially affect behavior, architecture, data safety, or user-facing output.
- Prefer simple, maintainable solutions: Choose clear, readable code over clever abstractions; optimize for future maintainers, not just passing the immediate task. Ask yourself "Would a senior engineer say this is overcomplicated?" If yes, simplify.
- Validate the work: If present, run relevant tests, type checks, linters, builds, or targeted manual checks whenever practical; report what was run and what passed or failed.
- Handle errors intentionally: Do not silently swallow failures; add appropriate validation, error messages, logging, and edge-case handling consistent with the project.
- Protect user data and secrets: Never expose, log, commit, or hardcode credentials, tokens, private keys, personal data, or environment-specific values. Use `.env` files.
- Use dependencies carefully: Do not add or upgrade packages unless clearly justified; prefer existing project utilities and libraries before introducing new ones.
- Report clearly at the end: Summarize what changed, why it changed, how it was verified, any known limitations, and any follow-up work that remains.
- MCP: If a dependency or an external package did not work as you expected, you are encouraged to research its docs and verify. The context7 MCP tools are available for getting the latest documentations.
