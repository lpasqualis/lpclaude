# Claude Agent Configuration Repository

This repository contains custom agents and commands for Claude AI, designed to enhance productivity and maintain project-specific conventions.

## Agents

### 1. Memory Keeper Agent
**File:** `agents/memory-keeper.md`  
**Purpose:** Records NEW information, facts, decisions, or project-specific information in the CLAUDE.md file for long-term memory.  
**Use Cases:**
- Recording architectural decisions
- Establishing coding standards and conventions
- Documenting project-specific configurations
- Creating or updating CLAUDE.md files

### 2. Claude MD Quality Reviewer Agent
**File:** `agents/claude-md-quality-reviewer.md`  
**Purpose:** Reviews and improves the quality, organization, and consistency of EXISTING CLAUDE.md files.  
**Use Cases:**
- Checking for contradictions and redundancies in CLAUDE.md
- Reorganizing content for better clarity
- Resolving conflicting instructions
- Improving overall file structure and formatting

## Commands

### 1. Agents Review Command
**File:** `commands/agents_review.md`  
**Purpose:** Analyzes sub-agent definition files to identify ambiguities, overlaps, conflicts, and gaps in capabilities.  
**Output:** Comprehensive report with executive summary, detailed analysis table, and actionable recommendations for improving the agent ecosystem.

### 2. Capture Session Command
**File:** `commands/capture_session.md`  
**Purpose:** Documents the complete status of work done in a session for seamless handoff to other agents.  
**Output Location:** `docs/dev_notes/` folder  
**Includes:**
- Problem statement
- Actions taken
- Key findings and technical insights
- Next steps and recommendations

### 3. Capture Strategy Command
**File:** `commands/capture_strategy.md`  
**Purpose:** Creates a comprehensive project context document for any agent to pick up work without loss of context.  
**Output Location:** Main documents folder of the current project  
**Includes:**
- Problem statement and success criteria
- Strategy overview
- Phased implementation plan
- Document usage notes
- Technical notes

## Directory Structure

```
├── agents/
│   ├── claude-md-quality-reviewer.md
│   └── memory-keeper.md
├── commands/
│   ├── agents_review.md
│   ├── capture_session.md
│   └── capture_strategy.md
├── .gitignore
└── README.md
```

## Usage

These agents and commands are designed to be used with Claude AI to enhance project management, code quality, and knowledge retention. Each agent and command has specific trigger conditions and use cases as outlined in their respective files.