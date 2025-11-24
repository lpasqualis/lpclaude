---
description: Create new Claude Code skills with best practices and proper directory structure
argument-hint: "[description of what the skill should do] (skill name optional - can be embedded in description or will be generated)"
allowed-tools: Read, Write, Edit, LS, Glob, Grep, Bash(mkdir:*)
---

## Skill Creation Process

Parse the user's input to extract:
1. **Skill description**: What capability the skill should provide
2. **Skill name**: Extract from patterns like "called [name]", "named [name]", or generate from description (lowercase-hyphenated)
3. **Scope**: Default to project-local (`.claude/skills/`) unless "global", "personal", or "all projects" mentioned

## Requirements Analysis

From the description, determine:
- Core capability and when Claude should use it
- Whether tool restrictions are appropriate (`allowed-tools`)
- Supporting files needed based on keywords:
  - "reference", "documentation", "docs" → `reference.md`
  - "examples", "samples" → `examples.md`
  - "scripts", "automation", "utilities" → `scripts/` directory with placeholder
  - "templates", "boilerplate" → `templates/` directory with placeholder

## Skill Structure

Skills are directories containing a `SKILL.md` file plus optional supporting resources:

```
skill-name/
|-- SKILL.md           (required - main instructions)
|-- reference.md       (optional - detailed documentation)
|-- examples.md        (optional - usage examples)
|-- scripts/           (optional - utility scripts)
|   |-- README.md      (placeholder explaining purpose)
|-- templates/         (optional - reusable templates)
    |-- README.md      (placeholder explaining purpose)
```

## SKILL.md Format

```yaml
---
name: skill-name
description: What it does AND when Claude should use it (critical for discovery)
allowed-tools: Tool1, Tool2  # Optional - only include if restrictions needed
---

# Skill Name

## Overview
Brief explanation of the skill's purpose and value.

## Instructions
Step-by-step guidance for Claude when this skill is active.

## When to Use
Specific triggers and contexts where this skill applies.

## References
Links to supporting files if they exist.
```

## Description Quality Guidelines

The `description` field is critical for Claude's automatic discovery. A good description:

**Includes WHAT the skill does:**
- "Extract text and tables from PDF files, fill forms, merge documents"
- "Analyze Excel spreadsheets, create pivot tables, generate charts"

**Includes WHEN to use it:**
- "Use when working with PDF files or when the user mentions PDFs, forms, or document extraction"
- "Use when working with Excel files, spreadsheets, or analyzing tabular data"

**Bad examples (too vague):**
- "Helps with documents" (what kind? when?)
- "Data processing" (too generic)
- "Useful utility" (meaningless)

## Tool Restriction Guidance

Only add `allowed-tools` when the skill should be limited:

**Read-only skills:**
```yaml
allowed-tools: Read, Grep, Glob
```

**Analysis skills (no file modification):**
```yaml
allowed-tools: Read, Grep, Glob, Bash(git log:*), Bash(git diff:*)
```

**Omit `allowed-tools`** for skills that need full capabilities - Claude will ask for permission as normal.

## Implementation Steps

1. **Analyze Requirements**: Determine skill purpose, scope, and supporting files needed
2. **Validate Name**: Ensure lowercase letters, numbers, and hyphens only (max 64 chars)
3. **Create Directory Structure**:
   ```bash
   mkdir -p [scope]/skills/[skill-name]
   ```
4. **Generate SKILL.md**: Write main skill file with quality description
5. **Create Supporting Files**: Based on detected keywords, create placeholder files
6. **Validate Description**: Check that description includes both WHAT and WHEN
7. **Report Creation**: Provide summary including:
   - Skill name and location
   - Files created
   - Tool restrictions (if any)
   - Description quality assessment
   - **Reminder to restart Claude Code**

## Supporting File Templates

### reference.md
```markdown
# [Skill Name] Reference

## Detailed Documentation

[Add comprehensive reference material here]

## API/Tool Reference

[Add relevant API documentation or tool references]

## Best Practices

[Add domain-specific best practices]
```

### examples.md
```markdown
# [Skill Name] Examples

## Basic Usage

[Add simple examples]

## Advanced Usage

[Add complex examples with explanations]

## Common Patterns

[Add frequently used patterns]
```

### scripts/README.md
```markdown
# Scripts

This directory contains utility scripts for the [skill-name] skill.

## Available Scripts

- Add your scripts here

## Usage

Describe how Claude should use these scripts.
```

### templates/README.md
```markdown
# Templates

This directory contains reusable templates for the [skill-name] skill.

## Available Templates

- Add your templates here

## Usage

Describe how Claude should use these templates.
```

## Best Practices

- **Focus on discovery**: Write descriptions that help Claude find the skill when relevant
- **Be specific**: One clear capability per skill
- **Include triggers**: Mention keywords users would say that should activate this skill
- **Progressive disclosure**: Put detailed info in supporting files, not SKILL.md
- **Test discovery**: After creation, ask Claude questions that should trigger the skill

## Post-Creation Checklist

After creating the skill, remind the user:
1. Restart Claude Code to load the new skill
2. Test discovery by asking relevant questions
3. Refine description if Claude doesn't find it when expected
4. Add content to placeholder files as needed

## User's Skill Request

$ARGUMENTS
