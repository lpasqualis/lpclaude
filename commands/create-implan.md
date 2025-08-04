---
description: Create a comprehensive implementation plan from the current conversation context
model: sonnet
argument-hint: "[implementation plan name] (optional - if updating existing plan)"
---

Create a comprehensive implementation plan from the current conversation context and save it in the project's `docs/implans/` directory. If a plan already exists, update it to fully comply with the template structure below.

## Process Overview

1. **Analyze Context**: Extract key information from the current conversation
2. **Determine Action**: Create new plan or update existing one (using optional argument: `$ARGUMENTS`)
3. **Generate Plan**: Use the detailed template structure provided below
4. **Save File**: Follow naming conventions and ensure proper organization

## Analysis Requirements

From the conversation context, identify:
- **Feature/fix/component** being discussed
- **Key requirements** and constraints
- **Technical approach** and architecture decisions
- **Risks and challenges** that need addressing

## File Naming Convention

- **Active plans**: `docs/implans/ACTIVE_<DESCRIPTIVE-NAME>_implan.md`
- **Completed plans**: `completed_<YYYY-MM-DD>-<descriptive-name>_implan.md`
- Update existing files to comply with this naming convention

## Implementation Plan Template

Use this exact template structure:

```markdown
# [Feature/Component Name] Implementation Plan

**Version:** 1.0  
**Date:** [Current Date]  
**Author:** [Get from context or use "Team"]  
**Status:** 🚧 IN PROGRESS

## 🤖 Agent Instructions

### For Agents Resuming Work

1. **Start Here**: Read the "Current Status" section to understand what has been completed
2. **Check TODOs**: Look for unchecked items in the implementation phases
3. **Update Status**: Mark items complete as you finish them using [x]
4. **Document Learnings**: Add important discoveries to the "Learnings & Decisions" section
5. **Test Your Work**: Run tests mentioned in each phase before marking complete.
6. **Update This Doc**: Keep this document current - it's the source of truth. If the work on phase affects other phases, update those too accordingly.
7. **Keep It Simple**: Avoid unnecessary complexity; focus on essential details.

#### VERY IMPORTANT
- **Done means that it is fully implemented and proven to work** You cannot mark items are done until they are fully implemented and tested and they are proven work as designed.
  - If a test coudn't be executed for any reason, the item is NOT done.
  - If the project has unit tests, any non-trivial item marked as done MUST include a passing unit test following the project standards.
  - If the project has manual or integration tests, any non-trivial item marked as done MUST have a corresponding passing manual or integration test included and following the project standards.
  - If there are no tests available yet, write down why and how you intend to add them later.
  - Work with the user to ensure that the test can run properly.
  - Warnings and errors are not acceptable. Items that generate warnings or errors cannot be marked as done.
  - If an item is incomplete due to external factors (e.g., waiting for another team), mark it as such but keep working towards completion if possible.
- **Living Document**: This implementation plan is a living document that MUST be kept updated throughout the implementation
- **Session Updates**: After each work session, update the session history and current status
- **Progress Tracking**: Use checkboxes [x] to track completed items
- **Percentage Updates**: Keep the overall progress percentage current
- **Agent Handoff**: This document is the primary handoff mechanism between agents
- **Get today's date from the date command**: Run "date" to get the current date. Do not assume what day it is.

---

## 📊 Current Status ([Date])

### 🎯 Quick Summary
- **Overall Progress**: ~X% Complete ([Brief Description])
- **Last Updated**: [Date and Time]  
- **Last Session**: [Brief summary of last work session]  
- **Current State**: [Brief summary of where things stand]
- **Major Achievements**: [List key completed items]
- **Current Focus**: [What's being worked on now]
- **Current Priority**: [What needs immediate attention]
- **Blockers**: [Any blocking issues]

### Critical Context
[List any critical constraints, dependencies, or architectural decisions that agents must know]

### ✅ Recently Completed ([Date])
[List recently completed items with brief descriptions]

### ⚠️ Active Issues
[List any current problems, blockers, or concerns]

### 🎯 Next Steps
[Clear list of what to do next]

### 📝 Notes for Next Session

**Immediate TODOs**:
1. [First thing to do next session]
2. [Second thing to do]
3. [Third thing to do]

**Questions to Resolve**:
- [Open questions needing answers]

**Remember to**:
- Update progress percentages
- Mark completed tasks with [x]
- Add new learnings to the appropriate section
- Keep the current status section up-to-date

---

## 🎯 Project Overview

### Problem Statement
[Clear description of the problem being solved]

### Solution Approach
[High-level description of the chosen solution]

### Success Criteria
[Measurable criteria for completion]

### Constraints & Requirements
[Technical, business, or other constraints]

---

## 📋 Planned Implementation Phases

### Phase 1: [Phase Name]
**Expected Complexity**: [Trivial | Low | Medium | High | Very high | Extremely high]
**Status**: ⏳ NOT STARTED | 🚧 IN PROGRESS | ✅ COMPLETED

#### Objectives
- [ ] [Specific objective 1]
- [ ] [Specific objective 2]

#### Tasks
- [ ] [Detailed task 1]
  - [ ] [Subtask if needed]
- [ ] [Detailed task 2]

#### Validation Criteria
- [ ] [How to verify this phase is complete]
- [ ] [Test scenarios to run]
- [ ] [Planned Units/integration/manual tests]

#### Dependencies
- [External dependencies]
- [Required tools or access]
- [Required environment to run the tests and/or verification steps]

---

### Phase 2: [Phase Name]
[Repeat structure for each phase]

---

## 💡 Learnings & Decisions

### Session History

#### Session 1 ([Date]) - [Session Title]
- **Focus**: [What was worked on]
- **Completed**: [What was finished]
- **Discovered**: [Key learnings]
- **Decisions**: [Important decisions made]
- **Next Time**: [What to do next session]

### Technical Decisions
1. **[Decision Topic]**: [Rationale and chosen approach]
2. **[Decision Topic]**: [Rationale and chosen approach]

### Key Discoveries
- [Important technical discoveries]
- [Gotchas or surprises]
- [Performance considerations]

### Tests Executed
- [Tests run during this session]
- [Results and notes]

---

## 📚 Resources & References

### Documentation
- [Relevant documentation links]
- [API references]
- [Design documents]

### Code Locations
- [Key files and their purposes]
- [Module structure]

### External Dependencies
- [Libraries and versions]
- [External services]

---

## ⚠️ Risks & Mitigations

| Risk | Impact | Probability | Mitigation Strategy |
|------|--------|-------------|-------------------|
| [Risk description] | High/Medium/Low | High/Medium/Low | [How to handle] |

---

```

## Important Notes

After creating the implementation plan:
1. Confirm the file was created successfully
2. Provide the file path
3. Give a brief summary of the plan's structure and current status