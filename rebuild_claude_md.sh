#!/bin/bash

# Build script to concatenate all directive files into CLAUDE_global_directives.md

# Output file
OUTPUT_FILE="directives/CLAUDE_global_directives.md"

echo "Building global directives file..."
echo "Output: $OUTPUT_FILE"

# Get initial file size if file exists
if [ -f "$OUTPUT_FILE" ]; then
    INITIAL_SIZE=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || stat -c%s "$OUTPUT_FILE" 2>/dev/null || echo 0)
else
    INITIAL_SIZE=0
fi

# Clear the output file
echo "Clearing existing output file..."
> "$OUTPUT_FILE"

# Header
echo "Writing header..."
echo "# Global directives" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Global directives file built on $(date '+%m-%d-%Y at %H:%M:%S')" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Find all .md files in directives/ except the output file itself, sorted alphabetically
echo "Processing directive files in alphabetical order..."
for file in $(ls directives/*.md | sort); do
    # Skip the output file itself
    if [ "$file" != "$OUTPUT_FILE" ]; then
        echo "  Adding: $file"
        # Add the content with an empty line between files
        cat "$file" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
done

echo "Successfully built $OUTPUT_FILE"

# Get final file size
FINAL_SIZE=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || stat -c%s "$OUTPUT_FILE" 2>/dev/null || echo 0)

# Calculate size change
SIZE_CHANGE=$((FINAL_SIZE - INITIAL_SIZE))

# Format sizes for display
format_size() {
    local size=$1
    if [ $size -ge 1048576 ]; then
        echo "$(echo "scale=2; $size / 1048576" | bc) MB"
    elif [ $size -ge 1024 ]; then
        echo "$(echo "scale=2; $size / 1024" | bc) KB"
    else
        echo "$size bytes"
    fi
}

echo ""
echo "File size summary:"
echo "  Previous size: $(format_size $INITIAL_SIZE)"
echo "  New size:      $(format_size $FINAL_SIZE)"
if [ $SIZE_CHANGE -gt 0 ]; then
    echo "  Change:        +$(format_size $SIZE_CHANGE)"
elif [ $SIZE_CHANGE -lt 0 ]; then
    echo "  Change:        -$(format_size ${SIZE_CHANGE#-})"
else
    echo "  Change:        No change"
fi