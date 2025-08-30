# Important Engineering Strategies

## The AI + Code Synergy Pattern

When building AI-powered systems, leverage the complementary strengths of non-deterministic AI and deterministic code.

### Core Principle
**AI provides intelligence, Code provides reliability**

### The Division of Labor

**Non-Deterministic (AI) Handles:**
- Understanding context and meaning
- Adapting to variation in inputs
- Making intelligent judgments
- Creative problem-solving
- Semantic analysis
- Natural language processing

**Deterministic (Code) Handles:**
- Enforcing structure and schemas
- Guaranteeing repeatability
- Managing state and progress
- Validating completeness
- Error handling and recovery
- Providing guardrails

### Implementation Pattern

1. Code defines structure (schema, required fields, formats, deterministic algorithms, execution) and execute algorithms
2. AI agents analyzes content (reads, understands, categorizes, summarize, interpret) and follow natural language directions
3. Code enforces boundaries (validation, required elements)
4. AI agents fill in intelligence (decisions within constraints, creativity)
5. Code validates output (completeness, correctness, exact accuracy)
6. Avoid trying to make code too smart and "creative"
7. Avoid trying to make an AI agent be too rigid and algorithmic
8. An AI agent can call code when it needs deterministic results
9. Code can prepare for an AI agent, and formalize data from an AI agent
