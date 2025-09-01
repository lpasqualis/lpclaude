---
name: /question
description: Answer questions without modifying any files
argument-hint: [your question]
allowed-tools: Read, LS, Glob, Grep, WebFetch, WebSearch, Bash
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-09-01 -->

Answer the following question comprehensively without creating, modifying, or deleting any files:

$ARGUMENTS

Step 1: Rephrase and present the rephrased question to the user the way you understand it. If you need to make any assumptions, state the assumptions you are making.

Step 2: Provide a clear, direct, but comprehensive answer based on:
- Current context
- File content analysis if relevant
- Existing codebase exploration

Focus ONLY on answering the question - do not implement or modify anything.
