---
name: /commands:migration:slashcommand-tool
description: Audit agentic frameworks for outdated SlashCommand tool workarounds and identify migration opportunities
argument-hint: [optional: specific directories or patterns to focus on]
allowed-tools: Read, LS, Glob, Grep, Edit, MultiEdit, Task
disable-model-invocation: true
---

# Audit Framework for SlashCommand Tool Migration Opportunities

Analyze the current project's agentic framework (`.claude/commands/`, `.claude/agents/`, `workers/` and related documentation) to identify outdated patterns from when slash commands couldn't be invoked programmatically. Now that the SlashCommand tool is available, these workarounds should be modernized.

## Phase 1: Discovery and Pattern Detection

### Search for Outdated Documentation Patterns
Use Grep to find documentation mentioning slash command limitations:
- Pattern: `cannot.*invoke.*slash|can't.*execute.*slash|unable.*run.*slash|limitation.*slash.*command`
- Pattern: `load.*slash.*command|read.*command.*definition|parse.*command.*file`
- Pattern: `workaround.*slash|alternative.*to.*slash`
- Search in: `**/*.md`, focusing on CLAUDE.md files, documentation, and command definitions

### Identify Code Workarounds
Search for patterns indicating manual slash command handling:
- Commands that instruct reading from `.claude/commands/` directories
- References to "load the slash command" or "read the command definition"
- Patterns like "follow the instructions in [command].md"
- Code that tries to manually parse YAML frontmatter from command files

### Check Agent/Subagent Configurations
Review agents in `.claude/agents/`:
- Look for agents designed solely to work around slash command limitations
- Identify agents that could be simplified to just use SlashCommand tool
- Find references to "cannot execute slash commands" that need updating

### Analyze Worker Patterns
Examine `workers/` directory for:
- Workers that mention slash command limitations in their instructions
- Complex orchestration patterns designed to avoid slash command invocation
- Workers that could be simplified using SlashCommand tool

## Phase 2: Classification and Impact Analysis

For each finding, classify as:
1. **Documentation Only** - Outdated text that needs correction
2. **Simple Workaround** - Can be directly replaced with SlashCommand tool
3. **Complex Pattern** - Requires careful migration strategy
4. **Architectural Decision** - May have valid reasons beyond the limitation

Create a structured report:
```
## SlashCommand Tool Migration Audit

### Documentation Updates Needed
- [file:line] - Description of outdated claim
  Suggested fix: [updated text]

### Code Patterns to Modernize
- [file:line] - Current workaround pattern
  Migration: Use SlashCommand(command: "/command-name")

### Agents/Workers to Simplify
- [component] - Current complexity
  Simplification: [proposed change]

### Validation Risks
- [pattern] - Why manual review is needed
```

## Phase 3: Generate Migration Tasks

For each identified pattern, create specific migration recommendations:

### For Documentation
- Exact line changes needed
- Consistent messaging about SlashCommand tool availability
- Update execution hierarchy diagrams

### For Code Patterns
- Before/after code examples
- Testing requirements
- Backward compatibility considerations

### For Architectural Changes
- Impact on existing workflows
- Dependencies that need updating
- Performance implications

## Phase 4: Priority Scoring

Score each finding by:
- **Impact**: How much complexity does this remove?
- **Risk**: What could break if changed?
- **Effort**: How difficult is the migration?

Present findings in priority order:
1. High impact, low risk, low effort → Do immediately
2. High impact, higher risk/effort → Plan carefully
3. Low impact → Document for future cleanup

## Output Format

Provide a comprehensive audit report with:
1. **Executive Summary** - Key findings and recommendations
2. **Detailed Findings** - Organized by component type
3. **Migration Plan** - Prioritized list of changes
4. **Risk Assessment** - What to test after changes
5. **Quick Wins** - Changes that can be made immediately

Focus on practical, actionable improvements that leverage the SlashCommand tool to simplify the framework.

$ARGUMENTS