---
name: learn
description: Extract critical insights from the current session and add only the most valuable, durable learnings to CLAUDE.md
allowed-tools: Read, Write, Edit, LS, Glob, Grep, Task
argument-hint: [specific focus area (optional)]
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-21 11:57:38 -->

Analyze the current conversation to identify critical insights that should be preserved in CLAUDE.md. Focus on extracting only the most valuable discoveries that meet strict quality criteria.

**CRITICAL PRINCIPLE**: This command should add minimal, high-value content to CLAUDE.md. Quality over quantity - prefer capturing 1-2 truly valuable insights over comprehensive documentation.

## Quality Gates - All Must Be Met

**Before adding any insight to CLAUDE.md, it MUST meet ALL criteria:**

1. **High Impact**: Would save significant time or prevent major issues in future sessions
2. **Non-obvious**: Not easily discoverable through documentation or standard practices  
3. **Durable**: Relevant across multiple future sessions, not session-specific
4. **Actionable**: Clear enough to guide future decision-making without additional context
5. **Generalizable**: Applies broadly, not tied to specific implementation details
6. **Project-relevant**: Directly applicable to this codebase/project type

**EXCLUDE entirely**:
- Routine operations or standard procedures
- Temporary project states or configurations
- Information easily found in documentation
- Session-specific troubleshooting steps
- Obvious conclusions or expected behaviors
- Implementation details that change frequently

## Execution Process

### Step 1: Load CLAUDE.md Best Practices
Fetch current guidelines to ensure additions align with best practices:
- WebFetch https://www.anthropic.com/engineering/claude-code-best-practices for structure guidelines
- WebFetch https://docs.anthropic.com/en/docs/claude-code/memory for scope and content guidelines
- Extract what belongs in CLAUDE.md vs external documentation

### Step 2: Focused Analysis
Using the fetched best practices as guidance, scan the conversation for insights that meet ALL quality gates above. Look specifically for:

- **Critical architectural constraints** discovered through trial and error
- **Non-obvious tool behaviors** that caused issues or enabled solutions
- **Configuration gotchas** that aren't documented but are essential
- **Workflow patterns** that proved unexpectedly effective
- **Integration insights** about how components interact in unexpected ways

Ensure findings align with what the best practices indicate belongs in CLAUDE.md.

### Step 3: CLAUDE.md Best Practices Validation
Read the current CLAUDE.md to understand:
- Existing organizational structure and conventions
- Current directive categories and formatting
- Tone and specificity level of existing content
- Areas where new insights would fit naturally

**Validation Requirements**:
- New content must match existing structure and tone
- Must not duplicate or contradict existing directives
- Should integrate seamlessly into appropriate sections
- Must follow established formatting patterns

### Step 4: Minimal Addition Strategy
For each insight that passes all quality gates:
- Write in concise, directive style matching existing CLAUDE.md tone
- Place in the most appropriate existing section
- Use clear, actionable language without unnecessary explanation
- Include only essential context

### Step 5: Storage with Memory-Keeper
Use Task tool with memory-keeper agent to add validated insights:
- Provide the specific text to add and target section
- Request confirmation of successful integration
- Verify CLAUDE.md structure remains intact

## Success Metrics
A successful execution should result in:
- **0-3 new lines** added to CLAUDE.md (not paragraphs - individual directive lines)
- Each addition provides clear, actionable guidance
- No redundancy with existing content
- Improved clarity for future sessions without bloating the file

**Remember**: The goal is surgical precision, not comprehensive capture. Better to add nothing than to dilute CLAUDE.md with non-essential information.