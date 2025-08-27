---
name: /implan:create
description: Create comprehensive implementation plans from conversation context
argument-hint: [plan-name] [additional-focus-areas-or-specific-requirements]
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, Bash
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-26 20:53:23 -->

# Create Implementation Plan

Generate a comprehensive, trackable implementation plan from the current conversation context. Plans are saved in `docs/implans/` and serve as living documents for project execution.

## Process

1. **Analyze Conversation**: Extract project requirements, technical approaches, constraints, and success criteria from the current conversation
2. **Generate Plan**: Create structured implementation plan using standardized template
3. **Save Plan**: Store in `docs/implans/` with proper naming convention
4. **Report**: Provide file path and brief summary of generated plan

## Plan Structure

Each generated plan must include:
- **Status tracking** with progress indicators and validation requirements
- **Agent handoff instructions** for seamless work resumption
- **Phase-based structure** with clear objectives, tasks, and validation criteria
- **Session history** section for continuous documentation
- **Risk assessment** with mitigation strategies
- **Resource tracking** for dependencies and references

## File Organization

### Naming Conventions
- **Active plans**: `docs/implans/ACTIVE_<descriptive-name>_implan.md`
- **Completed plans**: `docs/implans/completed_<YYYY-MM-DD>-<name>_implan.md`
- **Auto-naming**: Extract descriptive name from conversation context or use `$ARGUMENTS`

## Quality Standards

**Testing Requirements**: Plan items cannot be marked complete until:
- Fully implemented and tested with passing results
- Unit/integration tests written and executed (if project has testing infrastructure)
- No warnings or errors present
- Validation criteria verified

**Documentation Requirements**: Plans serve as living documents requiring:
- Real-time progress updates with current status
- Session history after each work period
- Decision documentation with rationale
- Risk tracking with mitigation progress

## Implementation Guidelines

1. **Directory Setup**: Ensure `docs/implans/` directory exists (create if needed)
2. **Context Extraction**: Analyze conversation for requirements, technical approaches, constraints, and success criteria
3. **Plan Generation**: Create comprehensive plan with:
   - Clear, actionable objectives and tasks
   - Specific validation criteria with test requirements
   - Realistic complexity assessments
   - Comprehensive risk analysis
   - Well-defined dependencies and prerequisites
   - Proper phase structure (typically 2-4 phases)
4. **File Creation**: Save with proper naming convention and confirm creation
5. **Summary**: Report file path and brief overview of generated plan

$ARGUMENTS

Plans should be immediately usable by any agent to resume work effectively.