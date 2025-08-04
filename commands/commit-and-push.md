---
description: Intelligently group changed files into logical commits with semantic messages and push to origin
argument-hint: "[commit message prefix] (optional, for single commit scenarios)"
---

Analyze all changed files in the project and create logical commit groupings with semantic commit messages, then push to origin.

## Process

### 1. Analyze Project State
- Examine all files that have changed, including those modified outside the current session
- Identify files that may not belong in version control and ask the user for confirmation
- Use `git status` and `git diff` to understand the full scope of changes

### 2. Create Logical Groupings
- If changes span multiple logical areas, group them into separate commits
- Each commit should represent a cohesive unit of work (e.g., feature addition, bug fix, refactoring)
- Ensure each group follows the single responsibility principle

### 3. Commit with Semantic Messages
- Use semantic commit notation (feat:, fix:, docs:, refactor:, etc.)
- Write clear, concise one-line commit messages that explain the "what" and "why"
- Stage and commit each logical group separately

### 4. Push to Origin
- Push all commits to the remote repository
- Verify the push was successful

## Guidelines
- Do not mention AI assistance in commit messages
- Ask for user confirmation if unsure about file inclusion
- Prioritize logical coherence over convenience when grouping changes
