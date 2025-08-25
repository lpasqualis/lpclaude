---
name: simplify
description: "Analyzes, simplifies, and verifies any input to its most essential form without losing detail."
argument-hint: "[file-path] [project-component] [full-project] [text-content] [special-instructions]"
model: claude-opus-4-1-20250805
allowed-tools: "Read, Write, Edit, MultiEdit, LS, Glob, Grep, Task"
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-24 21:34:36 -->

Simplify the target to its most essential form while preserving all functional information.

**CORE PRINCIPLE**: Preserve detail that enables reliable execution or understanding of the intended function.

**UNIVERSAL SIMPLIFICATION RULES**:
- **Functional detail is sacred** - Steps, conditions, or specifications that affect outcomes must be preserved
- **Only remove TRUE redundancy** - Information that is literally repeated without adding precision or clarity
- **Maintain causal chains** - Keep IF/THEN logic, dependencies, and sequential requirements intact
- **Preserve precision where ambiguity causes failure** - Exact values, explicit conditions, specific tools/methods
- **Format for clarity WITHOUT information loss** - Improve structure and readability while keeping all functional content

Use a rigorous three-phase approach that **actively modifies files and content**: **Analysis**, **Implementation**, and **Verification**.

The target to simplify is: $ARGUMENTS

## Input Detection and Preparation

First, determine the input type and prepare for simplification:

- **File path**: Use Read to load the file content for analysis and modification
- **Project component**: Use Glob/Grep to discover related files that need simplification
- **Full project**: Use LS and Glob to identify all files requiring simplification
- **Text content**: Treat as direct content to simplify and create/update files as needed
- **Directory**: Recursively analyze and simplify all contained files

---

## **Phase 1: Analysis & Deconstruction**

Critically analyze the target without making changes yet. Focus on deep understanding.

1. **Load and Examine Content:**
   - Read all relevant files using Read tool
   - For projects: Use LS and Glob to map the structure
   - Identify file types, dependencies, and relationships

2. **Capture Original State:** Determine and implement backup strategy:
   - **Check git status**: Run `git status --porcelain` to check if working tree is clean
   - **If git clean** (no uncommitted changes): 
     - Use HEAD as reference point - no backups needed
     - Most reliable: Git provides exact state tracking
   - **If git dirty or no git**: Create `.simplify/` folder at project root:
     ```
     .simplify/
       session_YYYYMMDD_HHMMSS/
         manifest.json    # Lists files, paths, session metadata, backup method
         files/          # Mirror of original file structure
           [original files backed up here preserving full paths]
     ```
     - Preserves exact state including uncommitted changes
     - Allows multiple simplification sessions without conflicts
     - Easy rollback: just copy files back
   - **Document method chosen** in manifest for verifiers

3. **Identify Core Concepts:** Extract every fundamental concept, requirement, function, and piece of essential data. Present as a detailed, hierarchical list - this is your "ground truth" for verification.
   - **Functional elements**: Steps that produce outcomes, conditions that control flow, values that affect behavior
   - **Dependencies**: What must happen before/after, what relies on what
   - **Precision requirements**: Where exact values, specific tools, or explicit methods are necessary

4. **Map Simplification Opportunities:** Identify specific locations of:
   - **TRUE redundancy**: Information literally repeated without adding precision or serving a different function
   - **Non-functional verbosity**: Explanations that don't affect execution or understanding
   - **Redundant examples**: Multiple examples demonstrating the same concept (keep the most comprehensive)
   - **Complex abstractions**: Can be simplified ONLY if precision and functionality are preserved
   - **Consolidatable patterns**: Repeated structures that can be unified WITHOUT losing sequential logic
   - **Dead elements**: Unused code, unreferenced sections, obsolete instructions

5. **Create Implementation Plan:** Design the specific file modifications needed:
   - Which files to edit vs. create vs. delete
   - Order of operations to maintain functionality
   - Record backup method decision (git HEAD vs .simplify folder)
   - Note session timestamp if using .simplify backups

---

## **Phase 2: Implementation & Modification**

Execute the simplification plan by **actively modifying files**.

### Simplification Principles:

**Preserve when it serves function:**
- **Sequential steps** where order affects outcome
- **Explicit conditions** that control behavior
- **Precise values** where approximation causes failure
- **Concrete examples** that clarify ambiguous instructions
- **Templates and patterns** that ensure consistency
- **Error handling** and edge case instructions

**Remove when it adds no function:**
- **Redundant explanations** of the same concept
- **Verbose descriptions** that don't clarify execution
- **Duplicate instructions** that literally repeat
- **Commentary** that doesn't affect understanding
- **Excessive examples** beyond what's needed for clarity

### For Files:
1. **If using .simplify backups**: Copy each file to `.simplify/session_[timestamp]/files/[path]` before editing
2. **Edit directly** using Edit/MultiEdit tools to implement simplifications
3. **Consolidate** redundant sections within files
4. **Streamline** complex logic and verbose explanations
5. **Update** any affected imports, references, or dependencies

### For Projects:
1. **Modify all relevant files** systematically using Edit/MultiEdit
2. **Consolidate** similar functionality across files
3. **Remove** unnecessary files and update references
4. **Create** simplified replacement files where beneficial

### For Text Content:
1. **Write** the simplified version to appropriate files
2. **Create** new files if organizing content into a project structure
3. **Update** existing files if improving existing content

**Track all changes made**: List every file modified, created, or deleted with a brief description of the changes.

**Preserve comparison capability**: 
- **If using git HEAD**: Verifiers can use `git diff` and `git show HEAD:file`
- **If using .simplify**: Verifiers read from `.simplify/session_[timestamp]/files/[path]` for originals
- **Update manifest.json**: Record each file modified with timestamp and method used

---

## **Phase 3: Iterative Verification & Validation**

Rigorously verify simplification quality through parallel expert analysis and iterative refinement until optimal simplification is achieved.

### Initial Self-Check
1. **Read back all modified files** to confirm changes were applied correctly
2. **Cross-reference Core Concepts**: For each concept from Phase 1, verify preservation in simplified version

### Parallel Expert Verification
Launch **at least 3 completion-verifier subagents in parallel** to independently assess:

```
Task(subagent_type: 'completion-verifier', prompt: "
CLAIM BEING VERIFIED: The simplification of [target] is complete and optimal.

BACKUP METHOD USED: [git-head | simplify-folder]

HOW TO ACCESS ORIGINAL vs CURRENT:
[If git-head]: 
  - Original: `git show HEAD:[file]`
  - Current: `Read [file]`
  - Changes: `git diff [file]`
[If simplify-folder]:
  - Session: `.simplify/session_[timestamp]/`
  - Original: `Read .simplify/session_[timestamp]/files/[path]`
  - Current: `Read [file]`
  - Manifest: `Read .simplify/session_[timestamp]/manifest.json`

TARGET FILES:
[List all files that were modified with their paths]

IMPLEMENTATION PLAN:
[Insert the simplification plan from Phase 1]

CHANGES SUMMARY:
[Insert list of all modifications from Phase 2]

Your verification focus: [Assign each verifier a specific focus]
- Verifier 1: Functional preservation
  * All steps that affect outcomes preserved
  * All conditions and dependencies maintained
  * Precision requirements met (exact values, specific methods retained)
- Verifier 2: Implementation completeness
  * All planned simplifications executed
  * Only non-functional redundancy removed
  * File modifications correctly applied
- Verifier 3: Optimization potential
  * Identify any remaining TRUE redundancy
  * Flag non-functional verbosity that can be removed
  * Ensure no over-simplification occurred

VERIFICATION CRITERIA:
- All functional elements preserved (steps, conditions, dependencies)
- Execution reliability maintained (can still produce intended outcomes)
- Precision preserved where required
- Only non-functional redundancy removed
- No ambiguity introduced where clarity is critical
- Changes correctly implemented in files

Use the specified method to compare BEFORE and AFTER states.
Verify that changes align with simplification principles.
Provide verdict on completion status and flag any issues or additional opportunities.")
```

### Iteration Logic
Based on parallel verifier feedback:

**IF ANY VERIFIER FINDS:**
- Missing important information → **Return to Phase 2**: 
  - If critical loss: Restore from backup (git reset or copy from .simplify)
  - Re-simplify with adjusted principles
- Incomplete implementations → **Return to Phase 2**: Complete the planned changes  
- Additional simplification opportunities → **Return to Phase 2**: Implement further optimizations

**CONTINUE ITERATING** between Phase 2 and Phase 3 until **ALL VERIFIERS AGREE**:
- ✅ No information loss occurred
- ✅ All simplifications were implemented
- ✅ No further lossless simplifications are possible
- ✅ Result achieves maximum clarity while preserving all essential content

### Final Validation
Only when all verifiers reach consensus, perform final validation:

- **Functional integrity**: Content can still achieve its intended purpose reliably
- **Precision preservation**: No loss of detail where exactness matters
- **Clarity improvement**: Better structure and formatting without information loss
- **True optimization**: Only non-functional redundancy removed
- **No over-simplification**: Maintains all elements that affect outcomes
- **Maximum effectiveness**: Achieves clarity while preserving all functional requirements

### Cleanup
After verification completes successfully:
- **If using git HEAD**: No cleanup needed (git tracks changes)
- **If using .simplify folder**: 
  - Keep session folder for rollback capability
  - Optionally add `.simplify/` to `.gitignore` if not already present
  - Document in manifest which files were successfully simplified
- **Final report**: List all files simplified with size/complexity reduction metrics

Present a complete summary of all iterations, files modified, verifier consensus, and final verification results.
