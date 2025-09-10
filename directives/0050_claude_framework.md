# Commands and agents/subagents

## Remember the difference between slash commands and agents:
- **Slash Commands**:
  - Markdown files containing prompts injected as user input into current conversation
  - Support YAML frontmatter (allowed-tools, model, description, argument-hint)
  - Can include dynamic arguments ($ARGUMENTS), file references (@), bash execution (!)
  - Written as instructions TO Claude ("Analyze this...", "Review the following...")
  - Location: `.claude/commands/` (project) or `~/.claude/commands/` (personal)
  - Can be organized in subdirectories for namespacing (shown in descriptions but don't affect slash command name)
  - Project slash commands take precedence over personal slash commands with same name
  - IMPORTANT: You CANNOT run a slash command. NEVER try. Whenever it is necessary to run a slash command (to test it, or perform operations) you need to ask the user to run it. Provide the full command syntax, and the user will run it for you.
- **Subagents**:
  - Specialized AI assistants with separate context windows
  - Contain system prompts defining identity AND behavioral guidelines
  - Written as role definitions ("You are an expert...") plus detailed instructions
  - YAML frontmatter: name, description (triggers automatic invocation), tools (optional)
  - Location: `.claude/agents/` (project) or `~/.claude/agents/` (personal)
  - Project agents take precedence over user agents with same name

## Slash Commands

### Slash Command Execution Model
- Slash commands are natural language prompts sent to Claude
- Claude interprets instructions in slash commands like if they were directives from the user
- Any code block in slash commands is just text - Claude must be EXPLICITLY instructed what to do with them

### Slash Command Special Placeholders

Special placeholders (macros) are replaced before they are sent to Claude:

- **`$ARGUMENTS`** - is expanded in all slash command arguments before Claude sees it
  - Example: `/some-command foo bar` → `$ARGUMENTS` becomes `foo bar` before Claude sees it
- **Bash Pre-execution** - bash shell commands prefixed wuth `!` are executed before Claude sees it, and the output is places in its place.
  - Example "!`echo say hello`" is received by Claude as "say hello"
  - **LIMITATIONS**: 
    - Each `!` shell command runs in isolation - variables don't persist between them
    - Can only access existing shell environment variables
    - Output is included as static text in the prompt
  - NOTES: markdown bash code blocks are NOT executed automatically like it happens using `!`. Claude sees all markdown code blocks as just text. 
- **File references** - filenames with prefix @ are expanded into the content of the file before Claude sees them. When this happens, Claude also receives any CLAUDE.md in that same directory
  - File paths can be relative or absolute
  - Directory references show listings, not contents
  - Files are read at execution time, ensuring fresh content
  - Large files are included in full, so be mindful of context limits
