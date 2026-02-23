---
name: kermit
description: Commits task changes, handles residual files, and pushes to remote. Triggered exclusively via the explicit "kermit" command.
---

**CORE DIRECTIVE:** Execute git operations deterministically. Prioritize repository safety and clean commit history.

**Step 1: Commit Current Task Changes**
1. **Identify Scope:** Use `git status -s` to identify files modified or created during the current task.
2. **Sensitive Data Scan:** Analyze the diff of these files for secrets (e.g., API keys, tokens, passwords) and temporary artifacts (e.g., `.env`, `__pycache__/`, `node_modules/`, `vendor/`).
   * *IF UNSAFE:* HALT immediately. Alert the user with the exact file and lines containing the suspected leak. Do not proceed.
   * *IF SAFE:* Run `git add <specific_files>`.
3. **Generate Message:** Run `git diff --staged`. Generate a Conventional Commit message based *strictly* on this diff output, not chat history.
4. **Commit with Hook Awareness:** Run `git commit -m "<message>"`. Then follow the **Pre-commit Hook Protocol** below.

---

**Pre-commit Hook Protocol**
*(Applies to every commit attempt, whether prek is present or not.)*

* **IF commit succeeds:** Continue to the next step normally.

* **IF commit fails:** Immediately run `git diff --name-only` to check for unstaged changes.

  * **Case A — Files were modified (auto-fix):** Pre-commit hooks rewrote files (e.g., trimmed whitespace, fixed line endings). 
    1. Run `git add <those modified files>`.
    2. Retry the commit **once** with the same message.
    3. If it fails again, fall through to Case B.

  * **Case B — No file changes (hard block):** A hook rejected the commit outright (e.g., detected a private key, invalid JSON/YAML, large file).
    1. HALT immediately.
    2. Report the **exact hook output** to the user — which hook failed and why.
    3. Do not attempt another commit. Leave the index staged as-is so the user can inspect and fix.

  * **IF unclear which case:** Check the commit error output for hook names or messages, then determine A vs B based on whether any files appear in `git diff --name-only`.

---

**Step 2: Handle Residual/Untracked Changes**
Run `git status -s` to identify remaining modifications.
* **If empty:** Proceed to Step 3.
* **If residual files exist:** Evaluate based on these strict thresholds:
   * *Minor (Safe):* < 3 files AND < 50 lines of code total (e.g., typos, formatting). Run the Sensitive Data Scan. If safe, stage and commit with an isolated, descriptive message. Apply the **Pre-commit Hook Protocol** here too.
   * *Major (Unsafe):* >= 3 files OR >= 50 lines of code, or unfamiliar untracked files. DO NOT commit. Leave in the working tree.

**Step 3: Remote Push & Cleanup**
1. **Push:** Run `git push`.
2. **Error Handling:** If the push fails (e.g., remote ahead, hook failure), HALT and report the exact git error output to the user.
3. **Report:** Output a concise summary of pushed commits and explicitly list any Major residual files left uncommitted. If any commits required a hook-fix retry (Case A), note which files were auto-corrected.

Note: Maximize the cleanup of residual files. Default to committing all minor, safe, and unrelated changes. Exclude only major refactors or large-scale untracked files.
