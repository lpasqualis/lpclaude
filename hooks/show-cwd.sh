#!/usr/bin/env bash
set -euo pipefail
# Claude runs hooks in the tool's current working directory.
echo "CWD: $(pwd)"
# Optional: show git branch if present
if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "GIT: $(git rev-parse --abbrev-ref HEAD)"
fi
