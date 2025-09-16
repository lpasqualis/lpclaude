#!/bin/bash
# generate-replacements.sh - Generate replacement file for git-filter-repo
# Usage: ./generate-replacements.sh <output_file>
# Reads bad commits from stdin (format: hash:old_msg:reason)

# Set up cleanup trap for temporary files
cleanup() {
    # Clean up .tmp directory if it's empty
    [ -d ".tmp" ] && rmdir ".tmp" 2>/dev/null || true
}
trap cleanup EXIT

# Ensure .tmp directory exists
mkdir -p ".tmp"
OUTPUT_FILE=${1:-.tmp/git_msg_replacements.txt}
SCRIPT_DIR="$(dirname "$0")"

echo "# Generated commit message replacements" > "$OUTPUT_FILE"
echo "# Created: $(date)" >> "$OUTPUT_FILE"

while IFS=: read -r prefix hash old_msg reason; do
    # Skip non-commit lines
    [[ "$prefix" != "BAD" ]] && continue
    
    # Generate improved message using analyze-commit.sh
    new_msg=$("$SCRIPT_DIR/analyze-commit.sh" "$hash")
    
    # Escape special regex characters in old message
    escaped_msg=$(printf '%s\n' "$old_msg" | sed 's/[][\.*^$()+?{|}]/\\&/g')
    
    # Add to replacement file
    echo "regex:^${escaped_msg}$==>${new_msg}" >> "$OUTPUT_FILE"
    echo "  Mapping: '$old_msg' → '$new_msg'"
done

echo "Replacement file generated: $OUTPUT_FILE"