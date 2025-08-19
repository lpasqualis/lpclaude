# Error Handling Principles

- Always provide actionable error messages with context
- Fail fast with clear explanations rather than silent failures
- Include recovery suggestions when operations fail
- Log errors at appropriate levels (debug vs error vs critical)
- Validate inputs early to prevent cascading errors
- Use specific exception types rather than generic exceptions
- Never suppress errors without explicit user consent