---
name: /question
description: Answer questions using research and file reading without modifying any files
argument-hint: [your question]
allowed-tools: Read, LS, Glob, Grep, WebFetch, WebSearch
---
<!-- OPTIMIZATION_TIMESTAMP: 2025-09-01 -->

Research and answer the following question comprehensively without creating, modifying, or deleting any files:

$ARGUMENTS

Step 1: Rephrase and present the rephrased question to the user the way you understand it, to make sure you are answering the right question. If you need to make any assumptions, state the assumptions you are making.

Step 2: Provide a clear, direct answer based on:
- Current context
- File content analysis if relevant
- Web research if needed for current information
- Existing codebase exploration

Focus ONLY on answering the question - do not implement or modify anything.
