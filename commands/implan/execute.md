---
description: Resume work on an existing implementation plan
argument-hint: "[implementation plan name] (optional - will find active plan if not specified)"
allowed-tools: Read, Edit, Write, LS, Glob, Grep, Bash, Task
---

Load and continue work on an implementation plan from the project's `docs/implans/` directory.

## Workflow

### 1. Find the Implementation Plan
- If an implementation name is provided in `$ARGUMENTS`, look for a file matching that name
- If no argument provided:
  - Look for all `ACTIVE_*_implan.md` files in `docs/implans/`
  - If only one active plan exists, use it
  - If multiple active plans exist, offer parallel processing option:
    - List all active plans for user selection
    - If user wants to work on multiple plans, use parallel execution strategy
  - If no active plans exist, inform the user and suggest using `/create-implan`

### 2. Read and Analyze the Plan
Read the entire implementation plan document and pay special attention to:
- **🤖 Agent Instructions** section for guidance
- **📊 Current Status** section to understand progress
- **🎯 Next Steps** section for immediate tasks
- Unchecked `[ ]` items in the implementation phases

### 3. Continue the Implementation
- Start with the immediate TODOs listed in "Notes for Next Session"
- Work on unchecked tasks in the current active phase
- Follow the validation criteria specified for each task
- Run tests as specified in the plan before marking items complete

### 4. Update the Plan as You Work
- Mark completed items with `[x]`
- Update the "Current Status" section with today's date
- Add session notes to the "Session History"
- Document any new learnings or decisions
- Update progress percentages
- Keep the "Next Steps" section current

### 5. Quality Assurance Integration
- For significant progress or plan completion, use Task tool with `implan-auditor` subagent
- Auditor will verify implementation completeness and identify any stubs or gaps
- Apply audit recommendations before marking the session complete

## Quality Standards

- **Items can only be marked done if fully implemented AND tested**
- Warnings and errors must be resolved - they are not acceptable
- Run all specified tests before marking items complete
- This is a living document - keep it updated throughout your work
- Use `date` command to get the current date for updates

## Before Finishing
- Ensure all completed work is reflected in the plan
- Update the overall progress percentage
- Add clear notes for the next session
- Save all changes to the implementation plan

## Parallel Execution Strategy

When working with multiple implementation plans:

### Multiple Plan Processing
1. **Identify Plans**: List all active plans for user selection
2. **Batch Processing**: If user selects multiple plans (3+), use parallel execution:
   - Use Task tool with subagent_type: 'implan-auditor' for plan analysis
   - Process up to 10 plans in parallel
   - Batch remaining plans if exceeding system limit
3. **Aggregated Results**: 
   - Consolidate status from all plans
   - Identify cross-plan dependencies
   - Provide unified next steps recommendation

### Integration Strategy
- **Single Plan**: Direct implementation with integrated quality checks
- **Multiple Plans**: Parallel analysis with coordinated execution
- **Quality Gates**: Use implan-auditor proactively for verification

**Start by loading the implementation plan and showing a summary of the current status and what needs to be done next.**