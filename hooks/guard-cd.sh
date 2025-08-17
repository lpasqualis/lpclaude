#!/usr/bin/env bash
set -euo pipefail

payload="$(cat)"
tool="$(jq -r '.tool_name // ""' <<<"$payload")"
cmd="$(jq -r '.tool_input.command // ""' <<<"$payload")"
proj="${CLAUDE_PROJECT_DIR:-}"

[[ "$tool" == "Bash" ]] || exit 0
[[ -n "$cmd" ]] || exit 0

# Fast-path: no 'cd' at all -> allow
if ! grep -Eq '(^|[;&|()[:space:]])cd([[:space:]]|$)' <<<"$cmd"; then
  exit 0
fi

# Helper to emit a machine-friendly rewrite message and block
block() {
  ROOT="${proj:-/ABS/PATH}"
  cat >&2 <<EOF
[CLAUDE_GUARD] POLICY_VIOLATION: INVALID_CD
ROOT="$ROOT"
WHY: Only subshell 'cd' to an absolute path inside ROOT is allowed:
  ( cd "\$ROOT[/subdir]" && <FULL_COMMAND_HERE> )
ALTERNATIVES (no 'cd'):
  - git -C "\$ROOT[/subdir]" <ARGS>
  - yarn --cwd "\$ROOT[/subdir]" <ARGS>
  - make -C "\$ROOT[/subdir]" <ARGS>
  - ./cexec "\$ROOT[/subdir]" <COMMAND> <ARGS>
ORIGINAL_COMMAND:
$cmd
RETURN: Output ONLY the corrected single-line command; no prose, no markdown.
EOF
  exit 2
}

# Allow exactly one leading subshell `cd ... &&` (coarse shell check)
# Examples matched:
#   ( cd /abs/path && make test )
#   (cd "$CLAUDE_PROJECT_DIR/tools/x" && npm ci)
shopt -s extglob
trimmed="$(sed -E 's/^[[:space:]]+|[[:space:]]+$//g' <<<"$cmd")"

# Extract leading subshell header if present
if [[ "$trimmed" =~ ^\([[:space:]]*cd[[:space:]]+([^[:space:];|)]+)[[:space:]]*&&[[:space:]] ]]; then
  cd_arg="${BASH_REMATCH[1]}"
  # Expand env vars like $CLAUDE_PROJECT_DIR safely
  # shellcheck disable=SC2016
  target="$(eval printf %s -- "$cd_arg" 2>/dev/null || true)"
  [[ -n "$target" ]] || block

  # Must be absolute
  [[ "$target" == /* ]] || block

  # If we know ROOT, enforce containment and existence
  if [[ -n "$proj" ]]; then
    rp="$(python3 - <<PY
import os,sys
p=os.path.realpath(sys.argv[1]); r=os.path.realpath(sys.argv[2])
print(p); print(r)
PY
"$target" "$proj" 2>/dev/null || true)"
    [[ -n "$rp" ]] || block
    t="$(sed -n '1p'<<<"$rp")"; r="$(sed -n '2p'<<<"$rp")"
    [[ -d "$t" ]] || block
    case "$t" in "$r"/*) ;; *) block ;; esac
  fi

  # Disallow any additional 'cd' tokens beyond the leading subshell
  rest="${trimmed#\(*\)}"
  if grep -Eq '(^|[;&|()[:space:]])cd([[:space:]]|$)' <<<"$rest"; then
    block
  fi

  # Looks good → allow
  exit 0
fi

# Any other 'cd' usage is blocked
block
