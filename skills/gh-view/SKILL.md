---
name: gh-view
description: Use this skill when the user wants to view, read, or check a GitHub issue or pull request. Triggers on phrases like "issueを見て", "PRの内容を確認", "read issue", "show PR", "what does issue #N say", "look at this PR", or any request to fetch or display GitHub issue/PR content. Use this skill whenever a GitHub issue or PR number is mentioned and the user wants to see its contents.
---

# /gh-view — GitHub Issue / PR Viewer

View a GitHub issue or pull request in the current repository.

## Usage

- `/gh-view` — infer number from the current branch name (e.g. `issues/11` → #11)
- `/gh-view 11` — view item #11 explicitly
- `/gh-view 11 ja` — view item #11 and display a Japanese translation alongside

## Steps

Follow these steps in order. Use the Bash tool for all shell commands.

### 1. Detect repository

Run `git remote -v` and parse `owner/repo` from the first remote URL.

- SSH format: `git@github.com:owner/repo.git` → `owner/repo`
- HTTPS format: `https://github.com/owner/repo.git` → `owner/repo`

If no GitHub remote is found, tell the user and stop.

### 2. Detect display language

Determine whether to show a translation alongside the original English content. Check in this priority order:

1. If a language code argument was passed (e.g., `ja`, `fr`), use it.
2. Otherwise, run `echo $GH_VIEW_LANG` — if set, use its value.
3. Otherwise, run `echo $LANG` — if it contains `ja`, use `ja`.
4. If none of the above match, no translation (display English only).

Record the resolved language for use in Step 6.

### 3. Determine item number

- If an argument was passed to this skill, use it as the number.
- Otherwise, run `git branch --show-current` and extract the trailing number from the branch name.
  - Matches patterns like `issues/11`, `fix/11`, `feature/11-some-title`, `bugfix/11_something`
  - Extract only digits after the last `/`
- If no number can be determined, ask the user: "Which issue or PR number would you like to view?"

### 4. Check for gh CLI

Run `gh --version`.

- If available: proceed to Step 5a.
- If not found: tell the user "The `gh` CLI is not installed. You can install it at https://cli.github.com/". Then ask: "Would you like to use `curl` with the GitHub API instead? (requires `GITHUB_TOKEN` env var or public repo)"
  - If yes: proceed using `curl` (see Step 5b).
  - If no: stop.

### 5a. Fetch with gh CLI

**Important:** `gh issue view` succeeds even for PR numbers (it treats a PR as an issue and omits PR-specific fields). Always try `gh pr view` first to get the correct type.

Try PR first:
```
gh pr view <number> --repo <owner/repo>
```

If that fails with a "not found" or "Could not resolve" error, try issue:
```
gh issue view <number> --repo <owner/repo>
```

If both fail, tell the user: "No issue or PR #<number> found in <owner/repo>."

Record whether the item was fetched as a PR or an issue — the display differs (Step 6).

### 5b. Fetch with curl (fallback)

Use the GitHub REST API issues endpoint (GitHub returns both issues and PRs from this endpoint):
```
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/<owner>/<repo>/issues/<number>
```

If the response contains a `pull_request` field, it is a PR. Also fetch the pulls endpoint for PR-specific fields:
```
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/<owner>/<repo>/pulls/<number>
```

If `GITHUB_TOKEN` is not set, omit the Authorization header (works for public repos only).

### 6. Display

**Common fields (issue and PR):**

- **Title**, item type (Issue / Pull Request), and number
- **State** (open / closed / merged)
- **Author** and creation date
- **Labels** (if any)
- **Body** (full text)

**PR-only fields (show only when item is a Pull Request):**

- **Branch**: `<head branch>` → `<base branch>`
- **Review state**: approved / changes requested / review required / etc.
- **Checks**: CI status summary (passing / failing / pending) if available
- **Mergeable**: whether the PR can be merged without conflicts

**Comments:**

The comment count is available in the fetched metadata (`comments` field).

- If comment count is **20 or fewer**: fetch and display all comments immediately (author + body for each).
- If comment count **exceeds 20**: tell the user "There are N comments. Display all?" and wait for confirmation before fetching.
  - If confirmed: fetch and display all comments.
  - If declined: skip comments.

**Translation (if language was resolved in Step 2):**

For the title, body, and each comment body: display the original English text first, then the translation directly below it, clearly separated. Example format:

```
## Body
This is the original English body text.

---（日本語）---
これは本文の日本語訳です。
```

Do not translate metadata fields (author, labels, branch names, state, dates).

Do not truncate body or comment text.
