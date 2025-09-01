# Bash cd Command Restrictions

## Rule: Only subshell cd to existing directories inside project root

### ALLOWED Format
```bash
( cd "$CLAUDE_PROJECT_DIR/subdir" && command )
```
- Must use subshell parentheses
- Must be absolute path inside project
- Directory must already exist
- Only ONE cd per command

### NOT ALLOWED
```bash
cd /tmp                          # No direct cd
( cd /tmp && command )           # Outside project
( cd ../other && command )       # Relative paths
cd dir1 && cd dir2              # Multiple cd
```

### Use Command Flags Instead
```bash
git -C "$CLAUDE_PROJECT_DIR/src" status       # Instead of cd + git
npm --prefix "$CLAUDE_PROJECT_DIR/app" test   # Instead of cd + npm  
yarn --cwd "$CLAUDE_PROJECT_DIR" install      # Instead of cd + yarn
make -C "$CLAUDE_PROJECT_DIR/build" all       # Instead of cd + make
python "$CLAUDE_PROJECT_DIR/script.py"        # Use full paths
```

**Best Practice**: Avoid cd entirely - use command flags or full paths.
