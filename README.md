**Version:** 1.1  
**Date:** August 7, 2025  
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

### 1. Subagent Optimizer
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

### 3. Implan Generator Agent
**File:** `agents/implan-generator.md`  
**Purpose:** A specialized implementation planning expert that creates comprehensive, actionable plans for software features and components.  
**Use Cases:**
- Breaking down complex development tasks into structured phases
- Creating detailed implementation plans with checkboxes and progress tracking
- Generating plans with agent instructions, phase breakdowns, testing requirements
- Starting new features, refactoring components, or organizing development work
- **Proactive**: Automatically triggered when implementation planning is needed

### 4. Memory Keeper Agent
**File:** `agents/memory-keeper.md`  
**Purpose:** Records NEW information, facts, decisions, or project-specific information in the CLAUDE.md file for long-term memory.  
**Use Cases:**
- Recording architectural decisions
- Establishing coding standards and conventions
- Documenting project-specific configurations
- Creating or updating CLAUDE.md files

### 5. Claude MD Optimizer Agent
**File:** `agents/claude-md-optimizer.md`  
**Purpose:** Optimizes and improves the quality, organization, and effectiveness of EXISTING CLAUDE.md files.  
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

## Command-Specific Subagents (cmd-*)

The repository includes specialized subagents designed to work in parallel with specific commands. These agents follow the `cmd-*` naming convention and are optimized for focused, specialized processing.

### 1. Session Analysis Agent
**File:** `agents/cmd-capture-session-analyzer.md`  
**Purpose:** Specialized agent for analyzing specific aspects of development sessions in parallel for capture-session and capture-strategy commands.  
**Use Cases:**
- Codebase structure analysis and architectural pattern identification
- Recent changes analysis and git history review
- Technical context analysis of specific files or code sections
- Problem domain analysis and requirement understanding
- **Model**: haiku (optimized for speed in parallel execution)

### 2. Commit Analysis Agent  
**File:** `agents/cmd-commit-and-push-analyzer.md`  
**Purpose:** Analyze changed files and classify them into logical commit groups with semantic commit types for the commit-and-push command.  
**Use Cases:**
- File classification into semantic commit categories (feat, fix, docs, etc.)
- Logical grouping of related files for coherent commits
- Priority assessment and commit ordering recommendations
- JSON-structured output for automated processing

### 3. Commit Security Agent
**File:** `agents/cmd-commit-and-push-security.md`  
**Purpose:** Analyze file contents for sensitive data, large binaries, and security concerns during commit preparation.  
**Use Cases:**
- Sensitive data detection (API keys, passwords, private keys)
- File size and type analysis for Git LFS recommendations
- Security risk assessment and anti-pattern identification
- Actionable security recommendations with risk levels

### 4. Commit Validator Agent
**File:** `agents/cmd-commit-and-push-validator.md`  
**Purpose:** Validate commit messages, file changes, and repository state before pushing changes.  
**Use Cases:**
- Commit message format validation against semantic conventions
- Change impact assessment and risk analysis
- Repository state verification and conflict detection
- Pre-push validation and quality gates

### 5. Command Validator Agent
**File:** `agents/cmd-create-command-validator.md`  
**Purpose:** Validate command definitions during command creation process.  
**Use Cases:**
- YAML frontmatter validation for required fields
- Command naming convention compliance
- Tool permission auditing for security best practices
- Command structure and format verification

### 6. Learning Analyzer Agent
**File:** `agents/cmd-learn-analyzer.md`  
**Purpose:** Extract and analyze learnings from development sessions for the learn command.  
**Use Cases:**
- Technical discovery identification and categorization
- Pattern recognition in development workflows
- Knowledge extraction for future reference
- Learning prioritization and organization

### 7. Ecosystem Analyzer Agent
**File:** `agents/cmd-review-subagent-ecosystem-analyzer.md`  
**Purpose:** Specialized analyzer for reviewing subagent ecosystem health and optimization opportunities.  
**Use Cases:**
- Individual agent analysis for clarity and appropriateness
- Cross-agent compatibility and overlap assessment
- Parallel execution for large agent ecosystems (up to 10 agents)
- Structured analysis output for ecosystem optimization

## Commands

### 1. Review Subagent Ecosystem Command
**File:** `commands/subagents/review-ecosystem.md`  
**Purpose:** Analyzes sub-agent definition files to identify ambiguities, overlaps, conflicts, and gaps in capabilities.  
**Output:** Comprehensive report with executive summary, detailed analysis table, and actionable recommendations for improving the agent ecosystem.

### 2. Capture Session Command
**File:** `commands/docs/capture-session.md`  
**Purpose:** Documents the complete status of work done in a session for seamless handoff to other agents.  
**Output Location:** `docs/dev_notes/` folder  
**Includes:**
- Problem statement
- Actions taken
- Key findings and technical insights
- Next steps and recommendations

### 3. Capture Strategy Command
**File:** `commands/docs/capture-strategy.md`  
**Purpose:** Creates a comprehensive project context document for any agent to pick up work without loss of context.  
**Output Location:** Main documents folder of the current project  
**Includes:**
- Problem statement and success criteria
- Strategy overview
- Phased implementation plan
- Document usage notes
- Technical notes

### 4. Commit and Push Command
**File:** `commands/git/commit-and-push.md`  
**Purpose:** Intelligently commits and pushes changes to git repository.  
**Features:**
- Reviews all changed files in the project
- Groups changes into logical commits
- Uses semantic commit notation
- Creates clear, concise commit messages
- Pushes to origin

### 5. Create Command Command
**File:** `commands/commands/create.md`  
**Purpose:** Interactive command creator that helps create new Claude Code commands.  
**Features:**
- Guides through command type selection (project vs personal)
- Helps define command requirements and details
- Creates properly formatted command files
- Provides templates and best practices

### 6. Learn Command
**File:** `commands/memory/learn.md`  
**Purpose:** Extracts and preserves important learnings from the current session for future reference.  
**Captures:**
- Technical discoveries and solutions
- Configuration and setup details
- Gotchas and pitfalls encountered
- Project-specific insights
- Workflow optimizations

### 7. Create Implan Command
**File:** `commands/implan/create.md`  
**Purpose:** Creates a comprehensive implementation plan from the current conversation context.  
**Features:**
- Analyzes conversation for requirements and approach
- Creates structured implementation plans
- Saves to `docs/implans/` directory
- Uses standardized naming convention
- Can update existing plans

### 8. Work on Implan Command
**File:** `commands/implan/execute.md`  
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
│   ├── claude-md-optimizer.md
│   ├── cmd-capture-session-analyzer.md
│   ├── cmd-commit-and-push-analyzer.md
│   ├── cmd-commit-and-push-security.md
│   ├── cmd-commit-and-push-validator.md
│   ├── cmd-create-command-validator.md
│   ├── cmd-learn-analyzer.md
│   ├── cmd-review-subagent-ecosystem-analyzer.md
│   ├── command-optimizer.md
│   ├── documentation-auditor.md
│   ├── hack-spotter.md
│   ├── implan-auditor.md
│   ├── implan-generator.md
│   ├── memory-keeper.md
│   └── subagent-optimizer.md
├── directives/
│   ├── .gitignore
│   └── CLAUDE_global_directives.md
├── commands/
│   ├── commands/
│   │   ├── create.md
│   │   └── normalize.md
│   ├── docs/
│   │   ├── capture-session.md
│   │   └── capture-strategy.md
│   ├── git/
│   │   └── commit-and-push.md
│   ├── implan/
│   │   ├── create.md
│   │   └── execute.md
│   ├── memory/
│   │   └── learn.md
│   └── subagents/
│       └── review-ecosystem.md
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
