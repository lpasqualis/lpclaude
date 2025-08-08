#!/bin/bash

# setup.sh - Claude Framework Symlink Setup Script
# 
# This script creates symbolic links from the Claude home directory to the
# repository's component folders (agents, commands, resources, directives, utils).
# 
# What it does:
# 1. Creates symlinks in $CLAUDE_HOME (default: ~/.claude) pointing to:
#    - agents/     -> Repository's agents folder
#    - commands/   -> Repository's commands folder
#    - resources/  -> Repository's resources folder
#    - directives/ -> Repository's directives folder
#    - utils/      -> Repository's utils folder
#    - CLAUDE.md   -> Repository's global directives file
# 
# 2. Performs non-destructive operations - skips existing files/symlinks
# 3. Reports which symlinks were created successfully and which were skipped
# 
# Usage: ./setup.sh
# 
# To change the Claude home directory, modify the CLAUDE_HOME variable below.

# First build the global directives file

./build.sh

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
    
    if [ -e "$target" ] || [ -L "$target" ]; then
        echo "⚠️  Skipping $name: File or symlink already exists at $target"
        FAILED_SYMLINKS="$FAILED_SYMLINKS\n  - $name: already exists"
    else
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
create_symlink "$REPO_PATH/directives/CLAUDE_global_directives.md" "CLAUDE.md" "CLAUDE.md"

echo

# Report any failures
if [ -n "$FAILED_SYMLINKS" ]; then
    echo "⚠️  Some symlinks were not created:"
    echo -e "$FAILED_SYMLINKS"
else
    echo "✓ All symlinks created successfully!"
fi