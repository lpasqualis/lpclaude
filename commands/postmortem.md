---
name: /postmortem
description: Analyze session context to identify and document issues encountered for systematic fixing
argument-hint: [optional focus area or specific issues]
allowed-tools: Read, LS, Glob, Grep, Bash
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-09-01 -->
Conduct a postmortem analysis of the current session to identify and document all issues encountered, their root causes, and next steps for systematic resolution.

## Areas of focus

Focus on the following area. If this section is empty, decided what to focus on:

<focus-area>
$ARGUMENTS
</focus-area>

## Purpose
Extract and document problems discovered during work in the focus area; examine true issues and root causes rather than workarounds. The goal is to produce a report that can be used to systematically fix underlying issues withou any additional context or logs. The report should NOT contain problems that were fully resolved permanently, if there is nothing left to do to improve the situation.

## Step 1: Issue Discovery

Analyze the session context for:
- **Errors and Failures**: Command failures, test failures, build errors
- **Workarounds Applied**: Temporary fixes or bypassed problems
- **Inconsistencies Found**: Configuration mismatches, dependency conflicts
- **Performance Problems**: Slow operations, resource bottlenecks
- **Development Friction**: Tool issues, workflow inefficiencies

Use these methods:
- Check bash history for failed commands or retries
- Review error messages and stack traces
- Identify patterns in problem occurrences
- Note any temporary fixes or manual interventions
- Document struggles, resolutions, and prevention strategies
- Document situations where you had to try and retry sto accomplish a goal in different ways

## Step 2: Root Cause Analysis

For each identified issue:
1. **Symptom**: What specific behavior was observed?
2. **Impact**: How did this affect the work?
3. **Root Cause**: What underlying problem caused this?
4. **Reproduction Steps**: How can this be reliably reproduced?
5. **Evidence & Domain**: File paths, error messages, command outputs

## Step 3: Issue Categorization

Group issues by:
- **Severity**: Critical (blocks work), Major (significant impact), Minor (inconvenience)
- **Domain**: Build system, dependencies, testing, documentation, tooling
- **Type**: Bug, configuration issue, missing feature, performance problem

## Step 4: Generate Report

Present a structured postmortem report:

```markdown
# Session Postmortem Report
Date: [current date]
Session Context: $ARGUMENTS

## Executive Summary
[Brief overview of major issues found]

## Issues Identified, in order of severity

### Issue #1: [Descriptive Title]
- **Severity**: [Critical/Major/Minor]
- **Domain**: [Category]
- **Symptom**: [What happened]
- **Root Cause**: [Why it happened]
- **Reproduction**:
  1. [Step 1]
  2. [Step 2]
  ...
- **Evidence**:
  - File(s): [path]
  - Error(s): [message]
  - Command: [what was run]
- **Workarounds**: [list of workaround that were implemented]
- **Recommended Fix**: [Specific action needed]

[Repeat for each issue]

## Patterns and Trends
[Common themes across multiple issues]

## Key Learnings
[Important insights to remember from this session]

## Next Steps
Priority order for fixing:
1. [Most critical issue] - [Brief fix description]
2. [Next issue] - [Brief fix description]
...

## Prevention Recommendations
[Suggestions to prevent similar issues in the future - avoid speculative suggestions]
```

Focus on actionable information that enables systematic fixes, not temporary workarounds. Present the complete report to the user without saving to file.
