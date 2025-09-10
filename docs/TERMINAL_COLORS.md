# Terminal Color Workarounds for Claude Code Status Lines

## Context
While developing my custom status line for Claude Code, I discovered several quirks in how Claude Code's terminal renders ANSI color escape sequences. This document captures the workarounds I found necessary to get colors displaying correctly.

**Note**: These are workarounds for Claude Code-specific rendering issues I encountered. Your terminal or a future Claude Code version may behave differently.

## Working Color Escape Sequences
Through trial and error with my status line, I found these patterns render correctly in Claude Code:

### 1. Combined escape sequences
Put background and foreground in ONE escape:
- ✅ `printf '\e[42;30m text '` (green bg, black fg)
- ✅ `printf '\e[1;42;30m text '` (bold, green bg, black fg)

### 2. Integer format specifiers
Use `%d` for color codes:
- ✅ `printf '\e[%d;%dm text ' "$bg" "$fg"`
- ❌ `printf '\e[%s;%sm text ' "$bg" "$fg"` (may not render correctly)

### 3. Standard 8/16 colors
Use numeric color codes:
- ✅ `30-37` (foreground), `40-47` (background), `90-97` (bright foreground)
- ❌ Truecolor/24-bit RGB like `38;2;R;G;B` (not supported)

## Non-Working Patterns
These patterns may display incorrectly or show literal characters:

### 1. Separate escape sequences
- ❌ `printf '\e[42m\e[30m text '` (may show as arrows or broken colors)
   
### 2. Truecolor sequences
- ❌ `printf '\e[38;2;0;0;0m text '` (24-bit RGB not supported)

### 3. String format with color codes
- ❌ Using `%s` format when color codes need integer formatting

## Lessons Learned for Status Line Development
- Combine all SGR parameters in one escape sequence (workaround for Claude Code parsing)
- Use `%d` format specifier for numeric color codes (avoids rendering issues)
- Stick to standard 8/16 color palette (24-bit colors don't work in Claude Code)
- Test in Claude Code environment, not just external terminal (they render differently)

## Why This Document Exists
I'm documenting these quirks so that:
1. Others developing status lines can avoid the same trial-and-error process
2. I remember these workarounds when updating my own status line
3. We can track if these issues are fixed in future Claude Code versions