---
description: Meta test that runs all test commands and reports their results
allowed-tools: Glob, Read, SlashCommand
---

# Test: Run All Tests and Report Results

## Purpose
Dynamically discovers and executes all test commands in the test namespace, reporting what each test finds without hardcoded expectations.

## Test Discovery and Execution

### Step 1: Discover All Test Commands
Use Glob to find all test files:
- Pattern: `.claude/commands/test/*.md`
- Exclude: `test-all.md` and `README.md`

### Step 2: Execute Each Test
For each discovered test:
1. Extract command name from filename
2. Report: "Executing: /test:{name}"
3. Use SlashCommand tool to invoke the test
4. Let the test report its own success/failure/deviations

### Step 3: Compile Results
Each test command is responsible for:
- Determining if its behavior matches expectations
- Reporting success, failure, or deviations
- Providing clear pass/fail status

This meta test simply:
- Runs each test
- Collects their self-reported results
- Presents a unified summary

## Report Format

```
CLAUDE CODE TEST SUITE EXECUTION
=================================
Timestamp: [current time]
Tests Discovered: X

INDIVIDUAL TEST RESULTS:
------------------------
[For each test, show its complete output]

/test:command-name
[Test's self-reported results]
---

SUMMARY:
--------
Total Tests Run: X
[Any patterns or issues observed across tests]
```

## Implementation Notes
- This command is a pure orchestrator
- It makes no assumptions about expected behaviors
- Each test is self-validating
- Results are reported exactly as returned by each test
- **CRITICAL**: Must execute ALL discovered tests sequentially
- Each test may have recursive chains that must complete
- Continue to next test after each one finishes