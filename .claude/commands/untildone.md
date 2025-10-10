---
description: Execute task instructions autonomously until completely done with full verification
argument-hint: [task instructions]
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, Bash, Task, SlashCommand, TodoWrite, WebFetch, WebSearch
---

# Complete Autonomous Task Execution

Execute the following task instructions with complete autonomy until finished. Work without stopping, making informed decisions based on available context and research.

## Task Instructions

$ARGUMENTS

## Execution Protocol

### 1. Planning & Setup
- Use TodoWrite to create a comprehensive task breakdown
- Identify all components, files, and systems involved
- Plan the complete implementation approach
- Mark the first task as in_progress before starting work

### 2. Autonomous Execution Standards

**Decision Making**:
- Make reasonable assumptions when requirements are ambiguous
- Research using WebFetch/WebSearch when information is needed
- Use Task tool to delegate specialized work to appropriate agents
- Track every assumption and decision made using TodoWrite

**Quality Requirements**:
- Write production-ready code with proper error handling
- Follow all coding standards and best practices from CLAUDE.md
- Implement complete functionality - no stubs, placeholders, or TODOs
- Add appropriate logging and validation
- Handle edge cases and error conditions

**Testing Requirements**:
- Write comprehensive tests for all new functionality
- Run all tests and ensure they pass
- Fix any test failures immediately
- Run builds and ensure no warnings or errors
- Validate the implementation works end-to-end

**Progress Tracking**:
- Update TodoWrite status as you complete each task
- Mark tasks as completed immediately when finished
- Add new todos if you discover additional work needed
- Keep only ONE task as in_progress at a time

### 3. Completion Verification

Before declaring completion:
1. Review all todos - ensure everything is marked completed
2. Run all tests and builds - ensure everything passes
3. Check for any warnings, errors, or TODOs in code
4. Verify documentation is updated if needed
5. Execute `/doublecheck` using SlashCommand tool to validate completion

### 4. Final Report

Create a summary report including:

**Assumptions & Decisions Made**:
- List all assumptions made during implementation
- Explain reasoning for key technical decisions
- Note any ambiguities resolved

**Work Completed**:
- Summary of all changes made
- Files created, modified, or deleted
- Tests written and their coverage

**Verification Results**:
- Test results and build status
- Output from `/doublecheck` command
- Confirmation that nothing is left incomplete

## Important Reminders

- Do NOT stop until the work is 100% complete, tested, and verified
- Do NOT leave stubs, placeholders, or incomplete implementations
- Do NOT skip testing or quality checks
- Do NOT declare completion without running `/doublecheck`
- DO make reasonable assumptions and document them
- DO research when you need information
- DO ask for clarification only if absolutely critical decisions cannot be reasonably inferred
