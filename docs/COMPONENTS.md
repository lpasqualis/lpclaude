# Component Reference

Complete inventory of all agents and commands in the Claude Framework.

## Agents

### Core Optimization Agents

#### Subagent Optimizer
**File:** `agents/subagent-optimizer.md`  
**Purpose:** Audits and enforces best practices on subagent definition files, optimizing structure, model selection, color assignment, and proactive directives.  
**Use Cases:**
- Refactoring agent descriptions for clarity and compliance
- Optimizing model selection based on task complexity (haiku/sonnet/opus)
- Assigning semantic colors based on agent function
- Adding proactive directives when appropriate
- Operates idempotently - only makes changes when necessary

#### Command Optimizer
**File:** `agents/command-optimizer.md`  
**Purpose:** Audits and enforces best practices on slash command definition files, optimizing frontmatter and prompt content only when necessary.  
**Use Cases:**
- Refactoring command descriptions for clarity and accuracy
- Auditing tool permissions for security compliance (Principle of Least Privilege)
- Improving argument hints and placeholder usage
- Ensuring proper use of placeholders like `{{selected_text}}`
- Checking latest documentation for updated best practices
- Operates idempotently - only makes changes when necessary

### Content Management Agents

#### Memory Keeper Agent
**File:** `agents/memory-keeper.md`  
**Purpose:** Records NEW information, facts, decisions, or project-specific information in the CLAUDE.md file for long-term memory.  
**Use Cases:**
- Recording architectural decisions
- Establishing coding standards and conventions
- Documenting project-specific configurations
- Creating or updating CLAUDE.md files

#### Claude MD Optimizer Agent
**File:** `agents/claude-md-optimizer.md`  
**Purpose:** Optimizes and improves the quality, organization, and effectiveness of EXISTING CLAUDE.md files.  
**Use Cases:**
- Checking for contradictions and redundancies in CLAUDE.md
- Reorganizing content for better clarity
- Resolving conflicting instructions
- Improving overall file structure and formatting

### Development Support Agents

#### Implan Generator Agent
**File:** `agents/implan-generator.md`  
**Purpose:** A specialized implementation planning expert that creates comprehensive, actionable plans for software features and components.  
**Use Cases:**
- Breaking down complex development tasks into structured phases
- Creating detailed implementation plans with checkboxes and progress tracking
- Generating plans with agent instructions, phase breakdowns, testing requirements
- Starting new features, refactoring components, or organizing development work
- **Proactive**: Automatically triggered when implementation planning is needed

#### Implan Auditor Agent
**File:** `agents/implan-auditor.md`  
**Purpose:** Audits implementation plans (implans) for completeness, correctness, and compliance with requirements.  
**Use Cases:**
- Detecting incomplete implementations and stubs
- Finding TODOs and temporary implementations
- Ensuring implans meet all stated requirements
- Adding testing phases when needed
- Verifying compliance with project standards

### Code Quality Agents

#### Hack Spotter Agent
**File:** `agents/hack-spotter.md`  
**Purpose:** Reviews code for technical debt, shortcuts, hardcoded values, and brittle implementations.  
**Use Cases:**
- Analyzing code for hardcoded secrets and magic numbers
- Finding brittle logic and temporary workarounds
- Detecting disabled safeguards and workflow bypasses
- Identifying configuration workarounds
- Focuses on production code (not test code)

#### Documentation Auditor Agent
**File:** `agents/documentation-auditor.md`  
**Purpose:** Comprehensively audits and updates documentation to ensure accuracy and relevance.  
**Use Cases:**
- Assessing documentation accuracy against current codebase
- Identifying outdated or conflicting information
- Consolidating redundant documentation
- Ensuring code examples and API documentation are current
- Note: Excludes CLAUDE.md files (use specialized agents for those)

### Utility Agents

#### Addjob Agent
**File:** `agents/addjob.md`  
**Purpose:** Creates job files for deferred task execution using the addjob utility when tasks need to be scheduled for later processing.  
**Use Cases:**
- Scheduling complex operations for later execution
- Creating batch processing jobs
- Queueing related tasks for sequential or parallel execution
- Deferring work that doesn't need immediate execution
- Creating self-contained tasks that will run via `/jobs:do` command
- **Proactive**: Automatically triggered when tasks need to be deferred

## Command-Specific Subagents (cmd-*)

These specialized agents work in parallel with specific commands for optimized processing.

### Session Analysis Agent
**File:** `agents/cmd-capture-session-analyzer.md`  
**Purpose:** Specialized agent for analyzing specific aspects of development sessions in parallel for capture-session and capture-strategy commands.  
**Use Cases:**
- Codebase structure analysis and architectural pattern identification
- Recent changes analysis and git history review
- Technical context analysis of specific files or code sections
- Problem domain analysis and requirement understanding
- **Model**: haiku (optimized for speed in parallel execution)

### Commit Analysis Agent  
**File:** `agents/cmd-commit-and-push-analyzer.md`  
**Purpose:** Analyze changed files and classify them into logical commit groups with semantic commit types for the commit-and-push command.  
**Use Cases:**
- File classification into semantic commit categories (feat, fix, docs, etc.)
- Logical grouping of related files for coherent commits
- Priority assessment and commit ordering recommendations
- JSON-structured output for automated processing

### Commit Security Agent
**File:** `agents/cmd-commit-and-push-security.md`  
**Purpose:** Analyze file contents for sensitive data, large binaries, and security concerns during commit preparation.  
**Use Cases:**
- Sensitive data detection (API keys, passwords, private keys)
- File size and type analysis for Git LFS recommendations
- Security risk assessment and anti-pattern identification
- Actionable security recommendations with risk levels

### Commit Validator Agent
**File:** `agents/cmd-commit-and-push-validator.md`  
**Purpose:** Validate commit messages, file changes, and repository state before pushing changes.  
**Use Cases:**
- Commit message format validation against semantic conventions
- Change impact assessment and risk analysis
- Repository state verification and conflict detection
- Pre-push validation and quality gates

### Command Validator Agent
**File:** `agents/cmd-create-command-validator.md`  
**Purpose:** Validate command definitions during command creation process.  
**Use Cases:**
- YAML frontmatter validation for required fields
- Command naming convention compliance
- Tool permission auditing for security best practices
- Command structure and format verification

### Learning Analyzer Agent
**File:** `agents/cmd-learn-analyzer.md`  
**Purpose:** Extract and analyze learnings from development sessions for the learn command.  
**Use Cases:**
- Technical discovery identification and categorization
- Pattern recognition in development workflows
- Knowledge extraction for future reference
- Learning prioritization and organization

### Ecosystem Analyzer Agent
**File:** `agents/cmd-review-subagent-ecosystem-analyzer.md`  
**Purpose:** Specialized analyzer for reviewing subagent ecosystem health and optimization opportunities.  
**Use Cases:**
- Individual agent analysis for clarity and appropriateness
- Cross-agent compatibility and overlap assessment
- Parallel execution for large agent ecosystems (up to 10 agents)
- Structured analysis output for ecosystem optimization

### Command Normalizer Agent
**File:** `agents/cmd-commands-normalize-analyzer.md`  
**Purpose:** Analyzes individual command files for naming conventions, structure, and best practices compliance during parallel normalization operations.

### Jobs Worker Agent
**File:** `agents/cmd-jobs-do-worker.md`  
**Purpose:** Specialized worker for processing .parallel.md job files in isolated parallel execution.

## Commands

### Subagent Management

#### Review Subagent Ecosystem Command
**File:** `commands/subagents/review-ecosystem.md`  
**Purpose:** Analyzes sub-agent definition files to identify ambiguities, overlaps, conflicts, and gaps in capabilities.  
**Output:** Comprehensive report with executive summary, detailed analysis table, and actionable recommendations for improving the agent ecosystem.

### Documentation Commands

#### Capture Session Command
**File:** `commands/docs/capture-session.md`  
**Purpose:** Documents the complete status of work done in a session for seamless handoff to other agents.  
**Output Location:** `docs/dev_notes/` folder  
**Includes:**
- Problem statement
- Actions taken
- Key findings and technical insights
- Next steps and recommendations

#### Capture Strategy Command
**File:** `commands/docs/capture-strategy.md`  
**Purpose:** Creates a comprehensive project context document for any agent to pick up work without loss of context.  
**Output Location:** Main documents folder of the current project  
**Includes:**
- Problem statement and success criteria
- Strategy overview
- Phased implementation plan
- Document usage notes
- Technical notes

#### README Audit Command
**File:** `commands/docs/readme-audit.md`  
**Purpose:** Audits and optimizes README.md files to ensure outstanding user experience.  
**Features:**
- Analyzes current README structure and content
- Identifies misplaced technical details
- Relocates content to appropriate documentation files
- Optimizes for user journey and progressive disclosure

### Git Operations

#### Commit and Push Command
**File:** `commands/git/commit-and-push.md`  
**Purpose:** Intelligently commits and pushes changes to git repository.  
**Features:**
- Reviews all changed files in the project
- Groups changes into logical commits
- Uses semantic commit notation
- Creates clear, concise commit messages
- Pushes to origin

### Command Management

#### Create Command Command
**File:** `commands/commands/create.md`  
**Purpose:** Interactive command creator that helps create new Claude Code commands.  
**Features:**
- Guides through command type selection (project vs personal)
- Helps define command requirements and details
- Creates properly formatted command files
- Provides templates and best practices

#### Normalize Commands Command
**File:** `commands/commands/normalize.md`  
**Purpose:** Normalizes command structure and naming conventions across the framework.

### Memory Management

#### Learn Command
**File:** `commands/memory/learn.md`  
**Purpose:** Extracts and preserves important learnings from the current session for future reference.  
**Captures:**
- Technical discoveries and solutions
- Configuration and setup details
- Gotchas and pitfalls encountered
- Project-specific insights
- Workflow optimizations

### Implementation Planning

#### Create Implan Command
**File:** `commands/implan/create.md`  
**Purpose:** Creates a comprehensive implementation plan from the current conversation context.  
**Features:**
- Analyzes conversation for requirements and approach
- Creates structured implementation plans
- Saves to `docs/implans/` directory
- Uses standardized naming convention
- Can update existing plans

#### Execute Implan Command
**File:** `commands/implan/execute.md`  
**Purpose:** Resumes work on an existing implementation plan.  
**Features:**
- Finds and loads active implementation plans
- Analyzes current progress and next steps
- Continues implementation based on plan
- Updates plan status as work progresses
- Handles multiple active plans

### Job Management

#### Do Jobs Command
**File:** `commands/jobs/do.md`  
**Purpose:** Executes job files created by the addjob utility.  
**Features:**
- Processes sequential (.md) and parallel (.parallel.md) job files
- Manages job execution order
- Supports batch processing
- Integrates with the addjob utility

## Maintenance Commands (Framework Only)

These commands are only available when working in this repository:

### Update Knowledge Base
**File:** `.claude/commands/maintenance/update-knowledge-base.md`  
**Purpose:** Updates embedded Claude Code knowledge in optimizers.  
**Features:**
- Fetches latest official documentation
- Identifies components needing updates
- Run quarterly or after Claude Code releases
- Maintains knowledge-base-manifest.json