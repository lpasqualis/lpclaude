# **Architecting Intelligence: A Technical Deep Dive into Claude Code Subagents and Agentic Workflows**

**Abstract:** This paper provides an exhaustive technical analysis of Claude Code subagents, clarifying their nature as markdown-based instructional configurations rather than executable code. It dissects their architecture, creation, and invocation mechanisms, contrasting them with user-invoked commands. The report details best practices for designing specialized, single-responsibility agents, managing parallel task execution, and orchestrating complex, multi-agent workflows. By examining the underlying principles of contextual isolation and delegated intelligence, this paper serves as a definitive guide for developers and engineering teams seeking to leverage the full potential of agentic systems within the Claude Code environment.

## **Section 1: Introduction to the Subagent Paradigm**

The evolution of AI-powered development tools has progressed from simple code completion to sophisticated, conversational partners. Within this trajectory, Anthropic's Claude Code introduces an advanced architectural pattern known as subagents, representing a significant step towards multi-agent, autonomous development systems. Understanding this paradigm requires moving beyond the notion of a single, monolithic AI assistant to embrace a model of orchestrated, specialized intelligence.

### **1.1 Defining Subagents: Beyond Code to Instructional Configuration**

A frequent misconception is that a Claude Code subagent is a form of executable code or a compiled binary. The reality is both simpler and more powerful: a subagent is fundamentally a **declarative, markdown-based configuration file**.1 This

.md file does not contain runnable code; instead, it serves as a detailed set of instructions, a blueprint that the main, interactive Claude Code agent uses to spawn a new, temporary, and isolated instance of itself.3

When a user or the main agent invokes a subagent, a lightweight Claude Code instance is created on-the-fly to perform a specific, delegated task. This ephemeral instance *is* the subagent in practice, and its appearance in the terminal is often signified by the Task(...) indicator.3 The configuration file is merely its constitution. This distinction is critical, as it underscores the system's inherent flexibility. Subagents, being simple text files, can be created, edited, shared, and version-controlled using standard developer tools like Git, integrating seamlessly into existing software engineering workflows.2

### **1.2 The Core Principle: Contextual Isolation and Specialization**

The primary architectural driver for the existence of subagents is the effective management of the Large Language Model's (LLM) finite context window. In a single, long-running agentic session, the conversation history, viewed files, and tool outputs accumulate. This can lead to "context pollution," where irrelevant information from previous tasks degrades the model's ability to focus on the current objective, potentially reducing the quality and relevance of its responses.4

Subagents provide an elegant solution to this scaling problem by operating within their own independent context windows.5 When a task is delegated to a subagent, it begins with a clean slate, unburdened by the main agent's conversational history. The main agent passes only the necessary instructions and data for the specific task. The subagent then performs its function—for example, reading and analyzing a thousand-line log file—and returns only the concise, final result, such as a list of three critical error IDs. This process functions much like a well-defined function call in a traditional programming language; it takes specific inputs and returns a clean output, preserving the integrity and focus of the main agent's context window, thereby extending the effective lifespan and coherence of the overall session.6

This contextual isolation is the foundation for specialization. By providing a subagent with a highly focused system prompt and a deliberately restricted set of tools, it can be molded into an "expert" on a single, well-defined task. One might create a security-auditor that can only read files and search for patterns, or a test-suite-generator that excels at creating unit tests but does nothing else. These specialized agents consistently achieve higher-quality and more reliable results on their designated tasks than a single, generalist agent attempting to manage all responsibilities simultaneously.6

### **1.3 The Main Agent as an Orchestrator**

The introduction of subagents reframes the role of the main, interactive Claude Code session. It transitions from being a "doer" to being an **orchestrator** or an AI project manager.13 Its primary responsibility shifts from executing every step itself to intelligently decomposing complex problems, delegating the resulting subtasks to the appropriate specialized worker agents, and finally synthesizing their outputs into a cohesive solution.15

This model directly implements Anthropic's "orchestrator-workers" workflow pattern, a system where a central lead agent dynamically directs a team of worker agents.15 This pattern is particularly effective for tasks with unpredictable sub-steps, which is characteristic of most non-trivial software development projects.15 Consequently, the developer's role in this paradigm evolves. They are no longer simply prompting an assistant but are acting as a workflow architect, designing the agentic system itself. This requires a "multi-threading mindset," where the developer must think critically about task decomposition, dependency management, and parallel execution to guide the AI team effectively.18 This represents a higher level of abstraction in human-AI collaboration, mirroring the responsibilities of a technical lead managing a team of human developers.

## **Section 2: The Anatomy of a Subagent: Setup and Design**

A subagent's capabilities and behavior are defined entirely within its corresponding markdown file. This file-based system is intentionally transparent, allowing developers to understand, modify, and share agentic behaviors with ease. The structure is consistent, comprising a metadata block and a detailed instructional prompt.

### **2.1 The Markdown Foundation: Structure of a Subagent Definition File**

Every subagent is defined in a standard Markdown (.md) file, a format chosen for its human readability and universal support across the development ecosystem.1 This design choice is significant, as it allows agent definitions to be treated like any other project artifact—they can be committed to Git, reviewed in pull requests, and shared among team members.

The file's structure is bipartite. It begins with a YAML frontmatter block, delimited by \---, which contains structured metadata about the agent. This is followed by the main body of the markdown file, which serves as the agent's system prompt.1 This architecture enables what can be described as "Agent Discovery via File System": Claude Code dynamically scans designated directories for these

.md files, loading and even hot-reloading their configurations. This makes the entire agentic system highly extensible, as new capabilities can be added simply by creating a new file.2

### **2.2 Dissecting the YAML Frontmatter**

The YAML frontmatter is the subagent's configuration header. It provides the main orchestrator agent with the essential metadata needed to identify, invoke, and manage the subagent.

* **name**: This is a required, unique identifier for the subagent. By convention, it is lowercase and uses hyphens to separate words (e.g., python-expert or code-refactoring-architect).7 This name is used when a developer wishes to invoke the agent explicitly in a prompt.20  
* **description**: This is arguably the most critical field for enabling autonomous workflows. It is a concise, action-oriented sentence that explains *when* the subagent should be used.5 The main orchestrator agent performs a semantic match between the user's request and this description to decide which subagent to delegate a task to. A well-written description like, "Use this agent to transform monolithic codebases into maintainable, modular architectures," acts as a clear signal for delegation.8  
* **model** (Optional): This field allows developers to specify which Claude model the subagent should use: haiku, sonnet, or opus.12 This feature is crucial for performance and cost optimization. A simple, repetitive task like generating documentation might be assigned to the fast and inexpensive  
  haiku model, while a complex task requiring deep reasoning, such as architectural analysis, would be better suited for the powerful opus model.12 If omitted, the subagent defaults to using the model of the parent session.  
* **tools** (Optional): This field defines a specific list of tools that the subagent is permitted to access, such as Read, Edit, Bash, or Grep.4 This enforces the principle of least privilege, a key security best practice. By restricting a subagent to only the tools necessary for its function, it becomes more focused and secure.2 For instance, a  
  code-reviewer agent might only be given Read and Grep access, preventing it from making any modifications to the codebase. If this field is omitted, the subagent inherits all tools available in the parent session.

### **2.3 Crafting the System Prompt: The "Soul" of the Subagent**

The markdown content that follows the YAML frontmatter constitutes the subagent's system prompt.9 This is the "soul" of the agent, defining its persona, role, responsibilities, constraints, and operational methodology. Crafting an effective system prompt is an exercise in clarity and precision.

Best practices for system prompt design include:

* **Single, Clear Responsibility:** An effective agent is a focused agent. The prompt should clearly define a single primary responsibility, avoiding the creation of generalist agents that try to do too much.5  
* **Detailed Instructions and Examples:** The prompt should provide specific, unambiguous instructions. Including examples of both desired inputs and outputs, as well as explicit constraints on what the agent should *not* do, can dramatically improve performance and reliability.5  
* **Structured Formatting:** Using standard markdown features like headers (\#\#), bulleted lists (-), and even XML tags (e.g., \<operating\_principles\>, \<example\>, \<quality\_checklist\>) helps structure the prompt. This makes the instructions easier for the model to parse and adhere to, leading to more consistent behavior.20 For instance, a  
  Code-Refactoring-Architect agent's prompt might include distinct sections for its Approach, Quality Assurance & Validation, and Communication Style.8

### **2.4 Storage and Scoping: Project vs. User Agents**

The location of a subagent's .md file determines its scope and availability, allowing for a powerful hierarchy of instructions that combines with project-level CLAUDE.md files.23

* **Project-level Agents**: These are stored in the .claude/agents/ directory within a project's repository. Agents defined here are specific to that project. The primary advantage of this approach is that these agent definitions can be committed to version control and shared with the entire development team. This creates a consistent, shared foundation for AI-assisted collaboration, ensuring that every team member's Claude Code instance behaves in the same predictable way for project-specific tasks.1  
* **User-level Agents**: These are stored in the \~/.claude/agents/ directory in the user's home folder. Agents defined here are global to the user and are available across all projects on their machine. This location is ideal for creating personalized, reusable agents that reflect a developer's individual workflow preferences, independent of any single project.1

---

### **Table 2.1: Subagent Markdown File Structure**

The following table provides a quick-reference guide to the structure of a subagent .md definition file, breaking down each component with its purpose and an illustrative example.

| Component | Key/Section | Description | Example |
| :---- | :---- | :---- | :---- |
| **YAML Frontmatter** | name | (Required) The unique, lowercase, hyphenated identifier for the agent. | name: security-auditor |
|  | description | (Required) A concise, action-oriented description for automatic delegation. | description: Use this agent to scan code for common security vulnerabilities like OWASP Top 10\. |
|  | model | (Optional) The specific Claude model to use (haiku, sonnet, opus). Defaults to session model. | model: opus |
|  | tools | (Optional) A comma-separated list of allowed tools. Defaults to inheriting all tools. | tools: Read, Grep |
| **Markdown Body** | **System Prompt** | The detailed instructions, role, and constraints for the agent, written in Markdown. | You are a security auditor. Your sole purpose is to analyze code for vulnerabilities... |

---

## **Section 3: Invocation Mechanics: Activating Subagents**

Once a subagent is defined, it can be brought to life through several invocation mechanisms. The Claude Code environment is designed with a philosophy that balances automation and user control, offering both implicit, intelligent delegation and explicit, precise command. This flexibility allows users to interact with their team of AI agents in a manner best suited to the task at hand.

### **3.1 Implicit Delegation: How the Main Agent Intelligently Routes Tasks**

In its most autonomous mode, Claude Code can automatically delegate a task to the most appropriate subagent without any explicit instruction from the user.5 This intelligent routing is the cornerstone of the orchestrator-worker pattern. The mechanism is driven by a semantic comparison between the user's natural language request and the

description field within each available subagent's YAML frontmatter.5

For example, if a user prompts, "Please review this new authentication module for potential security holes," the main agent will analyze this request. It will then scan the description fields of all known subagents (both project- and user-level). If it finds a subagent with a description like, "Use this agent to check for security vulnerabilities and compliance with best practices," it will recognize a strong match and delegate the task to that agent.11

This process highlights why the description field is not mere documentation but a functional API contract between the orchestrator and its workers. A clear, specific, and action-oriented description is essential for reliable automatic delegation. A vague or poorly written description can lead to the wrong agent being chosen or no delegation occurring at all, effectively breaking the autonomous workflow.

### **3.2 Explicit Invocation: Taking Direct Control of Subagent Execution**

For situations requiring absolute precision, developers can bypass the automatic routing system and explicitly invoke a subagent by its name.11 This provides deterministic control over the workflow, which is crucial for complex, multi-step processes where ambiguity is unacceptable.

The syntax for explicit invocation is conversational and intuitive. A user can simply include a phrase like "Use the code-reviewer to..." or "Have the database-expert agent analyze this schema..." in their prompt.12 The main agent recognizes this pattern, identifies the subagent by its unique

name, and delegates the task accordingly. This method is preferred when the developer knows exactly which specialized tool is needed for the job or when a task is ambiguous enough that it might match multiple subagents.

### **3.3 The /agents Command: An Interactive Creation and Management Interface**

To streamline the process of creating and managing subagents, Claude Code includes a built-in slash command: /agents.4 Typing this command in the terminal opens an interactive wizard that guides the user through the entire lifecycle of subagent management.

When creating a new agent, the wizard prompts the user for all the necessary information:

* **Scope**: Whether the agent should be project-level or user-level.  
* **Definition**: The agent's name, description, and system prompt.  
* **Tools**: A checklist of available tools to grant permission to.2

A key feature of this wizard is the "Generate with Claude" option. This allows the user to provide a high-level goal, and the AI will then generate a draft of the description and system prompt. This is the officially recommended starting point, as it provides a solid foundation that the user can then manually edit and refine to perfection.2 The

/agents command effectively lowers the barrier to entry for building a custom AI team, abstracting away the need to remember the exact file structure and syntax, and making agent creation accessible even to new users.11

## **Section 4: A Critical Distinction: Subagents vs. Slash Commands**

Within the Claude Code ecosystem, two primary features exist for automating workflows: subagents and slash commands. While both are configured via markdown files and aim to improve efficiency, they are architecturally and functionally distinct. Understanding this distinction is fundamental to mastering advanced agentic development.

### **4.1 Analyzing the Functional and Architectural Differences**

The core difference lies in their execution model and handling of context.

* **Subagents are new, isolated agentic processes.** Invoking a subagent is a heavyweight operation in comparison to a command. It involves the main agent spawning an entirely new, lightweight Claude instance. This new instance, the subagent, comes equipped with its own system prompt, its own restricted toolset, and, most importantly, its own clean and independent context window.3 It is a true delegation of a task to a separate worker.  
* **Slash Commands are prompt templates.** Invoking a slash command (e.g., /review) is a lightweight operation. It simply finds the corresponding markdown file (e.g., .claude/commands/review.md) and injects its contents as a prompt into the *current* agent's ongoing conversation.6 No new agent is created. The command is executed within the existing agent's session, using its established context.

This architectural divergence leads to opposite effects on context management. Subagents are a tool for *preserving* the main agent's context by offloading information-heavy tasks. Slash commands, by their nature, *consume* the main agent's context by adding their prompt text to the conversation history.

### **4.2 Use Cases and Decision Criteria: When to Build a Subagent vs. a Command**

The choice between creating a subagent and a slash command depends entirely on the nature of the task.

A developer should **build a subagent** when:

* The task is **complex** and requires its own dedicated "thinking space" or a multi-step reasoning process, such as analyzing an entire codebase or debugging an intricate issue.6  
* The task involves processing a **large volume of information** that would otherwise "pollute" the main agent's context, such as reading long documentation files, parsing large log outputs, or searching across many files.6  
* A **specialized persona or a restricted set of capabilities** is required. For example, a security-auditor that must not be allowed to write files, or a tdd-advocate that has a very specific, pedantic personality about testing.5  
* The task can be **run in parallel** with other tasks to accelerate the overall workflow.30

Conversely, a developer should **build a slash command** when:

* There is a **frequently repeated prompt** or a boilerplate set of instructions that needs to be recalled quickly, such as a template for generating a new React component or a standard checklist for a code review.24  
* A simple **workflow shortcut** is needed that should operate on the information already present in the current context.6  
* The task is a relatively **simple, one-shot instruction** rather than a complex, stateful process.

The community's desire to see subagent-like features, such as model selection, added to slash commands further underscores that these are viewed as two distinct but complementary tools in the developer's automation arsenal.21

---

### **Table 4.1: Comparative Analysis: Subagents vs. Slash Commands**

To provide a clear, at-a-glance reference, the following table compares subagents and slash commands across several key architectural and functional attributes.

| Attribute | Subagents | Slash Commands |
| :---- | :---- | :---- |
| **Core Concept** | A specialized, isolated AI assistant (a new agentic process). | A reusable prompt template. |
| **Execution Model** | Spawns a new, lightweight Claude Code instance (Task). | Inserts a prompt into the *current* Claude Code session. |
| **Context Handling** | Operates in its own independent context window. Preserves main context. | Operates within the main agent's context window. Consumes main context. |
| **Configuration** | .md file in agents/ with YAML frontmatter and system prompt. | .md file in commands/ containing only the prompt text. |
| **Invocation** | Implicitly via delegation or explicitly by name (e.g., "Use the..."). | Explicitly via /command\_name. |
| **Primary Use Case** | Complex, isolated, or parallelizable tasks. Role-based specialization. | Storing and reusing frequent prompts. Workflow shortcuts. |
| **Parallelism** | Yes, can be run in parallel with other subagents. | No, executes sequentially within the main agent's turn. |

---

## **Section 5: Orchestrating Parallelism: Managing Concurrent Tasks**

One of the most powerful capabilities unlocked by the subagent architecture is the ability to execute tasks in parallel. This allows a single orchestrator agent to manage multiple worker agents simultaneously, dramatically accelerating development timelines for complex projects that can be decomposed into independent workstreams.10

### **5.1 Strategies for Initiating Parallel Workflows**

Initiating a parallel workflow is done through natural language instructions to the main orchestrator agent. There is no special syntax; the developer simply describes the desired concurrent operation.

Common prompts for initiating parallel tasks include:

* Explore the codebase using 4 tasks in parallel. Each agent should explore different directories. 31  
* Use the task tool to create 10 parallel tasks. This is a simulation, use the sleep command to simulate wait... 30  
* Deploy multiple sub-agents, run them in parallel. 10

This capability is particularly effective for "fan-out" operations where a single problem can be broken into many independent sub-problems. Examples include analyzing different modules of a large codebase, implementing separate UI components for a new feature, running different kinds of static analysis (e.g., performance, security, complexity) on the same code, or researching multiple potential solutions to a problem on the web simultaneously.17

### **5.2 Understanding System Constraints: The Parallelism Cap and Task Queuing**

While powerful, the parallel execution capability of Claude Code is not infinite. The system appears to have a hard-coded cap of **10 concurrent parallel tasks**.3 This limit is likely in place to manage system resources and API rate limits effectively.

When a user requests more than 10 parallel tasks, the system does not fail. Instead, it employs a queuing mechanism. The first 10 tasks are executed concurrently, and the remaining tasks are placed in a queue. As soon as one of the active tasks completes, its execution slot is freed, and the next task from the front of the queue is initiated. This process continues until all requested tasks have been completed, ensuring that the system maintains maximum throughput without exceeding its parallelism cap.3

There is a subtle but important nuance in how the system handles explicit requests for a specific level of parallelism. If a prompt specifies a number (e.g., "run 4 parallel tasks"), Claude Code may execute the tasks in distinct batches, waiting for the entire batch of 4 to complete before starting the next batch. In contrast, if no parallelism level is specified (e.g., "run these 15 tasks in parallel"), the system seems to operate more efficiently, using the more dynamic queuing mechanism described above. Therefore, the general recommendation is to let Claude Code manage the level of parallelism automatically unless specific throttling of the workload is required.30

### **5.3 Best Practices for Efficient Parallel Task Design and Management**

Effective parallel orchestration requires more than just telling the agent to run tasks concurrently. It demands careful planning and task design from the developer or the lead orchestrator agent.

* **Ensure Task Independence**: The most critical prerequisite for successful parallelization is that the subtasks must be independent. They should not have dependencies on each other's outputs, and critically, they should not attempt to modify the same files or resources simultaneously. A failure to ensure independence can lead to race conditions, where one agent's work is overwritten by another, resulting in a corrupted final state.10  
* **Granular Task Decomposition**: The initial problem must be broken down into sufficiently small and well-defined subtasks. This process of decomposition is a key responsibility of the orchestrator, whether that is the human user or the main AI agent in a "plan-then-act" workflow.19  
* **Balance the Workload**: While it may be tempting to maximize parallelism, it can sometimes be more efficient to balance the workload across a smaller number of agents. The overall completion time of a parallel workflow is determined by its longest-running task (the bottleneck). Therefore, careful consideration should be given to how both fast- and slow-running tasks are batched and distributed among workers.30  
* **Manual Conflict Prevention**: As a manual safeguard against conflicts, some developers have reported success in instructing the orchestrator agent to dynamically create a CLAUDE.md file that explicitly reminds the worker subagents not to overwrite each other's changes. This serves as a form of rudimentary, instruction-based concurrency control.10

### **5.4 Advanced Orchestration: Integrating with External Tools and MCP Servers**

The native parallelism of Claude Code provides a powerful foundation, but the true frontier of agentic development lies in combining this capability with external orchestration frameworks and tools, often connected via the Model Context Protocol (MCP).33

Community-driven projects like claude-parallel-work exemplify this advanced approach. This tool provides an MCP server that goes beyond simple parallel execution. It intelligently breaks down tasks, analyzes dependencies, executes each task in a fully isolated Docker container for security and environment consistency, and manages the entire workflow's state in a persistent SQLite database.34 This represents a significant leap in sophistication, moving towards a robust, autonomous development platform.

This trend suggests a maturing ecosystem where a separation of concerns is emerging. Claude Code provides the core "agentic compute" primitive—the ability to run a specialized task in an isolated context. Higher-level tools and platforms, both open-source 33 and commercial 35, are being built on top of this primitive to provide the sophisticated orchestration layer (e.g., dependency management, state persistence, environment provisioning) required for true end-to-end project automation. This evolution mirrors historical trends in computing, such as the development of container orchestration systems like Kubernetes on top of the core container primitive provided by Docker.

## **Section 6: Advanced Strategies and Best Practices**

Moving from basic use to mastery of Claude Code's agentic capabilities requires the adoption of strategic workflows and design principles. These practices are not merely suggestions for better results; they are often necessary approaches to manage the complexity inherent in orchestrating multiple AI agents and to compensate for the current limitations of the technology.

### **6.1 The "Plan-Then-Act" Workflow for Complex Problem Solving**

A consistently reported best practice for tackling any non-trivial task is to adopt a multi-phase workflow, most commonly described as "Plan, Act, and Review".4 This structured approach dramatically improves the reliability and quality of the outcomes by decomposing a single, complex request into a series of simpler, more manageable steps.

* **Phase 1: Plan**: The initial instruction to the agent should be to explore the problem space and formulate a detailed plan of action *without writing any implementation code*. This involves tasks like reading relevant files, analyzing existing code, searching documentation, and outlining the proposed changes.24 To allocate more computational resources to this critical thinking phase, developers can use trigger words like  
  think, think hard, think harder, or ultrathink, which correspond to progressively larger thinking budgets within the system.24 The resulting plan should be outputted to a markdown file or a GitHub issue, creating a stable checkpoint and a checklist for the next phase.24  
* **Phase 2: Act**: Once the developer has reviewed and approved the plan, the second instruction is to execute it. This is where the main agent often acts as an orchestrator, delegating the individual steps from the plan to specialized subagents.10  
* **Phase 3: Review**: After the implementation is complete, a final phase of verification is essential. This can involve running a separate Claude instance or a dedicated reviewer-agent to analyze the generated code for quality, correctness, and adherence to style guides.24 A particularly powerful technique is to use a subagent to independently verify that the new code is not merely "overfitting" to the test cases it was designed to pass, ensuring a more robust solution.24

This phased approach is a form of meta-prompting. The output from the first prompt (the plan) serves as a highly structured and unambiguous input for the second prompt (the execution). This decouples the creative, open-ended problem-solving from the more mechanical implementation, a separation that significantly enhances the system's predictability and success rate.15

### **6.2 Designing for Synergy: Combining Commands and Subagents**

The most sophisticated and efficient workflows emerge from the synergistic combination of slash commands and subagents. A slash command can be used to encapsulate and name a complex, multi-agent orchestration pattern, effectively creating a reusable "program" of agentic behavior.

For example, a developer could create a slash command named /ship:feature. The corresponding markdown file (.claude/commands/ship:feature.md) would not contain code but rather a detailed natural language prompt that instructs the main agent to execute a full development lifecycle. This prompt might direct the agent to:

1. Invoke the laravel-planner subagent to create a feature plan.  
2. Invoke the laravel-coder subagent to implement the approved plan.  
3. Invoke the test-runner subagent to execute the test suite and fix any failures.4

This strategy transforms a complex, multi-step orchestration into a single, memorable, and reusable command. It represents the highest level of workflow automation currently achievable within the Claude Code environment, allowing developers to define their own high-level "agentic programming language" where slash commands act as named procedures that call upon a library of specialized subagent "functions".4

### **6.3 Defensive Design: The Principle of Least Privilege in Tool Allocation**

A crucial best practice for both security and performance is the careful application of the principle of least privilege when defining subagents. In the subagent's YAML frontmatter, the tools key should be used to grant access to *only* the tools that are absolutely necessary for its designated function.5

For instance, a security-auditor agent whose sole purpose is to analyze code for vulnerabilities should likely only be granted Read and Grep permissions.2 This prevents it from accidentally or maliciously modifying files, running shell commands, or performing other actions outside its scope. Beyond security, limiting the available tools also helps the agent to focus. With fewer choices, the LLM is less likely to become confused or select an inappropriate tool for a given step, leading to more predictable and efficient task execution.16

### **6.4 Iterative Refinement: Treating Subagent Definitions as Living Documents**

Subagent definition files should not be considered static artifacts. They are living documents that must be iteratively refined and improved based on their real-world performance.9 When a subagent fails to perform a task correctly or produces a suboptimal result, its system prompt should be analyzed and updated.

A powerful technique for this refinement process is to leverage Claude itself as a prompt engineering assistant. A developer can take the failing system prompt, describe the specific failure mode that occurred, and ask another Claude instance to diagnose the problem and suggest improvements to the prompt.16

By storing these agent definitions in a version control system like Git, development teams can collaborate on their evolution. The team's collective experience can be codified into the prompts, gradually building a more robust and capable team of shared AI assistants over time.5

## **Section 7: A Blueprint for Creation: Prompting a Subagent Generator**

The preceding sections have detailed the architecture, mechanics, and best practices for Claude Code subagents. This final section synthesizes these learnings into a practical, actionable tool: a structured prompt designed to guide an AI assistant in the creation of a new, high-quality subagent. This "meta-prompt" encapsulates the best practices of subagent design, serving as a blueprint for developers to build their own specialized AI workers.

### **7.1 Analysis of Requirements for a Meta-Prompt**

To be effective, a prompt for generating a subagent must guide a user through a structured process that elicits all the necessary components of the final .md file. It must actively encourage best practices rather than simply asking for the information. User reports indicate that asking Claude to create agents based on documentation and clear examples yields superior results compared to using the built-in wizard without guidance.20

The prompt must therefore:

* Sequentially request information for the name, description, model, and tools YAML fields.  
* Emphasize the importance of a single, clear responsibility.  
* Guide the user in crafting an action-oriented description suitable for automatic delegation.  
* Enforce the principle of least privilege by asking the user to justify each tool they select.  
* Explain the cost-versus-capability trade-offs for model selection.  
* Elicit a detailed, structured system prompt that defines the agent's role, responsibilities, constraints, and methodology.  
* Assemble all the pieces into a final, correctly formatted markdown file ready for use.

### **7.2 A Structured Prompt to Guide an AI in Generating a New, Custom Subagent**

The following prompt can be used in a Claude Code session to collaboratively design and generate a new subagent definition.

You are an expert assistant specializing in creating high-quality Claude Code subagents. Your goal is to guide me through a structured, step-by-step process to define a new subagent that is focused, secure, and effective. At the end of our conversation, you will assemble all our decisions into a complete .md file, ready for me to save in my .claude/agents/ directory.

Let's begin.

---

### **Step 1: Core Purpose and Name**

First, please describe in one or two sentences the primary goal of the subagent you want to create. What is its single most important responsibility? Keep in mind that the most effective agents are specialists, not generalists.

*Based on your description, I will suggest a concise, lowercase, hyphen-separated name for the agent, following best practices.*

---

### **Step 2: Description for Automatic Delegation**

Next, we will craft the description field. This is the most critical field for enabling Claude Code to automatically delegate tasks to this agent. It must be a single, clear, action-oriented sentence that starts with "Use this agent to...".

For example: "Use this agent to refactor Python code for PEP 8 compliance." or "Use this agent to write comprehensive unit tests for TypeScript functions."

*How would you describe, in one sentence, exactly when this agent should be used? I will help you refine it for maximum clarity and effectiveness.*

---

### **Step 3: Tool Selection (Principle of Least Privilege)**

Now, let's select the tools this agent will be allowed to use. For security and focus, it's crucial to grant only the minimum necessary permissions.

Here is a list of common tools: Read, Write, Edit, Grep, Glob, Bash, Task.

*Please list the tools you think this agent needs, and I will ask you to briefly justify why each one is essential for its core function. We will build a minimal, secure toolset.*

---

### **Step 4: Model Selection (Cost vs. Performance)**

We need to choose the right engine for this agent. The choice of model impacts cost, speed, and reasoning ability.

* **haiku**: Fastest and most cost-effective. Best for simple, repetitive tasks like formatting or boilerplate generation.  
* **sonnet**: A balance of speed and intelligence. Good for most standard tasks like code generation, explanation, and simple refactoring.  
* **opus**: Most powerful and intelligent, but also the most expensive. Best for highly complex tasks requiring deep reasoning, such as architectural planning, debugging intricate issues, or advanced security analysis.

*Based on the agent's purpose, which model do you believe is the most appropriate?*

---

### **Step 5: The System Prompt (The Agent's Soul)**

This is the final and most detailed step. We will write the main system prompt for the agent. I will help you structure it for clarity using Markdown. We should include the following sections:

1. **Role and Goal**: A clear declaration of the agent's persona and primary objective.  
2. **Core Responsibilities**: A bulleted list of key tasks the agent is expected to perform.  
3. **Constraints and Limitations**: A list of things the agent MUST NOT do.  
4. **Methodology/Process**: A step-by-step process the agent should follow when it is invoked.  
5. **Example(s) of Use**: (Optional but highly recommended) A small example of a user request and the agent's ideal response.

*Please provide the details for each of these sections, and I will help you formulate them into a clear and effective system prompt.*

---

Once we have completed all steps, I will provide you with the complete, formatted markdown file for your new subagent.

#### **Works cited**

1. Claude Code settings \- Anthropic API, accessed August 4, 2025, [https://docs.anthropic.com/en/docs/claude-code/settings](https://docs.anthropic.com/en/docs/claude-code/settings)  
2. Claude Code's Custom Agent Framework Changes Everything \- DEV Community, accessed August 4, 2025, [https://dev.to/therealmrmumba/claude-codes-custom-agent-framework-changes-everything-4o4m](https://dev.to/therealmrmumba/claude-codes-custom-agent-framework-changes-everything-4o4m)  
3. Claude Code: Subagent Deep Dive, accessed August 4, 2025, [https://cuong.io/blog/2025/06/24-claude-code-subagent-deep-dive](https://cuong.io/blog/2025/06/24-claude-code-subagent-deep-dive)  
4. Practical guide to mastering Claude Code's main agent and Sub‑agents | by Md Mazaharul Huq | Jul, 2025 | Medium, accessed August 4, 2025, [https://medium.com/@jewelhuq/practical-guide-to-mastering-claude-codes-main-agent-and-sub-agents-fd52952dcf00](https://medium.com/@jewelhuq/practical-guide-to-mastering-claude-codes-main-agent-and-sub-agents-fd52952dcf00)  
5. Subagents \- Anthropic API, accessed August 4, 2025, [https://docs.anthropic.com/en/docs/claude-code/sub-agents](https://docs.anthropic.com/en/docs/claude-code/sub-agents)  
6. Just tried using subagents. This unlocks the true power of Claude Code. \- Reddit, accessed August 4, 2025, [https://www.reddit.com/r/ClaudeAI/comments/1lojyky/just\_tried\_using\_subagents\_this\_unlocks\_the\_true/](https://www.reddit.com/r/ClaudeAI/comments/1lojyky/just_tried_using_subagents_this_unlocks_the_true/)  
7. 0xfurai/claude-code-subagents: A comprehensive ... \- GitHub, accessed August 4, 2025, [https://github.com/0xfurai/claude-code-subagents](https://github.com/0xfurai/claude-code-subagents)  
8. Claude Code sub agents : r/ClaudeAI \- Reddit, accessed August 4, 2025, [https://www.reddit.com/r/ClaudeAI/comments/1m8s70m/claude\_code\_sub\_agents/](https://www.reddit.com/r/ClaudeAI/comments/1m8s70m/claude_code_sub_agents/)  
9. Multi-agent Mastery: Building integrated analytics features with Claude Code and Tinybird Code, accessed August 4, 2025, [https://www.tinybird.co/blog-posts/multi-agent-claude-code-tinybird-code](https://www.tinybird.co/blog-posts/multi-agent-claude-code-tinybird-code)  
10. Mastering Claude Code: The Sub-agent Pattern \- Enting's Blog, accessed August 4, 2025, [https://enting.org/mastering-claude-code-sub-agent/](https://enting.org/mastering-claude-code-sub-agent/)  
11. Best Claude Code Agents and Their Use Cases: Complete Guide for Developers, accessed August 4, 2025, [https://superprompt.com/blog/best-claude-code-agents-and-use-cases](https://superprompt.com/blog/best-claude-code-agents-and-use-cases)  
12. wshobson/agents: A collection of production-ready subagents for Claude Code \- GitHub, accessed August 4, 2025, [https://github.com/wshobson/agents](https://github.com/wshobson/agents)  
13. BEST AI Coder\! SUPERCHARGE Claude Code and 10x Coding Workflow\! \- YouTube, accessed August 4, 2025, [https://www.youtube.com/watch?v=YxP7hZmysKk](https://www.youtube.com/watch?v=YxP7hZmysKk)  
14. How to use Claude Code Agents \- YouTube, accessed August 4, 2025, [https://www.youtube.com/watch?v=tw6AJ8nxu48](https://www.youtube.com/watch?v=tw6AJ8nxu48)  
15. Building Effective AI Agents \\ Anthropic, accessed August 4, 2025, [https://www.anthropic.com/research/building-effective-agents](https://www.anthropic.com/research/building-effective-agents)  
16. How we built our multi-agent research system \- Anthropic, accessed August 4, 2025, [https://www.anthropic.com/engineering/built-multi-agent-research-system](https://www.anthropic.com/engineering/built-multi-agent-research-system)  
17. Sub Agent / Multi-Agent Claude Code Commands for Refactoring, Testing, and Optimisation (Watch Your Tokens Disappear and Use Sparingly) : r/ClaudeAI \- Reddit, accessed August 4, 2025, [https://www.reddit.com/r/ClaudeAI/comments/1lf5gwp/sub\_agent\_multiagent\_claude\_code\_commands\_for/](https://www.reddit.com/r/ClaudeAI/comments/1lf5gwp/sub_agent_multiagent_claude_code_commands_for/)  
18. Task/Agent Tools | ClaudeLog, accessed August 4, 2025, [https://www.claudelog.com/mechanics/task-agent-tools/](https://www.claudelog.com/mechanics/task-agent-tools/)  
19. How I use Claude code or cli agents : r/ClaudeAI \- Reddit, accessed August 4, 2025, [https://www.reddit.com/r/ClaudeAI/comments/1l63454/how\_i\_use\_claude\_code\_or\_cli\_agents/](https://www.reddit.com/r/ClaudeAI/comments/1l63454/how_i_use_claude_code_or_cli_agents/)  
20. Claude Code now supports Custom Agents : r/ClaudeAI \- Reddit, accessed August 4, 2025, [https://www.reddit.com/r/ClaudeAI/comments/1m8ik5l/claude\_code\_now\_supports\_custom\_agents/](https://www.reddit.com/r/ClaudeAI/comments/1m8ik5l/claude_code_now_supports_custom_agents/)  
21. Feature Request: Add model selection support for custom commands (similar to subagents) · Issue \#4937 · anthropics/claude-code \- GitHub, accessed August 4, 2025, [https://github.com/anthropics/claude-code/issues/4937](https://github.com/anthropics/claude-code/issues/4937)  
22. Best format to feed Claude documents? : r/ClaudeAI \- Reddit, accessed August 4, 2025, [https://www.reddit.com/r/ClaudeAI/comments/1hs0adv/best\_format\_to\_feed\_claude\_documents/](https://www.reddit.com/r/ClaudeAI/comments/1hs0adv/best_format_to_feed_claude_documents/)  
23. What's a Claude.md File? 5 Best Practices to Use Claude.md for Claude Code \- Apidog, accessed August 4, 2025, [https://apidog.com/blog/claude-md/](https://apidog.com/blog/claude-md/)  
24. Claude Code: Best practices for agentic coding \- Anthropic, accessed August 4, 2025, [https://www.anthropic.com/engineering/claude-code-best-practices](https://www.anthropic.com/engineering/claude-code-best-practices)  
25. Common workflows \- Anthropic API, accessed August 4, 2025, [https://docs.anthropic.com/en/docs/claude-code/common-workflows](https://docs.anthropic.com/en/docs/claude-code/common-workflows)  
26. Claude Code introduces specialized sub-agents | Hacker News, accessed August 4, 2025, [https://news.ycombinator.com/item?id=44686726](https://news.ycombinator.com/item?id=44686726)  
27. How Can Claude Code Sub-Agents Revolutionize Your Development Workflow? \- Apidog, accessed August 4, 2025, [https://apidog.com/blog/claude-code-sub-agents/](https://apidog.com/blog/claude-code-sub-agents/)  
28. Slash commands \- Anthropic API, accessed August 4, 2025, [https://docs.anthropic.com/en/docs/claude-code/slash-commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands)  
29. PSA \- don't forget you can invoke subagents in Claude code. : r/ClaudeAI \- Reddit, accessed August 4, 2025, [https://www.reddit.com/r/ClaudeAI/comments/1l9ja9h/psa\_dont\_forget\_you\_can\_invoke\_subagents\_in/](https://www.reddit.com/r/ClaudeAI/comments/1l9ja9h/psa_dont_forget_you_can_invoke_subagents_in/)  
30. Subagent testing: what happens when you throw 100 tasks to Claude Code? \- Reddit, accessed August 4, 2025, [https://www.reddit.com/r/ClaudeAI/comments/1lk0usp/subagent\_testing\_what\_happens\_when\_you\_throw\_100/](https://www.reddit.com/r/ClaudeAI/comments/1lk0usp/subagent_testing_what_happens_when_you_throw_100/)  
31. Multi-agent parallel coding with Claude Code Subagents | by Cuong ..., accessed August 4, 2025, [https://medium.com/@codecentrevibe/claude-code-multi-agent-parallel-coding-83271c4675fa](https://medium.com/@codecentrevibe/claude-code-multi-agent-parallel-coding-83271c4675fa)  
32. How I Use Claude Code | Philipp Spiess, accessed August 4, 2025, [https://spiess.dev/blog/how-i-use-claude-code](https://spiess.dev/blog/how-i-use-claude-code)  
33. Feature Request: Parallel Agent Execution Mode · Issue \#3013 · anthropics/claude-code, accessed August 4, 2025, [https://github.com/anthropics/claude-code/issues/3013](https://github.com/anthropics/claude-code/issues/3013)  
34. ddfourtwo/claude-parallel-work: Async background workers for claude code. \- GitHub, accessed August 4, 2025, [https://github.com/ddfourtwo/claude-parallel-work](https://github.com/ddfourtwo/claude-parallel-work)  
35. How to Run Claude Code in Parallel (with Tembo), accessed August 4, 2025, [https://www.tembo.io/blog/how-to-run-claude-code-in-parallel](https://www.tembo.io/blog/how-to-run-claude-code-in-parallel)  
36. Mastering Claude Code: The Ultimate Guide to AI-Powered Development | by Kushal Banda, accessed August 4, 2025, [https://medium.com/@kushalbanda/mastering-claude-code-the-ultimate-guide-to-ai-powered-development-afccf1bdbd5b](https://medium.com/@kushalbanda/mastering-claude-code-the-ultimate-guide-to-ai-powered-development-afccf1bdbd5b)  
37. Wonderful world of Claude Code subagents running for \~2.5hrs non-stop\! \- Reddit, accessed August 4, 2025, [https://www.reddit.com/r/ClaudeAI/comments/1m8u4cx/wonderful\_world\_of\_claude\_code\_subagents\_running/](https://www.reddit.com/r/ClaudeAI/comments/1m8u4cx/wonderful_world_of_claude_code_subagents_running/)  
38. Full manual for writing your first Claude Code Agents : r/ClaudeAI \- Reddit, accessed August 4, 2025, [https://www.reddit.com/r/ClaudeAI/comments/1ma4ccq/full\_manual\_for\_writing\_your\_first\_claude\_code/](https://www.reddit.com/r/ClaudeAI/comments/1ma4ccq/full_manual_for_writing_your_first_claude_code/)