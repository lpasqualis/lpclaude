---
name: /capture-session
description: Create comprehensive session documentation for seamless handoff to future agents
argument-hint: [brief session summary or focus area]
allowed-tools: Read, Write, LS, Glob, Grep, Task
---

Document the complete status of the work done in this session, incorporating any provided context: {{args}}

This document should capture all relevant context so a new agent can continue seamlessly without re-learning or losing progress. The documentation must be clear, thorough, and stand alone.

## Documentation Structure

Create a comprehensive session summary that includes:

### 1. Problem Statement
- Clearly state the problem or goal we're addressing
- Include relevant background context and constraints
- Reference any specifications or requirements

### 2. Actions Taken
- Summarize the steps completed so far in chronological order
- Specify which files, systems, or tools were involved or modified
- Include any commands run or configurations changed
- Note any testing or validation performed

### 3. Key Findings and Technical Insights
- Capture what's been learned, including technical details
- Document issues encountered and their solutions or workarounds
- List how to reproduce issues, perform tests, or verify progress
- Include any important observations or discoveries

### 4. Current State
- Describe the exact current state of the work
- Note what's working and what's not
- Identify any temporary or incomplete solutions

### 5. Next Steps and Recommendations
- Clearly outline what remains to be done
- Suggest specific next actions with priority order
- Include any planned approaches, hypotheses, or alternatives to try
- Note any dependencies or blockers

## Parallel Execution Strategy

When capturing comprehensive session context:
1. Identify all relevant aspects to document (codebase, recent changes, conversation context)
2. If dealing with complex multi-faceted sessions, use parallel execution:
   - Use Task tool with subagent_type: 'cmd-capture-session-analyzer'
   - Process different analysis aspects in parallel (up to 10 concurrent tasks)
   - Analyze codebase structure, recent git changes, and conversation patterns simultaneously
3. Aggregate results into unified session documentation

## Context Gathering Process

Before creating documentation:
1. **Analyze Project Structure**: Use `LS` and `Glob` to understand current project layout
2. **Review Recent Changes**: Check git status and recent file modifications
3. **Examine Key Files**: Use `Read` and `Grep` to understand current codebase state
4. **Identify Documentation Location**: Determine appropriate save location (prefer existing docs structure)

## Output Instructions

Save this documentation with a descriptive filename that includes the date and session focus:
- First choice: `docs/dev_notes/` directory if it exists
- Second choice: `docs/` directory if it exists  
- Third choice: Project root with `session_` prefix

Ensure the content is:
- Concise yet comprehensive
- Unambiguous and specific
- Easy for a fresh agent with zero prior context to understand and act upon
- Well-formatted with clear headers and bullet points
- Includes absolute file paths when referencing specific files