# Commands and agents/subagents

Remember the difference between slash commands and agents:
- **Commands (slash commands)**:
  - Markdown files containing prompts injected as user input into current conversation
  - Support YAML frontmatter (allowed-tools, model, description, argument-hint)
  - Can include dynamic arguments ($ARGUMENTS), file references (@), bash execution (!)
  - Written as instructions TO Claude ("Analyze this...", "Review the following...")
  - Location: `.claude/commands/` (project) or `~/.claude/commands/` (personal)
  - IMPORTANT: You CANNOT run a slash command. NEVER try. Whenever it is necessary to run a slash command (to test it, or perform operations) you need to ask the user to run it. Provide the full command syntax, and the user will run it for you.
- **Subagents**:
  - Specialized AI assistants with separate context windows
  - Contain system prompts defining identity AND behavioral guidelines
  - Written as role definitions ("You are an expert...") plus detailed instructions
  - YAML frontmatter: name, description (triggers automatic invocation), tools (optional)
  - Location: `.claude/agents/` (project) or `~/.claude/agents/` (personal)
