---
name: /subagents:optimize
description: Optimize subagent definitions for reliable automatic invocation and peak performance
argument-hint: <agent-name> [--aggressive]
allowed-tools: Read, Edit, LS, Glob, Grep, Bash, WebFetch, Task
disable-model-invocation: true
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-27 -->

Audit and optimize the subagent `[agent-name]` to maximize its effectiveness for automatic invocation. Operate idempotently - if the agent already adheres to best practices, report that it's fully optimized and take no action.

$ARGUMENTS

## Optimization Process

### 0. Core Purpose Understanding
Before making ANY changes, identify what problem this agent solves:
- Preserve core functionality - don't optimize away the agent's purpose
- Dynamic content fetching and specific tool usage are often intentional
- If it uses WebFetch/WebSearch, these are features, not bugs

### 1. Locate and Create Working Copy
Search for the agent file using Glob in this order:
- First check `.claude/agents/[name].md` (project-local)
- Then check `~/.claude/agents/[name].md` (global)

If found:
1. Read the original file and save its content
2. Create a temporary working copy: `[original-path].optimizing`
3. Calculate size metrics using `wc -l` and `wc -c`
4. Perform ALL optimizations on the `.optimizing` copy only

### 2. YAML Frontmatter Audit

#### Required Fields
- **name**: Required, lowercase-hyphenated format
- **description**: CRITICAL for automatic invocation (see section 3)

#### Optional Fields
- **tools**: Comma-separated string format (CANNOT include Task)
- **model**: Simple names only (opus/sonnet/haiku) - never versioned
- **color**: Semantic assignment (Red if Bash in tools, otherwise by function)

### 3. Description Optimization (CRITICAL)

#### Requirements for Automatic Invocation
- **Length**: 3-4 sentences minimum with trigger keywords
- **Function**: Clear statement of what the agent does
- **Triggers**: Include "Use when..." phrases and action verbs
- **Proactive Flag**: Include "MUST BE USED PROACTIVELY" for agents that should auto-invoke

#### Template (if current description is inadequate)
"[Expert/Specialist] [domain] [purpose]. Invoke this agent to [capabilities]. Use when [trigger conditions] or when [problem indicators]. [MUST BE USED PROACTIVELY if applicable]."

### 4. Tool Permission Audit

Apply permissive tool selection based on agent type:
- **Code analysis**: `Read, LS, Glob, Grep`
- **File modification**: `Read, Edit, Write, MultiEdit, LS, Glob`
- **Repository exploration**: `Read, LS, Glob, Grep, Bash`
- **Documentation**: `Read, Write, LS, Glob, Grep`
- **Web research**: `WebFetch, WebSearch` (plus reading tools)
- **Complex workflows**: `Read, Write, Edit, MultiEdit, LS, Glob, Grep`

**CRITICAL**: Subagents CANNOT have Task tool (no recursive delegation)

### 5. Model Selection Optimization

Use simple model names only:
- **haiku**: Simple, repetitive tasks (formatting, basic validation)
- **sonnet**: Standard development (code review, documentation)
- **opus**: Complex reasoning (architectural analysis, semantic analysis)

Missing model field inherits from session (acceptable).

### 6. Semantic Color Assignment

If `Bash` in tools → must be `Red` (overrides all else)
Otherwise assign semantically based on primary function.

### 7. System Prompt Optimization

Subagent prompts are SYSTEM IDENTITY DEFINITIONS:
- Start with "You are a..." role definition
- Define HOW the agent behaves, not what task to do
- Write as behavioral guidelines, not task instructions

### 8. Size Analysis

**Thresholds**:
- **Optimal**: <100 lines
- **Acceptable**: 100-200 lines
- **Review Needed**: 200-300 lines
- **Too Large**: >300 lines (needs simplification)

**Simplification Principles**:
- Transform verbose content rather than deleting
- Preserve all constraint-bearing text
- Use structure (bullets, headers) over prose
- Only simplify if >1% byte reduction OR structural improvement

### 9. Anti-Pattern Detection

**Subagent Limitations** (fix if found):
- CANNOT parallelize (No Task tool)
- CAN execute slash commands (has access to SlashCommand tool)
- CANNOT invoke other agents (no delegation via Task tool)
- Must be self-contained for agent invocation

**Invalid Patterns to Fix**:
- Direct Task tool usage → Remove (subagents cannot use Task tool)
- Agent invocation attempts → Remove and restructure
- Absolute paths with usernames → Make portable

### 10. Verification Phase (Critical)

After optimizing the working copy, run THREE identical parallel verification tasks to ensure no functionality was lost. The verifiers will compare the original with the optimized copy.

#### Verification Process

1. **Provide both file paths** to verifiers:
   - Original: `[path]/[name].md`
   - Optimized: `[path]/[name].md.optimizing`
2. **Execute THREE identical verification tasks in parallel**
3. **Analyze the three reports for consensus**
4. **If no consensus**, adjust the optimized copy based on feedback
5. **Re-run verification and iterate** until all three agree
6. **Maximum 5 iterations** - if no consensus, delete the copy and report failure

#### Parallel Verification Execution

```markdown
# Set the file path for all verifiers
FILE_PATH="[full path to the agent file being optimized]"

# Run THREE identical verifiers in parallel using Task tool
# Each verifier gets the EXACT SAME prompt:

prompt = """
You are an independent verification specialist. Compare the optimized copy with the original to ensure the optimization is safe and complete.

Files to compare:
- Original: $ORIGINAL_PATH
- Optimized: $OPTIMIZED_PATH

COMPREHENSIVE ANALYSIS CHECKLIST:

1. Read both versions:
   - Original: Read($ORIGINAL_PATH)
   - Optimized: Read($OPTIMIZED_PATH)

2. Functional Completeness:
   - Core agent purpose preserved
   - Tool capabilities complete (no missing tools)
   - WebFetch/WebSearch operations preserved
   - Auto-invocation triggers intact
   - Model selection rationale preserved
   - Behavioral patterns maintained
   - Scope definitions preserved
   - All "MUST BE USED PROACTIVELY" flags preserved

3. Semantic Integrity:
   - Behavioral constraints intact (must/should/never/always)
   - Identity definition preserved ("You are..." statements)
   - Operational guidelines maintained
   - Trigger conditions for auto-invocation unchanged
   - Model requirements preserved
   - Tool usage patterns intact
   - Scope boundaries unchanged

4. Structural Validity:
   - YAML syntax valid
   - Required fields present (name, description)
   - Name in lowercase-hyphenated format
   - Description has trigger keywords for auto-invocation
   - Tools properly formatted (NO Task tool allowed)
   - Model using simple names only (opus/sonnet/haiku)
   - Color semantically appropriate
   - No invalid patterns (command execution, agent invocation)
   - Proper system prompt structure

REPORT FORMAT:
## Verification Report

**Overall Status**: [PASS | FAIL | UNCERTAIN]

**Critical Issues Found** (if any):
- [List each issue that would break functionality]

**Minor Issues Found** (if any):
- [List formatting or style issues that don't affect function]

**Risk Level**: [NONE | LOW | MEDIUM | HIGH]

**Recommendation**:
[APPROVE - All critical functionality preserved]
[REJECT - Specific functionality lost: ...]
[UNCERTAIN - Need clarification on: ...]
"""

# Execute all three verifiers with this identical prompt in parallel
```

#### Consensus Analysis and Iteration

After receiving three reports, analyze for consensus:

1. **Full Consensus (All PASS)**: Proceed to finalization
2. **Majority PASS (2 PASS, 1 FAIL/UNCERTAIN)**: 
   - Review the dissenting report's concerns
   - Make targeted adjustments to address specific issues
   - Re-run all three verifiers
3. **No Consensus or Majority FAIL**:
   - Identify common concerns across reports
   - Rollback problematic changes
   - Apply more conservative optimization
   - Re-run verification
4. **After 5 iterations without consensus**:
   - Revert ALL changes
   - Report that optimization cannot be safely applied

#### Iteration Loop

```markdown
iteration = 1
consensus = false

while iteration <= 5 and not consensus:
    # Run 3 parallel verifications
    results = [verifier1, verifier2, verifier3]
    
    # Check consensus
    if all results == PASS:
        consensus = true
    else:
        # Analyze disagreements
        issues = extract_common_issues(results)
        
        # Adjust optimization
        if critical_issues:
            rollback_specific_changes(issues)
        else:
            refine_optimization(issues)
        
        iteration += 1

if not consensus:
    delete_optimized_copy()
    report_optimization_failed()
else:
    replace_original_with_optimized()
    report_success()
```

### 11. Finalization

#### Success Path (All verifiers PASS):
1. Replace original with optimized copy:
   - Use Bash: `mv [path]/[name].md.optimizing [path]/[name].md`
2. Confirm replacement succeeded
3. Report successful optimization with all changes

#### Failure Path (No consensus after 5 iterations):
1. Delete the optimized copy:
   - Use Bash: `rm [path]/[name].md.optimizing`
2. Leave original file untouched
3. Report optimization failed with reasons

#### Cleanup:
- Ensure no `.optimizing` files remain after completion

## Report Format

```markdown
## Agent [Optimization/Review] Complete ✅

**Agent**: [name]  
**Status**: [Changes applied | Already compliant]
**Timestamp**: [date/time]

### Verification Results:
- **Verifier 1**: [PASS/FAIL/UNCERTAIN]
- **Verifier 2**: [PASS/FAIL/UNCERTAIN]
- **Verifier 3**: [PASS/FAIL/UNCERTAIN]
- **Consensus**: [ACHIEVED/FAILED]
- **Iterations used**: [X of 5 maximum]

### Final Disposition:
- **Original file**: [Replaced with optimized version | Preserved unchanged]
- **Working copy**: [Promoted to original | Deleted]

### Size Analysis:
- Line count: [X] lines
- Byte size: [Y] bytes  
- Assessment: [Status based on thresholds]

### Changes Applied (if any):
[List specific changes made]

### Compliance Status:
- ✅ Description optimized for auto-invocation
- ✅ Tools verified (no Task tool)
- ✅ Model appropriate
- ✅ Color semantically assigned
- ✅ Size within limits
- ✅ Timestamp updated
- ✅ All verifiers passed
```

## Additional Flags
- **--aggressive**: Apply more aggressive optimizations, including verbose content reduction (use with caution)