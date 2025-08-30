#!/bin/bash
# analyze-commit.sh - Analyze a commit and generate improved message
# Usage: ./analyze-commit.sh <commit_ref>

COMMIT=${1:-HEAD}
OLD_MSG=$(git log -1 --pretty=%s "$COMMIT")

# Get changed files and statistics
FILES=$(git diff-tree --no-commit-id --name-only -r "$COMMIT")
NUM_FILES=$(echo "$FILES" | wc -l | tr -d ' ')

# Get diff content for analysis
DIFF_CONTENT=$(git show "$COMMIT" 2>/dev/null | head -100)

# Determine type and description based on comprehensive analysis
if echo "$FILES" | grep -q "\.md$\|README\|CHANGELOG\|docs/"; then
    TYPE="docs"
    # Be more specific about documentation changes
    if echo "$FILES" | grep -q "README"; then
        DESC="Update README documentation"
    elif echo "$FILES" | grep -q "CHANGELOG"; then
        DESC="Update changelog"
    else
        DESC="Update documentation files"
    fi
elif echo "$FILES" | grep -q "_test\|\.test\|spec\.\|test_\|tests/"; then
    TYPE="test"
    DESC="Add or update test coverage"
elif echo "$DIFF_CONTENT" | grep -qE "(fix|bug|issue|error|crash|resolve|correct|repair)"; then
    TYPE="fix"
    # Try to be specific about what was fixed
    COMPONENT=$(echo "$FILES" | head -1 | xargs basename 2>/dev/null | cut -d. -f1)
    DESC="Resolve issues in ${COMPONENT:-codebase}"
elif echo "$DIFF_CONTENT" | grep -qE "(add|new|create|implement|introduce|feat)"; then
    TYPE="feat"
    # Describe based on file types
    if echo "$FILES" | grep -q "command"; then
        DESC="Add new command functionality"
    elif echo "$FILES" | grep -q "agent"; then
        DESC="Add new agent capability"
    elif echo "$FILES" | grep -q "worker"; then
        DESC="Add new worker template"
    else
        DESC="Implement new features"
    fi
elif echo "$FILES" | grep -qE "package\.json|requirements\.txt|Gemfile|go\.mod|yarn\.lock|package-lock\.json"; then
    TYPE="chore"
    DESC="Update project dependencies"
elif echo "$FILES" | grep -q "\.gitignore\|\.env\|config\|settings"; then
    TYPE="chore"
    DESC="Update configuration files"
elif echo "$DIFF_CONTENT" | grep -qE "(refactor|reorganize|restructure|optimize|improve|enhance)"; then
    TYPE="refactor"
    if [[ $NUM_FILES -gt 5 ]]; then
        DESC="Restructure multiple components"
    else
        DESC="Improve code organization"
    fi
elif echo "$OLD_MSG" | grep -qiE "typo|spelling|grammar"; then
    TYPE="fix"
    DESC="Correct typos and spelling errors"
else
    TYPE="refactor"
    # Default but try to be somewhat specific
    if [[ $NUM_FILES -eq 1 ]]; then
        COMPONENT=$(echo "$FILES" | xargs basename 2>/dev/null | cut -d. -f1)
        DESC="Update ${COMPONENT:-component} implementation"
    else
        DESC="Update multiple components"
    fi
fi

# Output the improved message
echo "${TYPE}: ${DESC}"