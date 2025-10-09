---
name: /commands:optimize
description: Optimize slash command definitions for best practices and performance
argument-hint: <command-name> [--aggressive]
allowed-tools: Read, Edit, MultiEdit, Write, LS, Glob, Grep, Bash, WebFetch, Task
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-27 -->

Audit and optimize the slash command `/[command-name]` to align with the latest best practices. Operate idempotently - if the command already adheres to all best practices, report that it's fully optimized and take no action.

$ARGUMENTS

## Optimization Process

### 0. Core Purpose Understanding
Before making ANY changes, identify the command's essential functionality:
- What problem does this command solve?
- If it fetches dynamic content (WebFetch), this is intentional to stay current
- If it uses specific URLs, these are features, not configuration to abstract
- NEVER optimize away the command's reason for existing

### 1. Locate and Create Working Copy
Parse the command name to determine the expected file path:
- `/command` → `command.md`
- `/namespace:command` → `namespace/command.md`

Search for the file using Glob in this order:
- First check `.claude/commands/[path]` (project-local)
- Then check `~/.claude/commands/[path]` (global)

If found:
1. Read the original file and save its content
2. Create a temporary working copy: `[original-path].optimizing`
3. Calculate size metrics using `wc -l` and `wc -c`
4. Perform ALL optimizations on the `.optimizing` copy only

### 2. YAML Frontmatter Audit

#### Required Fields
- **name**: Must start with `/`, use lowercase-kebab-case, match file location
- **description**: Clear, brief summary of function
- **allowed-tools**: Complete logical groupings (avoid incomplete sets like `Write` without `Edit, MultiEdit`)
- **argument-hint**: Clear hints for expected arguments (use `[]` for optional, `<>` for required)

#### Optional Fields
- **model**: Full model alias identifiers (e.g., `claude-opus-4-1`)
  - If omitted the model will be inherited from the session model
- **disable-model-invocation**: Set to `true` to exclude from SlashCommand tool
  - Consider for test commands, maintenance commands, or commands with very long descriptions
  - Saves context tokens by preventing command metadata from being loaded

#### Model Selection (if specified)
- Fetch current models from https://docs.anthropic.com/en/docs/about-claude/models/overview
- Commands need full model alias identifiers
- If omitted the model will be inherited from the session model which, in many cases, might be the right choice.

### 3. Prompt Body Optimization

#### Critical Preservation Rules
NEVER remove or replace:
- WebFetch operations that load dynamic content
- WebSearch operations for current information
- External API calls or integrations
- Dynamic data loading mechanisms
- Adaptive logic that discovers project structure
- Project-agnostic patterns

#### Safe Optimizations
Only make changes that meet ONE of these criteria:
1. **Critical Issues**: Missing required YAML fields, incomplete tool groupings
2. **Functional Improvements**: Adding parallelization ONLY when truly beneficial
3. **Security/Performance**: Addressing vulnerabilities or significant performance issues
4. **Structural Problems**: Major organizational issues
5. **Measurable Simplification**: >1% byte reduction through safe simplification
6. **Size Violations**: Commands exceeding 300 lines need decomposition recommendations

#### Simplification Techniques
- Convert verbose prose to structured formats (bullets, tables, headers)
- Remove only VERBATIM duplicates (exact character matches)
- Consolidate similar examples into comprehensive ones
- Transform educational content rather than removing it
- Preserve all constraint-bearing text

### 4. Size Analysis
**Thresholds**:
- **Optimal**: <100 lines
- **Acceptable**: 100-200 lines
- **Review Needed**: 200-300 lines
- **Too Large**: >300 lines (SUGGEST decomposition, don't implement)

For oversized commands, RECOMMEND (don't create) splitting into focused commands.

### 5. Parallelization Analysis

**CRITICAL**: Most commands don't need parallelization. Actively REMOVE unnecessary parallelization.

Check for existing parallelization to remove:
- Task tool usage in the command
- References to parallel processing or worker subagents
- Associated worker templates in `workers/` directory

Parallelization is ONLY appropriate when ALL criteria are met:
- Processing 10+ independent items
- True independence between items
- Read-only operations
- Would save >30 seconds vs sequential
- Clear aggregation pattern

### 6. Anti-Pattern Detection
Fix these issues if found:
- Incomplete tool groupings
- Monolithic commands doing unrelated things
- Invalid slash command execution patterns (convert to SlashCommand tool usage)
- Absolute paths with usernames (breaks portability)

Consider adding `disable-model-invocation: true` when:
- Command name contains "test" and is for manual testing only
- Command is in maintenance/ namespace and rarely automated
- Description exceeds 150 characters (consumes excessive context)
- Command is project-specific and unlikely to be called programmatically

### 7. Verification Phase

If only minor changes were made, no need to verify. Skip directly to step 8.

If and only if significant changes were made, after optimizing the working copy, run THREE identical parallel verification tasks to ensure no functionality was lost. The verifiers will compare the original with the optimized copy.

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
FILE_PATH="[full path to the command file being optimized]"

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
   - All WebFetch/WebSearch operations preserved
   - Dynamic discovery logic intact
   - Tool permissions complete (no missing tools)
   - Conditional logic preserved
   - Error handling maintained
   - User inputs ($ARGUMENTS) preserved
   - External integrations intact
   - Parallelization logic preserved (if it was there originally)

3. Semantic Integrity:
   - Behavioral constraints intact (must/should/never/always)
   - Order dependencies preserved
   - Numeric values unchanged (timeouts, limits, thresholds)
   - Security requirements maintained
   - Edge cases still handled
   - Model selection rationale preserved
   - Scope boundaries unchanged

4. Structural Validity:
   - YAML syntax valid
   - Required fields present
   - Name matches file location
   - Tools properly grouped
   - No invalid command execution patterns
   - Proper Task tool usage
   - No hardcoded project-specific assumptions
   - Valid placeholder usage

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

### 8. Finalization

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
- If task templates were created for parallelization, finalize them

## Report Format

```markdown
## Command [Optimization Complete ✅ | Review Complete ✅]

**Command**: /[command-name]  
**Status**: [Changes applied | Already compliant]
**Timestamp**: YYYY-MM-DD HH:MM:SS

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
- **Line count**: [X] lines
- **Byte size**: [Y] bytes
- **Assessment**: [Status based on thresholds]

### Size Recommendations (if needed):
[Specific optimization suggestions or decomposition recommendations]

### Changes Applied (if any):
[List specific changes made]

### Compliance Status:
- ✅ Best practices compliance
- ✅ Complete tool permission groupings
- ✅ Size within limits or decomposition recommended
- ✅ Optimization timestamp added
- ✅ All verifiers passed
```

## Additional Flags
- **--aggressive**: Apply more aggressive optimizations, including removing most examples and verbose explanations (use with caution)