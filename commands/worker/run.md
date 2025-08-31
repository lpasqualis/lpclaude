---
name: /worker:run
description: Execute a worker template from the workers directory
argument-hint: <worker-name-or-path> [additional context]
allowed-tools: Read, Task, LS, Glob, Grep
---

Read the worker template specified in $ARGUMENTS from the workers directory and execute it using the Task tool.

The worker can be specified as:
- Full relative path: "optimize-workers/file-optimizer.md"
- Just the worker name: "file-optimizer" (will search for file-optimizer.md anywhere in workers/)
- Name without extension: "validator" (will search for validator.md)

1. Parse the first argument as the worker identifier
2. Search for the worker template:
   - If it's a path (contains '/'), look for exact match
   - If it's just a name, search for "{name}.md" or "{name}" files recursively
   - Check both `.claude/workers/` (project-local) and `~/.claude/workers/` (global)
   - If multiple matches found, prefer exact name matches over subdirectory matches
3. Read the worker template content (ignoring any frontmatter if present)
4. Analyze the worker template to understand what context it needs
5. Gather relevant context to pass to the worker:
   - Any additional arguments from $ARGUMENTS
   - Current file being edited (if applicable)
   - Recent conversation context that seems relevant
   - Project structure or files mentioned in the worker
   - Any specific data the worker references
6. Execute the template using Task with subagent_type: 'general-purpose', combining:
   - The worker template instructions
   - The gathered context formatted appropriately
   - Clear delineation between instructions and context

If the worker template is not found, list available workers in both directories to help the user.

$ARGUMENTS