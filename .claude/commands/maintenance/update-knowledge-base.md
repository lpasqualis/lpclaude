---
name: /maintenance:update-knowledge-base
description: Fetches latest Claude Code documentation and identifies components that need updating based on changes in best practices
argument-hint: "[force] (optional, to force update even if recently checked)"
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, WebFetch, WebSearch, Bash
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-07 17:24:15 -->

Update the embedded Claude Code knowledge across all optimizer agents, commands, and resource documentation.

## Purpose

This command maintains the accuracy of embedded Claude Code best practices throughout the codebase by:
1. Fetching the latest official documentation
2. Comparing with embedded knowledge in various components
3. Identifying what needs updating
4. Optionally applying updates automatically

## Process

### 1. Comprehensive Component Analysis
- Read `resources/knowledge-base-manifest.json` if it exists
- Scan ALL files in `agents/`, `commands/`, and `resources/` directories

#### Automatic Knowledge Detection
For each file, analyze content to determine if it contains embedded Claude Code knowledge:

**Indicators of embedded knowledge:**
- References to YAML frontmatter requirements (e.g., "must include name and description")
- Tool permission rules (e.g., "always include Read with Write")
- Model selection heuristics (e.g., "use haiku for simple tasks")
- Best practice enforcement (e.g., "commands cannot have model field")
- Template generation for commands/agents
- Validation rules for Claude Code components
- Documentation about Claude Code architecture

**Classification:**
- **Has embedded knowledge**: Contains specific rules, requirements, or patterns about Claude Code
- **No embedded knowledge**: Pure functionality without Claude Code-specific rules
- **Already tracked**: Present in manifest with accurate knowledge areas
- **Needs update**: In manifest but knowledge areas have changed

Automatically update the manifest with any newly discovered components or changed knowledge areas.

### 2. Fetch Latest Documentation
Read the official sources from `resources/knowledge-base-manifest.json` and use WebFetch to retrieve current best practices from each source using their specified check queries.

### 3. Analyze Components with Embedded Knowledge

Read the components list from `resources/knowledge-base-manifest.json` and analyze each component based on its type and knowledge areas.

For each component, check for:
- Outdated requirements or patterns
- Missing new best practices
- Deprecated patterns still being enforced
- Inconsistencies with latest documentation

### 4. Generate Update Report

Create a comprehensive report showing:

#### Component Discovery Results
```markdown
### Component Analysis Summary
- Total files scanned: [number]
- Components with embedded knowledge: [number]
- Newly discovered: [number]
- Already tracked: [number]
- No embedded knowledge: [number]

### Newly Discovered Components
[Automatically added to manifest]
- [file path]
  Knowledge areas: [detected areas]
  Evidence: [specific quotes showing embedded knowledge]

### Components Without Embedded Knowledge
[These don't need tracking]
- [file path] - Pure functionality component
```
```markdown
## Knowledge Base Update Report

### Last Check
- Date: [timestamp]
- Documentation Version: [if available]

### Components Analyzed
- [List of files checked]

### Updates Needed
#### High Priority (Breaking Changes)
- Component: [file]
  Current: [existing knowledge]
  Updated: [new requirement]
  Impact: [what breaks if not updated]

#### Medium Priority (New Features)
- Component: [file]
  Addition: [new best practice]
  Benefit: [why to add]

#### Low Priority (Deprecations)
- Component: [file]
  Deprecated: [old pattern]
  Replacement: [new pattern]

### Recommended Actions
1. [Specific update instructions]
```

### 5. Apply Updates (Optional)

If user confirms, apply the updates:
- Edit optimizer agents to reflect new best practices
- Update resource documentation
- Update the knowledge manifest with new timestamps

### 6. Update Manifest

Save/update `resources/knowledge-base-manifest.json`:
```json
{
  "last_check": "2025-08-07T16:00:00Z",
  "documentation_version": "...",
  "components": [
    {
      "path": "agents/command-optimizer.md",
      "last_updated": "2025-08-07T16:00:00Z",
      "knowledge_areas": ["slash-commands", "yaml-frontmatter"]
    }
  ],
  "findings": {
    "updates_applied": [...],
    "pending_updates": [...]
  }
}
```

## Usage Patterns

### Regular Maintenance
Run quarterly or when Claude Code announces updates:
```
/maintenance:update-knowledge-base
```

### Force Update
Skip time-based checks and force a fresh analysis:
```
/maintenance:update-knowledge-base force
```

### After Major Updates
When Claude Code has a major release:
1. Run this command to identify changes
2. Review the report
3. Apply updates systematically
4. Test affected components

## Guidelines

- **Conservative Updates**: Only flag significant changes that affect functionality
- **Preserve Customizations**: Don't overwrite local enhancements to best practices
- **Track History**: Maintain record of what changed and when
- **Test After Updates**: Verify optimizers still work correctly after knowledge updates

## Related Components

- **Optimizers**: `command-optimizer`, `subagent-optimizer`
- **Resources**: Documentation in `resources/` directory
- **Manifest**: `resources/knowledge-base-manifest.json`