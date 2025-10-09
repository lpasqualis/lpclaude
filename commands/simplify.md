---
name: /simplify
description: "Safely simplifies a single tracked file in a git repo to its most essential form without losing functional information. One-pass, dry-run guarded, idempotent."
argument-hint: "<file-path> [additional-constraints or focus-areas]"
allowed-tools: "Read, Write, Edit, MultiEdit, LS, Glob, Grep, Bash"
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-27 10:35:53 -->

**Assumptions**

* The input is **one file** path, already tracked in **git** (HEAD exists).
* If any requirement below can’t be proven, **abort without changes**.

---

## Contract (hard)

* **No-loss**: Preserve all *what* and *how*—steps, conditions, dependencies, order.
* **Precision intact**: exact values, units, ranges/tolerances, defaults, formats, commands, paths, API/CLI signatures.
* **Invariants**: edge cases, error handling, interfaces.
* **No token edits in code/config/data**: only comment/prose may change.
* **Removal rule**: Remove content only if it has **no functional constraint** (no GT item) or is a **verbatim duplicate**. Every removal must be justifiable.
* **No rephrasing** of constraint‑bearing text.
* **Idempotent**: running again must propose **zero** edits.

---

## File family (detect by extension + quick content check)

* **doc**: `.md`, `.txt`, `.rst`, `.adoc`
* **code**: common languages (py, js/ts, go, java, c/cpp, csharp, ruby, php, rust, sh, sql, …)
* **config/data**: `.json`, `.yaml`/`.yml`, `.toml`, `.ini`, `.env`, `.properties`, `.csv`, `.tsv`
* **markup**: `.html`, `.xml`
* **unknown**: treat as **doc** but be conservative

*(This matters only to decide what’s allowed to change.)*

---

## What edits are allowed (simple and safe)

**doc**

* Remove **verbatim duplicate paragraphs/lines**.
* Tighten obvious fluff that carries **no constraints** (e.g., redundant adjectives, repeated high‑level statements).
* **Do not** touch fenced code blocks or inline code.

**code**

* **Comments only** (line/block): remove verbatim duplicates; tighten wording that carries no constraints.
* **Do not** change code tokens, indentation, blank‑line structure, or string/number literals.

**config/data**

* Comments only (e.g., `# ...`, `; ...`, `// ...`) or trailing explanatory prose.
* **No** key/value edits, no reformatting, no reordering, no whitespace normalization inside data.

**markup**

* Comments only (`<!-- ... -->`).
* **Do not** reflow text nodes or attributes.

---

## Procedure (one file, one pass)

1. **Preflight**

   * `Read` the working file → `W`.
   * Get the **HEAD** version text by running: `git show HEAD:<path>` using `Bash` tool as the reference `H`. (If HEAD missing → abort.)
   * If `W` is binary/opaque → abort.

2. **Build GT‑mini (very small)**

   * Extract only constraint‑bearing items you must preserve:

     * steps/conditions/dependencies, exact values (with units/ranges/defaults), API/CLI signatures, error/edge cases, invariants.
   * Represent as a short checklist in memory (no files).

3. **Plan (dry‑run)**

   * Propose edits limited to the **allowed** set for the detected family.
   * **Never** touch anything referenced by a GT‑mini item.
   * **Compute candidate text `C`** by applying the plan mentally (dry‑run).
   * **Idempotence check**: Re‑run the plan logic against `C`. If it would propose *any* further change → **abort** (too aggressive).
   * **Benefit check**: If byte reduction `< 1%` **and** no duplicate removal occurred → **abort** (not worth it).

4. **Safety checks (dry‑run over `C`)**

   * **Code/config/data**: compare **non‑comment, non‑whitespace tokens** between `W` and `C`. They must be *byte‑for‑byte identical*.
     *(Heuristic: strip comment spans and all ASCII whitespace; strings/numbers remain.)*
   * **Doc/markup**: ensure all inline code or fenced blocks are byte‑identical.
   * Ensure every GT‑mini item is still **present and unchanged** in meaning (verbatim for values/signatures).

5. **Apply**

   * If (idempotence **pass**) and (benefit **pass**) and (safety **pass**) → `Edit` the file to `C`.
   * Otherwise **abort** without writing.

6. **Post‑write verification**

   * `Read` the file back → `W2`. Assert `W2 == C`.
   * Recompute plan over `W2` → must be **empty** (fixed point). If not empty, **revert** by writing back original `W` and **abort**.

7. **Report (stdout only)**

   * Print a 6‑line summary:

     * family, bytes before/after, % reduction
     * duplicates removed (count)
     * comment/prose lines changed (count)
     * “no token changes” check: **PASS**

---

## Quick heuristics (keep it deterministic)

* **Paragraphs** = blocks separated by ≥1 blank line (doc). When removing duplicates, require **exact** match.
* **Comments** (code/config):

  * Line comments: `#`, `//`, `;` at start after optional whitespace.
  * Block comments: `/* ... */` (no nesting). Don’t cross strings.
* **Non‑comment, non‑whitespace token stream**:

  * Remove comment spans; delete all `\s` chars; compare the resulting strings for `W` vs `C`.
  * If unequal → **abort**.

---

## Hard stops

* Any ambiguity about whether text carries constraints → treat as **constraint‑bearing**; **don’t edit**.
* Any parse uncertainty for comments/blocks → **don’t edit**.
* Any GT‑mini mismatch, token mismatch, or second‑pass changes → **abort**.

---

## Examples of safe wins

* Doc: remove repeated “Overview” paragraph; keep code blocks intact.
* Code: delete duplicated comment lines like `// TODO: cleanup` repeated 3×.
* Config: drop duplicated comment banners, leave keys/values untouched.

---

## Idempotence rule of thumb

If you run `simplify-file` twice in a row, the second run should print “no changes” and exit. If not, your plan wasn’t minimal—tighten it or abort.

---

$ARGUMENTS

**That's it.** One file in, either a safe, measurable reduction, or a clean abort—no background machinery, no artifacts, no churn.
