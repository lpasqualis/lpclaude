---
name: /commands:normalize
description: Analyzes all command names and structures, then refactors them to follow consistent naming conventions, proper grouping, and best practices with user confirmation
argument-hint: "[scope: project|personal|ask] [mode: names-only|full-optimization|ask]"
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, Task
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-07 20:42:33 -->

Analyze and normalize command naming conventions, structure, and organization across the specified scope. This is a comprehensive workflow that respects existing good patterns while enforcing best practices.

## Phase 1: Setup and Scope Determination

Parse arguments from: $ARGUMENTS

1. **Determine Scope**:
   - If scope not specified or "ask": Ask user whether to normalize project commands (`.claude/commands/`), personal commands (`~/.claude/commands/`), or both
   - Record the selected scope for processing

2. **Determine Mode**:
   - If mode not specified or "ask": Ask user whether to:
     - "names-only": Just normalize names and organization
     - "full-optimization": Also run command-optimizer on each command
   - Record the selected mode

3. **Understand Existing Philosophy**:
   - Read CLAUDE.md to understand project conventions and any documented naming philosophy
   - Read README.md to check for command organization documentation
   - Read resources/slash_commands_best_practices_research.md for best practices reference
   - Identify any existing good patterns that should be preserved

## Phase 2: Discovery and Analysis

1. **Discover All Commands**:
   - Use Glob to find all `.md` files in the selected scope(s)
   - Create a comprehensive list of all commands including their paths

2. **Analyze Current State**:
   - For each command, analyze:
     - Current name and location
     - Whether it follows lowercase-hyphenated convention
     - Whether it uses namespacing appropriately
     - Whether the name clearly indicates action vs. analysis
     - YAML frontmatter completeness
     - Tool permission appropriateness

3. **Parallel Analysis for Large Sets**:
   - If analyzing 5+ commands, use parallel processing:
   ```
   Use Task tool with subagent_type: 'cmd-commands-normalize-analyzer'
   - Process up to 10 commands in parallel
   - Each analyzer examines naming, structure, and conventions
   - Aggregate results for comprehensive analysis
   ```

4. **Identify Patterns**:
   - Read existing organizational philosophy from CLAUDE.md
   - Identify command groupings by functional domain/scope (not by action)
   - Map commands to established domains: implan, docs, git, memory, subagents, commands
   - Note any consistent patterns that work well

## Phase 3: Planning

1. **Apply Documented Normalization Philosophy**:
   Use the established philosophy from CLAUDE.md:
   ```
   NAMING PHILOSOPHY (from CLAUDE.md):
   - Namespace by functional domain/scope: Folders represent the area of work, not the action
   - Clear action-oriented names: Commands within namespaces start with action verbs
   - Domain-focused organization: Group by what you're working with, not what you're doing
   - Logical scope separation: Each namespace represents a distinct domain of functionality
   
   ESTABLISHED FUNCTIONAL DOMAINS:
   - implan:* - Implementation plans and project execution
   - docs:* - Documentation capture and management
   - git:* - Version control and repository management
   - memory:* - Learning capture and long-term memory management
   - subagents:* - Managing and reviewing subagents
   - commands:* - Managing the Claude command system itself
   ```

2. **Create Detailed Plan**:
   Generate a table showing:
   ```
   | Current Name | Proposed Name | Reason | Type of Change |
   |--------------|---------------|---------|----------------|
   | /commit-and-push | /git:commit-and-push | Group git domain operations | Move to git namespace |
   | /create-implan | /implan:create | Group implementation plan domain | Move to implan namespace |
   | /learn | /memory:learn | Group memory management domain | Move to memory namespace |
   ```

3. **Identify Documentation Updates**:
   - List all files that reference the commands to be renamed
   - Include: README.md, CLAUDE.md, other commands, agents

4. **Present the Plan**:
   ```
   ## NORMALIZATION PLAN
   
   ### Philosophy:
   [Explain the organizational philosophy]
   
   ### Proposed Changes:
   [Show the detailed table of changes]
   
   ### Documentation Updates Required:
   [List all files that need updating]
   
   ### Rationale:
   [Explain why these changes improve the command structure]
   ```

## Phase 4: Approval and Refinement

1. **Request User Approval**:
   ```
   Please review the normalization plan above.
   - Type 'approve' to proceed with all changes
   - Type 'modify' to provide additional directives
   - Type 'selective' to approve specific changes only
   - Type 'cancel' to abort
   ```

2. **Handle User Response**:
   - If "modify": Ask for specific guidance and regenerate plan
   - If "selective": Ask which changes to apply
   - If "approve": Proceed to execution
   - If "cancel": Exit gracefully

3. **Incorporate Feedback**:
   - Adjust philosophy based on user input
   - Regenerate plan if needed
   - Ensure user is satisfied before proceeding

## Phase 5: Execution

1. **Create Backup List**:
   - Document all original paths for potential rollback
   - Note: Git version control provides safety

2. **Execute Renamings and Moves**:
   - For each approved change:
     - Create new directory structure if needed
     - Move/rename the command file
     - Verify file moved successfully

3. **Update Documentation**:
   - Use MultiEdit to update all references in:
     - README.md
     - CLAUDE.md
     - Any other commands that reference renamed commands
     - Any agents that reference renamed commands
   - Ensure all references are updated consistently

4. **Run Optimization (if requested)**:
   - If mode is "full-optimization":
   ```
   For each normalized command:
   - Use Task tool with subagent_type: 'command-optimizer'
   - Optimize the command according to best practices
   - Apply recommended improvements
   ```

5. **Verify Changes**:
   - Confirm all files moved successfully
   - Verify no broken references remain
   - Check that command structure is consistent

## Phase 6: Reporting

1. **Generate Summary Report**:
   ```
   ## NORMALIZATION COMPLETE
   
   ### Changes Applied:
   - [X] Renamed N commands
   - [X] Created M namespaces
   - [X] Updated P documentation files
   - [X] Optimized Q commands (if applicable)
   
   ### Command Structure:
   [Show new organization tree]
   
   ### Documentation Updated:
   [List all updated files]
   
   ### Next Steps:
   - Test renamed commands to ensure they work
   - Run /commands:validate to verify integrity (if exists)
   - Consider creating additional namespaces for new commands
   ```

2. **Provide Testing Guidance**:
   - Suggest testing key commands
   - Remind to commit changes to git
   - Note any commands that may need manual verification

## Best Practices to Enforce

Based on resources/slash_commands_best_practices_research.md:

1. **Single Responsibility Principle**: Each command should do one thing well
2. **Clear Action vs. Analysis**: Names should indicate whether they modify or just analyze
3. **Domain-Based Grouping**: Commands working with the same functional domain should share namespaces
4. **Tool Groupings**: Ensure commands have appropriate tool permissions
5. **Anti-pattern Detection**: Identify monolithic commands that should be split

## Error Handling

- If a file move fails, log it and continue with others
- If documentation update fails, note it for manual intervention
- If optimization fails, log but don't block the normalization
- Provide clear error messages for any issues encountered

## Important Notes

- Always preserve git history by using git mv when possible
- Respect existing good patterns even if they differ from defaults
- Prioritize clarity and consistency over rigid rules
- Ensure all changes are reversible through version control