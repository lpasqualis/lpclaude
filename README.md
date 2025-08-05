**Version:** 1.0  
**Date:** August 4, 2025  
**Author:** Lorenzo Pasqualis  

# Claude Agent Configuration Repository

This repository contains custom agents and commands for Claude AI, designed to enhance productivity and maintain project-specific conventions.

## Usage

These agents and commands are designed to be used with Claude AI to enhance project management, code quality, and knowledge retention. Each agent and command has specific trigger conditions and use cases as outlined in their respective files.

### Installation

To use this repository's agents and commands globally, run the setup script:

```bash
# From the repository root
./setup.sh
```

The setup script will:
- **Automatically run `build.sh` first** to ensure CLAUDE_global_directives.md is up to date
- Automatically detect the repository path
- Create all necessary symlinks
- Skip existing files/symlinks (non-destructive)
- Report which symlinks were created or skipped

#### Important: Building CLAUDE_global_directives.md

The `CLAUDE_global_directives.md` file is **automatically generated** and should **NEVER be edited manually**. This file is built by the `build.sh` script, which:

1. **Collects all directive files** from the `directives/` directory (excluding .gitignore and local files)
2. **Aggregates their content** into a single comprehensive file
3. **Adds metadata** including build timestamp
4. **Creates the final CLAUDE_global_directives.md** file

**When to run build.sh:**
- Automatically runs when you execute `setup.sh`
- **Must be run manually** whenever you:
  - Add a new directive file to `directives/`
  - Modify any existing directive file
  - Delete a directive file

**How to run build.sh:**
```bash
# From the repository root
./build.sh
```

**Build process details:**
- The script scans for all `.md` files in `directives/` (except `.local.md` files which are ignored)
- Each directive file's content is included with a header indicating its source
- The resulting `CLAUDE_global_directives.md` serves as the master directive file when symlinked to `~/.claude/CLAUDE.md`
- Any manual edits to `CLAUDE_global_directives.md` will be lost on the next build

## Agents

### 1. Subagent Formatter
**File:** `agents/subagent-formatter.md`  
**Purpose:** Formats and improves the readability of Claude Code subagent definition files.  
**Use Cases:**
- Converting single-line YAML descriptions to literal block format
- Improving readability of agent definition files
- Cleaning up formatting in agent files
- Proactively lints and formats agent definition files

### 2. Subagent Optimizer
**File:** `agents/subagent-optimizer.md`  
**Purpose:** Audits and enforces best practices on subagent definition files, optimizing structure, model selection, color assignment, and proactive directives.  
**Use Cases:**
- Refactoring agent descriptions for clarity and compliance
- Optimizing model selection based on task complexity (haiku/sonnet/opus)
- Assigning semantic colors based on agent function
- Adding proactive directives when appropriate
- Operates idempotently - only makes changes when necessary

### 3. Command Optimizer
**File:** `agents/command-optimizer.md`  
**Purpose:** Audits and enforces best practices on slash command definition files, optimizing frontmatter and prompt content only when necessary.  
**Use Cases:**
- Refactoring command descriptions for clarity and accuracy
- Auditing tool permissions for security compliance (Principle of Least Privilege)
- Improving argument hints and placeholder usage
- Ensuring proper use of placeholders like `{{selected_text}}`
- Checking latest documentation for updated best practices
- Operates idempotently - only makes changes when necessary

### 4. Memory Keeper Agent
**File:** `agents/memory-keeper.md`  
**Purpose:** Records NEW information, facts, decisions, or project-specific information in the CLAUDE.md file for long-term memory.  
**Use Cases:**
- Recording architectural decisions
- Establishing coding standards and conventions
- Documenting project-specific configurations
- Creating or updating CLAUDE.md files

### 5. Claude MD Quality Reviewer Agent
**File:** `agents/claude-md-quality-reviewer.md`  
**Purpose:** Reviews and improves the quality, organization, and consistency of EXISTING CLAUDE.md files.  
**Use Cases:**
- Checking for contradictions and redundancies in CLAUDE.md
- Reorganizing content for better clarity
- Resolving conflicting instructions
- Improving overall file structure and formatting

### 6. Hack Spotter Agent
**File:** `agents/hack-spotter.md`  
**Purpose:** Reviews code for technical debt, shortcuts, hardcoded values, and brittle implementations.  
**Use Cases:**
- Analyzing code for hardcoded secrets and magic numbers
- Finding brittle logic and temporary workarounds
- Detecting disabled safeguards and workflow bypasses
- Identifying configuration workarounds
- Focuses on production code (not test code)

### 7. Implan Auditor Agent
**File:** `agents/implan-auditor.md`  
**Purpose:** Audits implementation plans (implans) for completeness, correctness, and compliance with requirements.  
**Use Cases:**
- Detecting incomplete implementations and stubs
- Finding TODOs and temporary implementations
- Ensuring implans meet all stated requirements
- Adding testing phases when needed
- Verifying compliance with project standards

### 8. Documentation Auditor Agent
**File:** `agents/documentation-auditor.md`  
**Purpose:** Comprehensively audits and updates documentation to ensure accuracy and relevance.  
**Use Cases:**
- Assessing documentation accuracy against current codebase
- Identifying outdated or conflicting information
- Consolidating redundant documentation
- Ensuring code examples and API documentation are current
- Note: Excludes CLAUDE.md files (use specialized agents for those)

## Commands

### 1. Review Subagent Echosystem Command
**File:** `commands/review-subagent-echosystem.md`  
**Purpose:** Analyzes sub-agent definition files to identify ambiguities, overlaps, conflicts, and gaps in capabilities.  
**Output:** Comprehensive report with executive summary, detailed analysis table, and actionable recommendations for improving the agent ecosystem.

### 2. Capture Session Command
**File:** `commands/capture-session.md`  
**Purpose:** Documents the complete status of work done in a session for seamless handoff to other agents.  
**Output Location:** `docs/dev_notes/` folder  
**Includes:**
- Problem statement
- Actions taken
- Key findings and technical insights
- Next steps and recommendations

### 3. Capture Strategy Command
**File:** `commands/capture-strategy.md`  
**Purpose:** Creates a comprehensive project context document for any agent to pick up work without loss of context.  
**Output Location:** Main documents folder of the current project  
**Includes:**
- Problem statement and success criteria
- Strategy overview
- Phased implementation plan
- Document usage notes
- Technical notes

### 4. Commit and Push Command
**File:** `commands/commit-and-push.md`  
**Purpose:** Intelligently commits and pushes changes to git repository.  
**Features:**
- Reviews all changed files in the project
- Groups changes into logical commits
- Uses semantic commit notation
- Creates clear, concise commit messages
- Pushes to origin

### 5. Create Command Command
**File:** `commands/create-command.md`  
**Purpose:** Interactive command creator that helps create new Claude Code commands.  
**Features:**
- Guides through command type selection (project vs personal)
- Helps define command requirements and details
- Creates properly formatted command files
- Provides templates and best practices

### 6. Learn Command
**File:** `commands/learn.md`  
**Purpose:** Extracts and preserves important learnings from the current session for future reference.  
**Captures:**
- Technical discoveries and solutions
- Configuration and setup details
- Gotchas and pitfalls encountered
- Project-specific insights
- Workflow optimizations

### 7. Create Implan Command
**File:** `commands/create-implan.md`  
**Purpose:** Creates a comprehensive implementation plan from the current conversation context.  
**Features:**
- Analyzes conversation for requirements and approach
- Creates structured implementation plans
- Saves to `docs/implans/` directory
- Uses standardized naming convention
- Can update existing plans

### 8. Work on Implan Command
**File:** `commands/workon-implan.md`  
**Purpose:** Resumes work on an existing implementation plan.  
**Features:**
- Finds and loads active implementation plans
- Analyzes current progress and next steps
- Continues implementation based on plan
- Updates plan status as work progresses
- Handles multiple active plans

## Directory Structure

```
├── agents/
│   ├── claude-md-quality-reviewer.md
│   ├── command-optimizer.md
│   ├── documentation-auditor.md
│   ├── hack-spotter.md
│   ├── implan-auditor.md
│   ├── memory-keeper.md
│   ├── subagent-formatter.md
│   └── subagent-optimizer.md
├── directives/
│   ├── .gitignore
│   └── CLAUDE_global_directives.md
├── commands/
│   ├── capture-session.md
│   ├── capture-strategy.md
│   ├── commit-and-push.md
│   ├── create-command.md
│   ├── create-implan.md
│   ├── learn.md
│   ├── review-subagent-echosystem.md
│   └── workon-implan.md
├── resources/
│   └── commands_and_agents.md
├── .gitignore
├── CLAUDE.md
├── README.md
└── setup.sh
```

## Resources

The `resources/` directory contains supporting files:
- **`commands_and_agents.md`**: Comprehensive technical deep dive into Claude Code subagents and agentic workflows, including architecture, creation, invocation mechanics, and best practices for parallel execution

## Claude Directives

The `directives/` directory contains:
- **`CLAUDE_global_directives.md`**: A dynamic loader for global Claude directives that implements situational directive loading based on context and relevance. This file can be symlinked from `~/.claude/CLAUDE.md` to enable automatic loading of relevant directive files
- This directory enables version control of personal Claude preferences
- The dynamic loading system analyzes directive filenames and content to apply only relevant directives based on the current project type, language, or context
- Additional directive files can be added for specific contexts (language-specific, project-type-specific, etc.)
