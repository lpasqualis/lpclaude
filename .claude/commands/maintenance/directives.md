---
name: /maintenance:directives
description: Analyze, optimize, and reorganize directive files for consistency and clarity
argument-hint: [--fix-all] [--scope all|numbered|named]
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, Bash, Task
disable-model-invocation: true
---

# Directive Files Maintenance

Perform comprehensive analysis and optimization of directive files in the `directives/` folder.

## Execution Steps

Parse $ARGUMENTS for options:
- `--fix-all`: Automatically apply all recommended fixes without waiting for approval
- `--scope all|numbered|named`: Process all files, only numbered (XXXX_*.md), or only named files
- Default behavior (no flags): Analyze, report issues, and wait for user guidance on what to fix

### Phase 1: Discovery and Analysis

List all directive files in `/Users/lpasqualis/.lpclaude/directives/`:
- Identify numbered files (XXXX_*.md pattern)
- Identify named files (non-numbered .md files)
- Skip CLAUDE_global_directives.md (generated file)

### Phase 2: Content Analysis

For each directive file, AND across directive files, analyze:

**Redundancy Detection:**
- Identify duplications across files
- Find conceptual overlaps (similar rules expressed differently)
- Detect partial redundancies (rules covering subset of another)

**Consistency Checks:**
- Grammar and spelling errors
- Inconsistent terminology or phrasing
- Overuse of emphasis (CRITICAL, MUST, ALWAYS, NEVER)
- Violations of "Avoid Overstatement" principle
- Verbosity
- Opportunities to simplify and consolidate

**Structure Validation:**
- Proper markdown formatting
- Clear section headers
- Logical content grouping
- Title matches file name intent

**Self-Compliance:**
- Ensure directives follow their own rules
- Check for violations of core principles
- Verify adherence to style guidelines

### Phase 3: Naming and Numbering Analysis

**File Naming:**
- Verify descriptive names match content
- Identify misleading or vague names
- Suggest clearer alternatives

**Numbering Scheme:**
- Check for gaps or clustering in number sequence
- Propose optimal renumbering (10, 20, 30... spacing)
- Maintain logical ordering by importance/dependency

### Phase 4: Optimization Recommendations

Generate comprehensive report with:
1. **Redundancies Found** - Specific duplications with file:line references
2. **Inconsistencies** - Grammar, style, or principle violations
3. **Naming Issues** - Current vs suggested names
4. **Reorganization Plan** - Consolidation and restructuring proposals
5. **Priority Actions** - Ranked by impact

### Phase 5: Implementation

If `--fix-all` specified OR after user approves specific fixes:

**Consolidation:**
- Merge redundant content into appropriate files
- Delete obsolete files after merging
- Update cross-references

**Corrections:**
- Fix grammar and spelling errors
- Standardize terminology
- Remove excessive emphasis

**Renaming:**
- Apply new file names
- Update numbering scheme
- Maintain git history with mv commands

**Cleanup:**
- Remove empty sections
- Consolidate related content
- Ensure consistent formatting

### Phase 6: Rebuild and Verify

After all changes:
- Run `./rebuild_claude_md.sh` to regenerate global directives
- Report file size changes and reduction percentage
- Verify no content was accidentally lost

## Output Format

Present results as structured report:

```
=== DIRECTIVE FILES MAINTENANCE REPORT ===

Files Analyzed: X
Mode: [analysis|fix-all]

REDUNDANCIES:
- [Description]: Found in file1.md:L1, file2.md:L2
  Recommendation: [Consolidate into file1.md]

INCONSISTENCIES:
- [file.md:L]: [Issue description]
  Fix: [Proposed correction]

NAMING/NUMBERING:
- Current: 0300_hygene.md
  Proposed: 0100_temp_files.md
  Reason: Accurate description of content

SUMMARY:
- Redundancies found: X
- Inconsistencies: Y
- Files to rename: Z
- Estimated reduction: X%

[If not --fix-all]:
OPTIONS:
1. Apply all fixes: Re-run with --fix-all
2. Apply specific fixes: [Provide instructions on which fixes to apply]
3. Skip: [Continue without changes]

What would you like to do?
```

## Constraints

- Preserve all unique content - never lose information
- Maintain logical flow and readability
- Keep local (.local.md) files separate
- Don't modify CLAUDE_global_directives.md directly
- Create backup before major changes if requested
- Respect existing organizational patterns

Execute this comprehensive directive maintenance workflow to ensure optimal organization and clarity.

$ARGUMENTS