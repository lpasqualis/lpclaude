---
name: /jobs:auto-improve
description: Natural language project improvement system that understands contextual improvement requests and creates targeted scanners with safeguards against infinite loops
argument-hint: ["improvement description (e.g., 'migrate to modern libraries', 'follow best practices')"]
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, Bash, Task, WebFetch, WebSearch
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-21 14:36:50 -->

# Intelligent Project Improvement Orchestrator

Parse user improvement requests using natural language understanding to create targeted, context-aware improvements.

## Step 1: Parse Natural Language Request

Extract from user input:
- **Target scope**: Specific files, patterns, or project-wide
- **Improvement intent**: Technology migrations, pattern updates, quality fixes, research-driven updates
- **Constraints**: What to preserve/avoid 
- **Research needs**: Keywords indicating need for current best practices
- **Execution params**: Number of improvements (default: 3-5), continuous mode, iteration limits

Initialize iteration tracking:
- Check `jobs/` directory for existing `NNNN-auto-improve-session-*.md` files to count iterations
- Validate iteration limits (max 10 unless specified)
- Let addjob utility handle proper job numbering automatically

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
template = Read('tasks/jobs-auto-improve-scanner.md')
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

## Step 4: Prioritize and Create Jobs

Filter improvements by relevance to original request:
- **High**: Directly addresses stated intent
- **Medium**: Related to intent or mentioned areas  
- **Low**: General improvements found incidentally

Create contextual improvement jobs including:
- WHY this improvement matches the request
- Reference to specific parts of original request
- Implementation details with constraint compliance

## Step 5: Create Jobs and Continue

Create improvement jobs using the addjob utility:
- Use Bash tool with stdin: `echo "job content" | addjob --stdin "auto-improve-{description}"`
- The utility handles proper numbering and creates files in jobs/ directory  
- Include original request context and specific improvement instructions in job content

Context-aware continuation decision:
- Stop if all specifically requested improvements are complete
- Stop if research shows no better alternatives exist  
- Stop if constraints prevent further improvements
- Stop if iteration limit reached (default: 10)
- Otherwise create continuation job: `echo "Continue auto-improve session..." | addjob --stdin "auto-improve-session-{next-iteration}"`

## Step 6: Session Reporting

Provide summary relating to original request:
- **Request fulfillment**: How well improvements match original intent
- **Jobs created**: Number and types of improvement jobs queued
- **Research findings**: Key discoveries if research was performed
- **Constraint compliance**: Confirmation constraints were respected
- **Iteration status**: Current iteration and whether continuing
- **Next steps**: Jobs queued for processing or session complete

## Example Usage

**Technology Migration**:
`/jobs:auto-improve "migrate all database queries from raw SQL to SQLAlchemy ORM, but keep the existing schema unchanged"`

**Best Practices**:
`/jobs:auto-improve "update all React components to use modern hooks patterns instead of class components, research latest React 18 features"`

**Targeted File Improvements**:
`/jobs:auto-improve "improve spec_v3_1.md to use LiteLLM instead of custom adapters, update to FastMCP 2.0 patterns"`

**Quality with Constraints**:
`/jobs:auto-improve "improve error handling throughout the codebase but don't change any public API signatures"`

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

**Context-Aware**: Responds to actual user intent, not predetermined categories
**Research-Driven**: Discovers current best practices when needed  
**Constraint-Respectful**: Preserves what shouldn't be changed
**Domain-Adaptive**: Works across any technology stack
**Progress-Oriented**: Reports fulfillment of original request