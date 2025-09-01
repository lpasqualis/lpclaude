---
name: learn
description: Add specific insights to CLAUDE.md or extract learnings from conversation, placing them in the appropriate location
argument-hint: [specific fact to remember (optional)]
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, WebFetch
---

# Learn Command - Intelligent Memory Management

Capture and store critical insights in the appropriate CLAUDE.md file based on scope and relevance.

**Key Principle**: Ensure insights are in clear, directive CLAUDE.md format - rephrase if needed for clarity or consistency.

## Operating Modes

### Mode 1: Specific Fact (with argument)
When you provide a specific fact: `/learn WebFetch fails silently in subagents when rate-limited`
- Ensure the insight is in clear, directive format (rephrase if needed)
- Evaluate against quality gates - reject if fails any
- Determine ideal location (root vs subfolder CLAUDE.md)

### Mode 2: Conversation Analysis (no argument)
When run without arguments: `/learn`
- Analyzes current conversation for valuable insights
- Extracts only the most critical learnings
- Places each in the appropriate CLAUDE.md

## Quality Gates

Before adding an insight, verify it meets these criteria:

1. **High Impact**: Would save significant time or prevent major issues
2. **Non-obvious**: Not easily discoverable through documentation
3. **Durable**: Relevant across multiple sessions, not temporary
4. **Actionable**: Clear enough to guide future decisions
5. **Generalizable**: Applies broadly, not one-off situations
6. **Project-relevant**: Directly applicable to this codebase/project

**Automatically EXCLUDE**:
- Anything that is already in CLAUDE.md (avoid duplicates)
- Routine operations or standard procedures
- Temporary states or configurations
- Information in official documentation
- Session-specific troubleshooting
- Obvious conclusions
- Frequently changing details

## Execution Process

### Step 1: Determine Input Mode
Check if $ARGUMENTS is provided:
- If YES: Process as specific fact (Mode 1)
- If NO: Analyze conversation (Mode 2)

### Step 2: Load Best Practices
Fetch current guidelines to ensure proper placement:
- WebFetch https://www.anthropic.com/engineering/claude-code-best-practices for structure
- WebFetch https://docs.anthropic.com/en/docs/claude-code/memory for scope guidelines
- Extract placement rules for root vs subfolder CLAUDE.md

### Step 3: Extract/Validate Insights

**For Mode 1 (Specific Fact)**:
- Parse the provided fact
- **Refine for CLAUDE.md if needed**:
  - If already clear and directive, keep as-is
  - If casual or unclear, rephrase to be actionable
  - Example: "I found WebFetch breaks in subagents" → "WebFetch operations fail silently in subagents when rate-limited - use alternative approaches"
- Apply all 6 quality gates
- If fails any gate, explain why and don't add

**For Mode 2 (Conversation Analysis)**:
Look for patterns indicating valuable insights:
- "I discovered that..." → potential non-obvious finding
- "The issue was..." → potential gotcha to document
- "Remember that..." → explicit memory request
- Critical architectural constraints discovered
- Non-obvious tool behaviors that caused issues
- Configuration gotchas not in documentation
- Workflow patterns that proved effective
- Unexpected component interactions

### Step 4: Determine Correct Location

Based on scope analysis, determine where each insight belongs:

**Root CLAUDE.md** (`./CLAUDE.md` or project root):
- Project-wide conventions and patterns
- Critical architectural decisions
- Domain-specific terminology
- Key constraints affecting entire project
- Cross-cutting concerns
- Setup requirements for whole project

**Subfolder CLAUDE.md** (e.g., `src/components/CLAUDE.md`):
- Module-specific instructions
- Component-specific patterns
- Directory-specific conventions
- Local implementation details
- Subsystem-specific gotchas
- Package-specific setup requirements

**Decision Process**:
1. Does the insight reference specific directories repeatedly?
2. Is it only relevant when working in a particular subsystem?
3. Would it confuse someone working in other parts of the codebase?
4. If YES to any → Find/create appropriate subfolder CLAUDE.md
5. If NO to all → Use root CLAUDE.md

### Step 5: Check Existing Content

For each target CLAUDE.md:
- Read current content
- Check for contradictions
- Ensure no duplication
- Identify appropriate section
- Verify format consistency

### Step 6: Add Insights

**Format Guidelines**:
- **Directive style preferred**: "Do X when Y" rather than narrative
- **Professional tone**: Technical and clear
- **Actionable**: Include what to do, not just what's wrong
- **Concise**: Maximum 1-3 lines per insight
- **Consistent**: Match existing CLAUDE.md style

**When to rephrase**:
- Casual language: "memory-keeper doesn't work" → "Use /learn command directly - subagents cannot execute slash commands"
- Missing context: "bash breaks with ${var,,}" → "Use `tr '[:upper:]' '[:lower:]'` instead of `${var,,}` for bash 3.2 compatibility"
- Well-formed input can be kept as-is

**If creating new subfolder CLAUDE.md**:
```markdown
# CLAUDE.md - [Module Name] Context

## Module-Specific Conventions
[Add insight here]
```

### Step 7: Report Results

Provide clear feedback:
- What was added (if anything)
- Where it was placed (which CLAUDE.md)
- What was rejected and why
- Total lines added (should be 0-3)

## Success Metrics

A successful execution results in:
- **0-3 lines added** across all CLAUDE.md files
- Each addition is high-value and actionable
- Correct scope-based placement
- No redundancy with existing content
- Improved clarity without bloat

## Error Handling

- No CLAUDE.md found → Create with proper structure
- WebFetch fails → Use embedded knowledge, note limitation
- Contradiction found → Present options, wait for guidance
- All insights fail gates → Report that nothing met criteria

## Examples

### Example 1: Project-wide insight
```
/learn API endpoints need trace IDs for debugging
```
→ Rephrased and added to root CLAUDE.md as: "All API endpoints must include `trace_id` in response headers for cross-service debugging"

### Example 2: Module-specific insight
```
/learn found that components break with CSS modules, use styled-components instead
```
→ Rephrased and added to `src/components/CLAUDE.md` as: "Use styled-components exclusively - CSS modules cause build conflicts in this module"

### Example 3: Conversation extraction
```
/learn
```
→ Analyzes conversation, finds 2 insights:
  - One about build process → root CLAUDE.md
  - One about test utilities → `tests/CLAUDE.md`

Remember: Quality over quantity. Better to add nothing than dilute CLAUDE.md with non-essential information.