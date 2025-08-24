#!/bin/bash
# Read JSON input from stdin
input=$(cat)

# Extract values using jq
model_name=$(echo "$input" | jq -r '.model.display_name')
output_style=$(echo "$input" | jq -r '.output_style.name // "default"')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
exceeds_200k=$(echo "$input" | jq -r '.exceeds_200k_tokens // false')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# Use right-pointing triangle character that's more universally supported
ARROW="▶"

# Format lines added - green background, black text
lines_added_segment=$(printf "\033[42;30m +%s \033[0m\033[30m%s\033[0m " "$lines_added" "$ARROW")

# Format lines removed - red background, white text
lines_removed_segment=$(printf "\033[41;97m -%s \033[0m\033[30m%s\033[0m " "$lines_removed" "$ARROW")

# Model segment - cyan background, black text
model_segment=$(printf "\033[46;30m %s \033[0m\033[30m%s\033[0m " "$model_name" "$ARROW")

# Context segment based on the exceeds_200k flag
if [ "$exceeds_200k" = "true" ]; then
    # Red background when context exceeds 200k
    context_segment=$(printf "\033[41;97m >200k \033[0m\033[30m%s\033[0m " "$ARROW")
else
    # Green background when under 200k (safe zone)
    context_segment=$(printf "\033[42;30m <200k \033[0m\033[30m%s\033[0m " "$ARROW")
fi

# Output style segment - blue background, white text
output_style_segment=$(printf "\033[44;97m %s \033[0m\033[30m%s\033[0m " "$output_style" "$ARROW")

# Path segment - magenta background, white text (no arrow at end)
path_segment=$(printf "\033[45;97m %s \033[0m" "$current_dir")

# Format the complete status line
printf "%s%s%s%s%s%s" \
    "$lines_added_segment" \
    "$lines_removed_segment" \
    "$model_segment" \
    "$context_segment" \
    "$output_style_segment" \
    "$path_segment"