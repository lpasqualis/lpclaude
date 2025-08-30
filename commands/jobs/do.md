---
name: /jobs:do
description: Process job queue files (.md and .parallel.md files) from a specified folder with context-aware execution
argument-hint: "[folder_path] [stop_condition]"
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-10 21:23:45 -->

Process markdown job files from a queue folder with context-aware execution. This command monitors a specified folder (default: `jobs/`) for `.md` and `.parallel.md` files. Regular `.md` files execute sequentially in the main agent with full context access. Files ending with `.parallel.md` can run in parallel via subagents when no sequential jobs precede them alphabetically.

## Execution Process

Parse the arguments:
- First argument (optional): folder path (defaults to `jobs/`)
- Second argument (optional): stop condition (e.g., "5 files", "30 minutes", "until empty")

## Execution Strategy

### Job Types:
1. **Regular Jobs (`.md` files)**: 
   - Execute sequentially in main agent context
   - Full access to conversation history
   - Can invoke subagents via Task tool
   - Can interact with user if needed

2. **Parallel Jobs (`.parallel.md` files)**:
   - Execute in parallel via task templates
   - Run in isolated contexts (no conversation history)
   - Cannot invoke other subagents
   - Must be self-contained tasks

### Processing Order:
- All jobs are processed in alphabetical order
- `.parallel.md` files can ONLY run in parallel when no `.md` files come before them alphabetically
- This ensures job dependencies are respected
- Users can prefix parallel jobs (e.g., `00-task.parallel.md`) to prioritize them

Initialize tracking:
- Use TodoWrite to create a job processing status list with items for tracking progress
- Start time for time-based stop conditions

Begin the job processing loop:

### 1. Find Available Job Files
Use Glob to find all `*.md` and `*.parallel.md` files in the specified folder.
Filter out files ending in `.working`, `.done`, `.done_log`, `.error`, `.error_log`, or `.retry`
Sort the results alphabetically for predictable processing order.

**Processing Decision**:
- Check the first available job in alphabetical order:
  - If it's a `.md` file: Process it sequentially in main agent
  - If it's a `.parallel.md` file: Batch it with up to 7 more consecutive `.parallel.md` files
- CRITICAL: Never process `.parallel.md` files if any `.md` file comes before them alphabetically

**Discovery Strategy**:
- Create a `.jobqueue` lock file to prevent race conditions
- Respect alphabetical ordering to maintain dependencies
- Batch consecutive `.parallel.md` files only when appropriate
- Implement adaptive polling: start with 2-second intervals, increase to 10 seconds if no jobs found

If no `.md` files are found:
- Check for abandoned `.working` files older than 30 minutes and recover them
- If explicit stop condition satisfied, report completion and stop
- Use adaptive waiting: shorter intervals when jobs were recently processed
- Log waiting status every 3rd cycle to reduce noise

### 2. Job Locking and Execution Strategy

**For Regular Jobs (`.md` files)**:
- Process sequentially in main agent context
- Attempt atomic rename from `{name}.md` to `{name}.md.working`
- If rename succeeds, log "Processing sequential job: {name}"
- Execute with full context and subagent access

**For Parallel Jobs (`.parallel.md` files)**:
- Only process if no `.md` files precede them alphabetically
- Batch up to 8 consecutive `.parallel.md` files
- Load task template from `workers/jobs-do-workers/parallel-job-worker.md` if it exists
- Use Task tool with subagent_type: 'general-purpose' and the template
- Each worker:
  - Attempts to lock by renaming to `.parallel.md.working`
  - Pre-scans content for context requirements (subagent usage, user interaction)
  - Returns "NEEDS_CONTEXT" if job requires main agent execution
  - Otherwise processes the job in isolation
- Main agent:
  - Coordinates and aggregates worker results
  - For jobs with "NEEDS_CONTEXT" status, processes them sequentially
  - Continues with remaining parallel jobs

### 3. Execute Job Instructions
Read the contents of the `.working` file and parse it for frontmatter and content.

**Parse Job File Structure**:
1. **Check for YAML frontmatter**: If the file starts with `---`, parse the YAML frontmatter section
2. **Extract frontmatter metadata** (if present):
   - title: Job description for display
   - created: Creation date
   - origin: What led to creating this job
   - priority: Execution priority level
   - complexity: Expected difficulty
   - notes: Additional context or constraints
3. **Extract executable content**: Everything after the closing `---` (or entire file if no frontmatter)
4. **Display job information**: Show frontmatter details for better tracking:
   ```
   📋 Executing Job: [title]
   📅 Created: [created] | 🎯 Priority: [priority] | ⚙️ Complexity: [complexity]
   📝 Origin: [origin]
   📄 Notes: [notes list]
   ```

**Check for Slash Command References** (in the executable content):
If the job content mentions executing a slash command (patterns like "run /memory:learn", "execute /docs:readme-audit", "use the slash command /X", "invoke /X", or any reference to executing slash commands):
1. Extract the slash command name (e.g., `/memory:learn`)
2. Convert to file path format:
   - `/command` → `command.md`
   - `/namespace:command` → `namespace/command.md`
3. Use Glob to find the command definition file:
   - First check `.claude/commands/[path]` (project-local)
   - Then check `~/.claude/commands/[path]` (global)
   - Finally check `commands/[path]` (this framework repository)
4. If found: Immediately read that command definition file and execute all its instructions
5. If not found: Report an error that the command doesn't exist

**Execute the job content** (not including frontmatter):
- Treat only the executable content (after frontmatter) as the user message
- Execute any tasks, write any code, perform any operations specified
- Use all available tools as needed to complete the job
- Do not add any preamble or explanation - just do what the content says
- Update TodoWrite to mark current job as in_progress (include title from frontmatter if available)
- Do NOT stop to ask unimportant things to the user; make decisions and proceed unless the content itself specifies to ask the user
- Note any new or updated stop condition that might be specified in the working file

### 4. Completion Verification

**After job execution appears successful:**

Before marking a job as done, optionally verify it actually accomplished its goals:

1. **Determine if verification is needed**:
   - Skip for simple, deterministic jobs (e.g., "run tests", "commit changes")
   - Skip if job explicitly says "no verification needed"
   - Verify for complex jobs with specific outcomes (e.g., "refactor", "optimize", "fix bug")
   - Verify if job mentions expected results or success criteria

2. **Extract expected outcomes from job description** (if verifying):
   - Parse the job file for success criteria, goals, or expected results
   - Identify specific files, changes, or outcomes mentioned

3. **Use completion-verifier agent** (if verifying):
   - Invoke via Task tool: `Task(subagent_type: 'completion-verifier', prompt: 'Verify job completion: [job description and expected outcomes]')`
   - Provide the job's original instructions and what was supposedly done
   - Let the verifier check if the actual results match expectations

4. **Handle verification results**:
   - **If verified complete**: Proceed to mark as `.done`
   - **If verification fails**: Mark as `.needs-verification` with details
   - **If partially complete**: Create follow-up job for remaining work

### 5. Error Handling and Recovery

**Robust Error Recovery System**:
- **Context Detection**: Workers detecting context needs return jobs for sequential processing
- **Retry Logic**: Jobs that fail with recoverable errors are marked with `.retry` extension
- **Abandoned Job Recovery**: Detect and recover `.working` files older than 30 minutes
- **Graceful Degradation**: If parallel processing fails, fall back to sequential mode
- **Resource Monitoring**: Monitor system resources and adjust parallel job count if needed

**Job Completion Handling**:

**If execution succeeded AND verification passed:**
- Rename from `{name}.md.working` to `{name}.md.done` using Bash `mv`
- Create comprehensive `{name}.md.done_log` with:
  - **Job metadata** (from frontmatter): title, created date, origin, priority, complexity
  - Execution timestamps (start/end duration)
  - Processing mode (sequential/parallel)
  - Verification status: "✓ Verified complete by completion-verifier"
  - Detailed accomplishments and outcomes
  - Performance metrics (execution time, resources used)
  - Key learnings and insights from job execution
  - Any warnings or recommendations for future jobs
- Log "✓ Completed: [title from frontmatter] (duration: Xs, priority: [priority], complexity: [complexity])"
- Update TodoWrite with completion status using job title and metadata

**If execution succeeded but verification failed:**
- Rename to `{name}.md.needs-verification`
- Create `{name}.md.verification_log` with:
  - What was expected vs what was found
  - Specific gaps or issues identified
  - Suggestions for completion
- Log "⚠️ Job executed but verification failed: {name}"
- Optionally create follow-up job for remaining work

**If execution encountered errors:**
- Implement retry logic for recoverable errors (network timeouts, temporary file locks)
- For permanent failures: rename to `{name}.md.error`
- For recoverable failures: rename to `{name}.md.retry` (max 3 retry attempts)
- Create detailed `{name}.md.error_log` or `{name}.md.retry_log` with:
  - Full error context and stack traces
  - System state at time of failure
  - Retry attempt history if applicable
  - Suggested manual intervention steps
  - Partial progress preservation for resumption
- Log "✗ Failed job: {name} - {error_type} - see log for details"
- Update TodoWrite with failure analysis and next steps

### 6. Check Stop Condition
Evaluate the stop condition if provided:
- "N files" - stop after processing N files (count both completed and failed)
- "N minutes" - calculate elapsed time since start, stop if exceeded
- "until empty" - stop when no more unprocessed .md files found
- "until error" - stop when there was some error and a job couldn't complete
- "until verification fails" - stop when a job fails verification
- Any other condition specified when /jobs:do was invoked OR in the latest working file itself - respect exactly as specified
- No condition - continue indefinitely until user interrupts

### 7. Continue Loop
Return to step 1 to find the next job file.

## Implementation Details

- **File Processing Order**: Always process files in alphabetical order for predictability
- **Concurrency Safety**: Enhanced locking with `.jobqueue` coordination file and atomic operations
- **Parallel Safety**: Each worker operates independently with its own locking mechanism
- **Failed Renames**: Intelligent retry logic distinguishes between race conditions and system errors
- **Execution Context**: Support for both sequential and parallel execution contexts
- **Status Visibility**: Real-time TodoWrite updates with detailed progress metrics
- **Resource Management**: Adaptive job batching based on system resources and queue size
- **Recovery Mechanisms**: Automatic detection and recovery of abandoned or stuck jobs

## Advanced Error Handling

- **Missing Folder**: Auto-create jobs folder structure with proper permissions using Bash `mkdir -p`
- **Job Execution Errors**: Comprehensive error classification and handling:
  - **Transient Errors**: Network timeouts, temporary file locks - trigger retry mechanism
  - **Permanent Errors**: Syntax errors, missing dependencies - mark as `.error`
  - **Resource Errors**: Memory/disk issues - pause processing and alert user
- **Malformed Job Files**: Validate job file format and provide detailed error diagnostics
- **Interruption Handling**: Graceful shutdown with proper cleanup of all `.working` files
- **Parallel Processing Errors**: If workers fail, collect partial results and continue with remaining jobs
- **System Resource Monitoring**: Monitor CPU/memory usage and adjust parallel job count dynamically
- **Recovery from Crashes**: On startup, scan for and recover any orphaned `.working` files

## Enhanced Status Reporting

Maintain comprehensive status reporting throughout execution:
- **Startup**: "🚀 Starting job queue processing in {folder} (mode: {sequential/parallel/auto})"
- **Job Progress**: "📋 Processing batch {X}: {job_names} (parallel: {count}/8)" or "🔄 Processing job {X} of {Y}: {filename}"
- **Performance Metrics**: Include processing rate, average job duration, resource utilization
- **Completion Summary**: "✅ Job queue complete: {X} succeeded, {Y} failed, {Z} retried (total time: {duration})"
- **Waiting Status**: "⏳ Queue empty, adaptive polling (interval: {X}s)..." (every 3rd cycle)
- **Error Alerts**: "⚠️ {count} jobs need manual intervention - see error logs"
- **Resource Warnings**: Alert when system resources are constrained

## Performance Optimizations

- **Adaptive Polling**: Dynamic wait intervals based on job processing patterns
- **Smart Batching**: Intelligent grouping of jobs for optimal parallel processing
- **Resource Awareness**: Monitor system resources and adjust concurrency accordingly
- **Efficient File Operations**: Use atomic operations and minimize filesystem calls
- **Memory Management**: Stream large job files and clean up resources promptly
