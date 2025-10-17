---
name: /implan:create
description: Create comprehensive implementation plans from conversation context
argument-hint: [plan-name] [additional-focus-areas-or-specific-requirements]
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, Bash
---

# Create Implementation Plan

Generate a comprehensive, trackable implementation plan from the current conversation context. Plans are saved in `docs/implans/` and serve as living documents for project execution.

**CRITICAL**: This command creates an implementation PLAN, not an actual implementation. Use ultrathink mode to deeply analyze the problem space and create strategic guidance. NEVER write actual implementation code in the plan document.

## Process

1. **Ultrathink Mode**: Engage deep thinking to analyze the problem space, consider alternatives, and identify risks
2. **Analyze Conversation**: Extract project requirements, technical approaches, constraints, and success criteria from the current conversation
3. **Generate Plan**: Create structured implementation plan using standardized template - this is STRATEGIC GUIDANCE, not code
4. **Save Plan**: Store in `docs/implans/` with proper naming convention
5. **Report**: Provide file path and brief summary of generated plan

## Plan Structure

Each generated plan must include:
- **Status tracking** with progress indicators and validation requirements
- **Agent handoff instructions** for seamless work resumption
- **Phase-based structure** with clear objectives, tasks, and validation criteria
- **Session history** section for continuous documentation
- **Risk assessment** with mitigation strategies
- **Resource tracking** for dependencies and references
- **Agent update reminders** (see template below) - critical for preventing status drift

## File Organization

### Naming Conventions
- **Active plans**: `docs/implans/ACTIVE_<descriptive-name>_implan.md`
- **Completed plans**: `docs/implans/completed_<YYYY-MM-DD>-<name>_implan.md`
- **Auto-naming**: Extract descriptive name from conversation context or use `$ARGUMENTS`

## Quality Standards

**Testing Requirements**: The plan must be clear that items cannot be marked complete until:
- Fully implemented and tested with passing results
- Unit/integration tests written and executed (if project has testing infrastructure)
- No warnings or errors present
- Validation criteria verified

**Documentation Requirements**: Plans serve as living documents requiring:
- Real-time progress updates with current status
- Session history after each work period
- Decision documentation with rationale
- Risk tracking with mitigation progress

## Agent Update Reminder Template

**CRITICAL**: Every generated implementation plan MUST include this section near the top (after the executive summary, before the implementation phases). This section keeps agents focused on status updates during execution:

```markdown
## 🤖 Agent Update Reminders

**AFTER EVERY TASK COMPLETION:**
- [ ] Mark the completed task with `[x]` in this implan file
- [ ] Update "Current Status" section with current date (use `date` command)
- [ ] Add brief note to "Session History" about what was completed
- [ ] Verify your updates by reading back the implan file

**AFTER EVERY PHASE COMPLETION:**
- [ ] Stop implementation work before starting next phase
- [ ] Run `/implan:update [plan-name]` to verify the completed phase
- [ ] Review verification results carefully
- [ ] Fix any discrepancies found (stubs, TODOs, failing tests)
- [ ] Re-verify if fixes were needed
- [ ] Only after clean verification, proceed to next phase

**BEFORE CLAIMING PLAN COMPLETE:**
- [ ] DO NOT rename file to COMPLETE_ yet
- [ ] DO NOT tell user it's complete yet
- [ ] Run `/implan:update [plan-name]` for comprehensive verification
- [ ] Review full verification report
- [ ] Fix ALL issues discovered
- [ ] Ensure all tests pass with zero failures
- [ ] Ensure no TODOs, stubs, or placeholder code remains
- [ ] Only after clean verification, rename to COMPLETE_ and report to user

**WHY THESE UPDATES MATTER:**
Without regular updates, the plan becomes stale. If execution stops unexpectedly (context limits, errors, interruption), an outdated plan makes it impossible to resume work effectively. Update after each task, verify at phase boundaries, and comprehensively verify before claiming completion.
```

## IMPORTANT Plan Creation Guidelines

1. **Engage Ultrathink Mode**: Use deep thinking to thoroughly analyze the problem space before planning
2. **Directory Setup**: Ensure `docs/implans/` directory exists (create if needed)
3. **Context Extraction**: Analyze conversation for requirements, technical approaches, constraints, and success criteria
4. **Plan Generation**: Create comprehensive plan with:
   - Clear, actionable objectives and tasks (DESCRIBE what needs to be done, don't write the code)
   - Specific validation criteria with test requirements
   - Realistic complexity assessments
   - Comprehensive risk analysis
   - Well-defined dependencies and prerequisites
   - Proper phase structure
   - **Agent Update Reminders section** (use the template above) - place it near the top
   - **NO IMPLEMENTATION CODE** - plans describe the strategy, not the implementation
5. **File Creation**: Save with proper naming convention and confirm creation
6. **Summary**: Report file path and brief overview of generated plan

$ARGUMENTS

## What Plans Should NOT Contain

- **Implementation code**: No actual code snippets, functions, or classes
- **Pre-written solutions**: Plans guide future work, they don't do the work
- **Copy-paste ready content**: Describe what to build, don't build it
- **Detailed algorithms**: High-level approach only, not step-by-step code logic
- **Time estimates**: NO dates, deadlines, hours, days, or duration estimates of any kind
- **Completion schedules**: NO timelines, target dates, or "when" predictions
- **Velocity assumptions**: AI execution timing is unpredictable and unmeasurable

**ALLOWED assessments**: Complexity (low/medium/high), Risk level (low/medium/high/critical), Dependencies

Plans are STRATEGIC DOCUMENTS that guide implementation work. They should be immediately usable by any agent to resume work effectively.
