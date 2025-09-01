---
name: /jobs:queue-learnings
description: Review current work context to identify remaining tasks that need to be captured as jobs, then create them using the addjob agent
argument-hint: [optional context about recent work or specific area to focus on]
allowed-tools: [Read, LS, Glob, Grep, Task]
---

Review the current work context and recent activities to identify any learnings or remaining tasks that still require work but are not captured in existing job files.

## Process

### Step 1: Scan Existing Jobs
Check what jobs are already scheduled:
- List all files in `jobs/` directory
- Read job titles and descriptions to understand what's already covered
- Note any gaps in the planned work

### Step 2: Analyze Recent Context
Review recent work to identify uncaptured learnings:
- Consider any issues discovered during recent implementations
- Look for incomplete solutions or workarounds that need proper fixes
- Look for errors we encountered, and ways we could avoid them in the future
- Identify any best practices or patterns that emerged
- Check for any technical debt or follow-up items mentioned

### Step 3: Identify Missing Work
Ask the key question: "Did we learn anything that still requires work that is not captured in jobs already scheduled in jobs/*.md?"

Consider categories like:
- Bug fixes needed
- Performance improvements
- Code quality enhancements
- Documentation updates
- Testing gaps
- Refactoring opportunities
- New features identified during implementation
- Integration improvements
- User experience enhancements
- Errors we encounterd
- Problems we had to solve that could be resolved once and for all

### Step 4: Create Jobs for Missing Items
If any missing work is identified, use the addjob agent to create comprehensive job files that are **self-sufficient and self-documenting**. Each job should include:

**Essential Context:**
- Complete background: What project/work led to this discovery
- Root cause: What problem occurred that revealed this need
- Current state: What exists now and what's missing
- Impact: Why this work matters and what it improves

**Detailed Problem Description:**
- Specific symptoms or issues encountered
- Examples of when/where the problem manifests
- Current workarounds being used (if any)
- How the problem was discovered

**Implementation Roadmap:**
- Step-by-step approach to solve the problem
- Specific files, directories, or components involved
- Technical requirements and dependencies
- Expected deliverables and success criteria

**Reference Information:**
- Links to related files or directories
- Commands or tools that need to be used
- Examples of similar implementations
- Any research or investigation already done

Use the Task tool to invoke the addjob agent with COMPLETE context:
```
Task(subagent_type: 'addjob', description: 'Create comprehensive self-documenting jobs', prompt: 'Create detailed job files for the following work items. Each job must be completely self-sufficient with full background context, problem description, implementation details, and all reference information needed to execute the work without requiring additional context from previous conversations: [provide exhaustive details for each item]')
```

### Step 5: Report Results
Summarize what was found:
- List any new jobs created
- Confirm if all learnings are now captured
- Note if no additional work was identified

Focus on being thorough but practical - capture genuine work items that add value, not busy work.

## Job Quality Standards

Each created job must pass the "6 months later test" - someone (including yourself) should be able to execute the job 6 months from now without needing to:
- Remember the conversation that created it
- Hunt for missing context or background information
- Guess what files or components are involved
- Figure out why the work is needed

**Good job example:**
- "During git rewrite-commit-descriptions development, we encountered bash syntax `${var,,}` that failed on macOS default bash 3.2. This broke the detect-bad-commits.sh script. Need to establish coding standards..."

**Bad job example:**
- "Fix bash compatibility issues" (no context about what, where, or why)