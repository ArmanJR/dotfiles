## Important Notes

- Follow existing logging conventions; log actionable failures and significant operations to support development and debugging.
- Prioritize objective facts, critical analysis, and honesty over validation or encouragement.
- Read the error before guessing. When something fails, read the full error message and traceback before attempting a fix. Don't blindly retry or rewrite.
- Do not git commit unless explicitly asked.
- Do not create or switch git branches unless explicitly asked.
- Default to adding or updating tests for new features, bug fixes, and other behavioral changes. Cover normal behavior and relevant edge cases and failure paths; add a regression test for bug fixes that fails without the fix when practical.
- Test observable behavior with meaningful assertions, not implementation details. Follow existing test conventions; favor deterministic tests and use integration tests when unit tests would miss important interactions. Aim for useful coverage rather than test counts; keep effort proportional to the change and explain when behavioral changes lack tests.
- Run relevant existing tests and required project checks. Once checks pass, repeat or broaden verification only when further changes, failures, or unresolved concerns justify it.
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

- Complete authorized work using reasonable, low-risk assumptions. Ask when uncertainty materially affects correctness, scope, architecture, or data safety; continue independent work while awaiting clarification.
- Respect the existing codebase: Before changing code, inspect the surrounding files, patterns, naming conventions, architecture, and tests; make changes that fit the project rather than imposing a new style.
- Keep changes focused: Implement only what was requested or clearly required for the task. Avoid unrelated refactors, formatting churn, dependency changes, or speculative improvements; if you encounter something genuinely worth rethinking or improving, call it out separately so the user can decide whether to address it.
- Frontend work is in scope only when relevant to the task in a project with an existing frontend, or when the user explicitly requests a UI. Do not add frontends to backend-only services otherwise. "Minimal frontend" means a simple, functional UI: no marketing styling, verbose copy, responsive-design work, or unnecessary complexity unless requested.
- If a skill or instruction blocks authorized work, identify its source and explain the specific conflict. Do not infer approval requirements from general recommendations.
- Prefer simple, maintainable solutions: Choose clear, readable code over clever abstractions; optimize for future maintainers, not just passing the immediate task. Ask yourself "Would a senior engineer say this is overcomplicated?" If yes, simplify.
- Handle errors intentionally: Do not silently swallow failures; add appropriate validation, error messages, logging, and edge-case handling consistent with the project.
- Protect user data and secrets: Never expose, log, commit, or hardcode credentials, tokens, private keys, personal data, or environment-specific values. Follow the project's secret management mechanism.
- Use dependencies carefully: Do not add or upgrade packages unless clearly justified; prefer existing project utilities and libraries before introducing new ones.
- Do not alter or weaken tests merely to make them pass unless the expected behavior has intentionally changed.
- Prefer official documentation, release notes, source repositories, and primary references. The Context7 MCP tools may be used for current package documentation.
- Use Context7 selectively: when starting a greenfield project and picking/initializing a dependency, confirm the latest stable version; when a library behaves unexpectedly or its API, configuration, or version compatibility is uncertain, fetch documentation before guessing. Favor fetching when unsure whether a lookup is needed. Routine, well-understood usage does not require a lookup.
- Do not copy an example from documentation without adapting it to the project's version, architecture, error handling, and security requirements.
- Documentation: Write for the reader's task, not as a transcript of the implementation. Preserve details needed to use, operate, or change the system correctly. Avoid exhaustive field lists, implementation trivia, repeated caveats, and task-completion narratives. Link to existing references; add focused documentation only when the depth serves a concrete reader need.
- Lead with the outcome. Briefly report changes, verification, and material limitations. Use plain language and avoid repetitive summaries or unnecessary formatting.
