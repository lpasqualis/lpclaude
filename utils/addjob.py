#!/usr/bin/env python3
"""
addjob.py - Create and open job files for the jobs:do command

This script creates sequentially numbered job files in the project's jobs/ directory
and opens them in your preferred editor ($EDITOR, defaults to Visual Studio Code).
"""

import os
import sys
import subprocess
import re
import argparse
from pathlib import Path

# Constants for job numbering and validation
DEFAULT_JOB_START = 10
JOB_INCREMENT = 10
MAX_JOB_NUMBER = 9999
MIN_JOB_NUMBER = 0

DEFAULT_CONTENT="""---
title: [Clear description of what this job accomplishes]
created: [YYYY-MM-DD]
origin: [What work/event led to creating this job]
priority: [low/medium/high/critical - optional, defaults to medium]
complexity: [low/medium/high - effort/skill level required]
notes:
  - [Brief context or constraint]
  - [Additional notes as needed]
---

Follow exactly and without stopping:
"""

def get_project_root():
    """Get the project root directory (VS Code workspace or current directory)."""
    # Try to get VS Code workspace from environment
    vscode_workspace = os.environ.get('VSCODE_WORKSPACE_FOLDER')
    if vscode_workspace and os.path.exists(vscode_workspace):
        return Path(vscode_workspace)
    
    # Otherwise use current working directory
    return Path.cwd()


def get_existing_job_files(jobs_dir):
    """Get all existing job files matching the pattern NNNN-*.md."""
    if not jobs_dir.exists():
        return []
    
    job_files = []
    pattern = re.compile(r'^(\d{4})-.*\.(?:parallel\.)?md(?:\.(?:working|done|error|retry))?$')
    
    for file in jobs_dir.iterdir():
        if file.is_file():
            match = pattern.match(file.name)
            if match:
                job_files.append((int(match.group(1)), file.name))
    
    return sorted(job_files)


def calculate_next_number(job_files):
    """Calculate the next job number based on existing files."""
    if not job_files:
        return DEFAULT_JOB_START

    # Get the highest number
    highest_num = job_files[-1][0]

    # Round up to next multiple of JOB_INCREMENT
    next_num = ((highest_num // JOB_INCREMENT) + 1) * JOB_INCREMENT

    return next_num


def renumber_jobs(jobs_dir):
    """Renumber all job files starting from DEFAULT_JOB_START in increments of JOB_INCREMENT."""
    job_files = get_existing_job_files(jobs_dir)

    if not job_files:
        print("No job files found to renumber.")
        return

    # Create a mapping of old names to new names
    renames = []
    new_num = DEFAULT_JOB_START
    
    for old_num, old_name in job_files:
        # Extract the suffix after the number
        suffix = old_name[old_name.index('-'):]
        new_name = f"{new_num:04d}{suffix}"
        
        if old_name != new_name:
            renames.append((old_name, new_name))
        
        new_num += JOB_INCREMENT
    
    if not renames:
        print("All files are already correctly numbered.")
        return
    
    # First pass: rename to temporary names to avoid conflicts
    temp_renames = []
    for old_name, new_name in renames:
        temp_name = f"_temp_{old_name}"
        old_path = jobs_dir / old_name
        temp_path = jobs_dir / temp_name
        
        try:
            old_path.rename(temp_path)
            temp_renames.append((temp_name, new_name))
            print(f"  Preparing: {old_name}")
        except Exception as e:
            print(f"Error renaming {old_name}: {e}")
            # Rollback
            for temp, _ in temp_renames:
                (jobs_dir / temp).rename(jobs_dir / temp[6:])  # Remove "_temp_" prefix
            return
    
    # Second pass: rename from temporary to final names
    for temp_name, new_name in temp_renames:
        temp_path = jobs_dir / temp_name
        new_path = jobs_dir / new_name
        
        try:
            temp_path.rename(new_path)
            # Get original name by removing "_temp_" prefix
            original_name = temp_name[6:]
            print(f"  Renumbered: {original_name} -> {new_name}")
        except Exception as e:
            print(f"Error renaming {temp_name} to {new_name}: {e}")
            return
    
    print(f"\nSuccessfully renumbered {len(renames)} job file(s).")


def create_job_file(job_number, name, is_parallel, jobs_dir, content=None):
    """Create a new job file with the specified parameters."""
    # Ensure jobs directory exists
    jobs_dir.mkdir(parents=True, exist_ok=True)
    
    # Construct filename
    extension = ".parallel.md" if is_parallel else ".md"
    filename = f"{job_number:04d}-{name}{extension}"
    filepath = jobs_dir / filename
    
    # Check if file already exists
    if filepath.exists():
        print(f"Error: File {filename} already exists.")
        return None
    
    # Use provided content or default
    file_content = content if content is not None else DEFAULT_CONTENT
    
    try:
        filepath.write_text(file_content)
        print(f"Created job file: {filename}")
        return filepath
    except Exception as e:
        print(f"Error creating file: {e}")
        return None


def open_in_editor(filepath):
    """Open the file in the user's preferred editor."""
    # Get editor from environment variable, default to 'code' if not set
    editor = os.environ.get('EDITOR', 'code')
    
    try:
        subprocess.run([editor, str(filepath)], check=True)
        editor_name = 'Visual Studio Code' if editor == 'code' else editor
        print(f"Opened {filepath.name} in {editor_name}")
    except subprocess.CalledProcessError:
        print(f"Error: Could not open file in {editor}.")
        print(f"Make sure '{editor}' is installed and accessible from the command line.")
    except FileNotFoundError:
        print(f"Error: '{editor}' command not found.")
        if editor == 'code':
            print("Please install VS Code command line tools or set $EDITOR to your preferred editor.")
        else:
            print(f"Please make sure {editor} is installed or set $EDITOR to a different editor.")


def main():
    parser = argparse.ArgumentParser(
        description='Create and open job files for the jobs:do command',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                    # Create job file with default name
  %(prog)s update-docs        # Create job file named NNNN-update-docs.md
  %(prog)s --parallel worker  # Create parallel job file NNNN-worker.parallel.md
  %(prog)s --n 1500 custom    # Create job file 1500-custom.md
  %(prog)s --renumber         # Renumber all existing job files
  %(prog)s -jf ~/my-jobs task # Use custom job folder
  echo "Task content" | %(prog)s --stdin task  # Create from stdin
        """
    )
    
    parser.add_argument('name', nargs='?', default='job',
                        help='Name for the job file (default: job)')
    parser.add_argument('--parallel', action='store_true',
                        help='Create a parallel job file (.parallel.md extension)')
    parser.add_argument('--n', type=int, metavar='NNNN',
                        help='Use specific job number instead of calculated')
    parser.add_argument('--renumber', action='store_true',
                        help='Renumber all existing jobs from 0010 in increments of 10')
    parser.add_argument('--job-folder', '-jf', type=str, metavar='PATH',
                        help='Use specific job folder instead of project-root/jobs')
    parser.add_argument('--stdin', action='store_true',
                        help='Read job content from stdin instead of opening editor')
    
    args = parser.parse_args()
    
    # Get jobs directory
    if args.job_folder:
        # Use custom job folder
        jobs_dir = Path(args.job_folder).expanduser().resolve()
        print(f"Using job folder: {jobs_dir}")
    else:
        # Use default project-root/jobs
        project_root = get_project_root()
        jobs_dir = project_root / 'jobs'
        print(f"Working in project: {project_root}")
    
    # Handle renumbering
    if args.renumber:
        renumber_jobs(jobs_dir)
        return
    
    # Get existing job files
    job_files = get_existing_job_files(jobs_dir)
    
    # Determine job number
    if args.n is not None:
        if args.n < MIN_JOB_NUMBER or args.n > MAX_JOB_NUMBER:
            print(f"Error: Job number must be between {MIN_JOB_NUMBER} and {MAX_JOB_NUMBER}")
            sys.exit(1)
        job_number = args.n
    else:
        job_number = calculate_next_number(job_files)
    
    # Sanitize the name (remove special characters that might cause issues)
    name = re.sub(r'[^\w\-]', '-', args.name)
    
    # Read content from stdin if requested
    content = None
    if args.stdin:
        if sys.stdin.isatty():
            print("Error: --stdin specified but no input provided via pipe")
            sys.exit(1)
        content = sys.stdin.read()
        if not content:
            print("Error: Empty content received from stdin")
            sys.exit(1)
    
    # Create the job file
    filepath = create_job_file(job_number, name, args.parallel, jobs_dir, content)
    
    if filepath:
        if args.stdin:
            # Don't open editor when using stdin
            print(f"Job file created from stdin: {filepath}")
        else:
            # Open in editor
            open_in_editor(filepath)


if __name__ == '__main__':
    main()