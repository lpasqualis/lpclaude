---
name: /commands:port-to-gemini
description: Translate Claude Code commands to Gemini CLI format
argument-hint: [optional: specific commands to translate, or special directives]
allowed-tools: Read, Write, MultiEdit, LS, Glob, Grep, Bash, WebFetch
disable-model-invocation: true
---

# Port Claude Code Commands to Gemini CLI

Translate Claude Code commands from `.claude/commands/` to Gemini CLI format in `.gemini/commands/`.

## Process

1. **Parse arguments** - Determine which commands to translate:
   - If `$ARGUMENTS` is empty, translate all commands in `.claude/commands/`
   - Otherwise, parse `$ARGUMENTS` for specific command names or patterns

2. Learn about Gemini CLI Commands.
   - Load the documentation from https://cloud.google.com/blog/topics/developers-practitioners/gemini-cli-custom-slash-commands:
   - Pay attention to the command format, and what feature are available from Gemini CLI commands

3. **For each claude slash command to translate:**

   a. **Read and analyze the Claude command** - Check for Claude-specific features:
      - Task tool usage (subagent coordination)
      - SlashCommand tool invocation
      - Special placeholders like `$ARGUMENTS`, `@file`, `!bash`
      - Claude-specific frontmatter fields

   b. **Assess portability** - Document incompatibilities:
      - If command uses Task tool → Note "Requires subagent coordination - cannot port"
      - If command uses SlashCommand → Note "Invokes other commands - manual adaptation needed"
      - If command uses special placeholders → Decides if the equivalent exists in GEMINI CLI commands - if it does not, report the issue

   c. **Convert to Gemini format** 
      - Preserve the exact command logic and instructions
      - Adapt format to Gemini's TOML structure
      - Maintain the same command name pattern
      - Translate all the concepts from Claude to Gemini commands equivalents, if available

4. **Create output structure:**
   - Ensure `.gemini/commands/` directory exists
   - Mirror the subdirectory structure from `.claude/commands/`
   - Write each successfully translated command

5. **Report results:**
   - Summary of translation: X commands ported, Y skipped
   - List any commands requiring manual intervention
   - Highlight critical incompatibilities discovered

## Special Directives

$ARGUMENTS

## Output Format

For each translated command, preserve the original intent while adapting to Gemini's requirements. Document all translation decisions and incompatibilities clearly.