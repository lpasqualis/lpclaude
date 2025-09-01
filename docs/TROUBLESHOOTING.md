# Troubleshooting Guide

Quick solutions to common Claude Framework issues.

## Agent Issues

### Agent Not Triggering Automatically

**Symptoms:** Agent doesn't activate when expected keywords are mentioned.

**Solutions:**
1. **Add trigger phrase**: Include "MUST BE USED PROACTIVELY" in description
2. **Add keywords**: Use specific action verbs and domain terms
3. **Run optimizer**: `"Optimize agents/my-agent.md"`
4. **Test explicitly**: `Task(subagent_type: 'agent-name', prompt: 'test')`

### Agent Fails with Tool Errors

**Symptoms:** "Tool not available" or permission errors.

**Solutions:**
1. **Remove Task tool**: Agents cannot have Task tool (framework limitation)
2. **Grant complete groups**: Use logical tool sets (e.g., Read+Write+Edit)
3. **Check YAML syntax**: Ensure tools are comma-separated strings

## Command Issues

### Command Not Found

**Symptoms:** Slash command doesn't work or "command not found" error.

**Solutions:**
1. **Check location**: Verify file matches namespace
   - `/git:commit` → `commands/git/commit.md`
   - `/learn` → `commands/learn.md`
2. **Verify symlinks**: `ls -la ~/.claude/commands/`
3. **Check YAML**: Ensure frontmatter has `name:` field
4. **Run setup**: `./setup.sh` if symlinks missing

### Command Model Token Errors

**Symptoms:** "Token limit exceeded" when using custom model.

**Solutions:**
1. **Check model limits**: Some models have lower limits than Claude Code defaults
2. **Remove model field**: Let Claude Code use its defaults
3. **Use haiku for simple tasks**: Lower token requirements

### Parallel Processing Failures

**Symptoms:** Task templates don't run in parallel or fail silently.

**Solutions:**
1. **Check template location**: Must be in `workers/` directory
2. **Remove YAML**: Templates must be pure prompts
3. **Limit concurrency**: Max 10 parallel tasks
4. **Return structured data**: Use JSON for aggregation

## Framework Issues

### Changes Not Reflecting

**Symptoms:** Edits to agents/commands don't appear in other projects.

**Solutions:**
1. **Edit in framework repo**: Not in `~/.claude/` (those are symlinks)
2. **For directives**: Run `./rebuild_claude_md.sh`
3. **Check permissions**: Ensure files are readable
4. **Verify symlinks**: `ls -la ~/.claude/` should show arrows

### Optimization Not Working

**Symptoms:** Asking to optimize doesn't trigger optimizer agents.

**Solutions:**
1. **Use natural language**: "Optimize my agent" or "Improve this command"
2. **Specify file**: "Optimize agents/my-agent.md"
3. **Check optimizers exist**: Verify `subagent-optimizer` and `command-optimizer` present
4. **Clear language**: Avoid ambiguous requests

### Circular Dependencies

**Symptoms:** Stack overflow, infinite loops, or "maximum recursion" errors.

**Solutions:**
1. **No recursive Task**: Tasks cannot spawn Tasks
2. **Commands can't call commands**: Only main Claude can
3. **Agents can't use Task**: Framework prevents this
4. **Check command chains**: Avoid circular references

## Performance Issues

### Slow Command Execution

**Symptoms:** Commands take too long to complete.

**Solutions:**
1. **Use parallel processing**: Add Task tool and create templates
2. **Batch operations**: Process multiple items together
3. **Use appropriate models**: haiku for simple, opus for complex
4. **Limit file reads**: Use Glob/Grep before Read

### Resource Exhaustion

**Symptoms:** System slowdown, memory errors.

**Solutions:**
1. **Limit parallel tasks**: Max 10 concurrent
2. **Process in batches**: Don't load everything at once
3. **Clean up resources**: Close files, clear variables
4. **Use streaming**: For large file operations

## Setup Issues

### Symlinks Not Working

**Symptoms:** Components not available globally.

**Solutions:**
1. **Run setup**: `./setup.sh` from repository root
2. **Check permissions**: Need write access to `~/.claude/`
3. **Remove old symlinks**: `rm -rf ~/.claude/agents ~/.claude/commands`
4. **Verify paths**: Ensure repository path is correct

### Directive Compilation Fails

**Symptoms:** `rebuild_claude_md.sh` errors or CLAUDE.md not updating.

**Solutions:**
1. **Check syntax**: Validate markdown in directive files
2. **Remove `.local.md`**: These are ignored by design
3. **Check permissions**: Script needs read/write access
4. **Run from root**: Execute from repository root directory

## Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| "Tool not available" | Wrong tool permissions | Add to allowed-tools in YAML |
| "Agent not found" | Missing or misnamed file | Check filename matches agent name |
| "Command failed to parse" | Invalid YAML frontmatter | Validate YAML syntax |
| "Token limit exceeded" | Model limits too low | Remove model field or use default |
| "Cannot invoke Task" | Agent has Task tool | Remove Task from agent tools |
| "File not found" | Wrong path or missing file | Use absolute paths |
| "Permission denied" | File permissions issue | Check file/directory permissions |

## Debug Commands

```bash
# Check symlinks
ls -la ~/.claude/

# Verify agent files
ls agents/*.md

# Test command structure
grep -l "name:" commands/**/*.md

# Find optimization timestamps
grep -r "OPTIMIZATION_TIMESTAMP" agents/ commands/

# Check for legacy patterns
grep -r "proactive:" agents/ commands/
grep -r "cmd-" agents/

# Validate YAML
for f in agents/*.md commands/**/*.md; do
  echo "Checking $f"
  head -20 "$f" | grep -E "^(name|description|allowed-tools):"
done
```

## Getting More Help

1. **Check documentation**: Review guides in `docs/` folder
2. **Read research**: Check `resources/` for deep dives
3. **Test in isolation**: Create minimal test case
4. **Use optimizers**: They often fix issues automatically
5. **Review examples**: Look at existing agents/commands for patterns