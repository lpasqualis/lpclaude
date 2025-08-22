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

# Black separator between segments
SEP=" "

# Format lines added/removed as segments with black separators
# Green segment for added lines
lines_added_segment=$(printf "\033[42;30m +%s \033[0m%s" "$lines_added" "$SEP")
# Red segment for removed lines  
lines_removed_segment=$(printf "\033[41;97m -%s \033[0m%s" "$lines_removed" "$SEP")

# Model segment (cyan background)
model_segment=$(printf "\033[46;30m %s \033[0m%s" "$model_name" "$SEP")

# Context segment based on the exceeds_200k flag
if [ "$exceeds_200k" = "true" ]; then
    # Red background when context exceeds 200k
    context_segment=$(printf "\033[41;97m >200k \033[0m%s" "$SEP")
else
    # Green background when under 200k (safe zone)
    context_segment=$(printf "\033[42;30m <200k \033[0m%s" "$SEP")
fi

# Output style segment (blue background)
output_style_segment=$(printf "\033[44;97m %s \033[0m%s" "$output_style" "$SEP")

# Path segment (magenta background)
path_segment=$(printf "\033[45;97m %s \033[0m" "$current_dir")

# Format the complete status line with segments
printf "%s%s%s%s%s%s" \
    "$lines_added_segment" \
    "$lines_removed_segment" \
    "$model_segment" \
    "$context_segment" \
    "$output_style_segment" \
    "$path_segment"