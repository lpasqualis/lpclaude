---
name: /claude:agentic-review
description: Analyze project's commands, subagents, and workers to identify needed conversions and optimizations
allowed-tools: Read, LS, Glob, Grep, Task
---

Conduct a comprehensive review of this project's agentic components (commands, subagents, and workers) to identify opportunities for optimization based on Claude Code best practices.

## Analysis Tasks

1. **Inventory all components**:
   - List all slash commands in `.claude/commands/`
   - List all subagents in `.claude/agents/`
   - List all workers in `workers/` or `tasks/`

2. **Analyze usage patterns**:
   - For each subagent: Check if it's only invoked by slash commands and doesn't need to be invoked by the user directly (candidate for worker conversion)
   - For each worker: Check if it could benefit from user/Main Claude invocation (candidate for subagent conversion)
   - For inline prompts in slash commands: Identify candidates for worker extraction (reused or parallelizable)

3. **Check for anti-patterns**:
   - Subagents with no auto-trigger keywords that are never invoked by Main Claude
   - Workers that implement functionality users might want to trigger directly
   - Slash commands with complex inline prompts that could run in parallel
   - Components with overlapping functionality that could be consolidated

4. **Verify technical constraints**:
   - Ensure no subagents have Task tool in their allowed tools
   - Check that workers don't attempt to invoke other tasks
   - Validate that slash commands don't try to invoke other slash commands

5. **Generate optimization report** with sections:
   - **Immediate Actions**: Critical issues that should be fixed
   - **Recommended Conversions**: 
     * Subagent → Worker conversions (with context savings estimate)
     * Subagent → Slash Command conversions (for false-positive prone auto-triggers or to save context space if there is no good reason for a prompt to be a subagent)
     * Worker → Subagent conversions (with rationale - rare)
     * Inline → Worker extractions (with parallelization benefits)
   - **Consolidation Opportunities**: Redundant or overlapping components
   - **Best Practice Violations**: Any deviations from documented patterns
   - **Context Optimization**: Estimate of context savings from recommended changes

Format the report clearly with specific file paths and actionable recommendations. Include rationale based on the execution hierarchy and documented best practices.

$ARGUMENTS