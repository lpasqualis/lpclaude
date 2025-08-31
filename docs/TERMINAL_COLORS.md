# Claude Code Terminal Color Handling

## Working Color Escape Sequences
Claude Code's terminal properly renders ANSI colors when using these patterns:

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

## Best Practices for Statusline Scripts
- Combine all SGR parameters in one escape sequence
- Use `%d` format specifier for numeric color codes
- Stick to standard 8/16 color palette
- Test in Claude Code environment, not just external terminal