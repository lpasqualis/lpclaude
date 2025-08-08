# Utils Directory

This directory contains utility scripts for the Claude Framework.

## Available Utilities

### addjob
Create and manage job files for the `/jobs:do` command.

## Making addjob Globally Accessible

There are three simple ways to make `addjob` available from anywhere in your terminal:

### Option 1: Add to PATH via shell profile (Recommended)

Add this line to your shell profile (`~/.bashrc`, `~/.zshrc`, or `~/.bash_profile`):

```bash
export PATH="$HOME/.claude/utils:$PATH"
```

Then reload your shell:
```bash
source ~/.zshrc  # or ~/.bashrc or ~/.bash_profile
```

Now you can use `addjob` from anywhere:
```bash
addjob my-new-task
addjob --parallel worker-task
addjob --renumber
```

### Option 2: Create an alias

Add this line to your shell profile:

```bash
alias addjob='python3 ~/.claude/utils/addjob.py'
```

Then reload your shell and use it:
```bash
source ~/.zshrc  # or ~/.bashrc
addjob my-task
```

### Option 3: Symlink to a directory already in PATH

```bash
ln -s ~/.claude/utils/addjob /usr/local/bin/addjob
```

This creates a symlink in `/usr/local/bin` (which is typically in PATH).

## Usage Examples

Once globally accessible, you can use addjob from any project:

```bash
# Create a new job with default name
addjob

# Create a named job
addjob update-documentation

# Create a parallel job
addjob --parallel data-processing

# Create a job with specific number
addjob --n 2000 high-priority

# Renumber all existing jobs
addjob --renumber

# Get help
addjob --help
```

## How It Works

1. `addjob` detects your current project directory (or VS Code workspace)
2. Creates sequentially numbered job files in the `jobs/` folder
3. Opens the new file in your preferred editor (uses $EDITOR environment variable, defaults to VS Code)
4. Supports both sequential (`.md`) and parallel (`.parallel.md`) job types

## Setting Your Preferred Editor

The script uses the `$EDITOR` environment variable to determine which editor to use. If not set, it defaults to Visual Studio Code (`code`).

To set your preferred editor, add one of these to your shell profile:

```bash
# For vim
export EDITOR=vim

# For nano
export EDITOR=nano

# For Visual Studio Code (default)
export EDITOR=code

# For Sublime Text
export EDITOR=subl

# For any other editor
export EDITOR=your-editor-command
```

## File Naming Convention

- Files are named: `NNNN-{name}.md` or `NNNN-{name}.parallel.md`
- Numbers are rounded to nearest multiple of 10
- Example: if last job is 1232, next will be 1240
- Example: if last job is 1238, next will be 1250