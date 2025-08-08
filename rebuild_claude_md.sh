#!/bin/bash

# Build script to concatenate all directive files into CLAUDE_global_directives.md

# Output file
OUTPUT_FILE="directives/CLAUDE_global_directives.md"

echo "Building global directives file..."
echo "Output: $OUTPUT_FILE"

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