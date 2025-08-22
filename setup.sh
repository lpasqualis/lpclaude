#!/bin/bash

# setup.sh - Claude Framework Symlink Setup Script
# 
# This script creates symbolic links from the Claude home directory to the
# repository's component folders (agents, commands, resources, directives, utils, output-styles, hooks).
# 
# What it does:
# 1. Creates symlinks in $CLAUDE_HOME (default: ~/.claude) pointing to:
#    - agents/        -> Repository's agents folder
#    - commands/      -> Repository's commands folder
#    - resources/     -> Repository's resources folder
#    - directives/    -> Repository's directives folder
#    - utils/         -> Repository's utils folder
#    - output-styles/ -> Repository's output-styles folder
#    - hooks/         -> Repository's hooks folder
#    - CLAUDE.md      -> Repository's global directives file
# 
# 2. Performs non-destructive operations - skips existing files/symlinks (default)
# 3. With --force option: updates symlinks that point to different locations
# 4. Reports which symlinks were created successfully and which were skipped
# 
# Usage: 
#   ./setup.sh           - Normal mode (non-destructive)
#   ./setup.sh --force   - Force mode (updates mismatched symlinks)
# 
# To change the Claude home directory, modify the CLAUDE_HOME variable below.

# Parse command line arguments
FORCE_MODE=false

# Check for help option
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Claude Framework Symlink Setup Script"
    echo
    echo "Usage:"
    echo "  ./setup.sh           - Normal mode (non-destructive, skips existing symlinks)"
    echo "  ./setup.sh --force   - Force mode (updates symlinks pointing to wrong locations)"
    echo "  ./setup.sh --help    - Display this help message"
    echo
    echo "Options:"
    echo "  -f, --force    Update symlinks that point to different locations"
    echo "  -h, --help     Display this help message"
    echo
    echo "Force mode will:"
    echo "  - Only update symlinks (never touch regular files/directories)"
    echo "  - Update symlinks that point to different locations"
    echo "  - Leave symlinks that already point to the correct location"
    echo
    echo "This is useful when you move the .lpclaude repository to a different location"
    echo "and need to update all the symlinks to point to the new location."
    exit 0
fi

if [ "$1" = "--force" ] || [ "$1" = "-f" ]; then
    FORCE_MODE=true
    echo "🔄 Running in FORCE mode - will update symlinks pointing to different locations"
    echo
fi

# First build the global directives file

./rebuild_claude_md.sh

# Claude Home Location
CLAUDE_HOME="$HOME/.claude"

# Get the directory where this script is located (repository root)
REPO_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Navigate to Claude home directory
cd "$CLAUDE_HOME" || { echo "Error: $CLAUDE_HOME directory does not exist"; exit 1; }

# Track if any symlinks failed
FAILED_SYMLINKS=""

# Function to create symlink with checks
create_symlink() {
    local source="$1"
    local target="$2"
    local name="$3"
    
    # Check if source exists
    if [ ! -e "$source" ]; then
        echo "ℹ️  Skipping $name: Source doesn't exist at $source"
        return
    fi
    
    # Check if target exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        # If it's a symlink, check where it points
        if [ -L "$target" ]; then
            current_target=$(readlink "$target")
            # Resolve to absolute path for comparison
            if [ "${current_target:0:1}" != "/" ]; then
                # Relative symlink - resolve it
                current_target="$(cd "$(dirname "$target")" && cd "$(dirname "$current_target")" && pwd)/$(basename "$current_target")"
            fi
            
            # Check if symlink points to the expected location
            if [ "$current_target" = "$source" ]; then
                echo "✓ $name: Symlink already points to correct location"
                return
            elif [ "$FORCE_MODE" = true ]; then
                echo "🔄 Updating $name: Symlink points to different location"
                echo "   Old: $current_target"
                echo "   New: $source"
                rm "$target"
                if ln -s "$source" "$target" 2>/dev/null; then
                    echo "   ✓ Updated symlink for $name"
                else
                    echo "   ✗ Failed to update symlink for $name"
                    FAILED_SYMLINKS="$FAILED_SYMLINKS\n  - $name: update failed"
                fi
                return
            else
                echo "⚠️  $name: Symlink points to different location (use --force to update)"
                echo "   Current: $current_target"
                echo "   Expected: $source"
                FAILED_SYMLINKS="$FAILED_SYMLINKS\n  - $name: points to different location"
                return
            fi
        else
            # It's a regular file or directory
            echo "⚠️  Skipping $name: Regular file/directory exists at $target (not a symlink)"
            FAILED_SYMLINKS="$FAILED_SYMLINKS\n  - $name: blocked by regular file/directory"
            return
        fi
    else
        # Target doesn't exist, create new symlink
        if ln -s "$source" "$target" 2>/dev/null; then
            echo "✓ Created symlink for $name"
        else
            echo "✗ Failed to create symlink for $name"
            FAILED_SYMLINKS="$FAILED_SYMLINKS\n  - $name: creation failed"
        fi
    fi
}

echo "Setting up symlinks from $CLAUDE_HOME to $REPO_PATH..."
echo

# Create symlinks for each component
create_symlink "$REPO_PATH/agents/" "agents" "agents"
create_symlink "$REPO_PATH/commands/" "commands" "commands"
create_symlink "$REPO_PATH/resources/" "resources" "resources"
create_symlink "$REPO_PATH/directives/" "directives" "directives"
create_symlink "$REPO_PATH/utils/" "utils" "utils"
create_symlink "$REPO_PATH/output-styles/" "output-styles" "output-styles"
create_symlink "$REPO_PATH/hooks/" "hooks" "hooks"
create_symlink "$REPO_PATH/tasks/" "tasks" "tasks"
create_symlink "$REPO_PATH/directives/CLAUDE_global_directives.md" "CLAUDE.md" "CLAUDE.md"
create_symlink "$REPO_PATH/settings/settings.json" "settings.json" "settings.json"
create_symlink "$REPO_PATH/statusline/statusline.sh" "statusline.sh" "statusline.sh"
create_symlink "$REPO_PATH/mcp/" "mcp" "mcp"

echo

# Report any failures
if [ -n "$FAILED_SYMLINKS" ]; then
    echo "ℹ️  Some symlinks were not created or updated:"
    echo -e "$FAILED_SYMLINKS"
    if [ "$FORCE_MODE" = false ]; then
        echo
        echo "💡 TIP: If symlinks point to wrong locations (e.g., after moving the repository),"
        echo "        run './setup.sh --force' to update them."
    fi
else
    echo "✓ All symlinks are correctly configured!"
fi

echo

# Check if addjob alias exists
if ! command -v addjob &> /dev/null && ! alias addjob &> /dev/null 2>&1; then
    echo "💡 TIP: To use the addjob utility from anywhere, add this alias to your shell profile:"
    echo
    echo "  alias addjob='python3 ~/.claude/utils/addjob'"
    echo
    echo "Add it to ~/.bashrc, ~/.zshrc, or ~/.bash_profile, then reload your shell."
    echo "This will allow you to create job files easily: addjob my-task"
fi