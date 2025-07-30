Create a document that contains the context of the current session. This document should be stored in the main documents folder of the current project, ensuring it can be used by any agent to pick up the project without loss of context or repeated efforts. An agent session will start with no prior knoweldge of the progress, other than the content of the document that you are about to write.

**Your document must include:**

1. **Problem Statement**

   * Briefly describe the problem being solved.
   * Success criteria

2. **Strategy Overview**

   * Summarize the agreed-upon strategy or approach.

3. **Phased Implementation Plan**

   * Break down the implementation into one or more phases. For each phase, include:

     * **Phase Name and Objective:** Clearly state what this phase is about.
     * **Tasks:** List the main tasks to complete in this phase.
     * **Intended Outcomes:** Describe what completion of the phase should achieve.
     * **Status Section:** Include a space for ongoing status updates and notes, to be filled in as work progresses.

4. **Document Usage Notes**

   * This section **must be included in the document itself**. Use it to explain:

     * How to check the current implementation status.
     * How to review what’s been done in previous phases.
     * How and when to update the documentation (including the phase status sections) as work advances.
     * The importance of capturing all relevant context and decisions, so any agent can continue seamlessly from where things left off.

5. **Technical Notes**
   * This section should include any technical detail that we don't want the next agent to have to re-learn. That could be things like how to run tests, implementation details that must be remembered, etc.