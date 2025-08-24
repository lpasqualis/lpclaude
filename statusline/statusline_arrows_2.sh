#!/usr/bin/env bash
# Reads JSON on stdin and prints powerline-style segments

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

# ── glyphs (Nerd Font *Mono* required) ──────────────────────────────────────────
SEP_R=$'\ue0b0'   #  between segments (right hard)
SEP_END=$'\ue0b4' #  closing cap into background

# ── colors ─────────────────────────────────────────────────────────────────────
# Backgrounds: keep 8/16-color (fast). Foregrounds: standard colors for Claude Code
BG_RED=41; BG_GREEN=42; BG_BLUE=44; BG_MAGENTA=45; BG_CYAN=46
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
# 1: green box (bold, black fg)
seg "$BG_GREEN"   "$FG1" "+$lines_added"     "$BG_RED"     1
# 2: red box (normal, white fg)
seg "$BG_RED"     "$FG2" "-$lines_removed"   "$BG_CYAN"    0
# 3: cyan box (bold, black fg)
seg "$BG_CYAN"    "$FG3" "$model_name"       "$CTX_BG"     1
# 4: ctx box (bold, black fg)
seg "$CTX_BG"     "$CTX_FG" "$CTX_TEXT"      "$BG_BLUE"    1
# 5: blue box (normal, white fg)
seg "$BG_BLUE"    "$FG5" "$output_style"     "$BG_MAGENTA" 0

# 6: magenta box (bold, black fg) — last with separator
printf '\e[1;%d;%dm %s ' "$BG_MAGENTA" "$FG6" "$current_dir"
# Separator arrow into terminal background
sep_fg=$(bg_to_fg "$BG_MAGENTA")
printf '\e[22;%d;%dm%s' "$sep_fg" "$BG_DEFAULT" "$SEP_R"
printf '\e[0m\n'
