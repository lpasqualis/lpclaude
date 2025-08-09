---
name: /docs:readme-audit
description: Audits and optimizes repository README.md to ensure an outstanding first-impression user experience
argument-hint: [optional path to README.md]
allowed-tools: Read, Write, Edit, MultiEdit, LS, Glob, Grep
---

# README Audit & Optimization Command

You are tasked with auditing and optimizing a repository's README.md file to ensure it provides an outstanding user experience and serves as an effective entry point for visitors.

## Step 1: Analysis Phase

First, analyze the current README file and enclose your findings in <analysis> tags:

1. **Locate the README**:
   - If argument provided, use that path
   - Otherwise, search for README.md in root directory
   - Check case-insensitive variations (Readme.md, readme.md, README.MD)
   - If not found, note that a README needs to be created

2. **Evaluate user experience** by checking if the README answers these critical questions:
   - **What is this?** - Clear in the first paragraph
   - **Why should I care?** - Problem it solves or value it provides
   - **How do I start?** - Clear, simple getting started instructions
   - **Where can I learn more?** - Links to detailed documentation
   - **How can I contribute?** - Path to participation

3. **Identify misplaced content** that disrupts the user journey:
   - Deep technical implementation details
   - Internal development notes or TODOs
   - Extensive API documentation
   - Complex configuration details
   - AI/agent-specific instructions
   - Anything that makes the README overwhelming

## Step 2: Repository Context Audit

Review the repository structure to understand the project's documentation patterns:

1. **Analyze existing structure**:
   - Check for documentation directories (docs/, documentation/, wiki/, .docs/)
   - Look for specialized files (CLAUDE.md, CONTRIBUTING.md, ARCHITECTURE.md)
   - Identify the project type (library, application, framework, data project, etc.)
   - Note existing documentation patterns and conventions

2. **Understand the audience**:
   - Who is the primary user? (developers, end users, data scientists, etc.)
   - What's their likely first goal? (install, understand, contribute, evaluate)
   - What level of expertise do they have?

Enclose your audit findings in <audit> tags.

## Step 3: Optimization Strategy

Based on your analysis, create a flexible optimization plan enclosed in <plan> tags:

1. **Prioritize by user journey**:
   - What must users see first?
   - What can be linked for later?
   - What should be moved elsewhere?

2. **Respect repository patterns**:
   - Follow existing documentation structure if well-organized
   - Propose improvements that fit the project's style
   - Only create new patterns if necessary

3. **Plan specific improvements**:
   - Sections to add or enhance
   - Content to relocate (with destinations)
   - New files to create (only if needed)
   - Order changes for better flow

## Step 4: Implementation

Execute the optimization while maintaining flexibility:

1. **Relocate content thoughtfully**:
   - Move content to locations that match repository patterns
   - If no clear pattern exists, create logical structure in docs/
   - For AI/agent instructions, use or create CLAUDE.md
   - Always add clear references from README to relocated content
   - Preserve all valuable information

2. **Optimize the README structure** based on project type and user needs:

   **Core structure** (adapt based on project):
   ```markdown
   # [Project Name]
   
   [Compelling one-paragraph description that immediately conveys value]
   
   ## [Why Section - adapted title]
   
   [Brief, compelling explanation of the problem solved or value provided]
   
   ## [Getting Started Section - adapted title]
   
   [Simplest possible path to first success]
   
   ## [Key Features/Capabilities - if relevant]
   
   [What makes this valuable - only if adds value]
   
   ## [Examples/Usage - essential section]
   
   [Real, runnable examples that demonstrate value]
   
   ## [Documentation/Learn More]
   
   [Clear links to detailed information]
   
   ## [Contributing/Community - if applicable]
   
   [How to participate or get help]
   
   ## [License]
   
   [License information]
   ```

3. **Enhance user experience**:
   - **First paragraph must hook**: Clear value proposition
   - **Progressive disclosure**: Start simple, link to complex
   - **Scannable structure**: Use headers, lists, code blocks effectively
   - **Working examples**: Ensure code examples actually run
   - **Visual aids**: Add diagrams or screenshots only if they clarify
   - **Clear next steps**: Every section should guide to the next action

4. **Adapt to project style**:
   - Match the tone (formal/informal) of existing docs
   - Respect formatting conventions
   - Maintain consistency with project's brand/voice
   - Keep cultural elements that work well

## Step 5: Validation

After optimization, validate the user experience in <validation> tags:

1. **The 30-second test**:
   - Can someone understand what this is and why they should care in 30 seconds?
   - Is the path to getting started immediately clear?
   - Do they know where to go for more information?

2. **Quality checks**:
   - Examples are accurate and runnable
   - Links work and point to useful resources
   - Structure flows logically
   - No critical information was lost
   - README length is appropriate (not overwhelming, not sparse)

3. **Experience assessment**:
   - Does it build excitement about the project?
   - Does it inspire confidence?
   - Is it welcoming to newcomers?
   - Does it respect the reader's time?

## Output

Provide a comprehensive summary:

1. **User Experience Improvements**:
   - How the README better serves users now
   - Key improvements to first impressions

2. **Structural Changes**:
   - Major modifications to README.md
   - Content organization improvements

3. **Content Relocation** (if any):
   - What was moved and where
   - Why the new location improves user experience

4. **Additional Recommendations**:
   - Further improvements to consider
   - Documentation gaps to address
   - User experience enhancements for future

If the README already provides an outstanding user experience, explain what makes it effective and suggest only minor enhancements if applicable.

## Guiding Principles

- **User journey over completeness**: Better to link to details than overwhelm
- **Clarity over cleverness**: Simple, clear communication wins
- **Respect existing patterns**: Work with the repository's style, not against it
- **Progressive disclosure**: Start simple, provide paths to complexity
- **Every README is unique**: Adapt to the specific project and audience