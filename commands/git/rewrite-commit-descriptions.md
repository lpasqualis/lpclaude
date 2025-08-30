---
name: /git:rewrite-commit-descriptions
description: Intelligently rewrite poor Git commit messages based on actual code changes
argument-hint: [--dry-run] [--no-backup-branches] [scope like "last 10", "last week", "all bad commits"]
allowed-tools: [Bash, Read, Write, Edit, Task, LS, Glob, Grep]
---

Analyze and rewrite Git commit messages based on the scope: "$ARGUMENTS"

## Step 1: Parse Scope and Flags
Interpret the natural language scope to determine which commits to analyze:

**Targeted Fix Patterns (only rewrites bad commits, leaves good ones untouched):**
- "all bad commits" → scan last 50 commits, fix only the bad ones
- "find N bad" or "fix N bad commits" → scan history until N bad commits found, fix only those
- "bad in last N" or "scan last N" → examine last N commits, fix only the bad ones
- "bad commits from last week" → scan time range, fix only bad ones found

**Range Patterns (analyzes all in range):**
- "last N" or "last N commits" → analyze last N commits
- "last N days" or "last week/month" → commits from time period
- Default (no arguments) → analyze last commit only

**Important:** Even when scanning a range, only commits with poor messages are rewritten. Good commit messages are always preserved.

**Flags:**
- If the user specified --dry-run, describe what you'd do without making the changes
- If the user specified --no-backup-branches, skip backup branch creation

## Step 2: Analyze Commit Quality
Get the commits in scope and evaluate each message:

```bash
# Get commit list based on parsed scope
git log --oneline <scope_flags>
```

For each commit, check if the message needs improvement:
- Too short (< 10 characters)
- Generic/meaningless ("fix", "update", "changes", "stuff", "asdf", etc.)
- No verb or unclear action
- Doesn't describe the actual change
- Contains profanity or placeholder text

**Selective Rewriting:** The command evaluates EACH commit individually. For example:
```
HEAD   → "Add user authentication system"    ✓ Keep (good)
HEAD~1 → "fix"                              ✗ Rewrite (too generic)
HEAD~2 → "Refactor database queries"        ✓ Keep (good)
HEAD~3 → "asdfasdf"                        ✗ Rewrite (meaningless)
HEAD~4 → "Update dependencies to latest"    ✓ Keep (good)
```
In this case, only HEAD~1 and HEAD~3 would be rewritten.

## Step 3: Generate Improved Messages
For commits identified as needing improvement:

1. Get the full diff for each commit:
```bash
git show --stat <commit_hash>
git diff <commit_hash>^ <commit_hash>
```

2. Analyze the changes to understand:
- What files were modified
- What type of change (feature, fix, refactor, docs, etc.)
- The scope and impact of changes

3. Generate an improved commit message following conventional format:
- Type: feat, fix, refactor, docs, test, chore, style, perf
- Scope: affected component/module
- Subject: clear, imperative mood description
- Body (if needed): why the change was made

## Step 4: Execute Rewrite (if no --dry-run)

### IMPORTANT SAFETY CHECKS FIRST:
```bash
# Check if we have unpushed commits
if git status | grep -q "Your branch is ahead"; then
    echo "✅ Safe: Working with unpushed commits only"
else
    echo "⚠️  WARNING: These commits may already be pushed!"
    echo "Rewriting pushed history requires coordination with team"
    echo "Continue? (y/n)"
    # Get user confirmation before proceeding
fi

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "📝 Stashing uncommitted changes..."
    git stash push -m "Temporary stash for commit rewrite"
fi
```

### Choose the safest method based on scope:

**For recent unpushed commits (SAFEST):**
Use interactive rebase - no history corruption risk:
```bash
# Create backup branch (unless --no-backup-branches specified)
if [[ "$ARGUMENTS" != *"--no-backup-branches"* ]]; then
    backup_branch="backup-$(date +%Y%m%d-%H%M%S)"
    git branch $backup_branch
    echo "Created backup branch: $backup_branch"
fi

# Use git rebase -i for recent commits
git rebase -i <base_commit>^
# Then manually mark bad commits as "reword"
```

**For already-pushed commits (REQUIRES CAUTION):**
1. First try creating a new branch with amended commits
2. Only use filter-branch/filter-repo as last resort
3. Always coordinate with team before rewriting shared history

```bash
# Safer alternative: Create new commits with better messages
# instead of rewriting history
git revert --no-commit <bad_commits>
git commit -m "Revert commits with poor messages"
# Then re-apply changes with good messages
```

## Step 5: Report Results
Show a summary of changes:
- Number of commits analyzed
- Number of commits with good messages (preserved)
- Number of commits with bad messages (rewritten)
- Before/after comparison of changed messages

Example output:
```
Analyzed 30 commits:
✓ 23 had good messages (preserved)
✗ 7 had poor messages (rewritten)

Changes made:
  HEAD~3:  "fix" → "fix: Resolve authentication timeout issue"
  HEAD~7:  "stuff" → "feat: Add user profile image upload"
  HEAD~12: "asdf" → "refactor: Extract validation logic to utility module"
  HEAD~15: "updates" → "chore: Update dependencies for security patches"
  HEAD~18: "wip" → "feat: Implement real-time notification system"
  HEAD~22: "." → "docs: Add API documentation for REST endpoints"
  HEAD~26: "test" → "test: Add integration tests for payment flow"
```

If this is a personal project branch, offer to force-push:
```bash
git push --force-lease origin <current_branch>
```

## Quality Guidelines for New Messages:
- Start with lowercase imperative verb
- Be specific about what changed and why
- Keep subject line under 50 characters
- Add body for complex changes
- Reference issue numbers if applicable
- Use conventional commit format when appropriate

## Safety Features:
- **Pre-flight checks**: Detects pushed commits and uncommitted changes
- **Backup by default**: Creates backup branch (disable with --no-backup-branches)
- **Dry-run mode**: Preview changes without modifying history
- **Stash protection**: Automatically stashes uncommitted work
- **Method selection**: Uses safest approach based on commit status
- **Recovery options**: Multiple ways to undo changes:
  ```bash
  # If rebase is still in progress:
  git rebase --abort
  
  # If you have a backup branch:
  git reset --hard backup-<timestamp>
  
  # If you need to restore original state:
  git reflog  # Find the commit before rewrite
  git reset --hard <original-commit>
  ```

## Best Practices:
1. **Always use --dry-run first** to preview changes
2. **Only rewrite unpushed commits** when possible
3. **Coordinate with team** before rewriting shared history
4. **Keep backup branches** unless you're absolutely certain
5. **Consider alternatives** like new commits instead of rewriting