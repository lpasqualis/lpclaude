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

# Use a custom job folder
addjob -jf ~/my-jobs-folder task-name
addjob --job-folder /path/to/jobs daily-task

# Create job from stdin (for automation)
echo "Run all unit tests and fix failures" | addjob --stdin test-task
cat instructions.md | addjob --stdin --parallel batch-job

# Combine features
echo "Process data files" | addjob --stdin --parallel -jf ~/batch-jobs data-processor

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

## Advanced Features

### Custom Job Folders
Use the `--job-folder` or `-jf` option to specify a custom directory for job files instead of the default `project-root/jobs`:

```bash
# Use absolute path
addjob -jf /home/user/global-jobs my-task

# Use relative path
addjob -jf ../shared-jobs team-task

# Use home directory expansion
addjob -jf ~/my-jobs personal-task
```

This is useful for:
- Maintaining global job queues across projects
- Sharing job folders between team members
- Organizing jobs by category or priority

### Automated Job Creation via stdin
Use the `--stdin` option to create jobs programmatically without opening an editor:

```bash
# Simple command
echo "Update documentation for API endpoints" | addjob --stdin doc-task

# Multi-line instructions
cat <<EOF | addjob --stdin complex-task
1. Review all test files
2. Update deprecated assertions
3. Run full test suite
4. Fix any failures
EOF

# From a file
cat task-template.md | addjob --stdin --parallel batch-task

# Generated from scripts
./generate-tasks.sh | addjob --stdin generated-task
```

When using `--stdin`:
- The editor is NOT opened after file creation
- Content is read from standard input
- Useful for CI/CD pipelines and automation scripts
- Can be combined with other options (--parallel, -jf, --n)

## File Naming Convention

- Files are named: `NNNN-{name}.md` or `NNNN-{name}.parallel.md`
- Numbers are rounded to nearest multiple of 10
- Example: if last job is 1232, next will be 1240
- Example: if last job is 1238, next will be 1250