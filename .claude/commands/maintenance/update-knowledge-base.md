---
name: /maintenance:update-knowledge-base
description: Fetches latest Claude Code documentation and identifies components that need updating based on changes in best practices
argument-hint: "[force] (optional, to force update even if recently checked)"
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, WebFetch, WebSearch, Bash
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-19 -->

Maintain the accuracy of embedded Claude Code best practices across optimizer agents, commands, and resource documentation.

## Purpose

This command keeps the framework current with Claude Code evolution by:
1. Discovering and cataloging components with embedded knowledge
2. Establishing baseline from local resource documentation
3. Fetching latest official documentation for comparison
4. Generating comprehensive update report
5. Optionally applying updates to maintain consistency

## Analysis Phase

### 1. Component Discovery and Manifest Management

Read `resources/knowledge-base-manifest.json` and scan for untracked components:
- Scan `agents/`, `commands/`, and `resources/` directories
- Compare against manifest entries to find new files
- Analyze each new file for embedded Claude Code knowledge

Indicators of embedded knowledge:
- YAML frontmatter requirements and restrictions
- Tool permission patterns and groupings
- Model selection heuristics
- Command/agent best practices
- Template generation logic
- Validation rules for components
- Architecture documentation
- Claude Code features and limitations

Classification outcomes:
- Has embedded knowledge → Add to manifest with knowledge areas
- Pure functionality → Skip (no tracking needed)
- Already tracked → Verify knowledge areas still accurate
- Needs update → Flag for knowledge area updates

Update manifest with discoveries before proceeding.

**Note**: Manifest structure (post-cleanup):
- `metadata`: Basic tracking info and timestamps
- `official_sources`: Claude Code documentation URLs with check queries
- `components_with_embedded_knowledge`: All tracked components
- `pending_updates`: Current update queue (typically empty)
- Historical data is maintained in `knowledge-base-reports/` directory

### 2. Establish Local Knowledge Baseline

From manifest, filter for documentation components (`type: "documentation"`) and read each file to:
- Extract knowledge patterns based on declared knowledge areas
- Identify redundant or overlapping content between resources
- Note outdated examples or deprecated patterns
- Find gaps in documentation coverage
Build comprehensive baseline mapping patterns to source documents.

### 3. Fetch Official Documentation

Use manifest's `official_sources` array (now at top of manifest) with WebFetch to retrieve current Claude Code best practices using specified check queries for each source.

### 4. Three-Way Component Analysis

For each component in manifest:
1. Read component file using its path
2. Compare against local baseline (verify adherence to documented patterns)
3. Cross-reference with official documentation (identify updates)

Check for:
- Deviations from local best practices
- New features in official docs not yet locally documented
- Deprecated patterns still in use
- Consistency issues between documentation and implementation

## Reporting Phase

### 5. Generate Comprehensive Update Report

Create directory and save report with timestamp:
```bash
mkdir -p knowledge-base-reports
```

Save to: `knowledge-base-reports/update-report-YYYY-MM-DD-HHMMSS.md`

Report structure:
```markdown
# Knowledge Base Update Report
Date: [timestamp]

## Component Discovery
- Files scanned: [number]
- New components with embedded knowledge: [list with knowledge areas]
- Components without embedded knowledge: [list]
- Manifest updates applied: [count]

## Knowledge Baseline Summary
- Resource documents analyzed: [list]
- Knowledge patterns mapped: [count by category]

## Analysis Results

### Resource Documentation Health
- Redundant content found: [list overlapping resources]
- Outdated patterns: [list deprecated content]
- Documentation gaps: [list missing coverage areas]
- Consolidation opportunities: [resources that should be merged]

### Compliance Issues
[Components not following local best practices]
- Component: [file]
  Issue: [deviation from best practice]
  Source: [which resource document]
  Fix: [specific correction needed]

### Update Priorities

**High Priority (Breaking Changes)**
- [Component]: [change description and impact]

**Medium Priority (New Features)**
- [Component]: [new capability to leverage]

**Low Priority (Optimizations)**
- [Component]: [enhancement opportunity]

## Recommended Actions
1. Resource consolidation: [specific merge recommendations]
2. Documentation updates: [what needs updating]
3. Component fixes: [specific corrections needed]
4. New documentation: [genuinely new pattern areas]
```

## Update Phase

### 6. Review and Confirm Updates

Present report to user and await confirmation before proceeding with any changes.

### 7. Apply Updates (if confirmed)

Apply updates systematically:

1. **Update Components**: Modify agents/commands with new best practices

2. **Consolidate and Update Resource Documentation**:
   - Review existing resource files for outdated information
   - Rename updated documents using format: `YYYY-MM-DD_VXXX_filename.md`
     * YYYY-MM-DD: Date of update
     * XXX: Incremental version (001, 002, etc.)
     * Example: `2025-08-19_V001_slash_commands_best_practices_research.md`
   - Use `git mv` to rename files (preserves history)
   - Update all references to point to new versioned filenames
   - Merge redundant documentation into unified resources
   - Update with new patterns discovered from:
     * Official Claude Code documentation changes
     * Patterns emerging from component analysis
     * Best practices learned from implementation review
   - Ensure cross-references between resources remain valid
   - Delete obsolete documentation (git preserves history)
   - Create new resource files only for genuinely new pattern domains
   
3. **Synchronize Knowledge**: 
   - Ensure consistency between resource docs and actual implementations
   - Update embedded knowledge in optimizers to match resource updates
   - Verify all components reference current best practices

4. **Update Manifest**: 
   - Update metadata timestamps (last_check, documentation_version)
   - Add new components to components_with_embedded_knowledge array
   - Update file paths to reflect new versioned names (if applicable)
   - Note: Historical changes are tracked in knowledge-base-reports/, not manifest

## Usage

```bash
# Regular quarterly maintenance
/maintenance:update-knowledge-base

# Force update (skip time checks)
/maintenance:update-knowledge-base force
```

## Guidelines

- Only flag significant functional changes
- Preserve local customizations and enhancements
- Maintain update history in manifest
- Test components after applying updates

## Related Files

- Manifest: `resources/knowledge-base-manifest.json`
- Reports: `knowledge-base-reports/`
- Optimizers: `agents/command-optimizer.md`, `agents/subagent-optimizer.md`
- Resources: `resources/` directory