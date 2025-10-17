---
name: /implan:update
description: Verify and update implementation plan status based on actual project state
argument-hint: [optional-plan-name]
allowed-tools: Read, Edit, Glob, Grep, Bash, Task
---

# Update Implementation Plan Status

Perform comprehensive verification of an implementation plan against actual project state. This command reconciles what the plan says is done with what is actually implemented, tested, and working.

**Purpose**: Ensure implementation plans accurately reflect reality, catch incomplete work marked as complete, and automatically detect true completion.

**Parallel Execution**: Uses Task tool to spawn multiple verification agents concurrently for faster, more thorough verification.

## Workflow

### 1. Find and Load the Plan

**If plan name provided in `$ARGUMENTS`:**
- Search for matching plan in `docs/implans/`
- Support partial name matching (e.g., "auth" matches "ACTIVE_auth-system_implan.md")

**If no plan name provided:**
- Find all `ACTIVE_*_implan.md` files in `docs/implans/`
- If multiple active plans exist, list them and ask user which to verify
- If single active plan, use it
- If no active plans, search for any `*_implan.md` files

**Load the plan:**
- Read entire implementation plan document
- Parse all phases, tasks, and checkboxes
- Note current status and progress percentages
- Identify what the plan claims is complete

### 2. Parallel Verification Strategy

**Before starting verification, analyze the plan and partition verification work into parallel domains:**

#### Identify Verification Domains

Analyze the implementation plan to identify independent verification tasks that can run in parallel:

1. **Code Quality Domain**: All tasks involving code implementation
   - Files/modules mentioned in implementation tasks
   - Code that needs quality checks (stubs, TODOs, error handling)

2. **Testing Domain**: All tasks involving tests
   - Unit tests
   - Integration tests
   - Test execution and results analysis

3. **Build & Linting Domain**: Project-wide quality checks
   - Build process
   - Type checking
   - Linting
   - Code formatting

4. **Documentation Domain**: All documentation tasks
   - README updates
   - API documentation
   - Code comments
   - User guides

5. **Integration & Configuration Domain**: System integration tasks
   - Configuration files
   - Dependency installation
   - Integration between components
   - End-to-end functionality

#### Spawn Parallel Verification Agents

**Use Task tool to spawn up to 5 concurrent verification agents (one per domain):**

For each domain with tasks to verify, create a verification agent:

```
Task tool parameters:
- subagent_type: 'general-purpose'
- description: "[Domain] Verification for [plan-name]"
- prompt: Detailed instructions including:
  * Full implementation plan content
  * Specific tasks to verify in this domain
  * Verification criteria and quality standards
  * What to return (verification results for each task)
```

**Example parallel invocation:**
- Agent 1: Verify code quality for tasks 1-5 (auth implementation)
- Agent 2: Run and analyze all test suites
- Agent 3: Execute build, lint, and type-check
- Agent 4: Verify documentation completeness
- Agent 5: Verify integration and configuration

**Agent Instructions Template:**

Each verification agent receives:
```
You are verifying implementation plan tasks for the [DOMAIN] domain.

Implementation Plan:
[Full plan content]

Your Tasks to Verify:
[Specific list of tasks in this domain]

Verification Requirements:
[Domain-specific verification criteria]

For each task, determine:
- Status: COMPLETE | PARTIAL | INCOMPLETE | NOT_STARTED
- Evidence: What you found (file contents, test results, etc.)
- Issues: Specific problems discovered (TODOs, failing tests, missing files)
- File References: Specific files and line numbers

Return Format:
For each task provide:
{
  "task": "task description",
  "status": "COMPLETE|PARTIAL|INCOMPLETE|NOT_STARTED",
  "evidence": "what verification was performed",
  "issues": ["specific issue 1", "specific issue 2"],
  "files": ["file:line references"]
}
```

#### Example: Parallel Invocation

**Given an implementation plan with these phases:**
- Phase 1: Authentication (5 tasks)
- Phase 2: Testing (3 tasks)
- Phase 3: Documentation (2 tasks)
- Phase 4: Build & Deploy (2 tasks)

**Spawn 4 parallel agents in a SINGLE message with multiple Task tool calls:**

```
Agent 1 - Code Quality Domain:
  Tasks: Phase 1 tasks (authentication implementation)
  Verify: Implementation files, error handling, edge cases

Agent 2 - Testing Domain:
  Tasks: Phase 2 tasks (test suite)
  Verify: Test files exist, tests run, all tests pass

Agent 3 - Documentation Domain:
  Tasks: Phase 3 tasks (docs)
  Verify: Documentation files, completeness, accuracy

Agent 4 - Build & Linting Domain:
  Tasks: Phase 4 tasks (build/deploy)
  Verify: Build succeeds, linting passes, no warnings
```

**IMPORTANT**: Use a single response with 4 Task tool invocations to run all agents in parallel. Do NOT send sequential messages.

#### Aggregate Parallel Results

**After all verification agents complete:**
1. Collect results from all parallel agents
2. Consolidate findings by task
3. Resolve any conflicts (if multiple agents checked same task)
4. Compile comprehensive verification report

### 3. Deep Implementation Verification

**This section describes what EACH verification agent does within its domain:**

For **each task/item** assigned to the verification agent, perform comprehensive verification:

#### Phase Analysis
- Extract what the phase/task is supposed to accomplish
- Identify acceptance criteria and validation requirements
- Determine what "done" means for this specific item

#### Code Quality Verification

**For implementation tasks:**
- Locate the relevant source files mentioned or implied by the task
- Read the actual implementation code
- Detect quality issues:
  - Stub implementations (functions that just `pass` or `return None`)
  - TODO/FIXME/HACK comments
  - Placeholder strings like "implement me", "coming soon"
  - Empty function bodies
  - Mock/dummy return values
  - Commented-out code that should be implemented
  - Error handling that just passes or prints instead of actually handling

**Example verification:**
```python
# Task: "Implement user authentication"
# This would be marked INCOMPLETE:
def authenticate(username, password):
    # TODO: implement password hashing
    return True  # temporary

# This would be marked COMPLETE:
def authenticate(username, password):
    hashed = hash_password(password)
    user = db.get_user(username)
    if not user or not verify_hash(user.password_hash, hashed):
        raise AuthenticationError("Invalid credentials")
    return create_session(user)
```

#### Functional Completeness

**Verify the implementation does what the plan says:**
- If task says "Add error handling", verify errors are actually caught and handled
- If task says "Implement feature X", verify X is fully functional, not stubbed
- If task mentions specific functionality, verify it exists in code
- Check edge cases are handled, not just happy path

#### Testing Verification

**For each task, verify tests:**
- Find relevant test files (following project conventions)
- Read test code to verify tests actually test the implementation
- Run the tests and capture results
- Check test output for:
  - All tests pass (no failures, no skips marked as TODO)
  - No test errors or exceptions
  - Tests actually validate the functionality (not just dummy tests)

**Test quality checks:**
- Tests exist for the implemented feature
- Tests cover edge cases mentioned in plan
- Tests are not disabled/skipped
- Tests actually assert correct behavior

**Run tests:**
```bash
# Detect project test framework and run appropriately
# Examples:
pytest path/to/test_auth.py -v
npm test
python -m unittest discover
cargo test
go test ./...
```

#### Build and Linting Verification

**If project has build/lint tools:**
- Run build process for affected components
- Run linters/type checkers/formatters
- Verify zero warnings and errors
- Check that code passes all quality gates

**Examples:**
```bash
# Python
mypy src/
pylint src/
black --check src/

# TypeScript
tsc --noEmit
npm run lint

# Go
go build ./...
golint ./...
```

#### Integration Verification

**For tasks involving integration:**
- Verify dependencies are installed and configured
- Check configuration files are updated
- Verify integrations actually work (not just exist)
- Test data flow between integrated components

### 4. Status Reconciliation

**After all parallel verification agents complete, aggregate results and update status:**

#### Consolidate Verification Results

**Merge findings from all parallel agents:**
- Combine verification results for all tasks
- Resolve any overlapping checks (e.g., if both code quality and testing agents checked same file)
- Create comprehensive list of issues found
- Categorize tasks by verification status

#### Checkbox States
- `[x]` - **Fully verified complete**: Implementation exists, is high quality, tests pass, no issues
- `[ ]` - **Not done or incomplete**: Missing implementation, stubs, failing tests, or quality issues
- `[~]` - **Partially complete** (add this marker): Implementation exists but has issues:
  - Tests exist but some fail
  - Core functionality works but edge cases missing
  - Implementation present but has TODOs
  - No error handling
  - Missing integration pieces

#### Document Issues Found

**For items marked complete but found incomplete, add notes:**
```markdown
- [~] Implement user authentication
  **Verification Issues**:
  - Found TODO comment in password hashing (auth.py:45)
  - Error handling just prints instead of raising (auth.py:67)
  - Tests exist but 2/5 failing (test_auth.py)
  - Missing integration with session store
```

#### Update Plan Sections

**Current Status:**
- Update with current date (use `date` command)
- Adjust progress percentages based on verification findings
- Document verification timestamp

**Session History:**
- Add entry documenting the verification session
- List what was verified
- Note discrepancies found
- Record adjustments made

**Next Steps:**
- Update based on verification findings
- Prioritize fixing items marked complete but incomplete
- List specific issues that need resolution

### 5. Completion Detection

**Only rename file to `COMPLETE_` if ALL criteria met:**

✅ **All verification checks:**
- All phase tasks marked `[x]` with verification
- Zero items marked `[ ]` or `[~]`
- All tests pass with zero failures
- Zero stub implementations or TODOs
- Build succeeds (if applicable)
- Zero linting/type errors
- All acceptance criteria verified

**Completion process:**
1. Verify every single criterion above
2. Run final comprehensive test suite
3. Verify project builds/runs without errors
4. Update plan with final status
5. Rename: `ACTIVE_name_implan.md` → `COMPLETE_name_implan.md`
6. Document completion in session history

**If any criteria not met:**
- Keep `ACTIVE_` prefix
- Document what's blocking completion
- Update next steps with specific remediation tasks

### 6. Verification Report

**Generate comprehensive report aggregating all parallel verification results:**

```
📊 Implementation Plan Verification Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Plan: [plan name]
Verification Date: [current date and time]
Previous Status: [X%] complete
Verified Status: [Y%] complete
Parallel Agents Used: [N domains verified concurrently]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VERIFICATION RESULTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Verified Complete: [N tasks]
   [list task names]

⚠️  Partially Complete: [N tasks]
   - [Task name]: [specific issues found]
   - [Task name]: [specific issues found]

❌ Marked Complete But Incomplete: [N tasks]
   - [Task name]: [specific issues found]
     • [Detail 1]
     • [Detail 2]

📋 Not Started: [N tasks]
   [list task names]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TEST RESULTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Tests Run: [N]
Passed: [N]
Failed: [N]
Skipped: [N]

[If failures exist, list them]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CODE QUALITY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Stubs/TODOs Found: [N]
[list files and line numbers]

Build Status: [✅ Success | ❌ Failed]
Lint Status: [✅ Clean | ⚠️  N warnings | ❌ N errors]
Type Check Status: [✅ Clean | ❌ N errors]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COMPLETION STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Overall Status: [COMPLETE | IN PROGRESS | BLOCKED]
Plan File Status: [Renamed to COMPLETE_ | Remains ACTIVE_ | Updated]

Next Steps:
[Prioritized list of what needs to be done based on verification]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Verification Strategies by Task Type

### Code Implementation Tasks
- Read source files and verify actual implementation
- Check for stubs, TODOs, placeholders
- Verify error handling exists and is comprehensive
- Check edge cases are handled
- Verify logging/monitoring is in place

### Testing Tasks
- Find test files
- Read tests to verify they test correct functionality
- Run tests and verify all pass
- Check test coverage if mentioned in task
- Verify tests are not disabled or skipped

### Documentation Tasks
- Verify documentation files exist
- Read documentation and verify completeness
- Check that examples work (run them if code examples)
- Verify documentation matches actual implementation

### Configuration Tasks
- Verify config files exist and are properly formatted
- Check all required configuration values are set
- Verify no placeholder values remain
- Test that configuration works (if possible)

### Integration Tasks
- Verify all components are connected
- Check data flows correctly between components
- Verify error handling across integration boundaries
- Test end-to-end functionality

### Refactoring Tasks
- Verify old code is removed (not just commented out)
- Check new structure is in place
- Verify tests still pass after refactoring
- Check no functionality regression

## Error Handling

**If verification discovers major issues:**
- Document all findings in session history
- Update next steps with remediation plan
- Adjust progress percentages realistically
- Consider adding new tasks for discovered issues

**If plan structure is problematic:**
- Update plan structure if needed (add missing phases, break down tasks)
- Document structural changes in session history
- Ensure plan remains actionable

**If unable to verify certain items:**
- Mark with `[?]` and document why verification failed
- Add note explaining what's needed to verify
- Move forward with verification of verifiable items

## Parallel Execution Considerations

### Advantages
- **Speed**: Multiple verification domains checked simultaneously
- **Thoroughness**: Each agent focuses deeply on its domain
- **Separation of Concerns**: Code quality, testing, build, docs, and integration verified independently
- **Scalability**: Can verify large plans with many tasks efficiently

### Domain Assignment Strategy

**Smart partitioning:**
- Group related tasks by domain (code, tests, build, docs, integration)
- Ensure each domain has meaningful work (don't spawn agent for empty domain)
- Balance load across agents (avoid one agent doing 90% of work)
- Maximum 5 parallel agents (to stay within Task tool limits)

**If plan has < 5 tasks:**
- Consider sequential verification (overhead of parallel may not be worth it)
- Or group all verification into 2-3 agents maximum

**If plan has > 20 tasks:**
- Definitely use parallel verification
- Distribute tasks evenly across domains
- Each agent verifies multiple tasks in its domain

### Result Aggregation

**Conflict resolution:**
- If multiple agents verify same task (e.g., both code and test agents check auth.py):
  - Take the more conservative status (PARTIAL > COMPLETE, INCOMPLETE > PARTIAL)
  - Merge all issues found by both agents
  - Include evidence from all verification attempts

**Missing verification:**
- If a task doesn't fit any domain, assign to "General" agent
- Ensure every task is assigned to at least one agent
- Track which agent verified which task in the report

## Important Notes

- **Be thorough**: Don't just check if files exist, verify they contain quality implementations
- **Be honest**: Adjust status downward if items were marked complete prematurely
- **Be specific**: Document exact issues found, not vague "needs work"
- **Be helpful**: Update next steps with actionable remediation tasks
- **Be objective**: Base status on evidence, not assumptions
- **Use parallelization**: Spawn parallel verification agents for comprehensive, fast verification

The goal is to ensure the implementation plan is a **truthful reflection of project state**, enabling effective work planning and accurate completion tracking.

$ARGUMENTS
