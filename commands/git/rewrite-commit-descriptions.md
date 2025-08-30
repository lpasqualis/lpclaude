---
name: /git:rewrite-commit-descriptions
description: Intelligently rewrite poor Git commit messages based on actual code changes
argument-hint: [--dry-run] [--no-backup-branches] [scope like "last 10", "last week", "all bad commits"]
allowed-tools: [Bash, Read, Write, Edit, Task, LS, Glob, Grep]
---

Analyze and rewrite Git commit messages based on the scope: "$ARGUMENTS"

## Step 1: Parse Scope and Flags
Interpret the natural language scope to determine which commits to analyze:
- "last N" or "last N commits" → HEAD~N
- "last N days" or "last week/month" → --since="N days ago"
- "all bad commits" → analyze last 50 commits, filter for poor quality
- Default (no arguments) → analyze last commit only
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
Create and execute an interactive rebase script:

1. Create backup branch (unless --no-backup-branches specified):
   ```bash
   # Create backup by default for safety
   if [[ "$ARGUMENTS" != *"--no-backup-branches"* ]]; then
       backup_branch="backup-$(date +%Y%m%d-%H%M%S)"
       git branch $backup_branch
       echo "Created backup branch: $backup_branch (use --no-backup-branches to skip)"
   fi
   ```

2. Identify the base commit for rebase
3. Generate the rebase todo script with "reword" for bad commits
4. For each reword operation, apply the improved message
5. Complete the rebase

```bash
# Start interactive rebase
git rebase -i <base_commit>^

# The script will automatically:
# - Mark bad commits as "reword"
# - Apply improved messages when Git prompts
```

## Step 5: Report Results
Show a summary of changes:
- Number of commits analyzed
- Number of commits improved
- Before/after comparison of changed messages

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
- Creates backup branch by default (can disable with --no-backup-branches)
- Warns if commits are already pushed to remote
- Dry-run mode available to preview changes
- Recovery instructions provided if rebase fails:
  ```bash
  # To recover from backup if something goes wrong:
  git rebase --abort  # If still in rebase
  git reset --hard backup-<timestamp>  # Return to backup state
  ```