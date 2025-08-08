---
name: /implan:create
description: Create comprehensive implementation plans from conversation context
argument-hint: [plan name] (optional - defaults to auto-generated name)
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, Bash, Task
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-08 08:32:14 -->

# Create Implementation Plan

Generate a comprehensive, trackable implementation plan from the current conversation context. Plans are saved in `docs/implans/` and serve as living documents for project execution.

## Execution Strategy

### Single Plan Creation
1. **Extract Context**: Analyze conversation for requirements, technical approach, and constraints
2. **Generate Plan**: Create structured plan using standardized template
3. **Save & Report**: Store in appropriate location with proper naming

### Multiple Plans (Parallel Processing)
When conversation mentions multiple features/components:
1. Identify all distinct implementation items
2. If 3+ items detected, use parallel execution:
   - Use Task tool with subagent_type: 'implan-generator'
   - Batch into groups of 10 (system limit)
   - Process up to 10 plans in parallel per batch
   - Aggregate results and provide unified summary

## Plan Structure Requirements

Each plan must include:
- **Status tracking** with progress indicators
- **Agent handoff instructions** for seamless work resumption  
- **Validation criteria** with testability requirements
- **Session history** for continuous documentation
- **Risk assessment** with mitigation strategies

## File Organization

### Naming Conventions
- **Active**: `docs/implans/ACTIVE_<descriptive-name>_implan.md`
- **Completed**: `docs/implans/completed_<YYYY-MM-DD>-<name>_implan.md`
- **Auto-naming**: Extract from context or use argument `$ARGUMENTS`

The plan template includes:
- **Agent handoff instructions** for seamless work resumption
- **Status tracking** with progress indicators and validation requirements
- **Phase-based structure** with objectives, tasks, and validation criteria  
- **Session history** for continuous documentation
- **Risk assessment** with mitigation strategies
- **Resource tracking** for dependencies and references

### Critical Requirements

**Testing Standards**: Items cannot be marked complete until:
- Fully implemented and tested with passing results
- Unit tests written for non-trivial functionality (if project has unit tests)
- Integration/manual tests executed (if project has them)  
- No warnings or errors present
- Validation criteria verified

**Documentation Standards**: Plans serve as living documents requiring:
- Real-time progress updates with current status
- Session history after each work period
- Decision documentation with rationale
- Risk tracking with mitigation progress

## Implementation Process

1. **Context Analysis**: Extract project requirements, technical approach, constraints, and success criteria from conversation
2. **Directory Setup**: Ensure `docs/implans/` directory exists, create if needed
3. **Plan Generation Strategy**:
   - **Single plan**: Generate directly using conversation context
   - **Multiple plans**: Use parallel processing with implan-generator subagent
     - Identify distinct implementation items
     - Batch into groups of 10 if needed
     - Execute parallel generation
     - Aggregate and consolidate results
4. **File Creation**: Save with proper naming convention and confirm success
5. **Status Report**: Provide file paths and brief summary of generated plan(s)

## Quality Assurance

Each generated plan must include:
- Clear, actionable objectives and tasks
- Specific validation criteria with test requirements  
- Realistic complexity assessments
- Comprehensive risk analysis
- Well-defined dependencies and prerequisites
- Proper phase structure (typically 2-4 phases)

Plans should be immediately usable by any agent to resume work effectively.