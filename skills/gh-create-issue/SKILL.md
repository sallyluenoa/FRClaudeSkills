---
name: gh-create-issue
description: Use this skill when the user wants to create a GitHub issue. Triggers on phrases like "issueを作成", "issueを立てる", "バグを報告する", "create issue", "open an issue", "file a bug", "report a problem", or any request to create or submit a new GitHub issue.
---

# /gh-create-issue — GitHub Issue Creator

Create a new issue in the current repository on GitHub.

## Usage

- `/gh-create-issue` — create an issue interactively
- `/gh-create-issue "Bug: login fails on Safari"` — create an issue with the given title

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

### 3. Determine issue title

Use in this priority order:

1. If an argument was passed to this skill, use it as the title.
2. Otherwise, ask the user: "What is the issue title?"

### 4. Detect and select issue template

Check for issue templates in this order:

**Multiple templates directory (most common):**
```
ls .github/ISSUE_TEMPLATE/ 2>/dev/null
```

**Single template files:**
```
ls .github/issue_template.md 2>/dev/null
ls .github/ISSUE_TEMPLATE.md 2>/dev/null
```

**YAML-based templates (GitHub Forms):**
If files in `.github/ISSUE_TEMPLATE/` have a `.yml` or `.yaml` extension, read their `name:` and `description:` frontmatter fields to build a display list.

**Template selection logic:**

- If multiple templates are found: list each template with its name and description (parsed from frontmatter if available, otherwise the filename). Ask the user: "Which issue template would you like to use?" Wait for selection.
- If exactly one template is found: use it automatically and tell the user which template was applied.
- If no templates are found: skip to Step 5 with an empty body.

**Reading the selected template:**

- For `.md` files: read the file content directly as the body.
- For `.yml`/`.yaml` files: extract the `body:` section. For each field in `body`, use its `label` as a section heading and `description` as placeholder text. Render as Markdown. Example:
  ```
  ## Steps to reproduce
  <!-- e.g. 1. Go to '...' 2. Click on '...' -->
  
  ## Expected behavior
  <!-- What you expected to happen -->
  
  ## Actual behavior
  <!-- What actually happened -->
  ```
- Strip YAML frontmatter (`---` blocks) from `.md` templates before using as body.

### 5. Fill in the template body

If a template body was obtained in Step 4:

1. Replace `<!-- ... -->` placeholder comments with a note to the user that these need to be filled in — do NOT invent content.
2. Leave all checkboxes (`- [ ]`) as-is.
3. Do not remove or reorder sections.

If no template was found, use an empty body.

Present the draft body to the user and ask: "Does this look right? You can also tell me what to fill in." Make any requested edits before proceeding.

### 6. Determine labels (optional)

Run:
```
gh label list --repo <owner/repo> --limit 50
```

If labels are available and the issue title/body strongly suggests a category (e.g., "bug", "enhancement", "documentation"), suggest the matching label and ask: "Would you like to add the label `<label>`?"

If the user confirms, record the label for use in the next step. Skip this step if no labels exist or the user declines.

### 7. Create the issue

Assemble the `gh issue create` command:

```
gh issue create \
  --title "<title>" \
  --body "<body>" \
  --repo <owner/repo>
```

If a label was selected in Step 6, add `--label "<label>"`.

Run the command.

- On success: display the issue URL returned by `gh`.
- On failure: show the error output and stop.

### 8. Display summary

Show a concise summary:

```
Issue created:
  Title:    <title>
  Template: <template filename, or "none">
  Labels:   <labels, or "none">
  URL:      <issue-url>
```
