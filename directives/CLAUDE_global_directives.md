# Main Directives

## Situational Directive Loading

Load and apply *.md directive files from ~/.claude/directives/ based on context and relevance:

### Loading Rules:
1. **Analyze directive filenames** to determine their applicability:
   - Files named with specific contexts (e.g., `development_projects_directives.md`) should only be applied when working on matching project types
   - Files with language/framework names should be loaded for those specific technologies

2. **Examine directive content** before applying:
   - Read the first few lines or headers to understand the directive's purpose
   - Only apply directives that are relevant to the current task or project
   - Skip directives that would conflict with the current context

3. **Priority and conflicts**:
   - Project-specific CLAUDE.md files take precedence over general directives
   - More specific directives override general ones
   - When directives conflict, use the most contextually relevant one

### Examples:
- When working on a Python project, prioritize Python-specific directives
- When doing documentation work, apply documentation-focused directives
- When in a security audit context, load security-related directives
