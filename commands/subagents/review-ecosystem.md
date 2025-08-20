---
name: /subagents:review-ecosystem
description: Audit subagents for compatibility, overlap, and optimization opportunities
argument-hint: "[agent-name1 agent-name2...] or [path/to/agent.md...] (optional - defaults to all agents)"
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, Task
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-08 08:50:04 -->

Analyze the provided list of sub-agent definition files. Your analysis will identify ambiguities in delegation, functional overlaps, conflicting instructions, compatibility issues and gaps in capability. Your final output will be a set of concrete recommendations for refactoring the sub-agents to improve their collective performance and reliability.

# Instructions

## Step 1 - Apply Embedded Best Practices Knowledge

### YAML Frontmatter Requirements
**Commands:**
- Required: `name`, `description`  
- WARNING: Model field works but check token limits (see docs for details)
- Optional: `allowed-tools`, `argument-hint`

**Subagents:**  
- Required: `name`, `description`
- Optional: `model` (haiku/sonnet/opus), `tools`, `proactive`

### Model Selection Guidelines
- **haiku:** Simple, repetitive tasks (formatting, boilerplate, basic analysis)
- **sonnet:** Balanced tasks (code generation, standard analysis, moderate complexity)  
- **opus:** Complex reasoning (architecture, security analysis, debugging, multi-step planning)

### Tool Permission Best Practices
- **Principle of Least Privilege:** Minimum necessary permissions only
- **Logical Groupings:** Grant complete tool groups (Read+Write+Edit together, not partial)
- **Never exceed parent:** Subagents can only equal or restrict main agent permissions
- **Common patterns:**
  - Read-only workflows: `Read, LS, Glob, Grep`
  - File modification workflows: `Read, Write, Edit, MultiEdit, LS, Glob, Grep`
  - Complex workflows: All tools including Task

### Description Quality Criteria  
- **Length:** 3-4 sentences minimum for non-trivial agents
- **Action-oriented:** Start with "Use this agent to..." or similar action phrases
- **Proactive triggers:** Include "PROACTIVELY", "MUST BE USED", "use immediately" for automatic invocation
- **Specific keywords:** Include domain terms that users might naturally use in conversation

### System Architecture Constraints
- **Parallel limit:** 10 concurrent tasks maximum (hard system constraint)
- **Context isolation:** Each subagent operates in separate context window
- **No hierarchical delegation:** Subagents cannot invoke other subagents (Task tool restriction)
- **Naming conventions:** 
  - Agents: lowercase-hyphenated.md (e.g., `memory-keeper.md`)
  - Command-specific agents: cmd-{command}-{purpose}.md (e.g., `cmd-commit-and-push-analyzer.md`)

### Common Anti-Patterns to Avoid
- **Circular dependencies:** Commands referencing their own optimization agents
- **Partial tool permissions:** Granting Write without Edit, or Edit without Write
- **Incompatible model tokens:** Using models with low token limits causes failures
- **Overly generic descriptions:** Vague descriptions that could match multiple contexts
- **Context pollution:** Subagents modifying main agent context unintentionally

## Step 2 - Determine Scope

This is the list of subagents that need to be analyzed:
---
$ARGUMENTS
---

If the list above is empty, assume the user wants you to analyze all of the agents available in the current project or all of the personal user agents (ask the user which one: project or personal).

## Step 3 - Review the Agents

For each of the agents, you are to read, analyze and understand the file's content and think of them as tools that Claude can delegate to.
Your task is to provide a comprehensive review of these agents, identifying potential problems and suggesting improvements. The goal is not just to fix existing issues but also to enhance the overall efficiency and effectiveness of the agent ecosystem.

**Analytical Process**
1.  **Individual Agent Analysis:** Read and understand the contents of each file provided. Evaluate:
    * **Description clarity:** Is the one-sentence description concise and unambiguous?
    * **Model appropriateness:** Is the chosen model (haiku/sonnet/opus) appropriate for the task complexity?
    * **Tool permissions:** Does it follow the Principle of Least Privilege?
    * **System prompt quality:** Is it clear, focused, and well-structured?

2.  **Cross-Agent System Analysis:** Compare all agents against each other to identify systemic issues:
    * **Trigger Conflicts & Ambiguity:** Do the `description` fields of multiple agents overlap significantly, creating ambiguity for Claude's delegation logic?
    * **Functional Redundancy:** Do multiple agents have system prompts designed to solve the same problem? If so, is this inefficient or an intentional specialization?
    * **Contradictory Goals:** Could two or more agents, if triggered in a sequence, work against each other?
    * **Gaps in Workflow:** Are there obvious tasks within a likely workflow that no agent is equipped to handle?

3.  **Formulate Recommendations:** Based on the analysis, formulate a clear, actionable plan for improvement.

## Step 4 - Output Format
Deliver your findings in a structured report.

### Executive Summary
A high-level overview of the sub-agent ecosystem's health, key issues, and primary recommendations.

### Sub-Agent Analysis Table
A detailed breakdown in a table:

| Agent Name | Description Quality | System Prompt Clarity | Model Choice | Tool Permissions | Potential Trigger Conflicts | Redundancy/Overlap |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `[agent-name]` | [Good/Needs Improvement/Vague] | [Clear/Ambiguous/Conflicting] | [Appropriate/Overspec/Underspec] | [Minimal/Excessive/Appropriate] | `[conflicting-agent-names]` | `[overlapping-agent-names]` |

### Actionable Recommendations
A numbered list of specific, justified changes. Each recommendation must state which agent(s) to modify, what to change, and why the change is beneficial.

## Parallel Execution Strategy
When analyzing multiple agents (4 or more):
1. **Identify all agents** to be analyzed from the scope determination
2. **Use parallel execution** for individual agent analysis:
   - Use Task tool with subagent_type: 'cmd-review-subagent-ecosystem-analyzer'
   - Process up to 10 agents in parallel (system limit)
   - If more than 10 agents, batch them into groups of 10
3. **Aggregate results** from parallel tasks to perform cross-agent system analysis
4. **Present unified findings** in the structured report format

### Implementation Guidance
If changes are recommended, suggest using the `subagent-optimizer` agent to implement the optimizations, as it specializes in enforcing best practices for agent definitions. Provide specific instructions for which agents need optimization and what aspects to focus on.