# Commands and agents/subagents

- Remember the difference between slash commands and agents:
  - Commands:
    - Contain prompt templates that get injected as user input into the current conversation
    - Written as instructions TO Claude ("Analyze this...", "Review the following...")
  - Subagents:
    - Contain system-level identity prompts that define HOW the agent should behave
    - Written as role definitions and behavioral guidelines ("You are an expert...", "Your purpose is...")
    - The description field enables automatic invocation, the body defines the agent's personality
