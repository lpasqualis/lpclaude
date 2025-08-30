# Git Rewrite Commit Descriptions - Helper Scripts

This directory contains helper scripts used by the `/git:rewrite-commit-descriptions` command.

## Scripts

### detect-bad-commits.sh
Identifies commits with poor messages based on various criteria.

**Usage:** `./detect-bad-commits.sh <scan_limit> <num_to_find>`

**Output format:**
- `BAD:<hash>:<message>:<reason>` for each bad commit
- `SUMMARY:Found N bad commits` at the end
- `NONE:No bad commits found` if none found

**Detection criteria:**
- Messages shorter than 10 characters
- Generic/vague messages (fix, update, changes, improvements, etc.)
- Messages with typos (Importat, Optmized, etc.)
- Incomplete action descriptions
- Single words without conventional commit prefix

### analyze-commit.sh
Analyzes a commit's changes and generates an improved commit message.

**Usage:** `./analyze-commit.sh <commit_ref>`

**Output:** A conventional commit message (e.g., `feat: Add new functionality`)

**Analysis based on:**
- File types changed (docs, tests, config, etc.)
- Diff content keywords (fix, feat, refactor, etc.)
- Number of files affected
- Component names extracted from filenames

### generate-replacements.sh
Creates a replacement file for git-filter-repo from detected bad commits.

**Usage:** `./generate-replacements.sh <output_file>`

**Input:** Reads bad commits from stdin (output of detect-bad-commits.sh)

**Output:** Replacement file in git-filter-repo format

### apply-rewrites.sh
Applies commit message rewrites using the best available tool.

**Usage:** `./apply-rewrites.sh [--dry-run] [--no-backup]`

**Features:**
- Automatically detects and uses git-filter-repo if available
- Falls back to git filter-branch if needed
- Creates backup branches by default
- Supports dry-run mode for previewing changes

## Testing

To test these scripts on a sample repository:

```bash
# Create test repo
mkdir /tmp/test-repo && cd /tmp/test-repo
git init
echo "test" > file1.txt && git add . && git commit -m "fix"
echo "test2" > file2.txt && git add . && git commit -m "update"
echo "test3" > file3.txt && git add . && git commit -m "stuff"

# Test detection
./detect-bad-commits.sh 10 5

# Test analysis
./analyze-commit.sh HEAD

# Test full pipeline
./detect-bad-commits.sh 10 5 | ./generate-replacements.sh /tmp/test-replacements.txt
./apply-rewrites.sh --dry-run
```

## Dependencies

- Git (obviously)
- Bash 4+ (for associative arrays and other features)
- git-filter-repo (recommended) or git filter-branch (fallback)

## Installation

For git-filter-repo:
- macOS: `brew install git-filter-repo`
- Python: `pip install git-filter-repo`
- Debian/Ubuntu: `apt install git-filter-repo`