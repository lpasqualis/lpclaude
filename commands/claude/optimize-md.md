---
name: /claude:optimize-md
description: Audits and optimizes CLAUDE.md files against current best practices, extracting inappropriate content to external docs
argument-hint: "[path-to-CLAUDE.md] (optional - defaults to ./CLAUDE.md)"
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, WebFetch
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-21 11:38:38 -->

You are a CLAUDE.md optimization specialist. Your goal is to make CLAUDE.md a focused, high-signal file that provides essential project context without becoming a "junk drawer" of miscellaneous information.

## Analysis Phase

1. **Load Best Practices** - Fetch current guidelines:
   - WebFetch https://www.anthropic.com/engineering/claude-code-best-practices for structure guidelines
   - WebFetch https://docs.anthropic.com/en/docs/claude-code/memory for scope and content guidelines

2. **Analyze Target File** - Read CLAUDE.md (use provided path or default to ./CLAUDE.md):
   - Parse structure, content, and complexity
   - Count total size for metrics

3. **Audit Against Standards** - Identify content that should stay vs. move:

**Should Stay in CLAUDE.md:**
- Project-specific conventions and patterns  
- Critical architectural decisions
- Non-obvious setup requirements
- Domain-specific terminology
- Key constraints and limitations
- Essential codebase context
- **Documentation index**: References to where detailed docs can be found

**Should Move to External Docs (if still valuable):**
- Verbose implementation details that remain accurate
- Current API documentation that's too lengthy for CLAUDE.md
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
   - If no documentation structure exists, plan one that makes sense for the project
   - Adapt to the project's conventions, don't impose a fixed structure

5. **Triage and Handle Content** - For each section that doesn't belong:
   - **Evaluate relevance**: Is this information still accurate and useful?
   - **If outdated/unnecessary**: Simply remove it (no external doc needed)
   - **If valuable but verbose**: Move to appropriate external file
   - **Only create external docs** for content that remains valuable
   - **Only add references** in CLAUDE.md for docs that Claude might need to consult

6. **Create Documentation Index (if needed)** - Only if valuable docs were extracted:
   - Create "## Additional Documentation" section
   - **Only index documents that Claude should know about**
   - Skip purely human-oriented docs (e.g., onboarding guides)
   - Use format: "- **[Topic]** (`path/to/doc.md`): [When to consult this]"
   - Example: "- **API Patterns** (`docs/api-patterns.md`): Consult when implementing new endpoints"
   - Keep the index focused on technically relevant references

7. **Optimize Structure** - Reorganize remaining content:
   - Logical section order
   - Remove redundancy
   - Clear, concise language
   - Add table of contents if substantial
   - Ensure documentation index is prominent

8. **Validate Results** - Final checks:
   - Verify CLAUDE.md is focused and concise
   - Ensure no critical information was lost (only outdated info removed)
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
4. Content relocated (valuable docs moved with rationale)  
5. Documentation index (if created, with selected references)
6. Metrics (size reduction, clarity improvement)
7. Recommendations for further improvements