

# **The Architect's Handbook to Claude Subagents: A Definitive Guide to Proactive Invocation and Multi-Agent Design**

## **Section 1: The Subagent Paradigm: An Architectural Overview**

The advent of subagents within the Claude Code ecosystem represents a significant architectural evolution in agentic software development. Moving beyond the limitations of a single, monolithic AI assistant, the subagent model introduces a paradigm of specialized, distributed intelligence. Understanding this architecture is fundamental to harnessing its full potential for building complex, automated development workflows.

### **1.1 Defining the Subagent: A Specialized Reasoning Process**

At its core, a Claude subagent is not a distinct technical component but rather a "functionality pattern" where the primary Claude agent creates a specialized, independent reasoning process to handle a focused task.1 These are best understood as "specialized AI assistants" or "lightweight instances of Claude Code" designed to augment the main agent's capabilities with task-specific expertise.2

This model establishes a clear hierarchy. The main Claude Code instance acts as a project manager, orchestrator, or liaison, responsible for understanding the user's high-level goals. Subagents, in contrast, function as "specialist gig workers".5 Each subagent is an expert in a narrow domain—such as code review, database optimization, or frontend development—that the main agent can delegate to when it encounters a relevant task.2 This modular approach marks a deliberate shift from all-in-one coding assistants to a more robust, distributed, and specialized architecture.7

### **1.2 The Core Architectural Components**

The efficacy of the subagent pattern is derived from three fundamental architectural components that work in concert: the isolated context window, the specialized system prompt, and granular permissions.

* **The Isolated Context Window:** This is arguably the most critical feature of the subagent architecture. Every subagent operates within its own independent context window, completely separate from the main conversation and other subagents.2 This isolation is the primary mechanism for preserving the main agent's limited and valuable context. It prevents the primary conversation from being "polluted" with the extensive but transient information required for a complex sub-task, such as the contents of a large log file or a verbose API response.5 The subagent performs its analysis in isolation and returns only the final, concise result, thereby protecting the main agent's token budget and cognitive focus.5  
* **The Specialized System Prompt:** Each subagent's expertise is defined and encoded within a highly tailored system prompt.7 This prompt, stored in the subagent's definition file, establishes its persona, role, constraints, and operational instructions. It is here that its "domain-specific intelligence" is programmed, allowing it to achieve superior performance on specialized tasks compared to a generalist agent.2  
* **Granular Tool & Model Permissions:** The architecture allows for fine-grained control over each subagent's capabilities. A subagent can be granted access to a specific subset of the available tools, adhering to the principle of least privilege for enhanced security.2 Furthermore, each subagent can be configured to use a different underlying model (e.g., the powerful Claude Opus for complex planning, or the fast and economical Claude Haiku for routine tasks), enabling developers to optimize workflows for both performance and cost.12

### **1.3 Key System-Level Benefits**

The combination of these architectural components yields several system-level benefits that transform the development experience:

* **Context Preservation and Memory Efficiency:** As established, the primary advantage is the preservation of the main agent's context window. This prevents the performance degradation commonly seen in large language models during long, complex conversations and allows the system to tackle more ambitious tasks.2 The subagent mechanism can be viewed as a  
  **programmable contextual firewall**. The developer defines the "firewall rules" through the subagent's prompt. When a task requires processing a large volume of "untrusted" or "noisy" context (e.g., analyzing a multi-megabyte log file), the main agent delegates it to the subagent. The subagent processes this data within its isolated zone and passes only a small, sanitized, and highly relevant piece of information back through the firewall, protecting the main context from being overwhelmed.5  
* **Enhanced Accuracy and Specialization:** By focusing a subagent with a specialized prompt and a curated toolset on a narrow task, it can achieve expert-level performance and higher accuracy than a generalist agent attempting the same task.2  
* **Parallelism and Efficiency:** The architecture supports the parallel execution of subagents. This allows for significant performance gains on tasks that can be decomposed into independent sub-problems, such as exploring multiple directories of a large codebase simultaneously or conducting parallel research on different facets of a topic.4  
* **Workflow Consistency and Reusability:** Subagents are defined in portable files that can be scoped to a specific project (.claude/agents/) or to a user's global environment (\~/.claude/agents/). This allows them to be version-controlled, shared across teams, and reused in multiple projects, thereby enforcing consistent development standards and best practices.2

## **Section 2: Mechanisms of Invocation: How Claude Summons a Subagent**

A subagent's power is only realized when it is invoked. The Claude Code framework provides a flexible spectrum of invocation mechanisms, ranging from fully autonomous delegation managed by the AI to precise, manual orchestration controlled by the user. Understanding these mechanisms is key to designing agents that are activated reliably and appropriately.

### **2.1 Implicit Invocation: The Automatic Delegator**

The most powerful invocation method is implicit. Claude Code is designed to automatically delegate a task to the most appropriate subagent based on the context of the user's prompt and the current state of the project.2 This autonomous behavior is the foundation of a proactive agentic system.

The core driver for this automatic selection is a semantic match between the user's request and the subagent's description field, which is defined in its configuration file.2 This description serves as the primary trigger. However, the decision is not based on the prompt alone; it is also informed by the broader context, including the types of files being edited, error messages encountered in the terminal, and the overall goal of the workflow.16 For example, encountering a series of

pytest errors is a strong contextual signal to invoke a subagent whose description mentions expertise in debugging Python tests.

### **2.2 Explicit Invocation: Manual Orchestration**

For situations requiring direct control, developers can invoke subagents explicitly through several methods:

* **@-Mentioning with Typeahead:** The most direct method is to mention the subagent by its name, prefixed with an @ symbol (e.g., @code-reviewer review these changes).12 This bypasses the automatic selection logic and ensures a specific specialist is engaged for the task. **Enhanced in 2025:** Claude Code version 1.0.62 introduced intelligent typeahead completion for @-mentions. When typing `@` in the command line, users see a filterable list of available subagents with descriptions, making discovery and selection seamless. This feature significantly improves the user experience by reducing the cognitive load of remembering exact subagent names and enabling rapid exploration of available capabilities.  
* **Natural Language Instructions:** A user can simply ask the main agent to use a specialist in plain English (e.g., "Use the security auditor to scan for vulnerabilities").1 This relies on the main agent's natural language understanding to correctly map the request to the intended subagent.  
* **Custom Slash Commands:** For complex, repeatable workflows, developers can define custom slash commands in the .claude/commands/ directory. These commands are essentially prompt templates that can encapsulate a series of steps, often including the explicit invocation of one or more subagents, thereby creating powerful, reusable agentic workflows.10

### **2.3 The Engine Under the Hood: The "Task Tool" and API Mechanics**

The entire subagent feature is a user-friendly abstraction built upon a more fundamental capability within the Claude ecosystem: the Task tool.4 When a subagent is invoked, the terminal output often displays "Task(Performing task X)", revealing the underlying mechanism.4

This Task tool is, in turn, a specific implementation of Anthropic's general-purpose tool-use API framework.20 This connection provides a unifying theory for subagent design:

**every best practice for designing a standard API tool applies directly to designing an effective subagent.** The architectural hierarchy is as follows:

1. The user provides a prompt to the main Claude Code agent.  
2. The main agent analyzes the prompt and decides to delegate the task.  
3. It internally invokes the built-in Task tool.  
4. The client-side application receives this tool-use request, which has a stop\_reason of tool\_use.20  
5. The client then executes the logic for the Task tool, which involves spinning up a new, temporary, and isolated instance of Claude. This new instance is initialized with the system prompt and configuration of the selected subagent.  
6. The subagent completes its work in this isolated environment.  
7. The final result is passed back to the main agent as a tool\_result, allowing the primary conversation to continue.20

Recognizing that subagents are a specialized form of tool use demystifies their design. The need for "extremely detailed descriptions" for standard tools is the same requirement for a subagent's description field.20 The importance of a clear purpose and well-defined inputs for tools translates directly to the design of focused, single-responsibility subagents.

### **2.4 Subagent Invocation Methods: A Comparative Analysis**

The following table provides a comparative analysis of the different methods for invoking subagents, helping developers choose the right approach for their specific needs.

| Invocation Method | Control Level | Automation Level | Primary Use Case | Key Sources |
| :---- | :---- | :---- | :---- | :---- |
| **Automatic Delegation** | Low | High | Allowing Claude to proactively manage tasks and select the best specialist based on context. Ideal for fluid, emergent workflows. | 2 |
| **@-Mention** | High | Low | Forcing the use of a specific subagent when the developer knows exactly which specialist is required, overriding automatic selection. | 12 |
| **Natural Language Request** | Medium | Medium | Guiding the main agent's choice of subagent without needing to remember the exact name, relying on Claude's NLU capabilities. | 1 |
| **Custom Slash Command** | High | High | Encapsulating complex, multi-step, and repeatable workflows that involve one or more subagents into a single, easy-to-use command. | 14 |

## **Section 3: Designing for Proactive Invocation: A Practical Guide**

Creating subagents that are reliably and proactively invoked is not a matter of chance; it is a matter of deliberate design. The process involves carefully authoring the subagent's definition file, with a particular focus on the description field and the system prompt, which serve as the primary signals for the main agent's delegation logic.

### **3.1 Mastering the Subagent Definition File**

Subagents are defined in standard Markdown files (.md) that contain a YAML frontmatter block followed by the system prompt in the body.5 These files are stored in

.claude/agents/ for project-specific agents or \~/.claude/agents/ for globally available user-level agents.2

The creation process can be done manually by creating these files or interactively through the Claude Code command-line interface by using the /agents command.2 The YAML frontmatter contains the core configuration:

* name: A unique, kebab-case identifier for the agent.  
* description: The critical field for triggering automatic invocation.  
* category: An organizational tag (e.g., development-architecture).  
* tools: An optional list of specific tools the agent is permitted to use.  
* model: An optional field to specify the underlying model (e.g., claude-3-5-sonnet-latest).

13

### **3.2 The Art of the description Field: The Key to Automation**

The description field is the single most important element for enabling proactive, automatic invocation. It should be treated as a piece of precision prompt engineering, not as simple metadata. The following principles are essential for crafting an effective description:

* **Principle 1: The Description *is* the Trigger.** The main agent's decision to delegate is based on a semantic match between the user's request and this field. It must explicitly state the conditions under which the agent should be used.2  
* **Principle 2: Be Extremely Detailed and Specific.** As with standard tool use, vague descriptions lead to unreliable behavior. A good description explains what the agent does, when it should be used, what its inputs are, and what it outputs. Aim for at least 3-4 sentences for any non-trivial agent.20  
* **Principle 3: Include Trigger Keywords and Use Cases.** The description should be populated with the specific words, phrases, and scenarios that a user might employ when they need the agent's expertise. Including concrete examples of when to use the agent can further solidify the connection for the main model.16

For instance, a poor description might be: "An agent for testing." A far more effective, proactive description would be: "An expert in Test-Driven Development (TDD) for Python applications using pytest. Invoke this agent to write new unit and integration tests from requirements, debug failing test suites by analyzing pytest output, or to ensure an implementation is not overfitting to existing tests."

### **3.3 Crafting the System Prompt: The Subagent's "Soul"**

If the description is the trigger, the system prompt in the Markdown body is the agent's "soul." It defines the agent's persona, expertise, constraints, and step-by-step reasoning process.7 A robust system prompt should include:

* **Role and Expertise:** Begin by clearly stating the agent's role and domain knowledge (e.g., "You are a senior database administrator specializing in PostgreSQL performance optimization").22  
* **Instructions and Constraints:** Provide explicit, step-by-step instructions for how the agent should approach its task. This includes defining what the agent *should not* do, which can be as important as what it should do.11  
* **Output Formatting:** Specify the desired structure of the agent's final output. This ensures the result is concise, relevant, and easily consumable by either the main agent or the user.8

The most effective way to develop a high-quality subagent is through an iterative feedback loop, akin to Test-Driven Development. First, write a clear description. Then, present the main agent with tasks that *should* trigger it. If it fails to invoke the subagent, the description needs refinement. If it invokes the agent but the output is poor, the system prompt needs refinement. This tight, iterative cycle of **Task \-\> Invocation \-\> Refine Description** and **Invocation \-\> Output \-\> Refine System Prompt** is the surest path to creating robust, reliable agents.

### **3.4 The Subagent Definition File: Anatomy and Best Practices**

The following table breaks down the components of the subagent definition file, providing best practices for authoring each part to achieve proactive and effective behavior.

| Component | Purpose | Best Practice Example | Rationale | Key Sources |
| :---- | :---- | :---- | :---- | :---- |
| **name** | Unique identifier | security-auditor | A clear, memorable, kebab-case name that reflects the agent's function. | 16 |
| **description** | **Primary trigger for automatic invocation** | "A security expert that scans code for common vulnerabilities (OWASP Top 10, SQL injection, XSS). Invoke when a user requests a security review, mentions vulnerabilities, or after implementing authentication features." | A detailed, multi-sentence description with keywords and specific use-case triggers is essential for reliable automatic delegation. | 16 |
| **category** | Organizational grouping | quality-security | Helps organize agents in the UI and provides another contextual clue about the agent's purpose. | 16 |
| **tools** | Restrict agent capabilities | \`\` | Adheres to the principle of least privilege, preventing an agent from performing unintended actions and keeping it focused. | 2 |
| **model** | Optimize for cost/performance | claude-3-opus-20240229 | Assigns powerful models for complex reasoning tasks (like security analysis) and faster models for routine tasks. | 12 |
| **System Prompt** | Defines agent behavior and expertise | "You are a senior security auditor. Your goal is to identify potential vulnerabilities... First, review the code for... Second, check for... Finally, produce a Markdown report categorizing findings by severity..." | A detailed, role-based prompt with step-by-step instructions ensures the agent performs its task consistently and produces a structured, useful output. | 7 |

## **Section 4: Advanced Architectures: Orchestrating Multi-Agent Systems**

Beyond creating individual specialists, the true power of the subagent paradigm lies in orchestrating them into sophisticated, multi-agent systems. These architectures enable the automation of complex, end-to-end development workflows by combining the strengths of multiple specialized agents. This capability is a native, first-party implementation of the "Deep Agent" pattern—an agent capable of planning and executing complex tasks over long horizons—which is characterized by a detailed system prompt, a planning tool, the use of sub-agents, and access to a file system for memory.25 The Claude Code ecosystem provides all four of these components.

### **4.1 Sequential Workflows: The Assembly Line Pattern**

The most common multi-agent pattern is the sequential workflow, which functions like a digital assembly line. In this model, a complex task is broken down into distinct phases, and a specialized agent is responsible for each phase. The output of one agent serves as the structured input for the next agent in the chain.8

A powerful example of this is a complete software development lifecycle workflow:

1. A spec-analyst agent takes a user's feature request and produces a formal requirements document.  
2. A spec-architect agent reads the requirements and designs the system architecture and API specifications.  
3. A spec-developer agent implements the code based on the architecture.  
4. A spec-tester agent writes and runs tests against the new code.  
5. A spec-reviewer agent performs a final quality and security review.

8

This approach enforces a systematic process and can include "Quality Gates" between phases to validate the artifacts before proceeding, reducing errors and ensuring a high-quality final product.8

### **4.2 Parallel Processing: Unleashing Concurrent Tasking**

For tasks that are divisible, Claude Code can execute multiple subagents in parallel. The system appears to support a cap of approximately 10 concurrent tasks.4 This "divide and conquer" strategy is highly effective for problems that can be broken down into independent sub-tasks.14

Common use cases include asking Claude to explore a large codebase using multiple agents in parallel, with each agent assigned to a different directory, or having several agents conduct web research on different sub-topics of a complex query simultaneously.4 This can dramatically reduce the time required for broad exploration and information-gathering phases.

### **4.3 The Orchestrator Pattern: Conducting the AI Symphony**

The most advanced architecture involves a dedicated "orchestrator" agent whose sole responsibility is to manage a team of specialist subagents.8 The orchestrator receives a high-level goal from the user (e.g., "Develop a CRM system with customer management and analytics") and then autonomously plans the project, delegating tasks to the appropriate specialist agents in the correct sequence.8 This pattern represents a higher level of abstraction, where the user interacts with a single project manager agent that coordinates the entire AI development team.

### **4.4 Inter-Agent Communication: The Shared Workspace**

Because subagents operate in isolated context windows, they cannot share memory directly. The dominant and recommended pattern for inter-agent communication is the use of a shared workspace: the local file system.25 In a sequential workflow, one agent writes its output to a structured artifact (e.g.,

architecture.md), and the subsequent agent in the chain reads that file as its input.8 This file-based approach serves as a simple yet robust communication bus. It also provides the added benefit of creating durable checkpoints in the workflow, allowing for inspection and intervention if needed.5

## **Section 5: The Ecosystem: Context, Commands, and Best Practices**

To maximize the effectiveness of subagents, they must be integrated into the broader Claude Code ecosystem, leveraging project-wide context files, custom commands, and the growing collection of community-built agents.

### **5.1 The Role of CLAUDE.md: Setting the Stage for Success**

The CLAUDE.md file is a special document that provides persistent, project-wide context to the main Claude agent at the start of a session.19 This file is the ideal place to document high-level project information such as testing instructions, code style guidelines, common bash commands, and core architectural principles.19

By providing the main agent with this high-level context, it is better equipped to make intelligent decisions about *when* to delegate to a specialist subagent. For example, if CLAUDE.md specifies that the project follows a strict Test-Driven Development (TDD) workflow, the main agent is far more likely to proactively invoke a test-automator subagent at the appropriate time in the development process.19

### **5.2 Synergy with Custom Commands: Creating Agentic Workflows**

Custom slash commands allow developers to encapsulate complex, multi-step prompts into single, reusable actions.10 The most powerful application of this feature is to orchestrate subagents. A single command can trigger a sophisticated chain of subagents to perform a complete workflow. For instance, a

/triage-bug command could be created to invoke a sequence of agents: one to read a bug report from a URL, another to search the codebase for relevant files, a third to attempt a fix, and a fourth to run tests.14 This synergy transforms a series of manual steps into a single, automated, agentic workflow.

### **5.3 The Emergence of a "Subagent Economy"**

The research reveals a vibrant and rapidly growing ecosystem of public GitHub repositories dedicated to sharing pre-built, production-ready subagents.2 This phenomenon represents more than just code sharing; it is the emergence of a community-driven "subagent economy." Developers are creating, sharing, and refining a marketplace of specialized AI "workers."

This has a profound implication for any developer starting with subagents: **do not build from scratch unless necessary.** The first step in creating a new workflow should be to survey this existing market of open-source agents. It is highly likely that a well-crafted specialist for code review, security auditing, or documentation already exists. Developers can clone these repositories, "hire" the agents they need by placing them in their .claude/agents/ directory, and customize them as needed. This approach dramatically accelerates the adoption of advanced agentic systems.

### **5.4 High-Impact Subagent Archetypes**

The following table synthesizes the numerous examples found in community repositories into a list of high-impact subagent archetypes that provide immediate value in most software projects.

| Archetype | Core Function | Sample description Trigger | Recommended Model | Key Sources |
| :---- | :---- | :---- | :---- | :---- |
| **Code Reviewer** | Analyzes code for quality, style, and best practices. | "An expert code reviewer. Invoke to analyze code for quality, maintainability, and adherence to project style guides." | claude-3-5-sonnet-latest | 13 |
| **Security Auditor** | Scans code for common security vulnerabilities. | "A security specialist that scans for OWASP Top 10 vulnerabilities. Use for security reviews or after adding auth logic." | claude-3-opus-20240229 | 13 |
| **Test Automator** | Writes unit, integration, or E2E tests. | "A test automation expert. Use to write new pytest tests from requirements or to create Playwright E2E test suites." | claude-3-opus-20240229 | 13 |
| **Refactor Specialist** | Improves existing code without changing its external behavior. | "A code refactoring specialist. Use to improve code clarity, reduce complexity, or modernize legacy code patterns." | claude-3-5-sonnet-latest | 8 |
| **Documentation Architect** | Generates technical documentation from code. | "A technical writer that creates comprehensive documentation from code. Use to generate READMEs, API docs, or tutorials." | claude-3-5-sonnet-latest | 13 |
| **Database Optimizer** | Analyzes and improves database queries and schemas. | "A database performance expert. Invoke to optimize slow SQL queries, suggest new indexes, or design efficient schemas." | claude-3-opus-20240229 | 13 |
| **API Designer** | Designs REST or GraphQL API specifications. | "An API architect. Use to design new RESTful API endpoints or create/extend a GraphQL schema based on requirements." | claude-3-opus-20240229 | 2 |

## **Conclusion and Strategic Recommendations**

The Claude Subagent architecture provides a powerful framework for moving beyond simple conversational AI into the realm of complex, automated agentic systems. The core innovation—the isolated context window—acts as a contextual firewall, enabling the system to tackle large-scale tasks without performance degradation. Proactive invocation is not a random event but a direct result of meticulous design, centered on crafting a detailed and specific description field within the agent's definition file.

For developers and teams seeking to integrate this technology, the following strategic recommendations provide a clear path to adoption:

1. **Master the Fundamentals of Tool Use:** Recognize that subagents are a specialized implementation of Claude's core tool-use API. The principles of writing excellent tool descriptions—being specific, detailed, and clear about purpose and parameters—are directly and completely applicable to writing subagent descriptions that trigger proactive invocation.  
2. **Adopt an Iterative Design Process:** Treat subagent creation like Test-Driven Development. Establish a tight feedback loop where you first write a description to control invocation, test it, and then refine the system prompt to control output quality. A subagent is a living document, not a one-time creation.  
3. **Start with a Single, High-Value Specialist:** Resist the urge to build a complex multi-agent system immediately. Begin by identifying a single, high-pain, repetitive task in your current workflow—such as code review, test generation, or documentation—and build one expert subagent to solve it. Proving value with a single, reliable agent is the best way to gain buy-in and experience.  
4. **Survey the "Subagent Economy" First:** Before writing a new agent from scratch, explore the numerous open-source repositories of pre-built subagents. "Hiring" a proven, community-vetted agent and customizing it is far more efficient than building a new one from the ground up.  
5. **Scale Intentionally to Multi-Agent Architectures:** Once individual agents have proven their worth, begin composing them into more complex systems. Start with simple sequential workflows (the "assembly line") before moving to more advanced orchestrator patterns. Use the file system as the primary communication bus between agents.

By following these principles, developers can move from using Claude as a conversational assistant to deploying it as a sophisticated, autonomous team of AI specialists, capable of accelerating development cycles, improving code quality, and automating complex software engineering tasks.

#### **Works cited**

1. Unleashing Claude Code's hidden power: A guide to subagents ..., accessed August 7, 2025, [https://builder.aws.com/content/2wsHNfq977mGGZcdsNjlfZ2Dx67/unleashing-claude-codes-hidden-power-a-guide-to-subagents](https://builder.aws.com/content/2wsHNfq977mGGZcdsNjlfZ2Dx67/unleashing-claude-codes-hidden-power-a-guide-to-subagents)  
2. VoltAgent/awesome-claude-code-subagents: Production-ready Claude subagents collection with 100+ specialized AI agents for full-stack development, DevOps, data science, and business operations. \- GitHub, accessed August 7, 2025, [https://github.com/VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents)  
3. medium.com, accessed August 7, 2025, [https://medium.com/@joe.njenga/17-claude-code-subagents-examples-with-templates-you-can-use-immediately-c70ef5567308\#:\~:text=If%20you%20have%20not%20heard,the%20instructions%20you%20give%20them.](https://medium.com/@joe.njenga/17-claude-code-subagents-examples-with-templates-you-can-use-immediately-c70ef5567308#:~:text=If%20you%20have%20not%20heard,the%20instructions%20you%20give%20them.)  
4. Claude Code: Subagent Deep Dive, accessed August 7, 2025, [https://cuong.io/blog/2025/06/24-claude-code-subagent-deep-dive](https://cuong.io/blog/2025/06/24-claude-code-subagent-deep-dive)  
5. Just tried using subagents. This unlocks the true power of Claude Code. \- Reddit, accessed August 7, 2025, [https://www.reddit.com/r/ClaudeAI/comments/1lojyky/just\_tried\_using\_subagents\_this\_unlocks\_the\_true/](https://www.reddit.com/r/ClaudeAI/comments/1lojyky/just_tried_using_subagents_this_unlocks_the_true/)  
6. Continuously impressed by Claude Code \-- Sub-agents (Tasks) Are Insane \- Reddit, accessed August 7, 2025, [https://www.reddit.com/r/ClaudeAI/comments/1li5i01/continuously\_impressed\_by\_claude\_code\_subagents/](https://www.reddit.com/r/ClaudeAI/comments/1li5i01/continuously_impressed_by_claude_code_subagents/)  
7. How Can Claude Code Sub-Agents Revolutionize Your Development Workflow? \- Apidog, accessed August 7, 2025, [https://apidog.com/blog/claude-code-sub-agents/](https://apidog.com/blog/claude-code-sub-agents/)  
8. zhsama/claude-sub-agent: AI-driven development workflow ... \- GitHub, accessed August 7, 2025, [https://github.com/zhsama/claude-sub-agent](https://github.com/zhsama/claude-sub-agent)  
9. Master Claude Code Sub‑Agents in 10 Minutes \- YouTube, accessed August 7, 2025, [https://www.youtube.com/watch?v=mEt-i8FunG8](https://www.youtube.com/watch?v=mEt-i8FunG8)  
10. Practical guide to mastering Claude Code's main agent and Sub‑agents | by Md Mazaharul Huq | Jul, 2025 | Medium, accessed August 7, 2025, [https://medium.com/@jewelhuq/practical-guide-to-mastering-claude-codes-main-agent-and-sub-agents-fd52952dcf00](https://medium.com/@jewelhuq/practical-guide-to-mastering-claude-codes-main-agent-and-sub-agents-fd52952dcf00)  
11. Claude Code NEW Sub Agents in 7 Minutes \- YouTube, accessed August 7, 2025, [https://www.youtube.com/watch?v=DNGxMX7ym44](https://www.youtube.com/watch?v=DNGxMX7ym44)  
12. New Claude Code features: Microcompact, enhanced subagents, and PDF support \- Reddit, accessed August 7, 2025, [https://www.reddit.com/r/ClaudeAI/comments/1mhrbzn/new\_claude\_code\_features\_microcompact\_enhanced/](https://www.reddit.com/r/ClaudeAI/comments/1mhrbzn/new_claude_code_features_microcompact_enhanced/)  
13. wshobson/agents: A collection of production-ready subagents for Claude Code \- GitHub, accessed August 7, 2025, [https://github.com/wshobson/agents](https://github.com/wshobson/agents)  
14. What's your best way to use Sub-agents in Claude Code so far? \- Reddit, accessed August 7, 2025, [https://www.reddit.com/r/ClaudeAI/comments/1mdyc60/whats\_your\_best\_way\_to\_use\_subagents\_in\_claude/](https://www.reddit.com/r/ClaudeAI/comments/1mdyc60/whats_your_best_way_to_use_subagents_in_claude/)  
15. Build an AI Army With Claude Code's New Sub-Agents \- YouTube, accessed August 7, 2025, [https://www.youtube.com/watch?v=9i3ic1sVhlI](https://www.youtube.com/watch?v=9i3ic1sVhlI)  
16. davepoon/claude-code-subagents-collection: Claude Code ... \- GitHub, accessed August 7, 2025, [https://github.com/davepoon/claude-code-subagents-collection](https://github.com/davepoon/claude-code-subagents-collection)  
17. I asked 5 Claude Code Subagents to build my app for me from ONE file. This happened., accessed August 7, 2025, [https://www.youtube.com/watch?v=ujH1t1zzJV8](https://www.youtube.com/watch?v=ujH1t1zzJV8)  
18. Claude Code Subagents SIMPLIFIED in 7 Minutes\! \+ QUICKSTART Tutorial \- YouTube, accessed August 7, 2025, [https://www.youtube.com/watch?v=239JDMFuGcQ](https://www.youtube.com/watch?v=239JDMFuGcQ)  
19. Claude Code: Best practices for agentic coding \- Anthropic, accessed August 7, 2025, [https://www.anthropic.com/engineering/claude-code-best-practices](https://www.anthropic.com/engineering/claude-code-best-practices)  
20. How to implement tool use \- Anthropic \- Anthropic API, accessed August 7, 2025, [https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/implement-tool-use](https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/implement-tool-use)  
21. Tool use with Claude \- Anthropic API, accessed August 7, 2025, [https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/overview](https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/overview)  
22. lst97/claude-code-sub-agents: Collection of specialized AI ... \- GitHub, accessed August 7, 2025, [https://github.com/lst97/claude-code-sub-agents](https://github.com/lst97/claude-code-sub-agents)  
23. hesreallyhim/awesome-claude-code-agents \- GitHub, accessed August 7, 2025, [https://github.com/hesreallyhim/awesome-claude-code-agents](https://github.com/hesreallyhim/awesome-claude-code-agents)  
24. Maximising Claude Code: Building an Effective CLAUDE.md ..., accessed August 7, 2025, [https://www.maxitect.blog/posts/maximising-claude-code-building-an-effective-claudemd](https://www.maxitect.blog/posts/maximising-claude-code-building-an-effective-claudemd)  
25. Deep Agents \- LangChain Blog, accessed August 7, 2025, [https://blog.langchain.com/deep-agents/](https://blog.langchain.com/deep-agents/)  
26. Claude Code best practices \- YouTube, accessed August 7, 2025, [https://www.youtube.com/watch?v=gv0WHhKelSE](https://www.youtube.com/watch?v=gv0WHhKelSE)