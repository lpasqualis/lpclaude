---
description: Interactive command creator - helps you create new Claude Code commands
argument-hint: "[command name] (optional)"
---

First of all, learn about Claude commands here: : https://docs.anthropic.com/en/docs/claude-code/slash-commands
Then, guide the user through creating a new Claude Code command interactively. Follow this process:

## 1. Determine Command Type

Ask the user whether they want to create:
- **Project command** (stored in `.claude/commands/` - shared with team)
- **Personal command** (stored in `~/.claude/commands/` - available across all projects)

If unclear, explain the difference and wait for their choice.

## 2. Gather Requirements

Ask the user to describe:
- What the command should do
- What problem it solves
- When they would use it

Based on their response, ask clarifying questions as needed to fully understand the intent and/or to help the user decide what they want the command to really do.

## 3. Define Command Details

Work with the user to determine:
- **Command name**: If provided in ARGUMENTS, suggest using it. Otherwise, propose names based on the purpose
- **Arguments needed**: Will it accept arguments? What format?
- **Required tools**: Based on the purpose, identify which tools (file operations, web access, bash, etc.) should be allowed
- **Frontmatter needed**: Determine if description, argument-hint, or allowed-tools metadata is needed

## 4. Draft the Command

Create an initial command prompt that:
- Clearly instructs the AI agent what to do (not what to tell the user)
- Includes any necessary context or constraints
- Properly handles arguments if applicable
- Follows the pattern of existing commands in the commands folder

Show the draft to the user and ask for feedback.

## 5. Iterate and Refine

Based on user feedback:
- Adjust the prompt wording
- Add or remove functionality
- Clarify instructions
- Continue iterating until the user is satisfied

## 6. Save the Command

Once approved:
- Save the command to the appropriate directory
- Confirm successful creation
- Offer to test the command immediately

## Important Notes

- Write commands as prompts TO the AI agent, not as messages FROM the agent
- Keep prompts clear and actionable
- Include specific instructions about output format when relevant
- Consider edge cases and include appropriate handling
