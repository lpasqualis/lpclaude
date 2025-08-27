#!/usr/bin/env bash
# Reads JSON on stdin and prints powerline-style segments

input=$(cat)

version=$(echo "$input" | jq -r '.version // "unknown"')
model_name=$(echo "$input" | jq -r '.model.display_name')
output_style=$(echo "$input" | jq -r '.output_style.name // "default"')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
exceeds_200k=$(echo "$input" | jq -r '.exceeds_200k_tokens // false')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
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

# ── glyphs (Nerd Font *Mono* required) ──────────────────────────────────────────
SEP_R=$'\ue0b0'   #  between segments (right hard)
SEP_END=$'\ue0b4' #  closing cap into background

# ── colors ─────────────────────────────────────────────────────────────────────
# Backgrounds: keep 8/16-color (fast). Foregrounds: standard colors for Claude Code
BG_RED=41; BG_GREEN=42; BG_YELLOW=43; BG_BLUE=44; BG_MAGENTA=45; BG_CYAN=46; BG_WHITE=47
BG_DEFAULT=49

# Use standard colors instead of truecolor for Claude Code compatibility
FG_BLACK=30
FG_WHITE=97

# Boxes: 1,3,4,6 → black fg ; 2,5 → white fg
FG1="$FG_BLACK"; FG2="$FG_WHITE"; FG3="$FG_BLACK"
FG4="$FG_BLACK"; FG5="$FG_WHITE"; FG6="$FG_BLACK"

# ── helpers ────────────────────────────────────────────────────────────────────
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
    printf '\e[22;%d;%dm%s' "$sep_fg" "$next_bg" "$SEP_R"
  fi
}

# Context block (fg = black as requested)
if [[ "$exceeds_200k" == "true" ]]; then
  CTX_TEXT=">200k"; CTX_BG="$BG_RED";  CTX_FG="$FG_BLACK"
else
  CTX_TEXT="<200k"; CTX_BG="$BG_GREEN"; CTX_FG="$FG_BLACK"
fi

# ── render ─────────────────────────────────────────────────────────────────────
# 1: yellow box with version (bold, black fg)
seg "$BG_YELLOW" "$FG_BLACK" "v$version"    "$BG_CYAN"   1
# 2: cyan box (bold, black fg)
seg "$BG_CYAN"    "$FG3" "$model_name"       "$BG_WHITE"     1
# 3: white box with duration (normal, black fg) - work/api format
seg "$BG_WHITE"   "$FG_BLACK" "$duration_text" "$CTX_BG"    0
# 4: ctx box (bold, black fg)
seg "$CTX_BG"     "$CTX_FG" "$CTX_TEXT"      "$BG_MAGENTA" 1
# 5: magenta box (bold, black fg)
seg "$BG_MAGENTA" "$FG_BLACK" "$output_style"     "$BG_BLUE" 1

# 6: blue box (bold, black fg) — last with separator
printf '\e[1;%d;%dm %s ' "$BG_BLUE" "$FG6" "$current_dir"
# Separator arrow into terminal background
sep_fg=$(bg_to_fg "$BG_BLUE")
printf '\e[22;%d;%dm%s' "$sep_fg" "$BG_DEFAULT" "$SEP_R"
printf '\e[0m\n'
