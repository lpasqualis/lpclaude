---
name: /implan:execute
description: Resume work on an existing implementation plan with flexible execution control
argument-hint: "[plan name] [execution directive] (e.g., 'auth-system for 30 minutes', 'until tests pass', 'phase 2 only')"
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, Bash, Task
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-20 -->

Load and continue work on an implementation plan from the project's `docs/implans/` directory with natural language control over execution scope.

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

#### Default Execution
Without directive or with "until complete":
- Continue working through all phases sequentially
- Complete entire implementation plan
- Run full test suite and quality checks

### 4. Update the Plan as You Work
- Mark completed items with `[x]`
- Update the "Current Status" section with today's date
- Add session notes to the "Session History"
- Document any new learnings or decisions
- Update progress percentages
- Keep the "Next Steps" section current

### 5. Execution Monitoring and Stopping

During execution, continuously monitor for stopping conditions:
- **Time checks**: After each task completion if time-based
- **Milestone checks**: After each significant step
- **Error monitoring**: Stop gracefully on unrecoverable errors
- **User interruption**: Allow user to modify directive mid-execution

When stopping condition is met:
1. Complete current atomic task (don't leave work half-done)
2. Run any necessary cleanup or tests
3. Update implementation plan with detailed session notes
4. Provide clear summary of what was accomplished
5. Document any blockers or issues for next session

### 6. Quality Assurance Integration
- For significant progress or plan completion, use Task tool with `implan-auditor` subagent
- The auditor will verify implementation completeness and identify any stubs or gaps
- Apply audit recommendations before marking the session complete
- Ensure all tests pass before marking implementation items as complete

## Quality Standards

- **Items can only be marked done if fully implemented AND tested**
- Warnings and errors must be resolved - they are not acceptable
- Run all specified tests before marking items complete
- This is a living document - keep it updated throughout your work
- Use `date` command to get the current date for updates
- **Honor execution directives** - Stop when conditions are met

## Before Finishing (Any Stopping Condition)
- Ensure all completed work is reflected in the plan
- Update the overall progress percentage
- Add clear notes for the next session including:
  - What was accomplished this session
  - Why execution stopped (time limit, milestone reached, blocker, etc.)
  - Immediate next steps for resumption
- Save all changes to the implementation plan
- Provide execution summary to user

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

## Implementation Focus

This command supports flexible execution modes while maintaining:
- Full context awareness of the codebase and plan details
- Proper sequential execution of interdependent tasks
- Careful validation and testing at each step
- Accurate progress tracking and documentation updates
- Respect for user-specified execution boundaries

**Note**: Implementation plans require focused, contextual work and cannot be effectively parallelized.

**Start by parsing the execution directive, loading the implementation plan, and showing a summary of the current status and planned execution scope.**