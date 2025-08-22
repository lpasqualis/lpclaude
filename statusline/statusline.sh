#!/bin/bash
# Read JSON input from stdin
input=$(cat)

# Extract values using jq
model_name=$(echo "$input" | jq -r '.model.display_name')
output_style=$(echo "$input" | jq -r '.output_style.name // "default"')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
exceeds_200k=$(echo "$input" | jq -r '.exceeds_200k_tokens // false')

# Determine context display based on the exceeds_200k flag
if [ "$exceeds_200k" = "true" ]; then
    # Red background when context exceeds 200k
    context_display=$(printf "\033[41;97m >200k \033[0m")
else
    # Green background when under 200k (safe zone)
    context_display=$(printf "\033[42;30m <200k \033[0m")
fi

# Format the status line with consistent coloring
# Model (green bg) | Context (green/red based on size) | Output Style (blue bg) | Path (green text)
printf "\033[42;37m %s \033[0m %s \033[44;97m %s \033[0m \033[92m%s\033[0m" \
    "$model_name" \
    "$context_display" \
    "$output_style" \
    "$current_dir"