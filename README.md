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

## Adding skills

Add a `.md` file under `skills/` and it becomes available in Claude Code as `/skill-name`.

```
skills/
  my-skill.md   # → available as /my-skill
```
