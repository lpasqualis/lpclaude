# Workers Directory Context

## Worker Template Pattern
Worker templates are pure prompts designed for parallel execution - they do NOT have YAML frontmatter.

### Directory Organization
Worker templates are organized in subdirectories based on their parent command:
- Simple commands: `workers/{command-name}-workers/`
- Namespaced commands: `workers/{namespace}-{name}-workers/`

### Usage Pattern
1. **Load template**: `Read('workers/{namespace}-{name}-workers/template.md')`
2. **Execute**: `Task(subagent_type: 'general-purpose', prompt: template + context)`

### Key Constraints
- Workers **cannot** use Task tool (framework limitation)
- Workers **cannot** execute other commands
- Workers are designed for parallel execution (up to 10 concurrent)

### Naming Convention
- Worker files: `{command}-{purpose}.md`
- Keep names descriptive but concise
- Use lowercase-hyphenated format