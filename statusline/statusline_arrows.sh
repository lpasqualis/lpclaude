#!/usr/bin/env bash
# Read JSON on stdin
input=$(cat)

model_name=$(echo "$input" | jq -r '.model.display_name')
output_style=$(echo "$input" | jq -r '.output_style.name // "default"')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
exceeds_200k=$(echo "$input" | jq -r '.exceeds_200k_tokens // false')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# Convert absolute path to ~ if it's in user's home directory
if [[ "$current_dir" == "$HOME"* ]]; then
    current_dir="~${current_dir#$HOME}"
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
BG_RED=41; BG_GREEN=42; BG_BLUE=44; BG_MAGENTA=45; BG_CYAN=46

# Context block (fg must be black per your spec)
if [[ "$exceeds_200k" == "true" ]]; then
  CTX_TEXT=">200k"; CTX_BG=$BG_RED
else
  CTX_TEXT="<200k"; CTX_BG=$BG_GREEN
fi
CTX_FG=$FG_BLACK

# 1: green box (bold, black fg)
seg "$BG_GREEN"   "$FG_BLACK" "+$lines_added"     "$BG_RED"     1
# 2: red box (normal, white fg)
seg "$BG_RED"     "$FG_WHITE" "-$lines_removed"   "$BG_CYAN"    0
# 3: cyan box (bold, black fg)
seg "$BG_CYAN"    "$FG_BLACK" "$model_name"       "$CTX_BG"     1
# 4: ctx box (bold, black fg)
seg "$CTX_BG"     "$CTX_FG"   "$CTX_TEXT"         "$BG_BLUE"    1
# 5: blue box (normal, white fg)
seg "$BG_BLUE"    "$FG_WHITE" "$output_style"     "$BG_MAGENTA" 0
# 6: magenta box (bold, black fg) — last, then reset
printf '\e[1;%d;%dm %s \e[0m\n' "$BG_MAGENTA" "$FG_BLACK" "$current_dir"
