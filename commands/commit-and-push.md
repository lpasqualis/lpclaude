---
description: Intelligently group changed files into logical commits with semantic messages and push to origin
argument-hint: "[commit message prefix] (optional, for single commit scenarios)"
allowed-tools: Bash, Read, LS, Glob, Grep, Task
---

Analyze all changed files in the project and create logical commit groupings with semantic commit messages, then push to origin.

## Process

### 1. Repository State Analysis
- Execute `git status --porcelain` and `git diff --name-status` to identify all changes
- Check for untracked files, staged changes, and unstaged modifications
- Identify potentially problematic files (large binaries, sensitive data, temporary files)
- Verify repository is in a clean state (no ongoing merges, rebases, or conflicts)

### 2. File Classification and Grouping Strategy
- **For projects with 5+ changed files**: Use parallel analysis via Task tool
- Classify changes by logical areas:
  - **Features**: New functionality, API additions, user-facing changes
  - **Fixes**: Bug corrections, error handling improvements
  - **Refactoring**: Code restructuring without functional changes  
  - **Documentation**: README, comments, API docs, guides
  - **Configuration**: Build files, dependencies, environment settings
  - **Tests**: Test additions, modifications, test infrastructure
- Group related files that form cohesive units of work

### 3. Semantic Commit Creation
- Generate descriptive commit messages following conventional commit format:
  - `feat:` for new features
  - `fix:` for bug fixes
  - `docs:` for documentation changes
  - `refactor:` for code restructuring
  - `test:` for test-related changes
  - `chore:` for maintenance tasks
- Include scope when applicable: `feat(auth): add OAuth integration`
- Ensure messages are concise but descriptive (50 chars for subject line)

### 4. Staged Commit Execution
- Stage and commit each logical group separately
- Display commit summary before proceeding
- Ask for user confirmation if:
  - Large files (>1MB) are included
  - Sensitive patterns detected (passwords, API keys, tokens)
  - More than 20 files in a single commit

### 5. Remote Push and Verification
- Push all commits to origin using current branch
- Verify push success with `git status`
- Report final commit count and branch status

## Parallel Execution Strategy
When processing projects with 5+ changed files:
1. Use Task tool with `commit-analyzer` subagent for file classification
2. Process file groups in parallel batches (max 10 per batch)
3. Aggregate analysis results for commit planning
4. Present unified commit strategy to user

## Edge Case Handling
- **Merge conflicts**: Abort and request user resolution
- **Detached HEAD**: Warn user and suggest branch creation
- **Large binary files**: Confirm inclusion or suggest Git LFS
- **Empty commits**: Skip with notification
- **Protected branches**: Handle push restrictions gracefully

## Guidelines
- Never mention AI assistance in commit messages
- Prioritize logical coherence over file count convenience
- Ask for confirmation when unsure about file inclusion
- Preserve existing staged changes unless explicitly overridden
- Follow project-specific commit message conventions if detected
