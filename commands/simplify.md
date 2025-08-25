---

```yaml
name: simplify-no-loss
description: "Analyzes, simplifies, and verifies any input to its most essential form with zero loss of functional information."
argument-hint: "[file-path] [project-component] [full-project] [directory] [text-content] [special-instructions]"
model: claude-opus-4-1-20250805
allowed-tools: "Read, Write, Edit, MultiEdit, LS, Glob, Grep, Task"
```

<!-- OPTIMIZATION_TIMESTAMP: 2025-08-25  -->

**NO‑LOSS CONTRACT (hard requirement)**

* Preserve **all functional detail** and **all causal logic** (steps, conditions, dependencies, order).
* Preserve **precision** (exact values, tolerances, formats, tool names, commands).
* Preserve **edge cases, error handling, and invariants**.
* Removal is allowed **only** for **TRUE redundancy** (verbatim duplicates that add zero precision or clarity).
* If any item cannot be shown as preserved in the coverage matrix, **do not output a simplified version**. Output a **failure report** instead.

**Scope**: Works for single files, components, directories, and full projects.

Target to simplify: `$ARGUMENTS`

---

## Input Detection & Preparation

Determine input type and enumerate assets to analyze:

* **File path** → `Read` it.
* **Project component** → `Glob`/`Grep` to locate related files.
* **Full project / directory** → `LS` + `Glob` to map all files (code, config, docs, scripts).
* **Text content** → Treat as direct content; create/update files as needed.
* **Special instructions** → Treat as **constraints** on simplification.

**Backup Strategy (must choose one):**

1. If `git status --porcelain` is empty → Use **git HEAD** as reference; no extra backup.
2. Else (dirty or no git) → Create:

```
.simplify/
  session_YYYYMMDD_HHMMSS/
    manifest.json   # files, paths, session metadata, backup method
    files/          # 1:1 mirror of originals for rollback
```

Record method + timestamp in `manifest.json`. Always back up before editing when using `.simplify`.

---

## Phase 1 — Analysis & Ground Truth

**1) Load & map**

* Read all relevant files.
* Build a map of file types, dependencies, script entry points, and cross‑refs (import/use sites).

**2) Ground Truth Index (GTI) — required artifact**
Create `GTI` as a hierarchical list; each entry gets an ID `GT-###` with fields:

* `type`: step | condition | dependency | value | interface | error/edge | example | template/pattern | artifact path
* `content`: the exact requirement/behavior/spec/value
* `source`: file path (+ optional line range)
* `dependencies`: IDs this item relies on or unblocks
* `precision`: exact values, formats, commands, tools that must not change
  Write GTI to `.simplify/session_[ts]/ground_truth.md` (or keep in memory if using git‑HEAD, but you must still emit it in the final report).

**3) Simplification Opportunities (where changes may occur, never altering GTI meaning)**
Identify **locations** of:

* TRUE redundancy (literal duplicates).
* Non‑functional verbosity (doesn’t change execution/understanding).
* Redundant examples → keep the **single most comprehensive** unless others carry unique constraints.
* Complex abstractions → simplify **only if** precision and behavior are intact.
* Consolidatable patterns → unify repeated structures without changing sequence/logic.
* Dead elements (unused code, unreferenced sections, obsolete instructions).

**4) Implementation Plan (write this plan to the report)**

* Files to edit/create/delete; order of ops; references to update.
* Chosen backup method (git‑HEAD vs `.simplify` + timestamp).
* Acceptance criteria: every GT‑ID must map 1:1 to the simplified output.

---

## Phase 2 — Implementation (active edits)

**Preserve:**

* Sequential steps, IF/THEN logic, pre/post conditions, and dependency order.
* Exact values, strict formats, commands, API signatures.
* Error handling and edge‑case instructions.
* Concrete examples that resolve ambiguity.
* Templates/patterns required for consistency.

**Remove only:**

* Redundant explanations, literal repeats, non‑functional commentary.
* Excess examples that don’t add unique constraints.

**Actions:**

1. If using `.simplify`, copy each target to `.simplify/session_[ts]/files/[path]` **before** editing.
2. Apply edits with `Edit`/`MultiEdit`. Consolidate repeated sections; tighten language without changing semantics.
3. Update imports/references/links that simplification affects.
4. **Track all modifications** with a brief reason per file (keep this list).
5. **Project‑level rules:**

   * Modify all relevant files; consolidate cross‑file duplication; remove truly unnecessary files; create simplified replacements when beneficial; update references.
6. **Text‑content rules:**

   * Write the simplified version to appropriate files; create new files if reorganizing helps clarity.

**Comparison capability (must keep):**

* **git‑HEAD**: verifiers use `git diff` and `git show HEAD:[file]`.
* **.simplify**: verifiers read originals from `.simplify/session_[ts]/files/[path]`.
* Always update `.simplify/session_[ts]/manifest.json` with file changes, timestamps, method.

---

## Phase 3 — Verification & Iteration (fail closed)

**A. Coverage Matrix (required; zero gaps)**
Build `coverage.json` (and a human view `coverage.md`) with one row per GT‑ID:

* `gt_id`, `type`, `original_location`, `simplified_location`,
* `preservation_method` (verbatim | rephrased | consolidated | moved),
* `precision_kept` (true/false + details),
* `causal_chain_kept` (true/false + dependencies),
* `notes`, `status` (preserved | needs‑review).
  If any row ≠ `preserved`, **stop** and produce a failure report; do **not** ship a simplified output.

**B. Self‑check (deterministic tests)**

* Re‑scan simplified output with `Grep` for every exact value/command flagged in GTI.
* Assert that each dependency chain still appears in order (or is explicitly documented if restructured without semantic change).
* Confirm examples retained where they disambiguate behavior.

**C. Parallel verifier tasks (minimum 3 via `Task`)**
Use this reusable prompt template:

```
CLAIM: The simplification of [target] is complete and optimal with zero loss of functional information.

BACKUP METHOD: [git-head | simplify-folder]

ACCESS ORIGINAL vs CURRENT:
- git-head: Original → `git show HEAD:[file]`; Current → `Read [file]`; Changes → `git diff [file]`
- simplify-folder: Session → `.simplify/session_[ts]/`; Original → `.simplify/session_[ts]/files/[path]`; Manifest → `.simplify/session_[ts]/manifest.json`

ARTIFACTS:
- Ground Truth Index: ground_truth.md
- Coverage Matrix: coverage.json / coverage.md
- Implementation Plan and Change Log

FOCUS:
- Verifier 1: Functional preservation (steps, conditions, dependencies, precision).
- Verifier 2: Implementation completeness (plan executed, only non-functional content removed, references updated).
- Verifier 3: Optimization potential (remaining true redundancy, any non-functional verbosity, check against over‑simplification).

CRITERIA:
- All GT‑IDs mapped and marked preserved.
- Execution reliability maintained; no weaker conditions introduced.
- Precision unchanged where required.
- No ambiguity introduced where clarity is critical.
- File edits applied correctly; comparison path works.
```

Aggregate findings. If any verifier flags an issue → **iterate Phase 2** (restore from backup if needed), refresh GTI/coverage, and re‑verify.

**D. Final Gate (all must be true)**

* Every GT‑ID is `preserved`.
* No further lossless simplifications exist.
* Precision and causal chains intact.
* Clarity measurably improved (shorter/clearer language, fewer duplicates) **without** changing behavior.

---

## Required Outputs

Always produce these artifacts (even on failure; mark as failure if so):

* `.simplify/session_[ts]/ground_truth.md` — GTI
* `.simplify/session_[ts]/coverage.json` and `coverage.md`
* `.simplify/session_[ts]/manifest.json` (updated)
* `.simplify/session_[ts]/change_log.md` — files modified/created/deleted with reasons
* `.simplify/session_[ts]/final_report.md` — plan, decisions, verification results, consensus, metrics (size/duplication reduction)

If using git‑HEAD, write these artifacts under `.simplify/session_[ts]/` for verifiers even though git holds originals.

**Cleanup**

* Keep `.simplify/session_[ts]/` for rollback.
* Optionally add `.simplify/` to `.gitignore`.

**If uncertain about any GT‑ID mapping:** do **not** guess. Emit a **blocking questions** section in `final_report.md` and return the **failure report**.

---

### Why this guarantees no loss

* **Fail‑closed design**: no simplified output unless **every** GT‑ID is proven preserved.
* **Ground Truth + Coverage Matrix** create a one‑to‑one audit trail from original to result.
* **Parallel verifiers** check function, completeness, and optimization separately.
* **Exact‑value and causal‑chain checks** prevent subtle semantic drift.

Paste this as the system/tool prompt for your `simplify` command. It will work for single files through full projects and will stop rather than ship if preservation can’t be proven.
