```yaml
name: simplify
description: "Analyzes, simplifies, and verifies any input to its most essential form with zero loss of functional information."
argument-hint: "[file-path] [project-component] [full-project] [directory] [text-content] [special-instructions]"
model: claude-opus-4-1-20250805
allowed-tools: "Read, Write, Edit, MultiEdit, LS, Glob, Grep, Task"
```

<!-- OPTIMIZATION_TIMESTAMP: 2025-08-25  -->

**NO‑LOSS CONTRACT (hard requirement)**

* Preserve **all functional detail** and **all causal logic**: steps, conditions, dependencies, and order.
* Preserve **precision**: exact values, **units**, ranges/tolerances, **defaults**, formats, tool names, commands, API/CLI signatures.
* Preserve **edge cases, error handling, and invariants**.
* **Removal rule:** Content may be removed **only if** it (a) has **no GT‑ID** (non‑functional; adds no constraints) **or** (b) is a **verbatim duplicate**. Every removal must be recorded with a reason: `not-in-GTI` or `duplicate-of:<GT-ID>`.
* **Fail‑closed:** If any GT‑ID is not preserved, or any deletion lacks a valid ledger entry, or coverage has gaps → return a **failure report** (do **not** ship a simplified version).

**Scope:** Works for single files, components, directories, and full projects.
Target to simplify and/or special instructions: `$ARGUMENTS`

---

## Input Detection & Preparation

Determine input type and enumerate assets to analyze.

* **File path** → `Read` the file for analysis/modification.
* **Project component** → `Glob`/`Grep` to locate related files that must be considered.
* **Full project / directory** → `LS` + `Glob` to map all files (code, configs, docs, scripts).
* **Text content** → Treat as direct content; create/update files as needed via `Write`/`Edit`.
* **Special instructions** → Treat as **constraints** that must be captured in GTI.

**Backup Strategy (choose one):**

1. If `git status --porcelain` is empty → Use **git HEAD** as the reference; no extra backup required.

   * Verifiers: `git diff [file]`, `git show HEAD:[file]`.
2. Else (dirty or no git) → Create:

   ```
   .simplify/
     session_YYYYMMDD_HHMMSS/
       manifest.json   # files, paths, session metadata, backup method
       files/          # 1:1 mirror of originals for rollback
   ```

   Record method + timestamp in `manifest.json`. Copy each file before edits.

> Even when using git‑HEAD, write verification artifacts under `.simplify/session_[ts]/` so verifiers have a single place to look.

---

## Phase 1 — Analysis & Ground Truth

**1) Load & map**

* `Read` all relevant files.
* Build a dependency/map: file types, imports, script/CLI entry points, cross‑refs, config/ENV usage.

**2) Ground Truth Index (GTI) — required artifact**
Create a hierarchical list where each item has an ID `GT-###` with fields:

* `type`: step | condition | dependency | value | interface | error/edge | example | template/pattern | **constraint** | artifact path
* `content`: exact requirement/behavior/spec/value
* `source`: file path (+ optional line range)
* `dependencies`: GT‑IDs it relies on or unblocks
* `precision`: exact values, **units**, ranges/tolerances, **defaults**, formats, commands, tools that must not change

Write GTI to `.simplify/session_[ts]/ground_truth.md` (emit in final report even if using git‑HEAD).

**3) Simplification Opportunities (never alter GTI meaning)**
Identify **locations** of:

* TRUE redundancy (literal duplicates)
* Non‑functional verbosity (doesn’t affect execution/understanding)
* Redundant examples → keep the **single most comprehensive** unless others carry unique constraints
* Complex abstractions → simplify only if precision/behavior are intact
* Consolidatable patterns → unify repeated structures without changing sequence/logic
* Dead elements (unused code, unreferenced sections, obsolete instructions)

**4) Implementation Plan (write to report)**

* Files to edit/create/delete; order of operations; references to update
* Chosen backup method (git‑HEAD vs `.simplify` + timestamp)
* **Acceptance criteria:** every GT‑ID is **preserved and traceable** (verbatim | rephrased | consolidated | moved) in the simplified output

---

## Phase 2 — Implementation (active edits)

**Preserve:**

* Sequential steps; IF/THEN logic; pre/post conditions; dependency order
* Exact values, **units/ranges/defaults**, formats; commands; API/CLI signatures
* Error handling and edge‑case instructions
* Concrete examples that remove ambiguity
* Templates/patterns required for consistency

**Remove only (under the Removal rule):**

* Redundant explanations; literal repeats; non‑functional commentary
* Excess examples that don’t add unique constraints

**Actions:**

1. If using `.simplify`, copy each target to `.simplify/session_[ts]/files/[path]` **before** editing.
2. Apply edits with `Edit`/`MultiEdit`. Consolidate repeated sections; tighten language without semantic change.
3. Update imports/references/links affected by changes.
4. **Track all modifications** (file, change summary, rationale) in `change_log.md`.
5. **Record every removal** with file + span (line/char range if available) and `reason` ∈ {`not-in-GTI`, `duplicate-of:<GT-ID>`} in `removals.json` (or a structured table inside `change_log.md`).
6. **Project‑level rules:** modify all relevant files; consolidate cross‑file duplication; remove truly unnecessary files; create simplified replacements when beneficial; update references.
7. **Text‑content rules:** write the simplified version to appropriate files; create new files if reorganizing helps clarity.

**Comparison capability (must keep):**

* **git‑HEAD:** verifiers use `git diff` and `git show HEAD:[file]`.
* **.simplify:** verifiers read originals from `.simplify/session_[ts]/files/[path]`.
* Always update `.simplify/session_[ts]/manifest.json` with file changes, timestamps, and method.

---

## Phase 3 — Verification & Iteration (fail closed)

**A. Coverage Matrix (required; zero gaps)**
Build `.simplify/session_[ts]/coverage.json` (+ `coverage.md`) with one row per GT‑ID:

* `gt_id`, `type`, `original_location`, `simplified_location`
* `preservation_method`: verbatim | rephrased | consolidated | moved
* `precision_kept`: true/false + details
* `causal_chain_kept`: true/false + dependency notes
* **`interface_invariants_kept`**: true/false + diff if false
* **`units_ranges_defaults_kept`**: true/false + detail
* `status`: preserved | needs‑review
* `notes`

If any row ≠ `preserved` → **stop** and produce a failure report; do **not** ship.

**B. Self‑check (deterministic tests)**

* `Grep` for every exact value/command flagged in GTI.
* Assert dependency chains are intact (or explicitly documented if re‑ordered without semantic change).
* Confirm examples retained where they disambiguate behavior.
* Verify **units/ranges/defaults** for all `value` GT‑IDs.
* Verify **interface invariants** (API signatures/CLI flags) unchanged unless covered by GTI with an allowed transformation.

**B2. Removals Ledger Check (required)**

* Cross‑check that **every deleted span** appears in `removals.json` (or structured `change_log.md`) with a valid `reason`.
* Any orphan deletion → **fail**.

**C. Parallel verifier tasks (≥3 via `Task`)**
Reusable prompt template:

```
CLAIM: The simplification of [target] is complete and optimal with zero loss of functional information.

BACKUP METHOD: [git-head | simplify-folder]

ACCESS ORIGINAL vs CURRENT:
- git-head: Original → `git show HEAD:[file]`; Current → `Read [file]`; Changes → `git diff [file]`
- simplify-folder: Session → `.simplify/session_[ts]/`; Original → `.simplify/session_[ts]/files/[path]`; Manifest → `.simplify/session_[ts]/manifest.json`

ARTIFACTS:
- Ground Truth Index: ground_truth.md
- Coverage Matrix: coverage.json / coverage.md
- Removals Ledger: removals.json (or structured entries in change_log.md)
- Implementation Plan and Change Log

FOCUS:
- Verifier 1: Functional preservation (steps, conditions, dependencies, precision).
- Verifier 2: Implementation completeness (plan executed, only allowed removals, references updated).
- Verifier 3: Optimization potential (remaining true redundancy; any non-functional verbosity; guard against over-simplification).

CRITERIA:
- All GT-IDs mapped and `status: preserved`.
- Execution reliability maintained; no weaker conditions introduced.
- Precision unchanged where required (values/units/ranges/defaults).
- No ambiguity introduced where clarity is critical.
- Interface invariants maintained unless explicitly covered by GTI.
- File edits applied correctly; comparison paths work.
- All deletions justified and logged.
```

Aggregate findings. If any verifier flags an issue → **iterate Phase 2** (restore from backup if needed), refresh GTI/coverage, re‑run verifiers.

**D. Final Gate (ship only if all true)**

* Every GT‑ID is `preserved`.
* All deletions are justified and logged (no orphan removals).
* No further **lossless** simplifications remain.
* Precision and causal chains intact; interface invariants intact.
* Clarity measurably improved (shorter/clearer language, fewer duplicates) **without** behavioral change.

---

## Required Outputs (always produce; mark failure when applicable)

* `.simplify/session_[ts]/ground_truth.md` — GTI
* `.simplify/session_[ts]/coverage.json` and `coverage.md`
* `.simplify/session_[ts]/manifest.json` — updated with files and method
* `.simplify/session_[ts]/change_log.md` — files modified/created/deleted with reasons
* `.simplify/session_[ts]/removals.json` — deleted spans with `reason` and original refs (optional to embed as a structured table in `change_log.md`)
* `.simplify/session_[ts]/final_report.md` — plan, decisions, verification results, consensus, and metrics (size/duplication reduction)

**Cleanup**

* Keep `.simplify/session_[ts]/` for rollback.
* Optionally add `.simplify/` to `.gitignore`.

**Uncertainty rule**

* If uncertain about any GT‑ID mapping or preservation, **do not guess**. Emit **blocking questions** in `final_report.md` and return the **failure report** instead of a simplified output.
