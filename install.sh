#!/usr/bin/env bash
# arya — install / uninstall agent symlinks into ~/.claude/agents/
# Idempotent. Re-run after editing source files (symlinks resolve to current source).

set -euo pipefail

ARYA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$ARYA_DIR/agents"
DST="$HOME/.claude/agents"

usage() {
  cat <<EOF
Usage: $(basename "$0") [--uninstall]

Installs symlinks from $SRC/*.md into $DST/.
Run with --uninstall to remove only the symlinks this script created.
EOF
}

uninstall() {
  mkdir -p "$DST"
  local removed=0
  for src in "$SRC"/*.md; do
    [ -e "$src" ] || continue
    local name
    name="$(basename "$src")"
    local link="$DST/$name"
    if [ -L "$link" ] && [ "$(readlink "$link")" = "$src" ]; then
      rm -f "$link"
      echo "removed  $link"
      removed=$((removed + 1))
    fi
  done
  echo
  echo "Uninstalled $removed symlink(s)."
}

install() {
  mkdir -p "$DST"
  local linked=0 skipped=0
  for src in "$SRC"/*.md; do
    [ -e "$src" ] || continue
    local name
    name="$(basename "$src")"
    local link="$DST/$name"

    if [ -L "$link" ] && [ "$(readlink "$link")" = "$src" ]; then
      echo "ok       $link"
      linked=$((linked + 1))
      continue
    fi

    if [ -e "$link" ]; then
      echo "SKIP     $link (exists and is not our symlink — leaving alone)"
      skipped=$((skipped + 1))
      continue
    fi

    ln -s "$src" "$link"
    echo "linked   $link -> $src"
    linked=$((linked + 1))
  done
  echo
  echo "Linked $linked, skipped $skipped."
  if [ "$skipped" -gt 0 ]; then
    echo "Tip: remove or rename conflicting files in $DST/ and re-run."
  fi
}

case "${1:-}" in
  --uninstall) uninstall ;;
  -h | --help) usage ;;
  "") install ;;
  *) usage; exit 2 ;;
esac
