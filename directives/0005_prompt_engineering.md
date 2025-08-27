# Prompt Engineering Best Practices

When you are asked to write instructions for an AI (prompt), follow these best practices. This applies in cases like:
- Writing slash commands
- Writing instructions for a task when invoking a Task tool
- Writing an agent or subagent
- When invoking a delegate LLM

## Contextual Prompt Types

- **System Prompts**: Used for subagents and tasks. Define identity, core behaviors, and operational guidelines. Often start with role definitions like "You are an expert...".
- **User Prompts**: Used for direct commands and instructions to delegate LLMs. Written as imperatives like "Analyze this document..." or "Review the following code...".
- While the context differs, the principles of clarity, structure, and verification apply universally to the content of both prompt types.

## Foundational Principles

- **Clarity and Specificity**: Formulate prompts that are unambiguous and explicit about the task, desired output format, and all constraints. Vague instructions lead to inconsistent results.
- **Role and Perspective Assignment**: Begin prompts by assigning a specific, expert role (e.g., "You are a cybersecurity analyst") to anchor the model's tone, style, and knowledge base.
- **Structured Formatting**: Utilize Markdown or XML-style tags to logically organize the prompt's content. Place the most critical instructions at the very beginning or end of the prompt to leverage primacy and recency effects.
- **Provide Context and Examples**: Include all necessary background information, clearly separating it from the instructions. When possible, provide one or two "few-shot" examples of a correct output to clarify expectations better than a description alone.

## Advanced Reasoning and Planning Strategies

- **Chain-of-Thought (CoT)**: For tasks requiring logic, math, or multi-step reasoning, explicitly instruct the model to "think step by step" or "explain your reasoning". This forces the generation of an intermediate reasoning path, improving accuracy on complex symbolic tasks.
- **Task Decomposition**: Break down complex requests into a sequence of smaller, manageable sub-tasks. A reliable structure is **Decomposition** (break down the problem), **Analysis** (solve each part), and **Synthesis** (integrate the results).
- **Tree-of-Thought (ToT)**: For problems with multiple potential solution paths, instruct the model to explore and evaluate several different approaches or assumptions before selecting the most promising one. This can be prompted by asking the model to "Imagine three different experts are tackling the question...".

## Tool Integration and Agentic Actions

- **Reason-Act (ReAct) Framework**: Structure prompts to guide the model through a cycle of interweaving **thoughts** (reasoning traces), **actions** (tool calls), and **observations** (tool outputs).
- **Explicit Tool Use**: Clearly define available tools and their syntax. Instruct the model to use tools to verify information or perform calculations when uncertain, rather than hallucinating an answer.
- **Outcome Analysis**: Mandate a feedback loop where the model analyzes the outcome of each action. If a tool returns an error or an unexpected result, the model must diagnose the issue and adjust its plan accordingly.

## Verification and Self-Correction Protocols

- **Chain-of-Verification (CoVe)**: To reduce factual hallucinations, implement a multi-step verification process: 1) generate an initial answer; 2) formulate verification questions about claims in the answer; 3) answer these questions independently (using tools if needed); 4) revise the initial answer based on the verified facts.
- **Reflexion (Self-Critique)**: After an attempt, prompt the model to generate a self-reflection on its performance, identifying errors or shortcomings. This reflection is then used as context to inform and improve the next attempt, preventing repeated mistakes.
- **Automated Testing and Validation**:
  - **For Code**: Instruct the model to generate and execute unit tests for its own code, covering typical and edge cases. If tests fail, it must debug and correct the code.
  - **For System Operations**: Mandate post-action checks. For example, after a file move operation, instruct the model to list the contents of the source and destination directories to confirm success.

## Domain-Specific Adaptations

- **Software Engineering**: Prompts must specify roles, constraints (e.g., complexity), and require a plan (in comments or pseudocode) before implementation. Emphasize error handling and self-debugging loops.
- **Document Writing**: Define a clear structure or outline in the prompt (e.g., sections, headings). Use a checklist of required points to ensure content completeness and prompt for a self-review pass to check for clarity and coherence.
- **Problem Solving & Logic**: Always require a step-by-step chain of thought. Encourage the model to formalize the problem (e.g., into equations) and validate the final answer by checking it against the initial problem constraints.
- **File and System Operations**: Prioritize safety and deliberation. Instruct the agent to plan the sequence of commands, verify system state before acting (e.g., check if a file exists), and verify the outcome after acting. Mandate robust error handling for failed commands.