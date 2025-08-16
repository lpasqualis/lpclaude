#!/usr/bin/env bash
set -euo pipefail
# Reads hook JSON on stdin; block if Bash command uses a stateful `cd`.
# Exit code 2 = block & feed stderr back to Claude.
payload="$(cat)"
tool_name="$(jq -r '.tool_name // empty' <<<"$payload")"
cmd="$(jq -r '.tool_input.command // empty' <<<"$payload")"

if [[ "$tool_name" == "Bash" && -n "$cmd" ]]; then
  # Detect risky patterns: lone `cd`, `cd &&`, `; cd`, `&& cd`, line-start cd, etc.
  if grep -Eq '(^|[;&]|&&)[[:space:]]*cd([[:space:]]|$)' <<<"$cmd"; then
    {
      echo "Do not use plain 'cd'. Rewrite using one of these patterns:"
      echo "  ( cd \"\$DIR\" && full_command )"
      echo "  git -C \"\$DIR\" … / yarn --cwd \"\$DIR\" … / make -C \"\$DIR\" …"
      echo "Before any destructive op, print 'pwd' and verify."
      echo ""
      echo "Original command:"
      echo "$cmd"
    } 1>&2
    exit 2
  fi
fi
# allow
exit 0
