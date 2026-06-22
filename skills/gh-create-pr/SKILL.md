---
name: gh-create-pr
description: Use this skill when the user wants to create a pull request on GitHub. Triggers on phrases like "PRを作成", "pull requestを作る", "PRを出す", "create PR", "open a pull request", "submit PR", or any request to open or publish a PR for the current branch.
---

# /gh-create-pr — GitHub Pull Request Creator

Create a pull request for the current branch on GitHub.

## Usage

- `/gh-create-pr` — create a PR using auto-detected title and body
- `/gh-create-pr "Fix login bug"` — create a PR with the given title
- `/gh-create-pr draft` — create a draft PR

## Steps

Follow these steps in order. Use the Bash tool for all shell commands.

### 1. Detect repository

Run `git remote -v` and parse `owner/repo` from the first remote URL.

- SSH format: `git@github.com:owner/repo.git` → `owner/repo`
- HTTPS format: `https://github.com/owner/repo.git` → `owner/repo`

If no GitHub remote is found, tell the user and stop.

### 2. Check gh CLI

Run `gh --version`.

- If not found: tell the user "The `gh` CLI is not installed. Install it at https://cli.github.com/" and stop.

### 3. Check current branch

Run `git branch --show-current` to get the current branch name.

If the current branch is `main` or `master`, warn the user: "You are on the `<branch>` branch. Creating a PR from this branch is unusual. Continue?" and wait for confirmation before proceeding.

### 4. Check for uncommitted changes

Run `git status --porcelain`.

If there are staged or unstaged changes, warn the user:
"You have uncommitted changes. These will not be included in the PR. Continue?"

Wait for confirmation before proceeding.

### 5. Determine base branch

Run:
```
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'
```

Use the result as the base branch (typically `main` or `master`). If the command fails, default to `main`.

### 6. Push branch to remote

Run:
```
git push -u origin <current-branch>
```

- If the push succeeds: continue to Step 7.
- If the push fails due to an existing remote branch with diverged history, tell the user the error and stop. Do NOT force-push without explicit user instruction.
- If the push fails for any other reason, show the error and stop.

### 7. Detect linked issue

Try to extract an issue number from the current branch name. Patterns to match:

- `issues/11` → 11
- `fix/11`, `bugfix/11`, `feature/11` → 11
- `fix/11-some-title`, `feature/11_some_title` → 11 (digits immediately after the last `/`)

If a number is found, fetch the issue:
```
gh issue view <number> --repo <owner/repo> --json title,labels,body
```

If the issue is found, record:
- **issue_title**: the `title` field
- **issue_labels**: the list of label names (e.g. `["bug", "p1"]`)
- **issue_number**: the number

If no number can be extracted or the issue is not found, record all three as empty and continue.

### 8. Determine PR title

Use in this priority order:

1. If a non-`draft` argument was passed to this skill, use it as the title.
2. If **issue_title** was found in Step 7, use it as the title as-is (e.g. `Migrate from A to B` stays `Migrate from A to B`). Tell the user: "Using issue title as PR title: `<title>`"
3. Otherwise, run `git log origin/<base-branch>..<current-branch> --oneline` to list commits.
   - If there is exactly one commit, use its message as the title.
   - If there are multiple commits, ask the user: "What should the PR title be?"

### 9. Detect and apply PR template

**Collect available templates:**

Check in this order:
```
ls .github/PULL_REQUEST_TEMPLATE/ 2>/dev/null   # multiple templates directory
ls .github/pull_request_template.md 2>/dev/null
ls .github/PULL_REQUEST_TEMPLATE.md 2>/dev/null
ls docs/pull_request_template.md 2>/dev/null
ls pull_request_template.md 2>/dev/null
```

**Auto-select template based on linked issue:**

If **issue_labels** from Step 7 is non-empty AND multiple templates exist, attempt to match a template by comparing label names against template filenames using these rules (case-insensitive):

| Issue label contains | Preferred template filename contains |
|---|---|
| `bug`, `fix`, `defect` | `bug`, `fix`, `bugfix` |
| `enhancement`, `feature` | `feature`, `enhancement` |
| `documentation`, `docs` | `doc` |
| `refactor`, `chore` | `refactor`, `chore` |
| `migration` | `migration` |

If exactly one template filename matches the mapped keyword, apply it automatically and tell the user: "Auto-selected template `<filename>` based on issue label `<label>`."

If no label-based match is found, or if there are multiple matches, fall back to the manual selection logic below.

**Manual selection fallback:**

- If multiple templates remain and no auto-selection occurred: list them to the user with filenames and ask: "Which PR template would you like to use?" Wait for selection.
- If exactly one template exists in total: use it automatically without asking.
- If no templates exist: skip to Step 10 using the generated body.

**Applying the template:**

Read the selected template file. Then:
1. Fill in any `## Changes` or similar section with the commit list from:
   ```
   git log origin/<base-branch>..<current-branch> --pretty=format:"- %s"
   ```
2. If **issue_number** is set, append `Closes #<issue_number>` at the end of the body (if not already present).
3. For any checklist items (`- [ ]`), leave them as-is.
4. Replace placeholder text like `<!-- description here -->` with a brief summary derived from the commit messages.
5. Do not remove or reorder sections defined in the template.

Use the filled template as the PR body.

### 10. Create the PR

Assemble the `gh pr create` command:

```
gh pr create \
  --title "<title>" \
  --body "<body>" \
  --base <base-branch> \
  --repo <owner/repo>
```

If `draft` was passed as an argument, add `--draft`.

Run the command.

- On success: display the PR URL returned by `gh`.
- On failure: show the error output and stop.

### 11. Display summary

Show a concise summary:

```
Pull Request created:
  Title:    <title>
  Base:     <base-branch> ← <current-branch>
  Template: <template filename, or "none">
  URL:      <pr-url>
```
