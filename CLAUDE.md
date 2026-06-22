# FRClaudeSkills

This repository manages custom Claude Code skills. Skills are stored here and symlinked into `~/.claude/skills` so Claude Code can invoke them as slash commands.

## Repository structure

```
skills/
  <skill-name>/
    SKILL.md        # skill definition — available as /<skill-name> in Claude Code
README.md           # human-facing documentation
setup.sh            # creates ~/.claude/skills symlink
CLAUDE.md           # this file
```

## How skills work

- Each directory under `skills/` corresponds to one slash command.
- The directory name becomes the command name (e.g. `skills/gh-view/` → `/gh-view`).
- `SKILL.md` contains a YAML frontmatter block (`name`, `description`) followed by the skill's instructions.
- The `description` field controls when Claude auto-invokes the skill — write it as a trigger sentence covering both English and Japanese phrases.

## Adding a new skill

1. Create `skills/<skill-name>/SKILL.md` with this structure:
   ```markdown
   ---
   name: skill-name
   description: Trigger description — include Japanese and English phrases.
   ---

   # /skill-name — Short title

   ## Usage
   ...

   ## Steps
   ...
   ```
2. Add a row to the Available skills table in **all three** of the following files:
   - `README.md` — English description
   - `README.ja.md` — Japanese description
   - `CLAUDE.md` — this file (Available skills section below)
3. Commit all changed files together.

No setup step is needed — the symlink already points here.

## Available skills

| Skill | Description |
|---|---|
| `/gh-view` | View a GitHub issue or pull request in the current repository |
| `/gh-create-pr` | Create a pull request for the current branch on GitHub |
| `/gh-create-issue` | Create a new issue in the current repository on GitHub |

Keep this table in sync with `README.md` and `README.ja.md` whenever a skill is added or removed.

## Conventions observed in this repo

- Step-by-step instructions in `SKILL.md` are written for Claude to follow at runtime, not for humans — be explicit about shell commands, fallback logic, and edge cases.
- Skills that interact with GitHub use the `gh` CLI as the primary method, with a `curl`/API fallback where appropriate.
- Warn before destructive or irreversible actions (e.g. never force-push without explicit user confirmation).
- When a skill auto-selects something (template, title, label), always tell the user what was chosen and why.
