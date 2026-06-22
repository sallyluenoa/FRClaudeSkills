# FRClaudeSkills

A repository for managing custom Claude Code skills.

## Setup

The repository can be placed in any directory, as it is referenced via a symlink.

```bash
chmod u+x setup.sh
./setup.sh
```

### What the script does

- Creates a symlink `~/.claude/skills -> <this repo>/skills`
- Prompts for confirmation if `~/.claude/skills` already exists

## Available skills

| Skill | Description |
|---|---|
| `/gh-view` | View a GitHub issue or pull request in the current repository |
| `/gh-create-pr` | Create a pull request for the current branch on GitHub |
| `/gh-create-issue` | Create a new issue in the current repository on GitHub |

## Adding skills

Add a directory under `skills/` containing a `SKILL.md` file and it becomes available in Claude Code as `/skill-name`.

```
skills/
  my-skill/
    SKILL.md   # → available as /my-skill
```
