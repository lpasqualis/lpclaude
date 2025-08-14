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

### 1. Load and Analyze Manifest
- Read `resources/knowledge-base-manifest.json` (create if doesn't exist)
- Extract lists of tracked components by type
- Identify documentation resources vs implementation components

#### Scan for New Components
Scan directories for files not yet in manifest:
- Check `agents/` directory against manifest's agent entries
- Check `commands/` directory against manifest's command entries  
- Check `resources/` directory against manifest's resource entries

#### Automatic Knowledge Detection
For each file not in manifest, analyze content to determine if it contains embedded Claude Code knowledge:

**Indicators of embedded knowledge:**
- References to YAML frontmatter requirements (e.g., "must include name and description")
- Tool permission rules (e.g., "always include Read with Write")
- Model selection heuristics (e.g., "use haiku for simple tasks")
- Best practice enforcement (e.g., "commands cannot have model field")
- Template generation for commands/agents
- Validation rules for Claude Code components
- Documentation about Claude Code architecture

**Classification:**
- **Has embedded knowledge**: Contains (or SHOULD contain but is lacking) specific rules, requirements, or patterns about Claude Code
- **No embedded knowledge**: Pure functionality without Claude Code-specific rules
- **Already tracked**: Present in manifest with accurate knowledge areas
- **Needs update**: In manifest but knowledge areas have changed

Automatically update the manifest with any newly discovered components or changed knowledge areas.

### 2. Analyze Local Resource Documentation
**CRITICAL STEP**: Read and analyze the local resource documentation to establish baseline knowledge.

**IMPORTANT**: You MUST actually READ these files using the Read tool, not just reference them!

From the manifest (`resources/knowledge-base-manifest.json`):
1. **Filter for documentation components**: Find all entries where `type` is "documentation"
2. **Read each documentation file**: Use the Read tool on each file path found
3. **Process dynamically**: Don't assume which files exist - use only what's in the manifest

For each resource document found and read:
1. **Extract key knowledge patterns** based on its declared `knowledge_areas`:
   - YAML frontmatter requirements and restrictions
   - Tool permission best practices and groupings
   - Model selection guidelines
   - Parallelization patterns and limits
   - Naming conventions and anti-patterns
   - Proactive invocation triggers
   - Command vs subagent architectural decisions
   - General best practices
   - Features and capabilities that could be used for maximum benefit
2. **Build a comprehensive baseline** of current best practices
3. **Create a knowledge map** showing which patterns are documented where

This baseline becomes the authoritative reference for validating all components.

### 3. Fetch Latest Documentation
Read the official sources from `resources/knowledge-base-manifest.json` and use WebFetch to retrieve current best practices from each source using their specified check queries.

### 4. Compare and Analyze Components

Read the components list from `resources/knowledge-base-manifest.json` and perform three-way analysis:

For each component in the manifest:
1. **Read the actual component file** using its `path` field
2. **Compare against local resource documentation baseline**:
   - Match component's `knowledge_areas` with resource documentation coverage
   - Verify it follows patterns documented in resources with matching knowledge areas
   - Check implementation against all applicable best practices from the baseline
   - Validate consistency with the component's declared `type` and `description`
3. **Cross-reference with fetched official documentation** for updates

Specifically check for:
- **Against Local Resources**:
  - Components not following documented best practices
  - Missing implementation of documented patterns
  - Deviations from established conventions
  - Opportunities to apply documented optimizations or features
- **Against Official Documentation**:
  - New features not yet in local resources
  - Deprecated patterns still in local documentation
  - Breaking changes affecting current implementations
- **Consistency Issues**:
  - Discrepancies between what's documented locally vs implemented
  - Conflicts between local resources and official docs
  - Components using outdated patterns from either source

### 5. Generate Update Report

Create a comprehensive report and save it to `knowledge-base-reports/` folder with timestamp:

**Report Location**: `knowledge-base-reports/update-report-YYYY-MM-DD-HHMMSS.md`

First ensure the reports directory exists:
```bash
mkdir -p knowledge-base-reports
```

Then create the report showing:

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

#### Local Resources Analysis
```markdown
### Resource Documentation Baseline
- Resources analyzed: [list of resource files]
- Key patterns extracted: [number]
- Best practices identified: [number]

### Knowledge Coverage Map
- YAML Frontmatter: [source documents]
- Tool Permissions: [source documents]
- Parallelization: [source documents]
- Model Selection: [source documents]
- Naming Conventions: [source documents]
```

```markdown
## Knowledge Base Update Report

### Last Check
- Date: [timestamp]
- Documentation Version: [if available]

### Components Analyzed
- [List of files checked]

### Local vs Implementation Consistency
#### Components Not Following Local Best Practices
- Component: [file]
  Local Resource: [which resource document]
  Best Practice: [what should be done]
  Current Implementation: [what is actually done]
  Action Required: [specific fix]

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

Save the complete report to the timestamped file in `knowledge-base-reports/`.

### 6. Synchronize Local Resources

**CRITICAL STEP**: Update local resource documentation to incorporate discoveries from official documentation and maintain currency with Claude Code evolution.

#### Resource Update Strategy

**Identify Update Opportunities:**
1. **Enhancement Gaps**: New features not yet documented in local resources
   - @-mention support and typeahead completion
   - Enhanced argument-hint field usage patterns
   - Model customization capabilities per command/agent
   - Bash output integration patterns

2. **Pattern Evolution**: Discoveries from component analysis
   - New UX optimization patterns from advanced commands
   - Workflow orchestration innovations from complex implementations  
   - Job-based improvement patterns from automated systems
   - Architecture patterns from sophisticated multi-agent systems

3. **Best Practice Refinements**: Updated guidance based on official changes
   - YAML frontmatter requirements and restrictions
   - Tool permission grouping recommendations
   - Security and performance optimization guidelines
   - Naming convention updates and domain organization

#### Implementation Approach

**Update Existing Resources:**
```markdown
For each resource file in resources/:
1. Read current content and identify sections needing updates
2. Add new subsections for 2025 features and enhancements
3. Update examples and code snippets to reflect latest syntax
4. Add cross-references to related patterns in other resources
5. Mark deprecated patterns with clear migration guidance
```

**Create New Resource Documentation:**
```markdown
When discoveries warrant new dedicated documentation:
1. Create focused resource files for significant new pattern areas
2. Follow established documentation structure and tone
3. Include comprehensive examples and implementation guidance
4. Reference existing resources to create knowledge web
5. Add to knowledge-base-manifest.json with appropriate knowledge areas
```

**Quality Assurance for Resource Updates:**
- **Consistency Check**: Ensure new content aligns with existing tone and structure
- **Cross-Reference Validation**: Verify all links and references work correctly
- **Example Verification**: Test that all code examples and patterns are current and functional
- **Knowledge Gap Analysis**: Confirm updates address identified gaps from analysis phase

#### Specific Update Actions

**For `resources/slash_commands_best_practices_research.md`:**
- Add section on @-mention support with typeahead completion (version 1.0.62)
- Enhance argument-hint field documentation with best practice examples
- Update model customization section with per-command optimization patterns
- Include bash output integration patterns for context-aware commands

**For `resources/subagent_invocation_research.md`:**
- Update @-mentioning section with typeahead functionality details
- Add enhanced proactive invocation patterns based on component analysis
- Include semantic color usage for improved agent organization
- Document latest model selection heuristics for different agent types

**For `resources/commands_and_agents.md` and `resources/understanding_commands_and_subagents.md`:**
- Integrate findings from advanced component analysis
- Add orchestration patterns discovered from complex implementations
- Update parallel execution guidance with system constraint awareness
- Include job-based workflow patterns for automated improvement systems

**Create New Resources (if warranted):**
- `resources/ux_optimization_patterns.md`: Document UX patterns from README audit and similar commands
- `resources/job_workflow_patterns.md`: Document automated improvement and job orchestration patterns  
- `resources/advanced_architecture_patterns.md`: Document sophisticated multi-agent system designs

### 7. Apply Updates (Optional)

If user confirms, apply the updates:
- **Update Components**: Edit optimizer agents and commands to reflect new best practices
- **Update Local Resources**: Apply the resource synchronization strategy defined in Step 6
- **Synchronize Knowledge**: Ensure consistency between resources and implementations
- **Update Manifest**: Record all changes with timestamps

### 8. Update Manifest

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