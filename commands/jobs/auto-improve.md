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

Initialize state:
- Check `.claude/improvement-history.json`
- Validate iteration limits (max 10 unless specified)
- Load previous improvements to avoid duplicates

## Step 2: Verify Previous Completions
Use completion-verifier agent to validate previous improvements from history.

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

## Step 5: Update State and Continue

Update improvement history with new jobs.

Context-aware continuation:
- Stop if all specifically requested improvements are complete
- Stop if research shows no better alternatives exist
- Stop if constraints prevent further improvements
- Otherwise continue with standard iteration limits

## Step 6: Session Reporting

Provide summary relating to original request:
- **Request fulfillment**: How well improvements match original intent
- **Specific progress**: Status on requested changes
- **Research findings**: Key discoveries if research was performed
- **Constraint compliance**: Confirmation constraints were respected

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