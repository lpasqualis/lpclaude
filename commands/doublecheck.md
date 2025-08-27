---
name: /doublecheck
description: Intelligently verify completion claims using parallel completion-verifier agents with smart task splitting
argument-hint: ["[optional: custom verification target instead of last claim]"]
allowed-tools: Read, LS, Glob, Grep, Task, Bash
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-08-27 10:32:55 -->

# Intelligent Completion Verification System

Verify completion claims using optimally-sized parallel completion-verifier agents.

## 1. Identify Verification Target

**Default**: Scan conversation for recent completion claims ("done", "complete", "ready", "finished", "implemented"). Focus on substantive deliverables, ignore trivial edits.

**Custom**: Use provided argument instead of automatic detection.

Extract specific claims:
- What was completed
- Expected outcomes/deliverables
- Success criteria
- Files/features that should exist

## 2. Assess Complexity & Choose Strategy

**Single verifier** for:
- Simple, single-component claims
- Basic file checking sufficient
- Obvious success criteria

**Parallel verifiers** for:
- Multi-component claims
- Different functional areas
- Complex implementations

**Skip verification** for:
- Trivial changes
- Already verified claims
- Questions without completion claims

## 3. Task Splitting (Parallel Only)

Split by logical boundaries:
- **Functional**: Components, features, verification types
- **File/Directory**: Related file groups, separate codebases
- **Size**: Substantial tasks, max 10 verifiers, justify overhead

Ensure non-overlapping scopes.

## 4. Execute Verification

**Single verifier**:
```
Task(subagent_type: 'completion-verifier', description: 'Verify completion claim', prompt: 'Verify: [claim with context and outcomes]')
```

**Parallel verifiers** (multiple Task calls in single message for true concurrency):
```
Task(subagent_type: 'completion-verifier', description: 'Verify component A', prompt: 'Verify [component A]: [scope, criteria, files]')
Task(subagent_type: 'completion-verifier', description: 'Verify component B', prompt: 'Verify [component B]: [scope, criteria, files]') 
Task(subagent_type: 'completion-verifier', description: 'Verify component C', prompt: 'Verify [component C]: [scope, criteria, files]')
```

**CRITICAL**: For true parallel execution, all Task calls must be made in a single message using multiple tool invocations. Sequential Task calls execute one after another, not concurrently.

Provide each verifier:
- Specific scope and boundaries
- Expected outcomes
- Success/failure criteria
- Relevant file paths

## 5. Report Results

```markdown
## Verification Results: [Claim]

### Status: [VERIFIED/PARTIALLY VERIFIED/NOT VERIFIED]

### Components:
- [Component]: [Status] - [Summary]

### Issues:
- [Specific problems]

### Required Actions:
- [Next steps if incomplete]
```

$ARGUMENTS

## Implementation Pattern for Parallel Execution

When using parallel verifiers, make multiple Task calls in a single message:

```
I'll verify this completion claim using 3 parallel verifiers:

[Multiple Task tool calls here - each with different verification scope]
```

**Example for agent/command development:**
- Verifier 1: Check YAML frontmatter structure and required fields
- Verifier 2: Validate tool permissions and accessibility  
- Verifier 3: Test actual functionality and invocation patterns

## Optimization Rules

- Skip trivial/recently verified claims
- Ensure non-overlapping verification tasks
- Validate sufficient scope per verifier
- Include conversation context in prompts
- Design combinable verification scopes
- Max 10 concurrent verifiers (framework limit)