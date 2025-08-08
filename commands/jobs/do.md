---
name: /jobs:do
description: Process job queue files (.md files) sequentially from a specified folder
argument-hint: "[folder_path] [stop_condition]"
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, Bash, Task, TodoWrite, NotebookEdit
---

Process markdown job files from a queue folder sequentially. This command monitors a specified folder (default: `jobs/`) for `.md` files and executes their contents as instructions.

## Execution Process

Parse the arguments:
- First argument (optional): folder path (defaults to `jobs/`)
- Second argument (optional): stop condition (e.g., "5 files", "30 minutes", "until empty")

Initialize tracking:
- Use TodoWrite to create a job processing status list with items for tracking progress
- Start time for time-based stop conditions

Begin the job processing loop:

### 1. Find Next Job File
Use Glob to find all `*.md` files (jobs) in the specified folder.
Filter out files ending in `.working`, `.done`,  `.done_log`, `.error`, or `.error_log` or anything that is not `.md`
Sort the results alphabetically and select the first one.

If no `.md` files are found:
- If there is an explicit stop condition and it is satisfied, report completion and stop
- Otherwise, log '/jobs:do waiting 10 seconds for new .md jobs to be queued in {folder path}..." and wait 10 seconds using Bash `sleep 10`
- Continue the loop to check again

### 2. Lock the Job File
When a job file is found:
- Attempt to rename from `{name}.md` to `{name}.md.working` using Bash `mv`
- If rename fails (file no longer exists or already locked), return to step 1
- If rename succeeds, log "Processing job: {name}" and proceed to step 3

### 3. Execute Job Instructions
Read the contents of the `.working` file.
Follow the instructions EXACTLY as written in the working file:
- Treat the entire file content as a user message
- Execute any tasks, write any code, perform any operations specified
- Use all available tools as needed to complete the job
- Do not add any preamble or explanation - just do what the file says
- Update TodoWrite to mark current job as in_progress
- Do NOT stop to ask unimportant things to the user; make decisions and proceed unless the file itself specifies to ask the user
- Note any new or updated stop condition that might be specified in the working file

### 4. Mark Job Complete or Failed
After processing the job file:

**If execution succeeded:**
- Rename from `{name}.md.working` to `{name}.md.done` using Bash `mv`
- Create a companion file `{name}.md.done_log` with:
  - Timestamp of beginning and end
  - Original job file name
  - Details of what work was accomplished
  - Details of anything that was learned during the completion of the job
  - Any issues or other important information the user should know about
- Log "Completed job: {name}"
- Update TodoWrite to mark job as completed


**If execution encountered errors:**
- Rename from `{name}.md.working` to `{name}.md.error` using Bash `mv`
- Create `{name}.md.error_log` file with:
  - Timestamp of error
  - Original job file name
  - Error details and stack trace if available
  - Any partial progress made
- Log "Failed job: {name} - see error log for details"
- Update TodoWrite to track the failed job

### 5. Check Stop Condition
Evaluate the stop condition if provided:
- "N files" - stop after processing N files (count both completed and failed)
- "N minutes" - calculate elapsed time since start, stop if exceeded
- "until empty" - stop when no more unprocessed .md files found
- "until error" - stop when there was some error and a job coudn't complete
- Any other condition specified when /jobs:do was invoked OR in the latest working file itself - respect exactly as specified
- No condition - continue indefinitely until user interrupts

### 6. Continue Loop
Return to step 1 to find the next job file.

## Implementation Details

- **File Processing Order**: Always process files in alphabetical order for predictability
- **Concurrency Safety**: The `.working` extension prevents race conditions if multiple agents run
- **Failed Renames**: If rename fails, another process likely grabbed the file - this is normal, just continue
- **Execution Context**: Each job file is executed completely before moving to the next
- **Status Visibility**: Use TodoWrite to maintain real-time status of job processing

## Error Handling

- **Missing Folder**: If the jobs folder doesn't exist, create it using Bash `mkdir -p`
- **Job Execution Errors**: Capture any errors, rename file to `.error`, create detailed error log
- **Malformed Job Files**: If a job file can't be read or is empty, treat as error
- **Interruption**: If user interrupts, ensure current `.working` file is renamed appropriately

## Status Reporting

Maintain clear status reporting throughout execution:
- Report when starting: "Starting job queue processing in {folder}"
- Report each job: "Processing job X of Y: {filename}"
- Report completion: "Job queue processing complete: X succeeded, Y failed"
- If waiting: "No jobs found, waiting..." (every 3rd wait cycle)
