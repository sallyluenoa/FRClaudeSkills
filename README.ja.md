# FRClaudeSkills

Claude Code のカスタム skills を管理するリポジトリです。

## セットアップ

シンボリックリンクで参照するため、リポジトリは任意のディレクトリに配置できます。

```bash
chmod u+x setup.sh
./setup.sh
```

### スクリプトの挙動

- `~/.claude/skills -> <このリポジトリ>/skills` のシンボリックリンクを作成します
- `~/.claude/skills` が既に存在する場合は上書きするか確認します

## 利用可能な skills

| Skill | 説明 |
|---|---|
| `/gh-view` | 現在のリポジトリの GitHub issue または pull request を表示する |
| `/gh-create-pr` | 現在のブランチの pull request を GitHub 上に作成する |
| `/gh-create-issue` | 現在のリポジトリに新しい issue を作成する |

## skills の追加方法

`skills/` 以下にディレクトリを作成し `SKILL.md` を配置すると、Claude Code から `/skill-name` として呼び出せます。

```
skills/
  my-skill/
    SKILL.md   # → /my-skill として使用可能
```
