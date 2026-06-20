#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
SKILLS_DST="$HOME/.claude/skills"

if [ -L "$SKILLS_DST" ]; then
  current="$(readlink "$SKILLS_DST")"
  if [ "$current" = "$SKILLS_SRC" ]; then
    echo "Already linked: $SKILLS_DST -> $current"
    exit 0
  fi
  echo "Existing symlink found: $SKILLS_DST -> $current"
  read -rp "Overwrite with $SKILLS_SRC? [y/N] " answer
  case "$answer" in
    [yY]) rm "$SKILLS_DST" ;;
    *) echo "Aborted."; exit 1 ;;
  esac
elif [ -e "$SKILLS_DST" ]; then
  echo "Existing directory/file found: $SKILLS_DST"
  read -rp "Remove and replace with symlink to $SKILLS_SRC? [y/N] " answer
  case "$answer" in
    [yY]) rm -rf "$SKILLS_DST" ;;
    *) echo "Aborted."; exit 1 ;;
  esac
fi

ln -s "$SKILLS_SRC" "$SKILLS_DST"
echo "Linked: $SKILLS_DST -> $SKILLS_SRC"
