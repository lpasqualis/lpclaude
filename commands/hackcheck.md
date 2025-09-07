---
name: /hackcheck
description: Run 6 parallel security audits and consolidate findings by priority
argument-hint: [optional: specific files/directories to focus on]
allowed-tools: Read, LS, Glob, Grep, Task
---

# Security Audit - Parallel Hack Detection

Run 6 concurrent hack-spotter agents to comprehensively audit the codebase for security issues, technical debt, and dangerous shortcuts.

## Execution Plan

Launch 6 parallel hack-spotter agents with different focus areas:

1. **Agent 1 - Authentication & Secrets**
   Focus: Hardcoded credentials, API keys, exposed secrets, authentication bypasses, disabled security checks

2. **Agent 2 - Code Quality & Brittleness**  
   Focus: Magic numbers, brittle conditionals, technical debt, error-prone patterns, missing validation

3. **Agent 3 - Data & Infrastructure**
   Focus: PII exposure, unsafe data handling, injection vulnerabilities, insecure configurations, resource leaks

4. **Agent 4 - Hardcoded Paths & Test Workarounds**
   Focus: Hardcoded execution paths, test-specific hacks, narrow implementations that pass specific test cases but lack generality, brittle conditionals targeting specific scenarios instead of general solutions, special-case handling that should be generalized

5. **Agent 5 - DRY Violations & Over-Engineering**
   Focus: Code duplication violations of DRY principle, copy-paste programming, redundant implementations, over-engineered solutions, speculative "future-proofing" code, unnecessary abstractions, YAGNI violations, premature optimization

6. **Agent 6 - Context-Specific Analysis**
   Dynamically determine focus based on project type and technology stack. First analyze:
   - Project type (web app, CLI tool, library, API, etc.)
   - Technology stack (languages, frameworks, dependencies)
   - Domain-specific concerns (financial, healthcare, infrastructure, etc.)
   Then focus on project-specific vulnerabilities and anti-patterns:
   - Framework-specific security issues
   - Language-specific gotchas and common mistakes
   - Domain-specific compliance and security requirements
   - Technology-specific performance bottlenecks
   - Stack-specific best practice violations

$ARGUMENTS

## Consolidation Requirements

After all agents complete, consolidate findings into:

### HIGH Priority (Critical Security/Stability)
- Issues that could lead to immediate compromise or system failure
- Include: file path, line numbers, issue description, expected fix complexity (Simple/Medium/Complex)

### MEDIUM Priority (Important Quality/Risk)
- Issues that create maintenance burden or future vulnerabilities
- Include: file path, line numbers, issue description, expected fix complexity

### LOW Priority (Best Practices/Cleanup)
- Issues that should be addressed but pose minimal immediate risk
- Include: file path, line numbers, issue description, expected fix complexity

## Fix Complexity Definitions
- **Simple**: Single line changes, configuration updates, removing hardcoded values
- **Medium**: Refactoring functions, implementing proper validation, updating patterns
- **Complex**: Architectural changes, implementing new security layers, major refactoring

Present findings in a clear, actionable format with specific recommendations for resolution.