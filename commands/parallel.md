---
name: /parallel
description: Execute a prompt in parallel N times (N<10 or batches up to 10) with intelligent work partitioning and result aggregation
argument-hint: [N] [prompt + result aggregation directives]
allowed-tools: Task, Read, LS, Glob, Grep
---

# Parallel Execution Command

Parse the provided arguments to extract:
1. **N**: The total number of parallel executions requested
2. **Prompt**: The task to execute in parallel

## Batch Processing for N > 10

If N exceeds 10:
1. Calculate batches: Total batches = ceiling(N / 10)
2. Process in sequential batches of up to 10 parallel tasks
3. Maintain a running accumulator of all results across batches
4. Apply aggregation across all batches at the end

Example: N=25 creates:
- Batch 1: Tasks 1-10 (parallel)
- Batch 2: Tasks 11-20 (parallel)
- Batch 3: Tasks 21-25 (parallel)

## Execution Strategy

Analyze the prompt to determine:
1. What operations are being requested for the parallel workers
2. What post-processing or aggregation is requested for the results
3. What context from the current conversation is relevant
4. Whether file modifications are involved
5. How to partition work safely

## Prompt Decomposition

Split the prompt into two parts:
1. **Worker Instructions**: What each parallel task should do
2. **Aggregation Instructions**: How to process the combined results

Look for aggregation keywords like:
- "return a report with..."
- "combine into..."
- "no duplicates"
- "rank by...", "with severity", "prioritize"
- "summarize as..."
- "merge the results..."

## Context Preparation

Based on the prompt analysis:
- If file operations are mentioned, identify all target files using Glob or Grep
- If the prompt references "current", "this", or "the" items, gather that context
- Extract any relevant findings, decisions, or state from the conversation

## Work Partitioning

If the prompt involves file modifications:
1. Distribute files across N tasks evenly (no task gets the same file)
2. For single-file operations, partition by line ranges or sections
3. For creation operations, assign unique namespaces or indices

If the prompt is analysis or read-only:
- Safe to run identical prompts with shared context
- Consider partitioning by search space or analysis scope

## Parallel Execution

For each batch (up to 10 tasks per batch):
Launch tasks simultaneously using the Task tool with:
- `subagent_type: 'general-purpose'`
- Each task receives:
  - The worker instructions portion of the prompt
  - Its specific partition of work
  - Necessary context from the conversation
  - Clear boundaries to prevent conflicts
  - Instructions to return structured results for aggregation

For file modifications, include in each task prompt:
- "You are task X of N total (batch Y of Z)"
- "Your assigned files/scope: [specific partition]"
- "Do not modify files outside your assignment"
- "Return your findings in a structured format for aggregation"

Between batches:
- Collect results from completed batch
- Update the work partition for the next batch
- Ensure no work overlap between batches

## Safety Constraints

- No limit on total N (will batch automatically)
- Maximum 10 concurrent tasks per batch
- If file conflicts are unavoidable, reduce batch size or serialize critical sections
- For database or API operations, include rate limiting instructions
- Prevent duplicate work by clearly defining boundaries

## Result Aggregation

After all batches complete, process combined results based on the aggregation instructions:

**If deduplication is requested:**
- Merge identical findings from different workers
- Keep one instance of each unique result

**If ranking/severity is requested:**
- Apply the specified ranking criteria
- Sort results by priority, severity, or importance
- Group by categories if appropriate

**If reporting format is specified:**
- Format results according to the requested structure
- Combine worker outputs into the specified report format
- Include statistics (total found, by category, etc.)

**Default aggregation:**
- Summarize the collective results
- Report any failures or conflicts
- Provide a unified view of what was accomplished

Always follow any specific post-processing instructions from the original prompt.

$ARGUMENTS