---
name: /git:rewrite-commit-descriptions
description: Intelligently rewrite poor Git commit messages based on actual code changes
argument-hint: [--dry-run] [--no-backup-branches] [scope like "last 10", "fix 10 bad", "all bad commits"]
allowed-tools: [Bash, Read, Write, Edit, Task, LS, Glob, Grep]
---

Analyze and rewrite Git commit messages based on the scope: "$ARGUMENTS"

## Quick Start Examples
- `/git:rewrite-commit-descriptions --dry-run fix 10 bad` - Preview changes for up to 10 bad commits
- `/git:rewrite-commit-descriptions fix 10 bad` - Fix up to 10 bad commits
- `/git:rewrite-commit-descriptions all bad commits` - Fix all bad commits in last 50
- `/git:rewrite-commit-descriptions --no-backup-branches bad in last 20` - Fix without backup

## Process Overview

### Step 1: Parse Arguments and Determine Scope
Parse the natural language arguments to determine:
- How many commits to scan (default: 50)
- How many bad commits to fix (default: 10)
- Whether to run in dry-run mode
- Whether to skip backup branch creation

**Scope patterns to recognize:**
- `fix N bad` or `find N bad` → Find and fix up to N bad commits
- `all bad commits` → Scan last 50, fix all bad ones found
- `bad in last N` → Check last N commits, fix bad ones
- `last N` → Check last N commits

### Step 2: Safety Checks
Before making any changes:
1. Check if commits are already pushed (warn if so)
2. Check for uncommitted changes (stash if needed)
3. Verify git-filter-repo is available (provide installation instructions if not)
4. Create backup branch (unless --no-backup-branches specified)

### Step 3: Detect Bad Commits
Use the helper script `.claude/utils/git-rewrite-commit-descriptions-helpers/detect-bad-commits.sh` to identify commits with poor messages.

Bad commit criteria:
- Too short (< 10 characters)
- Generic/vague ("fix", "update", "changes", "improvements", etc.)
- Contains typos ("Importat", "Optmized", etc.)
- Incomplete actions ("Making X", "Doing Y")
- Single words without conventional commit prefix

Execute: `bash .claude/utils/git-rewrite-commit-descriptions-helpers/detect-bad-commits.sh <scan_limit> <num_to_find>`

### Step 4: Generate Improved Messages
For each bad commit found:
1. Use `.claude/utils/git-rewrite-commit-descriptions-helpers/analyze-commit.sh` to analyze the commit
2. Generate contextual commit message based on:
   - Files changed (docs, tests, config, etc.)
   - Diff content (keywords like fix, feat, refactor)
   - Number of files affected
   - Component names

### Step 5: Create Replacement Mapping
Use `.claude/utils/git-rewrite-commit-descriptions-helpers/generate-replacements.sh` to create a mapping file for git-filter-repo.

This script:
- Takes bad commits from detection phase
- Generates improved messages for each
- Creates properly escaped regex replacements
- Outputs to `/tmp/git_msg_replacements.txt`

### Step 6: Apply Rewrites
Use `.claude/utils/git-rewrite-commit-descriptions-helpers/apply-rewrites.sh` to apply the changes.

Pass appropriate flags:
- `--dry-run` if user requested preview
- `--no-backup` if user doesn't want backup branch

The script will:
- Use git-filter-repo if available (recommended)
- Fall back to git filter-branch if needed
- Show what would change in dry-run mode
- Apply the rewrites to the repository

### Step 7: Report Results
After execution, show:
- Number of commits analyzed
- Number of bad commits found
- List of commits that were rewritten with before/after
- Instructions for pushing changes if needed
- How to restore from backup if needed

## Implementation Notes

**Helper Scripts Location:**
All helper scripts are in `.claude/utils/git-rewrite-commit-descriptions-helpers/`:
- `detect-bad-commits.sh` - Find commits with poor messages
- `analyze-commit.sh` - Analyze a commit and generate better message
- `generate-replacements.sh` - Create replacement file for git-filter-repo
- `apply-rewrites.sh` - Apply the rewrites using best available tool

**Safety Features:**
- Backup branches created by default
- Dry-run mode for previewing changes
- Detection of pushed commits with warnings
- Automatic stashing of uncommitted changes
- Clear restoration instructions

**Tool Preference:**
1. git-filter-repo (fast, safe, recommended)
2. git filter-branch (slower, deprecated, but works)

If git-filter-repo is not installed, provide installation instructions:
- macOS: `brew install git-filter-repo`
- Python: `pip install git-filter-repo`
- Linux: `apt install git-filter-repo` or equivalent