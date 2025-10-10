#!/usr/bin/env bash
set -euo pipefail
# Print CWD + repo context only when it actually changes.
# Force always-print with: SHOW_CWD_ALWAYS=1

always="${SHOW_CWD_ALWAYS:-0}"

# Canonical/physical path (resolve symlinks when possible)
cwd="$(pwd -P 2>/dev/null || pwd)"

# Build a compact, machine-friendly line
line="CWD:${cwd}"

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
  if [[ -n "${root:-}" ]]; then
    rel="${cwd#$root/}"; rel="${rel:-.}"
    branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"
    sha="$(git rev-parse --short HEAD 2>/dev/null || echo '?')"
    dirty=""
    if ! git diff --quiet --ignore-submodules --cached; then dirty="*"; fi
    if ! git diff --quiet --ignore-submodules; then dirty="*"; fi
    line="${line} REL:${rel} GIT:${branch}@${sha}${dirty}"
  fi
fi

# Per-project state file (works even without CLAUDE_PROJECT_DIR)
key="${CLAUDE_PROJECT_DIR:-$cwd}"
safe_key="$(echo -n "$key" | shasum | awk '{print $1}')"
state_dir="$HOME/.claude/state"
mkdir -p "$state_dir"
state="$state_dir/last_cwd_${safe_key}"

last="$(cat "$state" 2>/dev/null || true)"

if [[ "$always" = "1" || "$line" != "$last" ]]; then
  echo "$line"
  printf '%s' "$line" > "$state"
else
  # Exit silently when nothing changed to suppress hook completion messages
  exit 0
fi
