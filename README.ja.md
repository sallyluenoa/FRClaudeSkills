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

## skills の追加方法

`skills/` 以下に `.md` ファイルを追加するだけで Claude Code から `/skill-name` として呼び出せます。

```
skills/
  my-skill.md   # → /my-skill として使用可能
```
