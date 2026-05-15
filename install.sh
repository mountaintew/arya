#!/usr/bin/env bash
# arya — install / uninstall agent + slash-command symlinks into ~/.claude/.
# Idempotent. Re-run after editing source files (symlinks resolve to current source).

set -euo pipefail

ARYA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_SRC="$ARYA_DIR/agents"
AGENTS_DST="$HOME/.claude/agents"
COMMANDS_SRC="$ARYA_DIR/commands"
COMMANDS_DST="$HOME/.claude/commands"

usage() {
  cat <<EOF
Usage: $(basename "$0") [--uninstall]

Installs symlinks from:
  $AGENTS_SRC/*.md   -> $AGENTS_DST/
  $COMMANDS_SRC/*.md -> $COMMANDS_DST/

Run with --uninstall to remove only the symlinks this script created.
EOF
}

# link_dir <src> <dst> — returns "linked skipped" via globals
link_dir() {
  local src="$1" dst="$2"
  [ -d "$src" ] || return 0
  mkdir -p "$dst"
  for f in "$src"/*.md; do
    [ -e "$f" ] || continue
    local name link
    name="$(basename "$f")"
    link="$dst/$name"

    if [ -L "$link" ] && [ "$(readlink "$link")" = "$f" ]; then
      echo "ok       $link"
      LINKED=$((LINKED + 1))
      continue
    fi

    if [ -e "$link" ]; then
      echo "SKIP     $link (exists and is not our symlink — leaving alone)"
      SKIPPED=$((SKIPPED + 1))
      continue
    fi

    ln -s "$f" "$link"
    echo "linked   $link -> $f"
    LINKED=$((LINKED + 1))
  done
}

# unlink_dir <src> <dst>
unlink_dir() {
  local src="$1" dst="$2"
  [ -d "$src" ] || return 0
  mkdir -p "$dst"
  for f in "$src"/*.md; do
    [ -e "$f" ] || continue
    local name link
    name="$(basename "$f")"
    link="$dst/$name"
    if [ -L "$link" ] && [ "$(readlink "$link")" = "$f" ]; then
      rm -f "$link"
      echo "removed  $link"
      REMOVED=$((REMOVED + 1))
    fi
  done
}

install() {
  LINKED=0
  SKIPPED=0
  link_dir "$AGENTS_SRC" "$AGENTS_DST"
  link_dir "$COMMANDS_SRC" "$COMMANDS_DST"
  echo
  echo "Linked $LINKED, skipped $SKIPPED."
  if [ "$SKIPPED" -gt 0 ]; then
    echo "Tip: remove or rename conflicting files and re-run."
  fi
}

uninstall() {
  REMOVED=0
  unlink_dir "$AGENTS_SRC" "$AGENTS_DST"
  unlink_dir "$COMMANDS_SRC" "$COMMANDS_DST"
  echo
  echo "Uninstalled $REMOVED symlink(s)."
}

case "${1:-}" in
  --uninstall) uninstall ;;
  -h | --help) usage ;;
  "") install ;;
  *) usage; exit 2 ;;
esac
