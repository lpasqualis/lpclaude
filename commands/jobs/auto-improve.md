---
name: /jobs:auto-improve
description: Natural language project improvement system that understands contextual improvement requests and creates targeted scanners with safeguards against infinite loops
argument-hint: ["improvement description (e.g., 'migrate to modern libraries', 'follow best practices')"]
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, Bash, Task, WebFetch, WebSearch
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-22 09:50:48 -->

# Intelligent Project Improvement Orchestrator

Parse user improvement requests using natural language understanding to create targeted, context-aware improvements.

## Step 1: Parse Natural Language Request

Extract from user input:
- **Target scope**: Examples: Specific files, patterns, or project-wide
- **Improvement intent**: Examples: Technology migrations, pattern updates, quality fixes, research-driven updates
- **Constraints**: What to preserve/avoid 
- **Research needs**: Keywords indicating need for current best practices
- **Execution params**: Number of improvements (default: 3-5), continuous mode, iteration limits

Initialize iteration tracking:
- Check `jobs/` directory for existing `NNNN-auto-improve-session-*.md` files to count iterations
- Validate iteration limits (max 10 unless specified)
- Let @addjob subagent handle proper job numbering automatically

## Step 2: Check Previous Improvements
Scan jobs/ folder for previous auto-improve jobs:
- Look for `NNNN-auto-improve-*.md.done` files to avoid duplicate improvements
- Check `NNNN-auto-improve-*.md.error` files for failed attempts that shouldn't be retried
- Use completion-verifier agent if needed to validate suspicious completions

## Step 3: Context-Aware Research and Scanning

### Research Phase (if needed)
When request contains "modern", "best practices", "latest", or explicit research requests:
- Use WebFetch/WebSearch to gather current standards
- Cache findings for scanner instructions

### Parallel Scanning Strategy
Load context-aware scanner template:
```
template = Read('workers/jobs-auto-improve-workers/scanner.md')
```

Execute parallel scanning based on scope:
- **Single file/pattern**: Direct analysis with enhanced context
- **Multiple targets (3+)**: Parallel scanning with batching (max 10 concurrent)
- **Project-wide**: Adaptive scanning by discovered file types

Pass to each scanner:
- Original user request
- Parsed intent and constraints  
- Research findings (if applicable)
- Improvement history to avoid duplicates

## Step 4: Create Initial Improvement Jobs

Filter improvements by relevance to original request:
- **High**: Directly addresses stated intent
- **Medium**: Related to intent or mentioned areas  
- **Low**: General improvements found incidentally

Create initial batch of improvement jobs using the @addjob subagent:
- Include WHY this improvement matches the request
- Reference specific parts of original request
- Implementation details with constraint compliance
- These seed the continuous improvement loop in Step 6

## Step 5: Read and Follow the /jobs:do Command Instructions

1. **Locate and read the /jobs:do slash command file**:
   - /jobs:do is a slash command stored as a markdown file at `~/.claude/commands/jobs/do.md`
   - Use Read tool to read this instruction file: `Read('~/.claude/commands/jobs/do.md')`
   - This is NOT a bash command - it's a markdown file containing step-by-step instructions

2. **Follow the instructions from the /jobs:do file exactly**:
   - Start implementing from the "Execution Process" section of that file
   - Follow ALL the job processing steps as written in the file
   - This includes: finding jobs, locking, processing, error handling, etc.

3. **Initialize auto-improve tracking**:
   - TodoWrite list for improvement progress
   - Iteration counter and quality metrics
   - Stop conditions based on parsed user intent
   - Job metrics: counters, timestamps, file modifications, job genealogy

## Step 6: Auto-Improve Enhancements to Job Processing

While following the job processing instructions from the /jobs:do markdown file, add these auto-improve specific behaviors:

1. **Dynamic Improvement Discovery**:
   After each job completes successfully:
   - **Assess progress**: Evaluate how well the improvement addressed the intent
   - **Quality check**: If user specified quality criteria, invoke one or more parallel Task tools with independent verification agent(s)
   - **Identify gaps**: Analyze what still needs improvement
   - **Create new jobs**: If intent not reached and improvements possible:
     - Use @addjob subagent to create new jobs
     - These new jobs immediately join the queue for processing
   - **Learn and adapt**: Each new job incorporates learnings from previous iterations

2. **Jobs Creating Jobs**:
   Individual improvement jobs can themselves create follow-up jobs:
   - A job fixing tests might create jobs to fix newly discovered test failures
   - A refactoring job might create cleanup jobs for deprecated code it found
   - A performance job might create optimization jobs for specific bottlenecks
   - Track these as "child jobs" in metrics (job chain depth)

3. **Stop Condition Evaluation**:
   Continue loop until ANY condition is met:
   - **Intent achieved**: Quality verification confirms specified standard is met
   - **Exhaustion**: No more improvements identified after scanning
   - **Constraint boundary**: Further changes would violate preserved areas
   - **Iteration limit**: Reached max iterations (default 10, configurable)
   - **User condition**: Any custom stop condition from user is satisfied
   - **Error threshold**: Too many consecutive job failures
   - **Explicit check**: User requested "keep going until X" - use Task to verify X

### Quality Verification Integration
When user specifies quality standards (e.g., "until tests pass", "until performance improves by 50%"):
- Create verification job that uses Task tool with appropriate agent
- Verification job evaluates if standard is met
- If not met, create targeted improvement jobs for specific gaps
- If met, set stop flag to exit loop

### Continuous Learning
- Each completed job can discover new improvement opportunities
- Jobs can create follow-up jobs for deeper improvements
- System adapts based on what works and what doesn't
- Maintains context across all iterations for coherent improvements

## Step 7: Session Reporting

Provide comprehensive execution summary with detailed metrics:

### Improvement Summary
- **Original Request**: Echo the user's improvement intent
- **Final Status**: Quality gate achieved / Iteration limit / Error threshold / Manual stop
- **Key Achievements**: List major improvements made to meet the intent

### Job Execution Metrics
- **Jobs Created**: Total number (initial batch + dynamically created)
  - Initial scanner jobs: X
  - Improvement jobs: Y  
  - Verification jobs: Z
  - Follow-up jobs created by jobs: W
- **Jobs Executed**: X completed, Y failed, Z skipped
- **Success Rate**: Percentage of jobs completed successfully
- **Job Chain Depth**: Maximum depth of jobs creating other jobs

### Performance Metrics
- **Total Duration**: Start to finish time (e.g., "23 minutes 45 seconds")
- **Average Job Time**: Mean execution time per job
- **Iterations Completed**: Number of improvement cycles
- **Files Modified**: Count of unique files changed
- **Lines Changed**: Additions/deletions across all improvements

### Quality Verification
- **Verification Runs**: Number of quality checks performed
- **Final Score**: If quality metrics were tracked
- **Standards Met**: Which specific criteria were achieved
- **Remaining Gaps**: Any identified issues not addressed

### Session Details
- **Stop Reason**: Why the session ended (goal achieved, limit reached, etc.)
- **Constraint Compliance**: Confirmation that boundaries were respected
- **Research Performed**: Any external lookups or best practices discovered
- **Next Steps**: Recommendations or queued work for future sessions

## Example Usage

**Technology Migration with Quality Gate**:
`/jobs:auto-improve "migrate all database queries from raw SQL to SQLAlchemy ORM until all tests pass, but keep the existing schema unchanged"`
- Creates initial migration jobs, executes them, checks test results, creates fix jobs for failures, continues until tests pass

**Best Practices with Continuous Discovery**:
`/jobs:auto-improve "update all React components to use modern hooks patterns, keep going until no more class components exist"`
- Scans for class components, converts them, re-scans for any missed ones, continues until exhausted

**Performance Improvement with Metric Target**:
`/jobs:auto-improve "optimize API endpoints until response time improves by 50% or 10 iterations complete"`
- Creates optimization jobs, measures performance after each, creates targeted improvements based on bottlenecks found

**Quality with Constraints**:
`/jobs:auto-improve "improve error handling throughout the codebase but don't change any public API signatures"`
- Continuously finds and improves error handling while respecting API boundaries

## Implementation Notes

### Natural Language Processing
Identify intent from user input:
- Technology/library names for migrations
- Action verbs (migrate, update, improve, fix, research)
- File names and paths for targeted scope
- Constraint language ("but", "except", "maintain", "preserve")

### Research Integration
- Detect research needs from keywords ("modern", "latest", "best practices")
- Use WebFetch/WebSearch before scanning when appropriate
- Include research findings in scanner context
- Cache research results for efficiency

## Key Advantages

**Continuous Until Done**: Keeps improving until specified intent/quality is achieved
**Self-Correcting**: Each iteration can fix issues from previous attempts
**Context-Aware**: Responds to actual user intent, not predetermined categories
**Research-Driven**: Discovers current best practices when needed  
**Constraint-Respectful**: Preserves what shouldn't be changed
**Domain-Adaptive**: Works across any technology stack
**Progress-Oriented**: Reports fulfillment of original request
**Dynamic Discovery**: Creates new jobs as new improvements are identified during execution

