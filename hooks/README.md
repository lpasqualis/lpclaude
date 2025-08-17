# Claude Code Hooks

This directory contains hooks that help Claude Code work more effectively by preventing common issues and enforcing helpful patterns.

## guard-cd.sh

### Purpose
This hook prevents Claude from getting lost in the directory structure by restricting the use of `cd` commands. Claude often chains multiple `cd` commands and loses track of the current working directory, leading to errors and confusion. This hook solves that problem.

### What it does
- **Blocks naked `cd` commands** - Prevents `cd /path` from changing the working directory
- **Allows only subshell `cd`** - Permits `( cd /absolute/path && command )` pattern
- **Enforces absolute paths** - Rejects relative paths to prevent confusion
- **Requires project containment** - Only allows navigation within the project root
- **Provides clear guidance** - Gives Claude specific alternatives when blocking

### Why it exists
This is NOT a security measure. It's a Claude-assistance tool that addresses a specific Claude limitation: maintaining state across multiple commands, especially directory location. By forcing all directory changes to be temporary and explicit, Claude can't get lost.

### Allowed patterns
```bash
# ✅ ALLOWED - Temporary subshell with absolute path
( cd /Users/LPasqualis/lpclaude/src && npm test )

# ✅ ALLOWED - Using CLAUDE_PROJECT_DIR variable
( cd "$CLAUDE_PROJECT_DIR/tests" && pytest )

# ✅ ALLOWED - Alternative commands without cd
git -C /Users/LPasqualis/lpclaude/src status
npm --prefix /Users/LPasqualis/lpclaude test
make -C /Users/LPasqualis/lpclaude/build
```

### Blocked patterns
```bash
# ❌ BLOCKED - Naked cd command
cd /Users/LPasqualis/lpclaude/src

# ❌ BLOCKED - Relative paths
( cd ../src && npm test )

# ❌ BLOCKED - Multiple cd commands
cd src && cd tests && pytest

# ❌ BLOCKED - cd outside project root
( cd /tmp && ls )
```

### How it helps Claude
1. **Prevents accumulating confusion** - No more losing track after multiple `cd` commands
2. **Forces clarity** - Absolute paths mean Claude always knows exactly where commands run
3. **Automatic return** - Subshell pattern means Claude returns to original directory after each command
4. **Teaches better patterns** - Error messages guide Claude toward more reliable command structures
5. **Works for subagents too** - The hook applies to ALL Bash tool invocations, including those from subagents
6. **Clear diagnostics** - Provides specific error messages for:
   - Non-existent directories (suggests creating them first)
   - Symlink resolution issues (explains why a path that looks valid is blocked)
   - General violations (provides alternative commands)

### Configuration
The hook automatically detects the project root from the `CLAUDE_PROJECT_DIR` environment variable. No configuration needed.

### Troubleshooting
If you need to temporarily disable this hook for a specific use case, you can:
1. Use the alternative commands suggested in the error message
2. Modify your command to use the subshell pattern with absolute paths
3. For special cases, consider using `git -C`, `npm --prefix`, or similar tool-specific directory flags

## show-cwd.sh

### Purpose
Shows the current working directory after bash commands to help Claude maintain awareness of location. Only displays when the directory actually changes, reducing output noise.

### Important Limitation
**This hook cannot fix the directory if it changes.** PostToolUse hooks run in subshells, so any `cd` command inside the hook doesn't affect Claude's actual working directory. The hook is purely informational.

### What it does
- **Smart display** - Only shows CWD when it changes (not after every command)
- **Git context** - Includes branch, commit SHA, and dirty status when in a git repository
- **Relative paths** - Shows position relative to git root for better context
- **State tracking** - Remembers last displayed CWD per project to avoid repetition
- **Compact format** - Machine-friendly output that's easy for Claude to parse

### Output format
```bash
# Basic format (non-git directory)
CWD:/Users/LPasqualis/some/path

# Git repository format
CWD:/Users/LPasqualis/project/src REL:src GIT:main@abc123*
#                                   ^relative  ^branch ^SHA ^dirty
```

### Configuration
- **SHOW_CWD_ALWAYS=1** - Force display after every command (useful for debugging)
- Default behavior: Only show when directory changes

### How it helps Claude
1. **Maintains orientation** - Claude always knows where commands are executing
2. **Reduces confusion** - Visual confirmation prevents "where am I?" moments
3. **Git awareness** - Claude can see branch context and whether there are uncommitted changes
4. **Minimal noise** - Only displays when needed, keeping output clean

### State management
The hook stores the last displayed CWD in `~/.claude/state/last_cwd_[hash]` to track changes per project. This ensures the display only appears when truly needed.

## Setup
These hooks are automatically loaded by Claude Code when placed in:
- Project-specific: `.claude/hooks/` in your project
- Global: `~/.claude/hooks/` for all projects

The hooks work together to keep Claude oriented and prevent directory-related confusion.