---
name: wrap-up
description: Prepare the session for a clean context /clear by finding and resolving loose ends. Use when the user says "wrap up", "prepare for a session clean", "prep for /clear", "tie off loose ends", "end of session", "clean up before I clear", or "leave it tidy for next time" — i.e. resolve danglers across git (uncommitted/unpushed), leftover TODO/FIXME/debug markers, temp/scratch files, stale implementation plans, lagging docs, and notes for the next session. Runs a read-only survey, then resolves each finding.
---

# wrap-up

Prepare the working state for a clean context `/clear`: surface every loose end,
then resolve it — so the next session starts from a tidy, fully-recorded baseline
with nothing half-wired left behind.

This skill is a **procedure**, not an app. The harness is a read-only survey
script that mechanically finds loose ends; you then resolve each one with
judgment. It is global — run it against whichever repo is the current directory.

## Step 1 — Run the survey (do this FIRST, before committing or cleaning)

Run it while the tree is still dirty, so it sees what you're about to leave
behind. It changes nothing; safe to run anytime.

```bash
bash ~/.claude/skills/wrap-up/survey.sh "$PWD"
```

Optional explicit path: `bash ~/.claude/skills/wrap-up/survey.sh /path/to/repo`.
Outside a git repo it exits 2 with a note (the rest of the wrap-up still applies).

The report has five sections and a `SUMMARY:` tally. Walk them in order.

## Step 2 — Resolve each section

The survey reports; you fix. Honor the user's standing directives as you go
(No Loose Ends, Definition of Done, commit-and-push-at-milestones, temp-file
cleanup, the memory system). Map each section to an action:

1. **Git state** — Group the dirty tree into atomic, semantically-typed commits
   (`feat`/`fix`/`docs`/`refactor`/`test`/`chore`), review staged with
   `git diff --staged`, then **commit and push** (this is pre-authorized at a
   milestone — do not ask). Push any ahead-of-upstream commits. Decide each
   forgotten **stash** consciously: pop and integrate, or drop. Caveat: if your
   changes share files with the user's own uncommitted parallel work, do not
   surgically split — leave it to commit together once it settles.
2. **Danglers in your changes** — For each TODO/FIXME/stub you introduced:
   finish it, or if it is genuinely future work, promote it to a tracked home
   (an implan entry or a future-note) rather than leaving a silent marker.
   **Remove every debug statement** (`console.log`, `breakpoint()`, …) before
   finalizing. The "code moved, docs did not" line is a soft prompt — check
   whether the touched code has docs that now lag.
3. **Temp / scratch artifacts** — If the session's work is done, delete the
   project's temp/scratch dirs and stray backups the survey lists. Use judgment:
   do not nuke a legitimate cache; `__pycache__`/`.pyc` is gitignored regen, not
   a loose end.
4. **Plans & TODO docs** — Reconcile each `ACTIVE_` plan with the actual state:
   mark finished phases done, and rename `ACTIVE_…` → `COMPLETE_…` when the plan
   is fully delivered. Skim listed TODO/PLAN docs for entries that are now stale.
5. **Notes for next session** — Persist anything durable and non-obvious to the
   memory system (one file per fact + a one-line `MEMORY.md` pointer; see the
   memory instructions). If work is mid-flight, leave an explicit handoff note
   (what's done, what's next, where you stopped) so the next session resumes
   without re-deriving context.

If a runtime-affecting change shipped this session (a new daemon/loop, a runtime
knob, behavior-changing config), confirm its operator surface is wired before
calling it done — that is itself a loose end (see the project's control-plane
standard when one exists).

## Step 3 — Confirm clean

After committing, pushing, and cleaning, re-run the survey. Aim for
`SUMMARY: clean.` (or only intentional, explained leftovers). Then the session
is safe to `/clear`.

```bash
bash ~/.claude/skills/wrap-up/survey.sh "$PWD"
```

## How the harness works (and why)

- **`survey.sh` is read-only.** It runs `git`, `find`, and `grep`; it never
  edits, commits, or deletes. All mutation is yours, with judgment.
- **"Your changes" = everything since the last push.** It diffs the working tree
  against the upstream (`git diff @{u}`), so committed-but-unpushed work and
  uncommitted work are scanned as one surface. No upstream → falls back to `HEAD`.
- **It scans new untracked files directly.** A brand-new file never appears in
  `git diff`, so a TODO or `breakpoint()` in a file you just created would be
  invisible to a diff-only scan. The survey greps untracked-not-ignored files on
  disk too. The plan scan (section 4) likewise unions tracked + untracked, so a
  plan you just created still counts.
- **The backup scan respects `.gitignore`.** It only flags backups git would
  care about (tracked, or untracked-and-not-ignored) — deliberately-ignored
  backups (e.g. timestamped directive backups) are left alone.
- **The memory path is derived from the repo path** (`$repo` with `/`→`-` under
  `~/.claude/projects/<slug>/memory`), so section 5 points at the right place
  per project.

## Gotchas

- **Run the survey before you commit/clean, not after.** Once you commit and
  push, sections 2–4 (which read the working-tree diff) go quiet — that's the
  point of the final re-run, but you'd miss danglers if you cleaned first.
- **A `git stash -u` hides the working tree.** If you stash untracked changes,
  the dirty-tree / dangler / temp / plan sections go silent because the files
  are now in the stash, not the tree — section 1 still flags the stash itself.
  Pop before surveying if you want to see what's in it.
- **The "code moved, docs did not" line is heuristic, not a verdict.** It only
  compares counts of changed code vs doc files; a code change with no doc impact
  trips it harmlessly. Treat it as a prompt to look, not a failure.

## The driver

`~/.claude/skills/wrap-up/survey.sh` — committed alongside this SKILL.md. It is
the harness this skill drives. Read-only, no dependencies beyond `git`/`find`/
`grep`/`sed`. Edit it here if the project's loose-end conventions change.
