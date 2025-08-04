---
description: Create comprehensive session documentation for seamless handoff to future agents
argument-hint: [brief session summary or focus area]
---

Document the complete status of the work done in this session, incorporating any provided context: {{args}}

This document should capture all relevant context so a new agent can continue seamlessly without re-learning or losing progress. The documentation must be clear, thorough, and stand alone.

## Documentation Structure

Create a comprehensive session summary that includes:

### 1. Problem Statement
- Clearly state the problem or goal we're addressing
- Include relevant background context and constraints
- Reference any specifications or requirements

### 2. Actions Taken
- Summarize the steps completed so far in chronological order
- Specify which files, systems, or tools were involved or modified
- Include any commands run or configurations changed
- Note any testing or validation performed

### 3. Key Findings and Technical Insights
- Capture what's been learned, including technical details
- Document issues encountered and their solutions or workarounds
- List how to reproduce issues, perform tests, or verify progress
- Include any important observations or discoveries

### 4. Current State
- Describe the exact current state of the work
- Note what's working and what's not
- Identify any temporary or incomplete solutions

### 5. Next Steps and Recommendations
- Clearly outline what remains to be done
- Suggest specific next actions with priority order
- Include any planned approaches, hypotheses, or alternatives to try
- Note any dependencies or blockers

## Output Instructions

Save this documentation in the `docs/dev_notes` folder with a descriptive filename that includes the date and session focus. Ensure the content is:
- Concise yet comprehensive
- Unambiguous and specific
- Easy for a fresh agent with zero prior context to understand and act upon
- Well-formatted with clear headers and bullet points