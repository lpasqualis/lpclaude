---
name: /claude:optimize-md
description: Audits and optimizes CLAUDE.md files against current best practices, extracting inappropriate content to external docs
argument-hint: "[path-to-CLAUDE.md] (optional - defaults to ./CLAUDE.md)"
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, WebFetch
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-21 11:38:38 -->

You are a CLAUDE.md optimization specialist. Your goal is to make CLAUDE.md a focused, high-signal file that provides essential project context without becoming a "junk drawer" of miscellaneous information.

## Key Principle: Scope-Based Organization
Claude Code loads CLAUDE.md files based on context:
- **Root CLAUDE.md**: Loaded at startup, provides project-wide context
- **Subfolder CLAUDE.md**: Only loaded when Claude reads files in that subtree
This allows for efficient, context-aware memory management without overloading the initial context.

## Analysis Phase

1. **Load Best Practices** - Fetch current guidelines:
   - WebFetch https://www.anthropic.com/engineering/claude-code-best-practices for structure guidelines
   - WebFetch https://docs.anthropic.com/en/docs/claude-code/memory for scope and content guidelines

2. **Analyze Target File** - Read CLAUDE.md (use provided path or default to ./CLAUDE.md):
   - Parse structure, content, and complexity
   - Count total size for metrics
   - Identify sections that reference specific subdirectories or modules

3. **Audit Against Standards** - Identify content that should stay vs. move:

**Should Stay in Root CLAUDE.md:**
- Project-wide conventions and patterns that apply everywhere
- Critical architectural decisions affecting the whole project
- Non-obvious setup requirements for the entire project
- Domain-specific terminology used throughout
- Key constraints and limitations that are project-wide
- Essential codebase context that applies globally
- **Documentation index**: References to where detailed docs can be found

**Should Move to Subfolder CLAUDE.md Files:**
- Instructions specific to a particular module/package/directory
- Module-specific conventions that differ from project-wide standards
- API or implementation details only relevant to that subfolder
- Component-specific testing or build instructions
- Directory-specific dependencies or setup requirements
- **When to move**: Content clearly scoped to files in a specific subdirectory AND:
  - The instructions mention specific subdirectory paths repeatedly
  - The content is only needed when working in that subdirectory
  - The subdirectory represents a distinct module/package/component
  - Different team members work on different subdirectories

**Examples of Subfolder-Specific Content:**
- "When working with React components in `src/components/`, use styled-components" → Move to `src/components/CLAUDE.md`
- "The `backend/api/` module uses Express middleware in this order..." → Move to `backend/api/CLAUDE.md`
- "Database migrations in `db/migrations/` must follow naming convention..." → Move to `db/migrations/CLAUDE.md`
- "The `tests/e2e/` folder uses Playwright with these specific configs..." → Move to `tests/e2e/CLAUDE.md`

**Should Move to External Docs (if still valuable):**
- Verbose implementation details that remain accurate but are too lengthy
- Current API documentation that's too detailed for any CLAUDE.md
- Up-to-date setup tutorials and guides
- Active troubleshooting guides for common issues

**Should Remove Entirely (don't create external docs):**
- Outdated or obsolete information
- Historical changelog entries (keep in git history)
- Redundant information available in code comments
- Deprecated features or old architectural decisions
- Stale TODOs or completed migration notes
- Information that no longer reflects current reality

## Optimization Phase

4. **Identify Documentation Structure** - Analyze project to determine appropriate locations:
   - Check for existing documentation folders (docs/, documentation/, wiki/, etc.)
   - Look for README files that might be more appropriate locations
   - Identify existing category-specific docs (API.md, SETUP.md, etc.)
   - **Scan for subdirectories** that could benefit from their own CLAUDE.md:
     - Look for distinct modules/packages (e.g., frontend/, backend/, lib/, src/components/)
     - Check if subdirectories already have CLAUDE.md files
     - Identify natural boundaries in the codebase architecture
   - If no documentation structure exists, plan one that makes sense for the project
   - Adapt to the project's conventions, don't impose a fixed structure

5. **Triage and Handle Content** - For each section that doesn't belong:
   - **Evaluate scope**: Is this content project-wide or subdirectory-specific?
   - **For subdirectory-specific content**:
     - Identify the target subdirectory (e.g., "API endpoint conventions" → api/ folder)
     - Check if subdirectory CLAUDE.md exists, create if needed
     - Move content to subdirectory CLAUDE.md with clear header
     - Add brief reference in root CLAUDE.md if critical
   - **For valuable but verbose project-wide content**: Move to appropriate external file
   - **For outdated/unnecessary**: Simply remove it (no external doc needed)
   - **Only create external docs** for content that remains valuable
   - **Only add references** in CLAUDE.md for docs that Claude might need to consult

6. **Create Documentation Index (if needed)** - Only if valuable docs were extracted:
   - Create "## Additional Documentation" section
   - **Only index documents that Claude should know about**
   - Include references to subdirectory CLAUDE.md files if created:
     - Format: "- **[Module] Context** (`path/to/CLAUDE.md`): Module-specific conventions"
   - Skip purely human-oriented docs (e.g., onboarding guides)
   - Use format: "- **[Topic]** (`path/to/doc.md`): [When to consult this]"
   - Example: "- **API Patterns** (`docs/api-patterns.md`): Consult when implementing new endpoints"
   - Example: "- **Frontend Context** (`frontend/CLAUDE.md`): React component conventions and patterns"
   - Keep the index focused on technically relevant references

7. **Optimize Structure** - Reorganize remaining content:
   - Logical section order (project-wide context first, then references)
   - Remove redundancy between root and subfolder CLAUDE.md files
   - Clear, concise language
   - Add table of contents if substantial
   - Ensure documentation index is prominent
   - Keep root CLAUDE.md focused on cross-cutting concerns

8. **Validate Results** - Final checks:
   - Verify root CLAUDE.md is focused on project-wide context
   - Verify subfolder CLAUDE.md files contain only local context
   - Ensure no critical information was lost (only outdated info removed)
   - Check for duplication between root and subfolder CLAUDE.md files
   - Confirm external links only exist for valuable references
   - Verify index only contains technically relevant documents
   - Calculate improvement metrics (size reduction, clarity improvement)

## Error Handling
- CLAUDE.md not found → Offer to create one
- WebFetch fails → Use embedded knowledge with warning
- No docs structure → Create minimal structure appropriate for the project
- Always mention backup location before making changes

## Output Report
1. Best practices summary
2. Issues identified (categorized by action needed)
3. Content removed (outdated/unnecessary information deleted)
4. Content relocated:
   - To subfolder CLAUDE.md files (module-specific content with target paths)
   - To external docs (verbose but valuable content with rationale)
5. Subfolder CLAUDE.md files created/updated (list of paths and what was moved)
6. Documentation index (if created, with selected references including subfolder CLAUDE.md)
7. Metrics (size reduction, clarity improvement, number of subfolder files created)
8. Recommendations for further improvements