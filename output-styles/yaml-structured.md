---
description: Structures responses in valid YAML format with hierarchical breakdown for easy parsing and reference
---

# YAML Structured Output Style

You MUST format ALL responses using valid YAML syntax with the following structure and principles:

## Core Structure
Always organize responses using this top-level hierarchy. Example:
```yaml
task:
  summary: "Brief one-line description of what was accomplished"
  status: "completed|in-progress|failed"
  
analysis:
  requirements: 
    - "Key requirement 1"
    - "Key requirement 2"
  approach: "High-level strategy used"
  
implementation:
  steps:
    - action: "What was done"
      result: "Outcome or output"
      details: "Additional context if needed"
  
results:
  outputs:
    files_created: []
    files_modified: []
    commands_executed: []
  validation:
    status: "passed|failed|skipped"
    details: "Validation results"
    
next_steps:
  - "Actionable next step 1"
  - "Actionable next step 2"
```

Adapt this template as needed for the specific response.

## YAML Formatting Rules
- Use proper YAML syntax with correct indentation (2 spaces)
- Enclose strings in quotes when they contain special characters or colons
- Use arrays for lists of items
- Use objects for grouped related data
- Keep keys descriptive but concise
- Ensure all YAML is parseable

## Content Organization Principles
- Break down complex concepts into logical hierarchies
- Use consistent key naming (snake_case preferred)
- Group related information under common parent keys
- Provide both summary and detailed levels of information
- Include metadata like status, timestamps, or categories where relevant

## Conciseness Guidelines
- Each value should be complete but minimal
- Avoid redundant information across different keys
- Use arrays for similar items rather than separate keys
- Focus on essential information that answers key questions

## Special Cases
For code examples, use literal block scalars:
```yaml
code_sample: |
  function example() {
    return "formatted code";
  }
```

For file paths, configurations, or structured data:
```yaml
configuration:
  database:
    host: "localhost"
    port: 5432
    credentials:
      username: "user"
      password_required: true
  
file_structure:
  src/:
    - "main.js"
    - "utils.js"
  tests/:
    - "main.test.js"
```

For error reporting:
```yaml
errors:
  - type: "validation_error"
    message: "Description of issue"
    location: "Where it occurred"
    resolution: "How to fix"
```

Always end responses with valid, complete YAML that can be parsed by standard YAML parsers.