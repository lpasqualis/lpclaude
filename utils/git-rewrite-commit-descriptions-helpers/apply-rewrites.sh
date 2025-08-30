#!/bin/bash
# apply-rewrites.sh - Apply commit message rewrites using best available tool
# Usage: ./apply-rewrites.sh [--dry-run] [--no-backup]

DRY_RUN=false
NO_BACKUP=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            ;;
        --no-backup)
            NO_BACKUP=true
            ;;
    esac
done

# Check which tool is available
if command -v git-filter-repo >/dev/null 2>&1; then
    TOOL="git-filter-repo"
else
    TOOL="git-filter-branch"
fi

echo "Using tool: $TOOL"

# Create backup branch unless disabled
if [[ "$NO_BACKUP" == "false" ]] && [[ "$DRY_RUN" == "false" ]]; then
    BACKUP_BRANCH="backup-$(date +%Y%m%d-%H%M%S)"
    git branch "$BACKUP_BRANCH"
    echo "Created backup branch: $BACKUP_BRANCH"
fi

# Apply rewrites based on tool
if [[ "$TOOL" == "git-filter-repo" ]]; then
    # Ensure .tmp directory exists
    mkdir -p ".tmp"
    REPLACEMENT_FILE=".tmp/git_msg_replacements.txt"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "=== DRY RUN MODE ==="
        echo "Would apply the following replacements:"
        cat "$REPLACEMENT_FILE"
        echo "=== END DRY RUN ==="
    else
        git-filter-repo --replace-message "$REPLACEMENT_FILE" --force
        echo "✓ Rewrites applied using git-filter-repo"
    fi
else
    # Fallback to filter-branch
    echo "⚠️  Using git filter-branch (slower, consider installing git-filter-repo)"
    
    # Read replacement file and build sed script
    # Ensure .tmp directory exists
    mkdir -p ".tmp"
    SED_SCRIPT=".tmp/git_msg_sed.sh"
    cat > "$SED_SCRIPT" << 'EOF'
#!/bin/bash
msg=$(cat)
EOF
    
    # Add replacements from file
    while IFS= read -r line; do
        if [[ "$line" =~ ^regex:(.*)=\=\>(.*)$ ]]; then
            pattern="${BASH_REMATCH[1]}"
            replacement="${BASH_REMATCH[2]}"
            # Remove regex anchors for simple matching
            pattern="${pattern#^}"
            pattern="${pattern%$}"
            echo "if [[ \"\$msg\" == \"$pattern\" ]]; then echo \"$replacement\"; exit; fi" >> "$SED_SCRIPT"
        fi
    done < ".tmp/git_msg_replacements.txt"
    
    echo "echo \"\$msg\"" >> "$SED_SCRIPT"
    chmod +x "$SED_SCRIPT"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "=== DRY RUN MODE ==="
        echo "Would run git filter-branch with custom message filter"
        echo "=== END DRY RUN ==="
    else
        FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f --msg-filter "$SED_SCRIPT" -- --all
        echo "✓ Rewrites applied using git filter-branch"
    fi
fi