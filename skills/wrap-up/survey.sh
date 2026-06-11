#!/usr/bin/env bash
# wrap-up survey — read-only loose-end finder for a session wrap-up.
# Surveys the current git repo for danglers an agent should resolve before a
# context /clear: dirty git state, unpushed work, debug/TODO markers introduced
# this session, temp/scratch artifacts, stale plans, and future-note targets.
#
# READ-ONLY. It changes nothing. It prints a report and a summary tally so the
# /wrap-up skill can decide what to fix. Run from anywhere inside a repo.
#
# Usage: survey.sh [path]   (path defaults to $PWD; cd-free, uses git -C)

root="${1:-$PWD}"
# Resolve to the repo top-level so every section sees the whole tree.
top="$(git -C "$root" rev-parse --show-toplevel 2>/dev/null)"
if [ -z "$top" ]; then
  echo "wrap-up survey: '$root' is not inside a git repository." >&2
  echo "(A wrap-up still applies — just no git section. cd into the repo or pass its path.)" >&2
  exit 2
fi
g() { git -C "$top" "$@"; }

issues=0
bar() { printf '%s\n' "------------------------------------------------------------"; }
hdr() { bar; printf '  %s\n' "$1"; bar; }

printf '\n'; hdr "WRAP-UP SURVEY"
printf '  repo: %s\n' "$top"

# ---------------------------------------------------------------- 1. GIT STATE
printf '\n## 1. Git state\n\n'
branch="$(g rev-parse --abbrev-ref HEAD 2>/dev/null)"
upstream="$(g rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)"
printf 'branch: %s\n' "${branch:-?}"
if [ -n "$upstream" ]; then
  set -- $(g rev-list --left-right --count "${upstream}...HEAD" 2>/dev/null)
  behind="${1:-0}"; ahead="${2:-0}"
  printf 'upstream: %s  (ahead %s, behind %s)\n' "$upstream" "$ahead" "$behind"
  if [ "${ahead:-0}" -gt 0 ]; then
    issues=$((issues+1))
    printf '\n[!] %s commit(s) not pushed:\n' "$ahead"
    g log --oneline "${upstream}..HEAD" | sed 's/^/    /'
  fi
else
  printf 'upstream: (none — branch has no tracking remote)\n'
fi

dirty="$(g status --porcelain 2>/dev/null)"
if [ -n "$dirty" ]; then
  issues=$((issues+1))
  n="$(printf '%s\n' "$dirty" | grep -c .)"
  printf '\n[!] working tree dirty — %s path(s):\n' "$n"
  printf '%s\n' "$dirty" | sed 's/^/    /'
else
  printf '\nworking tree: clean\n'
fi

stashes="$(g stash list 2>/dev/null)"
if [ -n "$stashes" ]; then
  issues=$((issues+1))
  printf '\n[!] forgotten stash(es):\n'
  printf '%s\n' "$stashes" | sed 's/^/    /'
fi

# --------------------------------------------- 2. DANGLERS IN SESSION CHANGES
# Best proxy for "this session": everything changed since the last pushed point
# (committed-but-unpushed + uncommitted), in one diff: `git diff <upstream>`.
printf '\n## 2. Danglers in your changes (since last push)\n\n'
if [ -n "$upstream" ]; then diffbase="$upstream"; else diffbase="HEAD"; fi
diff="$(g diff "$diffbase" 2>/dev/null)"
# Added lines (+, not the +++ header) carrying a marker. file:line not tracked
# by plain diff grep, so we show the added line; agent greps the file to place it.
markers='TODO|FIXME|XXX|HACK|WIP|STUB|TEMP HACK|REMOVE ME|DO NOT (COMMIT|MERGE)'
debug='console\.log|debugger;|breakpoint\(\)|pdb\.set_trace|import pdb|binding\.pry|dbg!|println!\("DEBUG'
# (a) tracked changes since last push: scan added (+) lines of the diff.
added="$(printf '%s\n' "$diff" | grep -E "^\+" | grep -vE '^\+\+\+')"
mk="$(printf '%s\n' "$added" | grep -E "$markers" | sed 's/^+/    + /')"
db="$(printf '%s\n' "$added" | grep -E "$debug"   | sed 's/^+/    + /')"
# (b) brand-new untracked-not-ignored files never appear in `git diff` — scan
#     them directly so a dangler in a file you just created still surfaces.
scan_new() { # $1 = pattern; greps each untracked-not-ignored file, file:line out
  printf '%s\n' "$new" | while IFS= read -r f; do
    [ -n "$f" ] || continue
    grep -HnIE "$1" "$top/$f" 2>/dev/null
  done | sed "s#^$top/#    #"
}
new="$(g ls-files -o --exclude-standard 2>/dev/null)"
umk=""; udb=""
[ -n "$new" ] && umk="$(scan_new "$markers")"
[ -n "$new" ] && udb="$(scan_new "$debug")"
allmk="$(printf '%s\n%s\n' "$mk" "$umk" | grep -E .)"
alldb="$(printf '%s\n%s\n' "$db" "$udb" | grep -E .)"
if [ -n "$allmk" ]; then
  issues=$((issues+1)); printf '[!] TODO/stub markers (changed or new files):\n%s\n\n' "$allmk"
fi
if [ -n "$alldb" ]; then
  issues=$((issues+1)); printf '[!] debug statements left in:\n%s\n\n' "$alldb"
fi
[ -z "$allmk$alldb" ] && printf 'none found.\n'
# Files touched since last push — eyeball whether docs lagged behind code.
touched="$(g diff --name-only "$diffbase" 2>/dev/null)"
if [ -n "$touched" ]; then
  code="$(printf '%s\n' "$touched" | grep -ivE '\.(md|txt|rst|adoc)$|(^|/)docs?/' | grep -c .)"
  docs="$(printf '%s\n' "$touched" | grep -iE  '\.(md|txt|rst|adoc)$|(^|/)docs?/' | grep -c .)"
  printf '\nchanged since last push: %s code file(s), %s doc file(s)' "$code" "$docs"
  [ "$code" -gt 0 ] && [ "$docs" -eq 0 ] && printf '  [!] code moved, docs did not — check for stale docs'
  printf '\n'
fi

# -------------------------------------------------- 3. TEMP / SCRATCH ARTIFACTS
printf '\n## 3. Temp / scratch artifacts\n\n'
found_temp=0
for d in tmp temp .tmp scratch .scratch; do
  if [ -d "$top/$d" ]; then
    sz="$(du -sh "$top/$d" 2>/dev/null | cut -f1)"
    cnt="$(find "$top/$d" -type f 2>/dev/null | grep -c .)"
    [ "$cnt" -gt 0 ] && { printf '[?] %s/  (%s, %s file(s)) — clean if this session is done\n' "$d" "$sz" "$cnt"; found_temp=1; }
  fi
done
# Stray editor/merge backups — but only ones git would care about (tracked, or
# untracked-and-not-ignored). Deliberately .gitignored backups are left alone.
bakpat='\.(bak|orig|rej|swp)$|~$'
backups="$( { g ls-files; g ls-files -o --exclude-standard; } 2>/dev/null | grep -E "$bakpat" | sort -u)"
if [ -n "$backups" ]; then
  found_temp=1
  printf '[?] stray backup/merge files (not gitignored):\n'
  printf '%s\n' "$backups" | head -20 | sed 's/^/    /'
  extra="$(printf '%s\n' "$backups" | grep -c .)"; [ "$extra" -gt 20 ] && printf '    ... and %s more\n' "$((extra-20))"
fi
if [ "$found_temp" -eq 1 ]; then issues=$((issues+1)); else printf 'none.\n'; fi
printf '(build noise like __pycache__/.pyc is gitignored regen — not a loose end; ignore.)\n'

# --------------------------------------------------- 4. PLANS / TODO DOCUMENTS
printf '\n## 4. Plans & TODO docs to update\n\n'
# tracked + untracked-not-ignored, so a plan you just created this session counts.
files="$( { g ls-files; g ls-files -o --exclude-standard; } 2>/dev/null | sort -u)"
# ACTIVE_ plans are the strongest signal: they explicitly claim in-progress work.
active="$(printf '%s\n' "$files" | grep -E '(^|/)ACTIVE_[^/]*\.md$')"
# Generic loose-end docs that tend to drift: top-level/anywhere PLAN/TODO/ROADMAP/NOTES.
loose="$(printf '%s\n' "$files" | grep -iE '(^|/)(PLAN|TODO|ROADMAP|NOTES)\.md$')"
if [ -n "$active" ]; then
  issues=$((issues+1))
  printf '[!] ACTIVE plan(s) — reconcile status / rename to COMPLETE_ if done:\n'
  printf '%s\n' "$active" | sed 's/^/    /'
fi
if [ -n "$loose" ]; then
  [ -n "$active" ] && printf '\n'
  printf 'plan/TODO docs to skim for stale entries:\n'
  printf '%s\n' "$loose" | sed 's/^/    /'
fi
[ -z "$active$loose" ] && printf 'no ACTIVE plans or TODO/PLAN docs found.\n'
# Count of done plans is context, not a task — one line, not a dump.
donep="$(printf '%s\n' "$files" | grep -cE '(^|/)COMPLETE_[^/]*\.md$')"
[ "$donep" -gt 0 ] && printf '(%s COMPLETE_ plan(s) on disk — already done, left as-is.)\n' "$donep"

# ------------------------------------------------------- 5. FUTURE-NOTE TARGETS
printf '\n## 5. Where to leave notes for next session\n\n'
slug="$(printf '%s' "$top" | sed 's#/#-#g')"
mem="$HOME/.claude/projects/${slug}/memory"
if [ -d "$mem" ]; then
  printf 'memory dir: %s\n' "$mem"
  [ -f "$mem/MEMORY.md" ] && printf '  MEMORY.md present — append/update facts worth persisting.\n'
else
  printf 'memory dir: (none yet at %s)\n' "$mem"
fi
[ -f "$top/NOTES.md" ] && printf 'NOTES.md present at repo root — fold scratch notes in or clear it.\n'
printf '(Also: this session-summary itself is a note — leave a handoff line if work is mid-flight.)\n'

# ------------------------------------------------------------------- SUMMARY
printf '\n'; bar
if [ "$issues" -eq 0 ]; then
  printf '  SUMMARY: clean. No loose ends found by the survey.\n'
else
  printf '  SUMMARY: %s category(ies) need attention. Walk sections 1-5 above.\n' "$issues"
fi
bar; printf '\n'
exit 0
