---
description: Intelligently group changed files into logical commits with semantic messages and push to origin
argument-hint: "[commit message prefix] (optional, for single commit scenarios)"
allowed-tools: Bash, Read, Write, Edit, MultiEdit, LS, Glob, Grep, Task
---

Analyze all changed files in the project and create logical commit groupings with semantic commit messages, then push to origin.

## Process

### 1. Repository State Analysis
- Execute single comprehensive `git status --porcelain=v1 --branch --ahead-behind` call for efficiency
- Use `git diff --name-status --cached` and `git diff --name-status` for staged/unstaged analysis
- Parallel execution of repository validation via `cmd-commit-and-push-validator` subagent
- Concurrent security scanning via `cmd-commit-and-push-security` for large file/sensitive data detection
- Verify repository is in a clean state (no ongoing merges, rebases, or conflicts)

### 2. File Classification and Grouping Strategy
- **For projects with 3+ changed files**: Use parallel analysis via Task tool
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
When processing projects with 3+ changed files, leverage parallel analysis:

### Phase 1: Concurrent Initial Analysis
Execute these tasks in parallel using Task tool:
1. **File Classification**: Use `cmd-commit-and-push-analyzer` for logical grouping
2. **Security Analysis**: Use `cmd-commit-and-push-security` for sensitive data detection
3. **Repository Validation**: Use `cmd-commit-and-push-validator` for git state verification

### Phase 2: Parallel Processing
- Process file groups in batches (max 10 per batch)
- Validate commit groups concurrently
- Perform security scans on file subsets simultaneously
- Execute repository checks in parallel

### Phase 3: Optimized Execution
- Consolidate git operations to minimize redundant commands
- Stage and validate commits in parallel where safe
- Batch push operations for efficiency
- Aggregate all results for unified user presentation

## Edge Case Handling
- **Merge conflicts**: Abort and request user resolution
- **Detached HEAD**: Warn user and suggest branch creation
- **Large binary files**: Confirm inclusion or suggest Git LFS
- **Empty commits**: Skip with notification
- **Protected branches**: Handle push restrictions gracefully

## Performance Optimizations

### Git Operation Efficiency
- **Single Status Call**: Use comprehensive git status with all flags to minimize subprocess overhead
- **Batch Operations**: Group related git commands into single calls where possible
- **Parallel Validation**: Run repository checks, security scans, and file analysis concurrently
- **Smart Caching**: Cache git status results across subagent calls to avoid redundant operations

### Parallel Processing Triggers
- **3+ files**: Activate basic parallel file classification
- **10+ files**: Enable full parallel processing with all three subagents
- **50+ files**: Implement batched processing with progress reporting
- **Large repositories**: Use selective file analysis based on change patterns

### Resource Management
- **Memory Optimization**: Stream large file analysis rather than loading entire contents
- **Process Pooling**: Reuse subagent contexts for similar analysis tasks
- **I/O Reduction**: Minimize file system operations through intelligent batching
- **Network Efficiency**: Batch remote operations and validate connectivity once

## Guidelines
- Never mention AI assistance in commit messages
- Prioritize logical coherence over file count convenience
- Ask for confirmation when unsure about file inclusion
- Preserve existing staged changes unless explicitly overridden
- Follow project-specific commit message conventions if detected
- Optimize for both speed and accuracy in large repositories
