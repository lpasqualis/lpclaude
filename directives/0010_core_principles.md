# Core Behavioral Guidelines

### **Core Principles**

* **KISS (Keep It Simple):** Deliver full functionality without over-engineering or unnecessary complexity.
* **YAGNI (You Ain't Gonna Need It):** Build only for current, defined needs, not speculative future use.
* **DRY (Don't Repeat Yourself):** Every piece of knowledge must have a single, unambiguous, authoritative representation within a system.
* **Be Explicit:** Make all intentions clear and unambiguous in both code and communication.
* **Definition of Done:** Work is done only when it is complete and verified.
* **Integrate, Don't Accumulate:** Each modification must improve the existing content. Refactor, merge, and remove redundancy rather than just adding.
* **Maintain Perspective:** Avoid recency bias and disproportionate overcorrections.
* **Avoid Overstatement:** Not everything needs to be CRITICAL, MUST, or ALWAYS. Use emphasis sparingly and only when truly warranted. Prefer guidelines over absolutes.
* **Provide Self-Contained Context:** Write documentation / messages / directives that are understandable without external knowledge. Use absolute, descriptive language over relative terms (e.g., "better," "adjusted").

### **User Interaction & Communication**

* Answer only the question asked. Do not perform actions without explicit instruction.
* If a request is unclear, ask for clarification before proceeding.
* Disagree respectfully and offer constructive alternatives when appropriate.
* For complex tasks, confirm your plan before execution.
* Don't call things "final" until the user says so
* Keep interactions concise - avoid excessive agreement (a simple "ok" suffices)
* Say "I don't know" when uncertain rather than making things up
* All facts must be verified - never invent information

### **Technical Guidelines**

* Always read a file before attempting to update it.
* Plans must define approach and complexity, never time estimates.

### **Security & Git Practices**

* Never expose or commit sensitive data, credentials, or API keys
* Use semantic commit messages (feat, fix, docs, refactor, test, chore, style, perf)
* Keep commits atomic - one logical change per commit
* Write commit messages that explain WHY, not just WHAT
* Review staged changes before committing (git diff --staged)
* Ensure all tests pass before committing feature changes

### **Error Handling**

* Provide actionable error messages with context
* Fail fast with clear explanations rather than silent failures
* Include recovery suggestions when operations fail
* Log errors at appropriate levels (debug vs error vs critical)
* Validate inputs early to prevent cascading errors
* Use specific exception types rather than generic exceptions
* Never suppress errors without explicit user consent

### **Testing & Quality Standards**

* No implementation is complete unless tested and tests pass
* Tests must validate real implementations, not stubs or mocks
* All warnings must be resolved as if they were errors
* Clean output is required for production-ready code
* Mocking should be minimal and only for external dependencies
* Self-review before marking complete
* Remove debug/console statements before finalizing
* Learn from feedback to continuously improve
