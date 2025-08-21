---
name: /capture-session
description: Create comprehensive session documentation for seamless handoff to future agents
argument-hint: [brief session summary or focus area]
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, Bash, Task, WebFetch, WebSearch, TodoWrite, NotebookEdit
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-08 08:29:45 -->

Document the complete status of the work done in this session, incorporating any provided context: {{args}}

This command creates comprehensive session documentation that enables seamless handoff to future agents without losing progress or context.

## Step 1: Context Analysis

First, systematically gather session context using parallel analysis:

### Identify Analysis Aspects
Determine which aspects of the session require documentation:
- **Project Structure**: Current codebase organization and architecture
- **Recent Changes**: Git history, modified files, and work patterns
- **Technical Context**: Implementation details, challenges, and solutions
- **Problem Domain**: Business requirements, constraints, and goals

### Parallel Execution Strategy
When analyzing sessions with multiple complex aspects (more than 3 areas):

1. **Identify Work Items**: Determine all aspects requiring analysis:
   - Project structure, recent changes, technical context, problem domain
   - Individual components, modules, or feature areas
   - Multiple files or directories requiring detailed examination

2. **Execute Parallel Analysis**: Launch multiple Task calls simultaneously with Read template: Read('tasks/capture-session-analyzer.md') then use Task with subagent_type: 'general-purpose'
   ```
   # IMPORTANT: Execute these in a single message with multiple tool uses for true parallelism
   Task 1: "Analyze project structure and architecture patterns in /src and /lib directories"
   Task 2: "Review git status and last 10 commits for development patterns" 
   Task 3: "Examine technical implementations in core modules and API endpoints"
   Task 4: "Document business requirements and constraints from README and docs"
   Task 5: "Analyze test coverage and validation approaches"
   Task 6: "Review configuration files and environment setup"
   Task 7: "Examine error handling and logging patterns"
   Task 8: "Document external dependencies and integrations"
   Task 9: "Analyze performance considerations and optimizations"
   Task 10: "Review security implementations and access controls"
   ```
   
   **Batching Strategy**: If more than 10 items:
   - First batch: Core analysis tasks (structure, changes, technical, domain)
   - Second batch: Deep-dive tasks (specific modules, edge cases, optimizations)
   - Third batch: Validation tasks (tests, security, performance)

3. **Result Aggregation Protocol**:
   - Collect all parallel analysis results
   - Cross-reference findings for consistency
   - Merge complementary insights
   - Resolve conflicting information by prioritizing most recent/specific data
   - Build unified narrative from distributed analyses

4. **Sequential Fallback**: For simpler sessions (3 or fewer aspects), analyze sequentially for efficiency

## Step 2: Context Gathering

Systematically collect session information:

### Project Structure Analysis
- Use `LS` and `Glob` to map current project layout
- Identify key directories, configuration files, and architectural patterns
- Note build systems, dependencies, and tooling setup

### Recent Activity Review
- Check `git status` and recent commits using `Bash`
- Examine recently modified files with `Read` and `Grep`
- Identify work-in-progress or uncommitted changes

### Technical State Assessment
- Review key implementation files and their current state
- Document any temporary solutions or incomplete work
- Note testing approaches and validation methods

### Problem Context Capture
- Extract problem statements and requirements from conversation
- Identify constraints, success criteria, and stakeholder needs
- Document any domain-specific knowledge discovered

## Step 3: Documentation Synthesis

Compile findings into structured documentation with these sections:

### 1. Problem Statement & Context
- Primary objective and background information
- Key constraints, requirements, and success criteria
- Stakeholders and their specific needs

### 2. Actions Completed
- Chronological summary of steps taken
- Files modified, commands executed, configurations changed
- Testing performed and validation results

### 3. Technical Insights & Discoveries
- Key learnings and implementation approaches
- Issues encountered and their solutions/workarounds
- Procedures for reproducing work or verifying progress

### 4. Current State Assessment
- Exact status of all work components
- What's working correctly vs. what needs attention
- Any temporary implementations or known issues

### 5. Forward Path & Recommendations
- Prioritized list of remaining tasks
- Specific next actions with clear success criteria
- Alternative approaches and contingency plans
- Dependencies and potential blockers

## Step 4: Documentation Output

### Location Determination
Systematically determine the optimal save location:

1. **Check Documentation Structure**: Use `LS` to identify existing documentation patterns:
   - Primary: `docs/dev_notes/` directory (preferred for session docs)
   - Secondary: `docs/` directory (general documentation)
   - Tertiary: `notes/` or `documentation/` directories
   - Fallback: Project root with `session_` prefix

2. **Create Descriptive Filename**: Include date and session focus:
   - Format: `YYYY-MM-DD_session_[focus-area].md`
   - Example: `2025-08-07_session_api-optimization.md`

### Content Requirements
Ensure the documentation is:

- **Self-Contained**: Complete context for agents with zero prior knowledge
- **Actionable**: Specific file paths, commands, and procedures
- **Structured**: Clear headers, bullet points, and logical flow
- **Technical**: Include absolute file paths, command sequences, and configuration details
- **Forward-Looking**: Clear next steps with success criteria

### Quality Checklist
Before saving, verify documentation includes:

- [ ] Absolute file paths for all referenced files
- [ ] Specific command sequences and procedures
- [ ] Clear problem statement and objectives
- [ ] Chronological action summary
- [ ] Current state assessment with specifics
- [ ] Prioritized next steps with success criteria
- [ ] Any temporary solutions or known issues flagged