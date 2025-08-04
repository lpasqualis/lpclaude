---
description: Audit a group of subagents to ensure they are well defined and compatible with each other
argument-hint: "[sub agents to examine] (optional)"
---

Analyze the provided list of sub-agent definition files. Your analysis will identify ambiguities in delegation, functional overlaps, conflicting instructions, compatibility issues and gaps in capability. Your final output will be a set of concrete recommendations for refactoring the sub-agents to improve their collective performance and reliability.

# Instructions

## Step 1 - Understand Sub-Agents

- Read and understand @~.claude/resources/commands_and_agents.md for a complete understandig of agents
- Read and understand any latest updates about agents: https://docs.anthropic.com/en/docs/claude-code/sub-agents (this documentation is the most recent)

## Step 2 - Review Provided Agents

This is the list of subagents that need to be analyzed:
---
$ARGUMENTS
---

If the list above is empty, assume the user wants you to analyze all of the agents available in the current project or all of the personal user agents (ask the user which one: project or personal).

#### Step 3 - Review the agents

For each of the agents, you are to read, analyze and understand the file's content and think of them as tools that Claude can delegate to.
Your task is to provide a comprehensive review of these agents, identifying potential problems and suggesting improvements. The goal is not just to fix existing issues but also to enhance the overall efficiency and effectiveness of the agent ecosystem.

**Analytical Process**
1.  **Analyze:** Read and understand the contents of each file provided. 

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

| Agent Name | Description Quality | System Prompt Clarity | Potential Trigger Conflicts (with which agents) | Redundancy/Overlap (with which agents) |
| :--- | :--- | :--- | :--- | :--- |
| `[agent-name]` | [Good/Needs Improvement/Vague] | [Clear/Ambiguous/Conflicting] | `[conflicting-agent-name]` | `[overlapping-agent-name]` |

### Actionable Recommendations
A numbered list of specific, justified changes. Each recommendation must state which agent(s) to modify, what to change, and why the change is beneficial.

Ask the user if you should proceed with the changes suggested.
