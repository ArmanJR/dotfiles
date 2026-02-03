---
name: cmt
description: Commits the current task's changes, checks for residual untracked files, and pushes to remote.
---

**Step 1: Commit Current Task Changes**
Identify the specific files and folders you modified or created during our current chat session.
1.  **Sensitive Data Check:** Scan these specific files for secrets (.env, API keys, credentials) or temporary artifacts (node_modules, __pycache__, .DS_Store).
    * *If unsafe:* Do NOT stage. Stop and alert me.
    * *If safe:* Proceed.
2.  **Stage & Commit:** Run `git add <specific_files>`.
3.  **Message:** Create a descriptive commit message using Conventional Commits format based on the work you just completed.

**Step 2: Handle Residual/Untracked Changes**
Run `git status` to identify any remaining modified or untracked files that were *not* part of your current task (the "hanging" changes).
* **Case A: No residual changes.** Proceed to Step 3.
* **Case B: Residual changes exist.** Analyze their complexity:
    * *Minor Changes:* (e.g., small typos, formatting, simple config updates).
        * Perform **Sensitive Data Check** on these files.
        * If safe, stage and commit them with a separate message.
    * *Major Changes:* (e.g., large sets of untracked files, unrelated feature code, deep refactors).
        * **Do NOT commit.** Leave them in the working tree.
        * Add a note to your final response listing these files so the user is aware they are still pending.

**Step 3: Push to Remote**
Push all new commits to the current branch.
