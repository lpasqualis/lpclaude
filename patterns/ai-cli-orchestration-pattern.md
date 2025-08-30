# AI + CLI Orchestration Pattern
## A Framework for Intelligent Tool Orchestration with Claude Code

### Table of Contents
1. [Introduction](#introduction)
2. [Core Philosophy](#core-philosophy)
3. [Architecture Overview](#architecture-overview)
4. [Setting Up the CLI System](#setting-up-the-cli-system)
5. [Communication Protocol](#communication-protocol)
6. [Responsibility Separation](#responsibility-separation)
7. [Claude Integration](#claude-integration)
8. [Implementation Guide](#implementation-guide)
9. [Best Practices](#best-practices)
10. [Examples](#examples)
11. [Troubleshooting](#troubleshooting)

## Introduction

This document describes a powerful architectural pattern for building AI-augmented systems where Claude Code orchestrates deterministic CLI tools to solve complex problems. This pattern combines the intelligence and adaptability of AI with the reliability and precision of traditional programming.

### When to Use This Pattern

Use this pattern when you need:
- Complex multi-step workflows requiring both intelligence and determinism
- Reliable execution of algorithmic operations with AI oversight
- State management and checkpoint recovery in long-running processes
- Clear audit trails of AI decisions and tool executions
- Separation between creative problem-solving and precise execution

### Key Benefits

- **Predictable Intelligence**: AI decisions within deterministic boundaries
- **Resumable Operations**: Checkpoint-based recovery from failures
- **Clear Accountability**: Traceable decisions and actions
- **Maintainable Systems**: Clean separation of concerns
- **Scalable Architecture**: Easy to add new tools and capabilities

## Core Philosophy

### "AI Orchestrates, Code Executes"

This pattern leverages the complementary strengths of two paradigms:

**AI (Non-Deterministic) Provides:**
- Natural language understanding
- Context-aware decision making
- Creative problem solving
- Adaptive error handling
- Pattern recognition
- Semantic analysis

**Code (Deterministic) Provides:**
- Guaranteed repeatability
- Precise calculations
- State management
- File system operations
- Network interactions
- Data validation

### The Synergy

```
User Request → AI Understanding → Tool Selection → Deterministic Execution
                                          ↓
AI Monitoring ← Progress Updates ← Tool Feedback ← State Management
```

## Architecture Overview

### System Components

```
project/
├── tools/                      # CLI tools directory
│   ├── venv/                  # Shared Python virtual environment
│   ├── requirements.txt       # Shared dependencies
│   ├── run.py                # Universal tool runner
│   └── [tool_name]/          # Individual tools
│       ├── cli.py            # Tool entry point
│       └── lib/              # Tool-specific modules
├── .claude/                   # Claude Code configuration
│   ├── commands/             # Slash commands
│   └── agents/               # AI workers
└── docs/                      # Documentation
```

### Execution Flow

1. **User Request** → Claude interprets intent
2. **Claude Decision** → Selects appropriate tool(s)
3. **Tool Execution** → Runs via universal runner
4. **Progress Feedback** → Tool communicates status
5. **AI Monitoring** → Claude tracks and responds
6. **Result Integration** → Claude synthesizes output

## Setting Up the CLI System

### 1. Create the Universal Tool Runner

```python
#!/usr/bin/env python3
"""
Universal Tool Runner - Single entry point for all CLI tools
"""

import os
import sys
import subprocess
from pathlib import Path
from typing import Dict, List

class ToolRunner:
    """Discovers and executes CLI tools."""
    
    def __init__(self):
        self.tools_dir = Path(__file__).parent
        self.venv_path = self.tools_dir / "venv"
        self.python_exe = self.venv_path / "bin" / "python"
        
    def discover_tools(self) -> Dict[str, Path]:
        """Auto-discover available tools."""
        tools = {}
        
        # Find tool directories with entry points
        for item in self.tools_dir.iterdir():
            if item.is_dir() and item.name not in ['venv', '__pycache__']:
                # Check for cli.py or main.py
                for entry in ['cli.py', 'main.py']:
                    entry_point = item / entry
                    if entry_point.exists():
                        tools[item.name] = entry_point
                        break
                        
        return tools
        
    def run_tool(self, tool_name: str, args: List[str]) -> int:
        """Execute a tool with arguments."""
        tools = self.discover_tools()
        
        if tool_name not in tools:
            print(f"Error: Tool '{tool_name}' not found", file=sys.stderr)
            return 1
            
        tool_path = tools[tool_name]
        
        # Execute in virtual environment
        cmd = [str(self.python_exe), str(tool_path)] + args
        env = os.environ.copy()
        env['PYTHONPATH'] = str(self.tools_dir)
        
        result = subprocess.run(cmd, env=env)
        return result.returncode

def main():
    runner = ToolRunner()
    
    if len(sys.argv) < 2:
        print("Usage: python tools/run.py <tool_name> [args...]")
        return 1
        
    if sys.argv[1] == "--list":
        tools = runner.discover_tools()
        print("Available tools:")
        for name in sorted(tools.keys()):
            print(f"  - {name}")
        return 0
        
    tool_name = sys.argv[1]
    tool_args = sys.argv[2:] if len(sys.argv) > 2 else []
    return runner.run_tool(tool_name, tool_args)

if __name__ == "__main__":
    sys.exit(main())
```

### 2. Create a Project Shortcut

```python
#!/usr/bin/env python3
# Save as 'tool' in project root, make executable with chmod +x tool

import sys
import subprocess
from pathlib import Path

def main():
    runner_path = Path(__file__).parent / "tools" / "run.py"
    cmd = [sys.executable, str(runner_path)] + sys.argv[1:]
    result = subprocess.run(cmd)
    return result.returncode

if __name__ == "__main__":
    sys.exit(main())
```

### 3. Set Up Virtual Environment

```bash
# One-time setup
python3 -m venv tools/venv
source tools/venv/bin/activate  # or tools\venv\Scripts\activate on Windows
pip install pyyaml jinja2 python-dateutil  # Common dependencies
pip freeze > tools/requirements.txt
```

## Communication Protocol

### Stdout-Based Markers

Tools communicate with AI using structured stdout messages:

```python
# Request AI action
print("AI_ACTION_REQUIRED: <action_type>")

# Provide instructions to AI
print("AI_INSTRUCTION: <specific_instruction>")

# Signal waiting state
print("WAIT_FOR_COMPLETION: <what_we're_waiting_for>")

# Report errors
print("ERROR: <error_message>")

# Report success
print("✅ <success_message>")

# Request AI review
print("AI_REVIEW_REQUIRED: <what_to_review>")
```

### File-Based Contracts

For complex data exchange, use files instead of stdout:

```python
import json
import yaml
from pathlib import Path
from datetime import datetime

class SessionManager:
    """Manages tool session state."""
    
    def __init__(self, work_dir: Path):
        self.work_dir = Path(work_dir)
        self.session_file = self.work_dir / "session.json"
        
    def save_checkpoint(self, data: dict):
        """Save progress checkpoint."""
        checkpoint = {
            "timestamp": datetime.now().isoformat(),
            "data": data,
            "status": "in_progress"
        }
        self.session_file.write_text(json.dumps(checkpoint, indent=2))
        
    def load_checkpoint(self) -> dict:
        """Load previous checkpoint if exists."""
        if self.session_file.exists():
            return json.loads(self.session_file.read_text())
        return None
```

### Progress Reporting

```python
def report_progress(current: int, total: int, description: str):
    """Report progress to AI."""
    percent = (current / total) * 100
    print(f"PROGRESS: {percent:.1f}% - {description}")
    
    if percent >= 100:
        print("✅ Task completed successfully")
```

## Responsibility Separation

### AI Responsibilities

1. **Understanding Intent**
   - Parse user requests
   - Identify required operations
   - Plan execution strategy

2. **Tool Selection**
   - Choose appropriate tools
   - Determine execution order
   - Handle tool dependencies

3. **Error Recovery**
   - Interpret error messages
   - Decide on retry strategies
   - Provide user feedback

4. **Result Synthesis**
   - Combine tool outputs
   - Generate human-readable summaries
   - Answer follow-up questions

### CLI Tool Responsibilities

1. **Deterministic Operations**
   - File I/O operations
   - Data transformations
   - Network requests
   - Database operations

2. **State Management**
   - Session persistence
   - Checkpoint creation
   - Progress tracking
   - Resource cleanup

3. **Validation**
   - Input validation
   - Schema enforcement
   - Output verification
   - Error detection

4. **Performance**
   - Efficient algorithms
   - Batch processing
   - Caching strategies
   - Resource optimization

### Decision Matrix

| Task Type | Handler | Reason |
|-----------|---------|---------|
| Parse natural language | AI | Requires understanding context |
| Sort 10,000 items | CLI Tool | Deterministic algorithm |
| Choose which file to process | AI | Requires judgment |
| Calculate checksums | CLI Tool | Precise computation |
| Decide error recovery strategy | AI | Requires adaptive thinking |
| Execute database transaction | CLI Tool | Needs ACID guarantees |
| Interpret ambiguous input | AI | Requires inference |
| Generate UUID | CLI Tool | Deterministic generation |

## Claude Integration

### Slash Commands

Create slash commands that leverage CLI tools:

```yaml
# .claude/commands/process_data.md
---
description: Process data files using CLI tools
allowed-tools: [Bash, Read, Write, Edit]
---

Process the data files in the specified directory.

1. First, run the data analyzer to understand the structure:
   ```bash
   ./tool analyze_data --input-dir "$ARGUMENTS"
   ```

2. Based on the analysis, determine processing strategy

3. Execute the appropriate processor:
   ```bash
   ./tool process_data --strategy <selected> --input-dir "$ARGUMENTS"
   ```

4. Verify results and report to user
```

### AI Workers/Agents

Define workers that coordinate with CLI tools:

```yaml
# .claude/agents/data_processor.md
---
name: data-processor
description: Processes data files using algorithmic tools
tools: [Bash, Read, Write]
---

You are a data processing specialist that coordinates with CLI tools.

## Your Workflow:

1. Analyze data requirements
2. Select appropriate CLI tools
3. Execute tools with proper parameters
4. Monitor execution progress
5. Handle errors gracefully
6. Validate output quality

## Available Tools:

- `./tool analyze_data` - Analyzes data structure
- `./tool transform_data` - Transforms data format
- `./tool validate_data` - Validates data integrity

## Communication Protocol:

When tools output AI_ACTION_REQUIRED, respond immediately.
When tools output WAIT_FOR_COMPLETION, monitor for completion.
When tools output ERROR, determine recovery strategy.
```

### Worker-Tool Interaction Pattern

```python
# In your CLI tool
def request_worker_assistance():
    """Request AI worker to handle complex decision."""
    print("AI_ACTION_REQUIRED: SPAWN_WORKER")
    print("AI_INSTRUCTION: Spawn data-analyzer worker to review output")
    print("WORKER_INPUT_FILE: /tmp/analysis_results.yaml")
    print("WAIT_FOR_COMPLETION: Waiting for worker analysis")
```

## Implementation Guide

### Step 1: Project Setup

```bash
# Create project structure
mkdir -p project/tools/venv
mkdir -p project/.claude/commands
mkdir -p project/.claude/agents
mkdir -p project/docs

# Initialize virtual environment
cd project
python3 -m venv tools/venv
source tools/venv/bin/activate
pip install pyyaml jinja2 python-dateutil click

# Create requirements file
pip freeze > tools/requirements.txt
```

### Step 2: Create Your First Tool

```python
# tools/example_processor/cli.py
#!/usr/bin/env python3
"""
Example data processor tool.
"""

import sys
import click
import json
from pathlib import Path

@click.command()
@click.option('--input', '-i', required=True, help='Input file path')
@click.option('--output', '-o', required=True, help='Output file path')
@click.option('--format', type=click.Choice(['json', 'yaml']), default='json')
def process(input, output, format):
    """Process input file and generate output."""
    
    input_path = Path(input)
    output_path = Path(output)
    
    # Validate input
    if not input_path.exists():
        print(f"ERROR: Input file not found: {input}")
        sys.exit(1)
    
    print(f"Processing {input_path.name}...")
    
    try:
        # Perform processing
        data = json.loads(input_path.read_text())
        
        # Transform data (example)
        processed = {
            "original_keys": list(data.keys()),
            "item_count": len(data),
            "processed": True
        }
        
        # Save output
        output_path.write_text(json.dumps(processed, indent=2))
        
        print(f"✅ Successfully processed to {output_path}")
        
    except Exception as e:
        print(f"ERROR: Processing failed: {e}")
        sys.exit(1)

if __name__ == '__main__':
    process()
```

### Step 3: Create Universal Runner

Copy the universal runner code from earlier into `tools/run.py`.

### Step 4: Create Project Shortcut

```bash
# Create executable shortcut in project root
cat > tool << 'EOF'
#!/usr/bin/env python3
import sys, subprocess
from pathlib import Path
subprocess.run([sys.executable, Path(__file__).parent / "tools" / "run.py"] + sys.argv[1:])
EOF

chmod +x tool
```

### Step 5: Test the System

```bash
# List available tools
./tool --list

# Run your tool
./tool example_processor --input data.json --output result.json
```

## Best Practices

### 1. Tool Design Principles

- **Single Responsibility**: Each tool should do one thing well
- **Idempotent Operations**: Running twice should be safe
- **Clear Error Messages**: Help AI understand failures
- **Progress Reporting**: Keep AI informed of status
- **Checkpoint Support**: Enable resumption after failures

### 2. Error Handling

```python
def safe_operation(func):
    """Decorator for safe tool operations."""
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except FileNotFoundError as e:
            print(f"ERROR: File not found: {e}")
            print("AI_INSTRUCTION: Check file path and retry")
            sys.exit(1)
        except PermissionError as e:
            print(f"ERROR: Permission denied: {e}")
            print("AI_INSTRUCTION: Check file permissions")
            sys.exit(1)
        except Exception as e:
            print(f"ERROR: Unexpected error: {e}")
            print("AI_ACTION_REQUIRED: DIAGNOSE_ERROR")
            sys.exit(1)
    return wrapper
```

### 3. Session Management

```python
import hashlib
from datetime import datetime

class Session:
    """Manages tool session with recovery support."""
    
    def __init__(self, work_dir: Path, session_id: str = None):
        self.work_dir = Path(work_dir)
        self.work_dir.mkdir(parents=True, exist_ok=True)
        
        # Generate or use session ID
        self.session_id = session_id or datetime.now().strftime("%Y%m%d_%H%M%S")
        self.session_dir = self.work_dir / f"session_{self.session_id}"
        self.session_dir.mkdir(exist_ok=True)
        
    def checkpoint(self, stage: str, data: dict):
        """Create checkpoint for recovery."""
        checkpoint_file = self.session_dir / f"checkpoint_{stage}.json"
        checkpoint_data = {
            "timestamp": datetime.now().isoformat(),
            "stage": stage,
            "data": data
        }
        checkpoint_file.write_text(json.dumps(checkpoint_data, indent=2))
        print(f"CHECKPOINT: Saved {stage}")
        
    def can_resume(self, stage: str) -> bool:
        """Check if can resume from stage."""
        checkpoint_file = self.session_dir / f"checkpoint_{stage}.json"
        return checkpoint_file.exists()
```

### 4. Parallel Execution Support

```python
def request_parallel_execution(tasks: list):
    """Request AI to execute tasks in parallel."""
    print("AI_ACTION_REQUIRED: PARALLEL_EXECUTION")
    print(f"AI_INSTRUCTION: Execute {len(tasks)} tasks in parallel:")
    
    for i, task in enumerate(tasks, 1):
        print(f"  Task {i}: {task['command']}")
        
    print("WAIT_FOR_COMPLETION: Monitor all parallel tasks")
```

### 5. Testing Strategy

```python
# tools/test_framework.py
import subprocess
import tempfile
from pathlib import Path

def test_tool(tool_name: str, args: list) -> dict:
    """Test a tool execution."""
    with tempfile.TemporaryDirectory() as tmpdir:
        # Run tool
        cmd = ["python", "tools/run.py", tool_name] + args
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            cwd=tmpdir
        )
        
        return {
            "success": result.returncode == 0,
            "stdout": result.stdout,
            "stderr": result.stderr,
            "return_code": result.returncode
        }
```

## Examples

### Example 1: Data Migration Tool

```python
# tools/data_migrator/cli.py
#!/usr/bin/env python3

import click
import json
from pathlib import Path
from datetime import datetime

@click.command()
@click.option('--source', required=True, help='Source directory')
@click.option('--target', required=True, help='Target directory')
@click.option('--batch-size', default=100, help='Batch size for processing')
def migrate(source, target, batch_size):
    """Migrate data from source to target."""
    
    source_path = Path(source)
    target_path = Path(target)
    
    # Discover files
    files = list(source_path.glob("*.json"))
    total = len(files)
    
    if total == 0:
        print("ERROR: No files found to migrate")
        return 1
        
    print(f"Found {total} files to migrate")
    
    # Request AI decision for strategy
    print("AI_ACTION_REQUIRED: CHOOSE_MIGRATION_STRATEGY")
    print(f"AI_INSTRUCTION: {total} files found, batch_size={batch_size}")
    
    # Process in batches
    for i in range(0, total, batch_size):
        batch = files[i:i+batch_size]
        current_batch = i // batch_size + 1
        total_batches = (total + batch_size - 1) // batch_size
        
        print(f"PROGRESS: Processing batch {current_batch}/{total_batches}")
        
        for file in batch:
            try:
                # Read and transform
                data = json.loads(file.read_text())
                
                # Apply transformation
                transformed = transform_data(data)
                
                # Write to target
                target_file = target_path / file.name
                target_file.write_text(json.dumps(transformed, indent=2))
                
            except Exception as e:
                print(f"ERROR: Failed to process {file.name}: {e}")
                print("AI_ACTION_REQUIRED: HANDLE_MIGRATION_ERROR")
                
    print(f"✅ Migration complete: {total} files processed")

def transform_data(data: dict) -> dict:
    """Apply data transformation."""
    return {
        "migrated_at": datetime.now().isoformat(),
        "original": data,
        "version": "2.0"
    }

if __name__ == '__main__':
    migrate()
```

### Example 2: Claude Slash Command

```markdown
# .claude/commands/migrate_data.md
---
description: Migrate data between formats
allowed-tools: [Bash, Read, Write]
---

Migrate data from source to target directory.

## Steps:

1. Analyze source directory:
```bash
./tool data_analyzer --scan "$ARGUMENTS"
```

2. Based on analysis, determine migration strategy

3. Execute migration:
```bash
./tool data_migrator --source "$ARGUMENTS" --target ./migrated --batch-size 50
```

4. When tool requests AI_ACTION_REQUIRED:
   - For CHOOSE_MIGRATION_STRATEGY: Select based on file count
   - For HANDLE_MIGRATION_ERROR: Decide skip/retry/abort

5. Validate migration:
```bash
./tool data_validator --directory ./migrated
```

6. Report results to user
```

### Example 3: Complex Workflow

```python
# tools/workflow_orchestrator/cli.py
#!/usr/bin/env python3

import click
import yaml
from pathlib import Path
from typing import List, Dict

class WorkflowOrchestrator:
    """Orchestrates complex multi-tool workflows."""
    
    def __init__(self, workflow_file: Path):
        self.workflow = yaml.safe_load(workflow_file.read_text())
        self.checkpoints_dir = Path(".checkpoints")
        self.checkpoints_dir.mkdir(exist_ok=True)
        
    def execute(self):
        """Execute workflow steps."""
        total_steps = len(self.workflow['steps'])
        
        for i, step in enumerate(self.workflow['steps'], 1):
            step_name = step['name']
            checkpoint_file = self.checkpoints_dir / f"{step_name}.done"
            
            # Check if already completed
            if checkpoint_file.exists():
                print(f"SKIP: {step_name} already completed")
                continue
                
            print(f"STEP {i}/{total_steps}: {step_name}")
            
            # Determine execution type
            if step['type'] == 'tool':
                self.execute_tool(step)
            elif step['type'] == 'ai_decision':
                self.request_ai_decision(step)
            elif step['type'] == 'parallel':
                self.execute_parallel(step)
                
            # Mark complete
            checkpoint_file.touch()
            print(f"✅ Completed: {step_name}")
            
    def execute_tool(self, step: Dict):
        """Execute a tool step."""
        print(f"EXECUTE: {step['command']}")
        # Tool execution logic here
        
    def request_ai_decision(self, step: Dict):
        """Request AI decision."""
        print(f"AI_ACTION_REQUIRED: {step['decision_type']}")
        print(f"AI_INSTRUCTION: {step['instruction']}")
        print("WAIT_FOR_COMPLETION: Awaiting AI decision")
        
    def execute_parallel(self, step: Dict):
        """Execute parallel tasks."""
        tasks = step['tasks']
        print(f"AI_ACTION_REQUIRED: PARALLEL_EXECUTION")
        print(f"AI_INSTRUCTION: Execute {len(tasks)} tasks in parallel")
        for task in tasks:
            print(f"  - {task}")

@click.command()
@click.option('--workflow', required=True, help='Workflow YAML file')
def orchestrate(workflow):
    """Orchestrate a complex workflow."""
    workflow_path = Path(workflow)
    
    if not workflow_path.exists():
        print(f"ERROR: Workflow file not found: {workflow}")
        return 1
        
    orchestrator = WorkflowOrchestrator(workflow_path)
    orchestrator.execute()

if __name__ == '__main__':
    orchestrate()
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Tool Not Found

**Problem**: `Error: Tool 'my_tool' not found`

**Solution**:
- Ensure tool directory exists in `tools/`
- Check for `cli.py` or `main.py` entry point
- Verify no Python syntax errors in entry point

#### 2. Virtual Environment Issues

**Problem**: `ModuleNotFoundError` when running tools

**Solution**:
```bash
# Rebuild virtual environment
rm -rf tools/venv
python3 -m venv tools/venv
source tools/venv/bin/activate
pip install -r tools/requirements.txt
```

#### 3. Communication Protocol Not Working

**Problem**: AI not responding to tool markers

**Solution**:
- Ensure markers are printed to stdout, not stderr
- Check exact marker format (case-sensitive)
- Verify markers are on their own lines

#### 4. Session Recovery Failing

**Problem**: Tool doesn't resume from checkpoints

**Solution**:
- Check checkpoint file permissions
- Verify checkpoint directory exists
- Ensure consistent session ID usage

#### 5. Parallel Execution Issues

**Problem**: Parallel tasks interfering with each other

**Solution**:
- Use unique working directories per task
- Implement proper file locking
- Avoid shared state between parallel tasks

### Debug Mode

Add debug support to tools:

```python
import os
import sys

DEBUG = os.environ.get('TOOL_DEBUG', '').lower() == 'true'

def debug_print(message):
    """Print debug message if debug mode enabled."""
    if DEBUG:
        print(f"[DEBUG] {message}", file=sys.stderr)

# Usage
debug_print(f"Processing file: {filename}")
```

Enable debug mode:
```bash
TOOL_DEBUG=true ./tool my_tool --input data.json
```

### Performance Profiling

```python
import time
from functools import wraps

def profile_performance(func):
    """Profile function performance."""
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        duration = time.time() - start
        print(f"PERFORMANCE: {func.__name__} took {duration:.2f}s")
        return result
    return wrapper

@profile_performance
def process_large_dataset(data):
    # Processing logic
    pass
```

## Conclusion

The AI + CLI Orchestration Pattern provides a robust framework for building intelligent systems that combine the best of both AI and traditional programming. By maintaining clear separation of responsibilities and using structured communication protocols, you can create maintainable, scalable, and reliable AI-augmented applications.

### Key Takeaways

1. **Separation is Strength**: Let AI handle intelligence, let code handle execution
2. **Communication is Critical**: Use structured markers and file contracts
3. **State Management Matters**: Implement checkpoints and session recovery
4. **Tools Should be Simple**: Each tool does one thing well
5. **Integration is Powerful**: Claude's features amplify tool capabilities

### Next Steps

1. Start with simple tools and gradually add complexity
2. Establish team conventions for markers and protocols
3. Build a library of reusable tool patterns
4. Document your specific implementations
5. Share learnings and improvements with the community

This pattern will continue to evolve as AI capabilities expand, but the fundamental principle remains: combine AI's intelligence with code's reliability to build systems that are both smart and dependable.