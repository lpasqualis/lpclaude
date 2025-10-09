---
name: /implan:execute
description: Resume work on an existing implementation plan with flexible execution control
argument-hint: "[plan name] [execution directive] (e.g., 'auth-system for 30 minutes', 'until tests pass', 'phase 2 only')"
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, Bash, Task
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-10-09 08:24:54 -->

Load and continue work on an implementation plan from the project's `docs/implans/` directory with natural language control over execution scope.

## Core Principles

### NO TIME PRESSURE - NEVER SHORTCUT

**You have unlimited time unless explicitly told otherwise.** When executing without a time-based directive, there are ZERO time constraints. Take as long as needed to do the work properly. Do not rush, do not shortcut, do not skip steps, do not make assumptions to save time.

**Quality is never compromised.** All work must meet full quality standards regardless of execution directive. Stopping directives (time limits, milestones, scope constraints) indicate when to pause work after completing the current task properly, not when to compromise quality or leave work half-done.

**Mandatory standards:**
- Complete each task fully before stopping
- All implementations must be tested and verified
- Resolve all warnings and errors - not acceptable to leave them
- Never leave placeholder code, stubs, or TODOs
- Never make assumptions or skip validation to save time
- If approaching a stopping condition, finish the current atomic task with full quality first

## Execution Control

The command supports natural language directives to control execution scope. Examples:
- **Time-based**: `"for 30 minutes"`, `"for 1 hour"`, `"for 2 hours"`
- **Milestone-based**: `"until tests pass"`, `"until phase 2 complete"`, `"until user input needed"`
- **Scope-based**: `"phase 1 only"`, `"current phase"`, `"next 3 tasks"`, `"one task"`
- **Conditional**: `"until blocked"`, `"until errors"`, `"until review needed"`
- **Default**: No directive or `"until complete"` - work until the entire plan is done

### Parsing Execution Directives
The command intelligently parses `$ARGUMENTS` to extract:
1. **Plan identifier** (optional): The name or partial match for the implementation plan
2. **Execution directive** (optional): Natural language describing when to stop

Examples of full arguments:
- `auth-system for 30 minutes` - Work on auth-system plan for 30 minutes
- `until tests pass` - Work on active plan until all tests are passing
- `phase 2 only` - Complete only phase 2 of the active plan
- `payment-integration until blocked` - Work on payment plan until hitting a blocker
- (empty) - Work on active plan until completion

## Workflow

### 0. Pre-Execution Checklist

**Before starting implementation work, verify:**

1. **Git State**
   - Check git status for uncommitted changes
   - Note any dirty working directory state in session notes
   - If user wants branch isolation, they will tell you (don't assume)

2. **Environment**
   - Verify project builds/runs (if applicable)
   - Check for obvious missing dependencies
   - Confirm you can access necessary tools (test runners, build systems, etc.)

3. **Plan State**
   - Confirm the implan file exists and is readable
   - Check for conflicting file modifications (if plan was recently edited externally)

### 1. Parse Arguments and Find the Plan
- Parse `$ARGUMENTS` to identify plan name and execution directive
- Find the implementation plan:
  - If a plan name is provided, look for matching files
  - If no name provided, find all `ACTIVE_*_implan.md` files in `docs/implans/`
  - Handle single/multiple/no active plans appropriately

### 2. Read and Analyze the Plan
Read the entire implementation plan document and pay special attention to:
- **🤖 Agent Instructions** section for guidance
- **📊 Current Status** section to understand progress
- **🎯 Next Steps** section for immediate tasks
- Unchecked `[ ]` items in the implementation phases
- **Execution directive context** to understand stopping conditions

### 3. Execute Based on Directive

#### Default Execution (No Directive Specified)

**CRITICAL: When no stopping directive is provided, you have UNLIMITED TIME.**

There are NO time constraints. ZERO. Take days if necessary. The user expects:
- Complete implementation of the ENTIRE plan without stopping
- ALL phases completed, including optional ones
- NEVER ask questions to the user mid-execution
- NEVER shortcut anything to save time
- NEVER make assumptions to go faster
- Full test suite run and passing
- Production-quality code with no compromises

Do not treat this like a timed task. Treat it like delivering a finished product with unlimited time budget. 

#### Time-Based Execution
If directive includes time limit (e.g., "for 30 minutes"):
- Track start time and periodically check elapsed time
- Complete current task before stopping if near time limit
- Update plan with session notes before stopping

#### Milestone-Based Execution
If directive specifies a milestone:
- **"until tests pass"**: Continue until all tests in current scope pass
- **"until phase X complete"**: Work until specified phase is fully done
- **"until user input needed"**: Stop when encountering decisions requiring user input

#### Scope-Based Execution
If directive limits scope:
- **"phase X only"**: Complete all tasks in specified phase
- **"current phase"**: Complete the currently active phase
- **"next N tasks"**: Complete exactly N unchecked tasks
- **"one task"**: Complete single task with full testing

#### Conditional Execution
If directive includes conditions:
- **"until blocked"**: Stop when encountering dependency issues or missing requirements
- **"until errors"**: Stop if encountering compilation/test errors that can't be resolved
- **"until review needed"**: Stop when reaching a point requiring code review

### 4. Update the Plan as You Work
- Mark completed items with `[x]`
- Add/update any items/phases/tasks as you discover the need for it during the execution. The plan is DYNAMIC, not static
- Update the "Current Status" section with today's date (fetch it using `date` bash command)
- Add session notes to the "Session History"
- Document any new learnings or decisions
- Update progress percentages
- Keep the "Next Steps" section current
- Update this regularly after each task is complete, do not let the file go stale. If the execution is interrupted, this file is the source of truth on the status.

### 5. Stopping Conditions & Error Handling

**Monitor for these stopping conditions during execution:**
- **Plan completed**: All phases and tasks are fully implemented and tested
- **Time limit reached**: If time-based directive, check after each task completion
- **Milestone achieved**: If milestone-based directive, check after significant steps
- **Blocker encountered**: See error handling below
- **User interruption**: User may modify directive mid-execution

**Error Handling:**

*Recoverable Errors* (continue working after resolution):
- Missing dependencies (install them)
- Test failures (fix the code)
- Linting/formatting issues (resolve them)
- Compilation errors (debug and fix)

*Unrecoverable Errors* (stop and document):
- Corrupted project files that can't be restored
- Missing critical files that define project structure
- Fundamental architecture conflicts requiring user decisions
- External service dependencies that are down

When encountering errors: attempt resolution first, only stop if truly unrecoverable.

### 6. Quality Standards & Testing Requirements

**Every task must meet these standards before being marked complete:**

- Fully implemented with no placeholder code, TODOs, or stubs
- All relevant tests written and passing
- All warnings and errors resolved
- Code reviewed for completeness and correctness
- Documentation updated as needed

**Plan Maintenance:**
- Keep the implementation plan updated throughout your work (it's a living document)
- Use `date` command to get current date for status updates
- Mark items `[x]` only when fully complete and tested
- Add/update phases and tasks as you discover needs during execution

### 7. Stopping Protocol

**When any stopping condition is met:**

1. **Complete current task** - Finish the atomic task you're working on with full quality (don't leave work half-done)
2. **Run cleanup/tests** - Execute any necessary cleanup or validation
3. **Update the plan** - Ensure all completed work is reflected, update progress percentage
4. **Document session** - Add clear session notes including:
   - What was accomplished
   - Why execution stopped (time limit, milestone reached, blocker, etc.)
   - Immediate next steps for resumption
5. **Provide summary** - Give user the execution summary (see format below)

### 8. Plan Completion

**When the entire implementation plan is complete:**

1. **Rename the plan file**: `ACTIVE_filename.md` or `filename.md` → `COMPLETE_filename.md`
2. **Cleanup**: Remove any temporary files or scripts created during implementation
3. **Organize**: Ensure codebase is clean and well-organized
4. **Update documentation**: Update project documentation (README.md, CLAUDE.md) to reflect the completed work
5. **Final verification**: Confirm all tests pass and the project is in excellent state

## Execution Summary Format

When execution completes (for any reason), provide a summary:
```
📊 Execution Summary
━━━━━━━━━━━━━━━━━━━
Plan: [Plan Name]
Directive: [Execution directive used]
Duration: [Time spent]
Tasks Completed: [X of Y]
Current Phase: [Phase name and progress]
Stopping Reason: [Why execution stopped]
Next Steps: [What to do next]
```


$ARGUMENTS

---

## REMINDER BEFORE YOU BEGIN

**If no time-based directive was specified above:**
- You have UNLIMITED TIME
- Do NOT rush or shortcut anything
- Take as long as needed for quality work
- There is NO deadline

**Start by parsing the execution directive, loading the implementation plan, and showing a summary of the current status and planned execution scope.**