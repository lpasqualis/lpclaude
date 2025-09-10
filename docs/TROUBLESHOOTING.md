# Troubleshooting Guide

## About This Guide

**This documents issues I've encountered with my personal Claude Code setup and how I solve them.** Your issues may be different based on your configuration.

Remember: This is NOT a framework - it's examples from one person's configuration. Adapt these solutions to your needs.

## Agent Issues

### Agent Not Triggering Automatically

**Symptoms:** Agent doesn't activate when expected keywords are mentioned.

**Solutions:**
1. **Add trigger phrase**: Include "MUST BE USED PROACTIVELY" in description
2. **Add keywords**: Use specific action verbs and domain terms
3. **Check keywords**: Ensure description contains words users would naturally say
4. **Test naturally**: Mention the trigger keywords in conversation

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

**Symptoms:** Worker templates don't run in parallel or fail silently.

**Solutions:**
1. **Check template location**: Must be in `workers/[command]-workers/` subdirectory
2. **Remove YAML**: Templates must be pure prompts (no frontmatter)
3. **Limit concurrency**: Max 10 parallel tasks
4. **Return structured data**: Use JSON for aggregation

## Framework Issues

### Changes Not Reflecting

**Symptoms:** Edits to agents/commands don't appear in other projects.

**Solutions:**
1. **Edit in source location**: If using symlinks, edit in the repository, not in `~/.claude/`
2. **For directives**: Run `./rebuild_claude_md.sh`
3. **Check permissions**: Ensure files are readable
4. **Verify symlinks**: `ls -la ~/.claude/` should show arrows

### Components Not Working as Expected

**Symptoms:** Agents or commands don't behave as intended.

**Solutions:**
1. **Check YAML frontmatter**: Ensure proper format and required fields
2. **Verify file location**: Commands need correct namespace structure
3. **Test trigger words**: For agents, use exact keywords from description
4. **Review tool permissions**: Ensure all needed tools are granted

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

### Components Not Available

**Symptoms:** Components not showing up in Claude Code.

**Solutions:**
1. **For manually copied files**: Verify they're in the right location (`~/.claude/agents/`, etc.)
2. **Check file extensions**: Must be `.md` files
3. **Restart Claude Code**: Some changes require a restart
4. **Verify permissions**: Files must be readable

**⚠️ WARNING**: If using symlinks (not recommended), never use `rm -rf` on ~/.claude folders

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