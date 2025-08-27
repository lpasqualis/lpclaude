#!/usr/bin/env bash
# Read JSON on stdin
input=$(cat)

version=$(echo "$input" | jq -r '.version // "unknown"')
model_name=$(echo "$input" | jq -r '.model.display_name')
output_style=$(echo "$input" | jq -r '.output_style.name // "default"')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
exceeds_200k=$(echo "$input" | jq -r '.exceeds_200k_tokens // false')
total_duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
api_duration_ms=$(echo "$input" | jq -r '.cost.total_api_duration_ms // 0')

# Convert absolute path to ~ if it's in user's home directory
if [[ "$current_dir" == "$HOME"* ]]; then
    current_dir="~${current_dir#$HOME}"
fi

# Format duration from milliseconds to MM:SS or HH:MM:SS
format_duration() {
    local ms=$1
    local seconds=$((ms / 1000))
    
    if [[ $seconds -lt 60 ]]; then
        # Less than 1 minute: show as Xs
        echo "${seconds}s"
    elif [[ $seconds -lt 3600 ]]; then
        # Less than 1 hour: show as MM:SS
        printf "%d:%02d" $((seconds / 60)) $((seconds % 60))
    else
        # 1 hour or more: show as HH:MM:SS
        printf "%d:%02d:%02d" $((seconds / 3600)) $(((seconds % 3600) / 60)) $((seconds % 60))
    fi
}

# Format durations
work_time=$(format_duration $total_duration_ms)
api_time=$(format_duration $api_duration_ms)

# Combine work/API time display
if [[ $total_duration_ms -gt 0 ]]; then
    duration_text="${work_time}/${api_time}"
else
    duration_text="--:--"
fi

# Powerline right separator (Nerd Font *Mono* required)
SEP=$'\ue0b0'   # 

# Map BG (40–47,100–107) -> FG (30–37,90–97)
bg_to_fg() { echo $(( $1 - 10 )); }

# seg bg fg text next_bg bold_flag
seg() {
  local bg=$1 fg=$2 text="$3" next_bg=${4:-} bold=${5:-0}

  # Bold ON for text if requested (SGR 1)
  if [[ $bold -eq 1 ]]; then
    printf '\e[1;%d;%dm %s ' "$bg" "$fg" "$text"
  else
    printf '\e[%d;%dm %s ' "$bg" "$fg" "$text"
  fi

  # Separator: turn off bold (SGR 22) and paint fg=current bg, bg=next bg
  if [[ -n "$next_bg" ]]; then
    local sep_fg; sep_fg=$(bg_to_fg "$bg")
    printf '\e[22;%d;%dm%s' "$sep_fg" "$next_bg" "$SEP"
  fi
}

# 8/16-color constants (your original palette)
FG_BLACK=30; FG_WHITE=97
BG_RED=41; BG_GREEN=42; BG_YELLOW=43; BG_BLUE=44; BG_MAGENTA=45; BG_CYAN=46; BG_WHITE=47

# Context block (fg must be black per your spec)
if [[ "$exceeds_200k" == "true" ]]; then
  CTX_TEXT=">200k"; CTX_BG=$BG_RED
else
  CTX_TEXT="<200k"; CTX_BG=$BG_GREEN
fi
CTX_FG=$FG_BLACK

# 1: yellow box with version (bold, black fg)
seg "$BG_YELLOW"  "$FG_BLACK" "v$version"         "$BG_CYAN"    1
# 2: cyan box (bold, black fg)
seg "$BG_CYAN"    "$FG_BLACK" "$model_name"       "$BG_WHITE"   1
# 3: white box with duration (normal, black fg) - work/api format
seg "$BG_WHITE"   "$FG_BLACK" "$duration_text"    "$CTX_BG"     0
# 4: ctx box (bold, black fg)
seg "$CTX_BG"     "$CTX_FG"   "$CTX_TEXT"         "$BG_MAGENTA" 1
# 5: magenta box (bold, black fg)
seg "$BG_MAGENTA" "$FG_BLACK" "$output_style"     "$BG_BLUE"    1
# 6: blue box (bold, black fg) — last, then reset
printf '\e[1;%d;%dm %s \e[0m\n' "$BG_BLUE" "$FG_BLACK" "$current_dir"
