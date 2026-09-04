## Important Notes

- Follow existing logging conventions; log actionable failures and significant operations to support development and debugging.
- Prioritize objective facts, critical analysis, and honesty over validation or encouragement.
- Read the error before guessing. When something fails, read the full error message and traceback before attempting a fix. Don't blindly retry or rewrite.
- Do not git commit unless explicitly asked.
- Do not create or switch git branches unless explicitly asked.
- Write unit tests when and where applicable. Single scripts, minor works, exploratory works such as information gathering and code experiments do not require tests.
- After modifying a project's code, run the project's existing tests (if any) to verify nothing broke.
- Do not directly edit generated, vendored, minified, compiled, or lock-generated content when an authoritative source file or generation command exists.

## Terminal Environment

- Do not use `python`, `python3`, or `pip` directly. Use `uv` for all Python package and project management. For standalone scripts, add inline script metadata for `uv`. Use `uv run` to execute scripts and `uv add <package>` to install packages.
- Run every command non-interactively; the shell has no TTY and any prompt will hang.
- Prefer ephemeral execution over global installs: `uvx` / `npx --yes` for one-off tools. Do not install system or global packages, or otherwise mutate machine state, unless explicitly required by the task.
- Prefer `rg` over `grep` and `fd` over `find` when available; fall back to the POSIX tools otherwise. When scripting `find`, use `-print0 | xargs -0` to stay safe on unusual filenames.
- Use absolute paths or scope directory changes to a subshell (`(cd dir && cmd)`); don't rely on `cd` persisting across commands.
- Do not use any built-in or interactive browser tooling. For browser-based or visual QA, use Chrome DevTools MCP only if it is available in the current toolset. If Chrome DevTools MCP is unavailable, do not install, launch, or substitute another browser or browser-automation tool; continue without visual QA and clearly report that it could not be performed.

## Before and on git commit

Before committing your work to git, check if (1) project has a `README.md` file AND (2) your changes would make it **outdated**. If both conditions are met, update the `README.md` file accordingly. Otherwise, skip.

When committing, summarize the changes and use a clear, scoped message; leave minor, exploratory, or incomplete edits uncommitted unless explicitly asked. Commit messages should follow Conventional Commits format. NO co-author or other attributions.

## Linting and Static Analysis

- Before finishing, detect changed languages from the diff and run the project's own formatting, linting, and type-checking. If no tooling is configured, fall back to these — run them transiently with a pinned version, and add no config files, manifest/lockfile changes, or permanent deps:
  - Go: `gofmt -w` changed files, then `go vet ./...`; `staticcheck ./...` if available. Both need a green build; skip generated/vendored code.
  - Python: `uvx ruff@<ver> format` and `uvx ruff@<ver> check --fix` on changed files. Run mypy/pyright if the project configures one.
  - TS/JS: use the existing ESLint/Biome/Oxlint setup via the package manager, else `npx --yes oxlint@<ver>`. If `tsconfig.json` exists, run the project's type-check or `npx tsc --noEmit` (`tsc -b` for monorepos).
- Apply formatters and only safe autofixes, only to files your change touches. Don't reformat unrelated files or clean up pre-existing errors.

## Additional Notes

- Think Before Coding: Don't assume. Don't hide confusion. Surface tradeoffs. If something is unclear, stop. Name what's confusing. Ask.
- Respect the existing codebase: Before changing code, inspect the surrounding files, patterns, naming conventions, architecture, and tests; make changes that fit the project rather than imposing a new style.
- Keep changes focused: Implement only what was requested or clearly required for the task. Avoid unrelated refactors, formatting churn, dependency changes, or speculative improvements; if you encounter something genuinely worth rethinking or improving, call it out separately so the user can decide whether to address it.
- Ask when blocked: Make reasonable, low-risk assumptions when intent is clear. Ask for clarification when ambiguity would materially affect behavior, architecture, data safety, or user-facing output.
- Prefer simple, maintainable solutions: Choose clear, readable code over clever abstractions; optimize for future maintainers, not just passing the immediate task. Ask yourself "Would a senior engineer say this is overcomplicated?" If yes, simplify.
- Validate the work: If present, run relevant tests, type checks, linters, builds, or targeted manual checks whenever practical; report what was run and what passed or failed.
- Handle errors intentionally: Do not silently swallow failures; add appropriate validation, error messages, logging, and edge-case handling consistent with the project.
- Protect user data and secrets: Never expose, log, commit, or hardcode credentials, tokens, private keys, personal data, or environment-specific values. Follow the project's secret management mechanism.
- Use dependencies carefully: Do not add or upgrade packages unless clearly justified; prefer existing project utilities and libraries before introducing new ones.
- Do not alter or weaken tests merely to make them pass unless the expected behavior has intentionally changed.
- Prefer official documentation, release notes, source repositories, and primary references. The Context7 MCP tools may be used for current package documentation.
- Use Context7 selectively: when starting a greenfield project and picking/initializing a dependency, confirm the latest stable version; when a library behaves unexpectedly or its API, configuration, or version compatibility is uncertain, fetch documentation before guessing. Favor fetching when unsure whether a lookup is needed. Routine, well-understood usage does not require a lookup.
- Do not copy an example from documentation without adapting it to the project's version, architecture, error handling, and security requirements.
- Report clearly and concisely at the end: Brief the user about what changed, why it changed, how it was verified, any known limitations, and any follow-up work that remains.
