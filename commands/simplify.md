---
name: simplify
description: "Analyzes, simplifies, and verifies any input (single file → full project) to its most essential form with zero loss of functional information; terminates at a fixed point."
argument-hint: "[file-path] [project-component] [full-project] [directory] [text-content] [special-instructions]"
model: claude-opus-4-1-20250805
allowed-tools: "Read, Write, Edit, MultiEdit, LS, Glob, Grep, Task"
---

<!-- OPTIMIZATION_TIMESTAMP: 2025-08-25 -->

**NO‑LOSS CONTRACT (hard requirement)**

* Preserve **all functional detail** and **causal logic**: steps, conditions, dependencies, order.
* Preserve **precision**: exact values, **units**, ranges/tolerances, **defaults**, formats, commands, API/CLI signatures, file paths, schemas.
* Preserve **edge cases, error handling, invariants, and interface contracts**.
* **Removal rule:** Content may be removed **only if** it (a) has **no GT‑ID** (non‑functional; adds no constraints) **or** (b) is a **verbatim duplicate**. Log every removal with `reason ∈ {not-in-GTI, duplicate-of:<GT-ID>}`.
* **Rephrase rule:** GT‑mapped text must remain **verbatim** unless the GTI marks it `needs-rephrase: true` (ambiguity/contradiction). Otherwise, rephrasing is disallowed.
* **Fail‑closed:** If any GT‑ID is not preserved, any deletion lacks a valid ledger entry, or coverage has gaps → emit a **failure report**; do **not** ship a simplified version.

**Scope / Target**

* Works for individual files, components, directories, and full projects comprising **textual artifacts** that can be read/modified with the allowed tools.
* Target to simplify: `$ARGUMENTS`

---

## Input Detection & Preparation

* **File path** → `Read`.
* **Project component** → `Glob`/`Grep` to locate related files.
* **Full project / directory** → `LS` + `Glob` to enumerate all textual artifacts (code, configs, docs, scripts, markup, data files).
* **Text content** → treat as direct content; create/update files via `Write`/`Edit`.
* **Special instructions** → record as **constraints** in GTI.

**Non‑text / opaque files**

* If `Read` returns binary/opaque content, mark as **opaque** in the manifest; **do not modify**; exclude from simplification but keep paths in the inventory for completeness.

**Inventory scope & ignores (must apply to Phase 0/1/2 and all equality checks)**

* Define the **inventory** = all discovered artifacts (text + opaque).
* Define the **content set** = inventory **minus** ignored/generated/volatile paths (these remain listed in the manifest with `ignored: true` + `reason`).
* Default ignore globs (extend with `.gitignore` if present):
  * `.simplify/**`, `.git/**`, `.svn/**`, `.hg/**`
  * `node_modules/**`, `vendor/**`, `third_party/**`, `dist/**`, `build/**`, `target/**`, `.next/**`, `.nuxt/**`, `.cache/**`
  * `__pycache__/**`, `.pytest_cache/**`, `.tox/**`, `.venv/**`, `venv/**`
  * `*.log`, `*.tmp`, `*.bak`
  * **lockfiles**: `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `poetry.lock`, `Pipfile.lock`, `go.sum`, `Cargo.lock`
* Record the **include**/**ignore** sets and reasons in `manifest.json`.
* **Never** edit or canonicalize ignored artifacts; they are out of scope for `M` and fixed‑point checks.

**Backup Strategy (choose one)**

* If `git status --porcelain` is empty → use **git HEAD** as reference (no extra backup). Verifiers: `git diff [file]`, `git show HEAD:[file]`.
* Else (dirty or no git) → create:

  ```
  .simplify/
    session_YYYYMMDD_HHMMSS/
      manifest.json   # files, families, include/ignore sets, session metadata, backup method
      files/          # 1:1 mirror of originals for rollback
  ```

  Record method + timestamp in `manifest.json`. Copy each file before edits.

> Even with git‑HEAD, write verification artifacts under `.simplify/session_[ts]/` so verifiers have a single place to look.

**Timestamp rule**
* Update `<!-- OPTIMIZATION_TIMESTAMP: ... -->` **only if** the **content‑set canonical snapshot** changes.
* Timestamp lines are **not** part of equality checks.

---

## Phase 0 — Canonicalization & Fixed‑Point Guard (format‑agnostic)

**Goal:** idempotence. Only write when there’s a real, loss‑free improvement.

**0.1 Inventory & family detection**

* For each **textual** artifact in the inventory, assign a **family** (extension + content heuristics):

  * `code/<lang>` (python, js/ts, go, java, c/cpp, csharp, ruby, php, rust, shell, sql, etc.)
  * `data/{json|yaml|toml|csv|tsv|ndjson}`
  * `markup/{html|xml}`
  * `doc/{markdown|text|restructuredtext|asciidoc}`
  * `config/{env|ini|properties}`
  * `notebook/ipynb` (JSON; treat outputs as content to **preserve**)
  * `unknown/text` (fallback)
  * `opaque` (binary/unreadable; never edited)
* Write `path → family` and `included/ignored` flags to `manifest.json`.

**0.2 Family‑aware canonicalization `CANON(text, family)` (semantics‑safe only)**
Apply the **least** normalization that guarantees idempotence **without** risking meaning:

* **ALL families:** normalize line endings to `\n`; ensure a single trailing newline. **Do not** trim trailing spaces globally.
* **code/\*:** EOL normalization only. Do **not** change indentation, quoting, tokens, or blank‑line counts.
* **data/json:** if valid JSON, pretty‑print with 2‑space indent **without reordering keys**; preserve numbers/strings exactly. If invalid JSON, treat as plain text (ALL rule only).
* **data/yaml|toml:** treat as plain text (ALL rule only). Do **not** reflow, re‑indent, or coerce scalars; preserve comments/anchors/tags.
* **data/csv|tsv|ndjson:** ALL rule only. Do **not** trim or rewrap lines; whitespace may be data.
* **markup/html|xml:** ALL rule only. Do **not** reflow text nodes or alter attribute order/entities.
* **doc/markdown|text|rst|asciidoc:** ALL rule only. **Do not** strip EOL spaces (Markdown hard breaks) or rewrap paragraphs; leave code fences untouched.
* **config/env|ini|properties:** ALL rule only. Do **not** trim or reorder.
* **notebook/ipynb:** treat as JSON per `data/json`, but **preserve execution counts and outputs verbatim**.

**0.3 Project canonical snapshot & signature (content set only)**

* For every **included** artifact, compute `canon_i = CANON(text, family)`.
* Concatenate in **path‑sorted** order into `.simplify/canonical.snapshot` using separator:
  `\n--- path: <file> ---\n` + `canon_i`
* Persist per‑file canonical text under `.simplify/canonical/<path>.canon`.
* The `.simplify/**` directory itself is **excluded** from the content set and never appears in the snapshot.
* Equality checks use **byte‑for‑byte** equality of the snapshot (timestamps excluded) and per‑file canonical texts.

**0.4 Monotonic measure (termination guard)**
Let `M = (U, R, C, O)` across **included** artifacts:

* `U` = count of GT‑IDs not `preserved`.
* `R` = count of GT‑IDs with `needs-rephrase: true` not yet rephrased.
* `C` = count of **canonicalization issues** remaining (files whose raw text still differs from `CANON` under allowed rules).
* `O` = count of **open simplification opportunities** flagged in Phase 1 (literal duplicates not consolidated; redundant examples beyond the chosen one; dead elements not removed; cross‑file duplication not unified).

**Proceed with edits only if BOTH are true:**

1. The **new** `.simplify/canonical.snapshot` (built from the content set) would differ from the previous one, **and**
2. `M` would **strictly decrease lexicographically**.
   Otherwise: **exit early** (fixed point). Do **not** touch source files or timestamps; write `final_report.md` noting a no‑op.

---

## Phase 1 — Analysis & Ground Truth

**Load & map**

* `Read` all **included** textual files.
* Build a dependency map: imports/uses, entry points, config/ENV usage, cross‑refs.

**Ground Truth Index (GTI) — required artifact**

* Create a hierarchical list. Deterministic IDs: `gt-<type>-<slug>` (lowercase, hyphenated ≤60 chars; add `-2`, `-3` for collisions).
* Fields per item:

  * `type`: step | condition | dependency | value | interface | error/edge | example | template/pattern | constraint | artifact path
  * `content`: exact requirement/behavior/spec/value
  * `source`: file path (+ optional line range)
  * `dependencies`: GT‑IDs it relies on or unblocks
  * `precision`: exact values, **units**, ranges/tolerances, **defaults**, formats, commands, tools that must not change
  * `invariants`: interface signatures, required flags, default values, units/ranges (if applicable)
  * `needs-rephrase`: true|false (default false)
* Write GTI to `.simplify/session_[ts]/ground_truth.md` (emit in final report even under git‑HEAD).

**Simplification Opportunities (never alter GTI meaning)**

* TRUE redundancy (literal duplicates)
* Non‑functional verbosity (doesn’t affect execution/understanding)
* Redundant examples → keep the **single most comprehensive** unless others carry unique constraints
* Complex abstractions → simplify only if precision/behavior intact
* Consolidatable patterns → unify repeats without changing sequence/logic
* Dead elements (unused code, unreferenced sections, obsolete instructions)

**Implementation Plan (write to report)**

* Files to edit/create/delete; order; references to update; cross‑file consolidation steps.
* Backup method (git‑HEAD vs `.simplify` + timestamp).
* **Acceptance criteria:** every GT‑ID is **preserved and traceable** (verbatim | rephrased\* | consolidated | moved).
  \*Rephrase allowed **only** when `needs-rephrase: true`.

---

## Phase 2 — Implementation (active edits)

**Preserve**

* Sequential steps; IF/THEN logic; pre/post conditions; dependency order.
* Exact values, **units/ranges/defaults**, formats; commands; API/CLI signatures.
* Error handling, edge cases, invariants.
* Concrete examples that remove ambiguity.
* Templates/patterns required for consistency.

**Remove only (under the Removal rule)**

* Literal duplicates; non‑functional commentary; excessive examples that add no unique constraints.

**Actions**

* If using `.simplify`, copy each target to `.simplify/session_[ts]/files/[path]` **before** editing.
* Apply edits with `Edit`/`MultiEdit`. Consolidate repeats; tighten language without semantic change.
* Update imports/references/links as needed.
* Track all modifications (file, change summary, rationale) in `change_log.md`.
* Record **every removal** with file + span (line/char range if available) and `reason ∈ {not-in-GTI, duplicate-of:<GT-ID>}` in `removals.json` (or a structured table in `change_log.md`), including the **canonical excerpt** justifying it.
* **Never modify** lockfiles or vendored/third‑party directories (`vendor/**`, `third_party/**`, `node_modules/**`, etc.); they remain inventory‑visible but **ignored** for edits, canonicalization, and `M`.
* Project‑level: consolidate cross‑file duplication; remove truly unnecessary files; create simplified replacements if beneficial; update references.
* Text‑content: write simplified versions; create new files if reorganizing improves clarity.

**Pre‑write fixed‑point check**

* Recompute per‑file `CANON` and the project snapshot; recompute `M`.
* **Only write** if snapshot changes **and** `M` strictly decreases. Otherwise, **exit early** (no‑op write).

**Comparison capability (must keep)**

* **git‑HEAD:** verifiers use `git diff [file]` and `git show HEAD:[file]`.
* **.simplify:** verifiers read originals from `.simplify/session_[ts]/files/[path]`.
* Always update `.simplify/session_[ts]/manifest.json` with file changes, timestamps, method, and include/ignore sets.

---

## Phase 3 — Verification & Iteration (fail closed)

**Coverage Matrix (required; zero gaps)**

* `.simplify/session_[ts]/coverage.json` (+ `coverage.md`) — one row per GT‑ID:

  * `gt_id`, `type`, `original_location`, `simplified_location`
  * `preservation_method`: verbatim | rephrased | consolidated | moved
  * `precision_kept`: true/false + details
  * `causal_chain_kept`: true/false + dependency notes
  * `interface_invariants_kept`: true/false + diff if false
  * `units_ranges_defaults_kept`: true/false + detail
  * `status`: preserved | needs‑review
  * `notes`
* Any row ≠ `preserved` → **fail** (do not ship).

**Self‑check (deterministic tests)**

* `Grep` for all exact values/commands flagged in GTI.
* Assert dependency chains intact (or explicitly documented if reordered without semantic change).
* Confirm examples retained where they disambiguate behavior.
* Verify **units/ranges/defaults** for all `value` GT‑IDs.
* Verify **interface invariants** (API signatures/CLI flags) unchanged unless covered by GTI with an allowed transformation.
* Compute `M` before/after; assert a **strict decrease** if any writes occurred.

**Removals Ledger Check (required)**

* Every deletion appears in `removals.json` (or structured `change_log.md`) with a valid reason; any orphan deletion → **fail**.

**Parallel verifier tasks (≥3 via `Task`)**
Reusable prompt:

```
CLAIM: The simplification of [target] is complete and optimal with zero loss of functional information, and the run is at a fixed point.

BACKUP METHOD: [git-head | simplify-folder]

ACCESS ORIGINAL vs CURRENT:
- git-head: Original → `git show HEAD:[file]`; Changes → `git diff [file]`
- simplify-folder: Session → `.simplify/session_[ts]/`; Original → `.simplify/session_[ts]/files/[path]`; Manifest → `.simplify/session_[ts]/manifest.json`

ARTIFACTS:
- Ground Truth Index: ground_truth.md
- Coverage Matrix: coverage.json / coverage.md
- Removals Ledger: removals.json (or structured entries in change_log.md)
- Implementation Plan and Change Log
- Canonical snapshot: .simplify/canonical.snapshot (and per-file .canon files)
- Measure M: (U, R, C, O) before/after
- Include/ignore sets from manifest

FOCUS:
- Verifier 1: Functional preservation (steps, conditions, dependencies, precision).
- Verifier 2: Implementation completeness (plan executed; only allowed removals; family-appropriate CANON applied).
- Verifier 3: Optimization potential (remaining true redundancy; any non-functional verbosity; guard against over-simplification).

CRITERIA:
- All GT-IDs mapped and `status: preserved`.
- Execution reliability maintained; no weaker conditions introduced.
- Precision unchanged where required (values/units/ranges/defaults).
- Interface invariants maintained unless explicitly covered by GTI.
- File edits applied correctly; comparison paths work.
- All deletions justified and logged.
- Canonical snapshot changed only when `M` **strictly decreased**; otherwise run must report fixed point.
```

Aggregate findings. If any verifier flags issues → **iterate Phase 2** (restore from backup if needed), refresh GTI/coverage, re‑verify.

**Final Gate**

* Every GT‑ID is `preserved`; all deletions justified and logged.
* No further **lossless** simplifications remain.
* Precision and causal chains intact; interface invariants intact.
* **Fixed point:** canonical snapshot unchanged on a dry‑run and `M` cannot decrease further.

---

## Required Outputs

* `.simplify/session_[ts]/ground_truth.md` — GTI
* `.simplify/session_[ts]/coverage.json` and `coverage.md`
* `.simplify/session_[ts]/manifest.json` — files, families, include/ignore sets, backup method
* `.simplify/session_[ts]/change_log.md` — files modified/created/deleted with reasons
* `.simplify/session_[ts]/removals.json` — deleted spans with `reason` and references (or structured table in `change_log.md`)
* `.simplify/session_[ts]/final_report.md` — plan, decisions, verification results, consensus, metrics (size/duplication reduction)
* `.simplify/canonical/<path>.canon` — per‑file canonical contents for included artifacts
* `.simplify/canonical.snapshot` — project‑level canonical snapshot for fixed‑point detection

---

## Cleanup

* Keep `.simplify/session_[ts]/` for rollback.
* Optionally add `.simplify/` to `.gitignore`.

---

## Uncertainty rule

* If uncertain about any GT‑ID mapping or preservation, **do not guess**. Emit **blocking questions** in `final_report.md` and return the **failure report** instead of a simplified output.
