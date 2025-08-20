---
name: /subagents:review-ecosystem
description: Audit subagents for compatibility, overlap, and optimization opportunities
argument-hint: "[agent-name1 agent-name2...] or [path/to/agent.md...] (optional - defaults to all agents)"
allowed-tools: Read, LS, Glob, Grep, Task
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-20 15:01:00 -->

Analyze subagent definition files to identify delegation ambiguities, functional overlaps, compatibility issues, and optimization opportunities. Provide concrete recommendations for improving collective agent performance and reliability.

## Scope Determination

Target agents for analysis:
```
$ARGUMENTS
```

**If no arguments provided**: Ask user to specify scope:
- **project**: Analyze agents in `.claude/agents/` (project-local)
- **global**: Analyze agents in `~/.claude/agents/` (global scope)

## Analysis Strategy

### For 1-3 Agents: Sequential Analysis
Read and analyze each agent individually, then perform cross-agent comparison.

### For 4+ Agents: Parallel Execution
1. **Identify all agents** from scope determination
2. **Batch parallel analysis**:
   - Use Task tool with subagent_type: 'cmd-review-subagent-ecosystem-analyzer'
   - Process up to 10 agents concurrently (system limit)
   - For >10 agents, process in batches of 10
3. **Aggregate results** for cross-agent system analysis
4. **Generate unified report**

## Analysis Criteria

### Individual Agent Assessment
- **Description Quality**: Clear, specific, actionable delegation triggers
- **Model Appropriateness**: Complexity matches haiku/sonnet/opus capabilities
- **Tool Permissions**: Follows principle of least privilege
- **System Prompt**: Well-structured, focused instructions

### Cross-Agent System Analysis
- **Trigger Conflicts**: Description overlap causing delegation ambiguity
- **Functional Redundancy**: Multiple agents solving identical problems
- **Contradictory Goals**: Agents working against each other in workflows
- **Capability Gaps**: Missing coverage for obvious workflow tasks

## Output Format

### Executive Summary
High-level ecosystem health assessment and primary recommendations.

### Agent Analysis Table
| Agent Name | Description Quality | Model Choice | Tool Permissions | Trigger Conflicts | Redundancy/Overlap |
|:-----------|:-------------------|:-------------|:-----------------|:------------------|:-------------------|
| `agent-name` | Good/Needs Improvement/Vague | Appropriate/Overspec/Underspec | Minimal/Excessive/Appropriate | `conflicting-agents` | `overlapping-agents` |

### Actionable Recommendations
Numbered list of specific changes with justification:
1. **Agent(s)**: [names] **Change**: [specific modification] **Benefit**: [improvement rationale]

### Implementation Guidance
Recommend using `@subagent-optimizer` for implementing optimizations, with specific focus areas for each agent requiring changes.