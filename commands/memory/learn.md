---
name: learn
description: Analyze the current session to extract and preserve key learnings and insights for future sessions
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep, Task
argument-hint: [specific area to focus on (optional)]
---

Analyze our current conversation session to identify the most important learnings and discoveries that should be preserved for future sessions. Extract key insights that were difficult to discover and have a good chance of being needed again when the current context is lost.

Do not capture status of the project, or something very specific and temporary. You need to extract the learnings and insights from the session, the principles behind the work we did together, and translate these in general terms that can be applied to all situations in the future. This is about learning to not make the same mistakes, not remembering specific things that will change quickly.

**Focus on capturing:**

1. **Technical Discoveries:**
   * Solutions to complex problems we encountered
   * Non-obvious approaches or workarounds that proved effective
   * Tools, commands, or techniques that were particularly helpful

2. **Configuration & Setup Details:**
   * Important configuration steps or settings
   * Dependencies or prerequisites that weren't immediately obvious
   * Environment-specific requirements we discovered

3. **Gotchas & Pitfalls:**
   * Errors or issues we encountered and how we resolved them
   * Common mistakes to avoid
   * Counterintuitive behaviors we discovered

4. **Project-Specific Insights:**
   * Conventions or patterns unique to this codebase
   * Architectural decisions or constraints we uncovered
   * Integration points or API behaviors worth remembering

5. **Workflow Optimizations:**
   * Efficient approaches we developed during the session
   * Time-saving shortcuts or automation opportunities
   * Testing strategies that proved valuable

## Execution Strategy

### Phase 1: Initial Assessment and Domain Identification
1. **Analyze conversation scope and complexity**:
   - Scan conversation for distinct learning domains
   - Count technical problem-solving sequences
   - Identify configuration/setup discussions
   - Note error resolution chains and workflow optimizations
   - Flag architectural or design decision threads

2. **Determine processing approach**:
   - **Simple conversations (1-2 domains)**: Direct analysis
   - **Complex conversations (3+ domains)**: Parallel processing
   - **Large conversations (10+ domains)**: Batched parallel processing

### Phase 2: Parallel Processing (When Applicable)
3. **Execute optimized parallel analysis**:
   - Use Task tool with subagent_type: 'cmd-learn-analyzer'
   - **Batch Strategy**: Process domains in optimal groups of 5-8 (maximizes throughput while staying under 10-task limit)
   - **Error Recovery**: If any analyzer fails, retry with fallback to sequential processing
   - **Progress Tracking**: Report processing status ("Analyzing batch 1 of 3...")
   - **Quality Gates**: Validate each analyzer produces structured output with required fields

4. **Handle edge cases**:
   - **Timeout Recovery**: If parallel processing stalls, switch to sequential mode
   - **Output Validation**: Ensure each analyzer returns insights in expected format
   - **Resource Management**: Monitor task completion and aggregate results incrementally

### Phase 3: Result Aggregation and Quality Control
5. **Consolidate parallel findings with enhanced quality control**:
   - Collect and validate insights from all analyzers
   - **Deduplication**: Use semantic matching to eliminate redundant insights across segments
   - **Cross-reference Validation**: Identify contradictory findings and resolve
   - **Pattern Recognition**: Extract meta-patterns that emerge across multiple domains
   - **Quality Scoring**: Rank insights by durability, actionability, and value
   - **Categorization**: Organize by learning type for optimal storage structure

## Phase 4: Storage and Integration

### Pre-Storage Validation Checklist
1. **Quality assurance checklist**:
   - [ ] All insights meet durability criteria (applicable beyond current session)
   - [ ] Each insight has clear, actionable description
   - [ ] Sufficient context provided for independent understanding
   - [ ] No temporary project states or routine operations included
   - [ ] Insights are generalizable beyond specific implementation details

### Storage Integration Process
2. **Systematic storage with memory-keeper**:
   - **Pre-Analysis**: Read existing CLAUDE.md to identify structure and potential conflicts
   - **Conflict Detection**: Flag any insights that contradict existing learnings
   - **Integration Strategy**: Use Task tool with memory-keeper agent to store consolidated insights
   - **Quality Metadata**: Include for each learning:
     * Clear, actionable description
     * Sufficient context for independent understanding
     * Date stamp for reference (current session date)
     * Appropriate categorization (Technical, Configuration, Gotcha, Workflow, etc.)
     * Value score (High/Medium priority for future sessions)

### Post-Storage Verification
3. **Completion verification**:
   - Confirm all high-value insights were successfully stored
   - Validate CLAUDE.md structure remains intact
   - Report summary of learnings captured and any conflicts resolved

### Quality Criteria
Only preserve discoveries that meet these standards:
- **High Value**: Would save significant time or prevent issues in future sessions
- **Generalizable**: Applicable beyond current specific context
- **Non-obvious**: Not easily discoverable through standard documentation
- **Durable**: Likely to remain relevant across multiple sessions
- **Actionable**: Clear enough to guide future decision-making

Exclude routine operations, temporary project states, or easily-discoverable information.