# Workers Directory Context

## What Are Workers?
**Workers are NOT a Claude Code feature** - they're my custom pattern for organizing reusable task instructions that can be executed in parallel without the overhead of full agents.

### Why Workers Instead of Agents?
- **Agents consume context space** even when not actively used
- **Agents auto-trigger** on keywords, which isn't always desired
- **Workers are lightweight** - just instruction templates loaded on-demand
- **Workers enable parallelization** - run up to 10 tasks concurrently

## Worker Template Pattern
Worker templates are pure prompts designed for parallel execution - they do NOT have YAML frontmatter.

### Directory Organization
Worker templates are organized in subdirectories based on their parent slash command:
- Simple slash commands: `workers/{command-name}-workers/`
- Namespaced slash commands: `workers/{namespace}-{name}-workers/`

### Usage Pattern
1. **Load template**: `Read('workers/{namespace}-{name}-workers/template.md')`
2. **Execute**: `Task(subagent_type: 'general-purpose', prompt: template + context)`

### Key Constraints
- Workers **cannot** use Task tool (framework limitation)
- Workers **can** execute slash commands via SlashCommand tool
- Workers are designed for parallel execution (up to 10 concurrent)

### Naming Convention
- Worker files: `{command}-{purpose}.md`
- Keep names descriptive but concise
- Use lowercase-hyphenated format