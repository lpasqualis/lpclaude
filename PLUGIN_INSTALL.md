# Installing lpclaude as a Claude Code Plugin

This repository is now available as a Claude Code plugin! You can install it through the plugin marketplace for easier setup and updates.

## What's New

- **Plugin Format**: Repository now includes `.claude-plugin/` directory with plugin manifest
- **Marketplace Support**: Can be installed via Claude Code's plugin system
- **Easier Updates**: Plugin system handles updates automatically
- **No Manual Symlinks**: Plugin system manages file locations

## Installation Methods

### Method 1: Install via Plugin Command (Recommended)

```bash
# Add the marketplace
claude plugin marketplace add lpasqualis/lpclaude

# Browse available plugins and install
claude plugin install lpclaude-config
```

### Method 2: Install from GitHub URL

```bash
# Direct installation from GitHub
claude plugin install https://github.com/lpasqualis/lpclaude
```

### Method 3: Traditional Setup (Still Supported)

If you prefer the traditional symlink approach documented in README.md:

```bash
git clone https://github.com/lpasqualis/lpclaude.git ~/.lpclaude
cd ~/.lpclaude
./setup.sh
```

## What Gets Installed

The plugin includes:

### Agents (6 agents)
- `addjob` - Creates job files for deferred task execution
- `completion-verifier` - Verifies task completion claims
- `delegate` - Delegates tasks to external LLMs
- `documentation-auditor` - Audits documentation against code
- `hack-spotter` - Security and code quality reviewer
- `implan-auditor` - Reviews implementation plans

### Slash Commands (30+ commands)

**Git & Version Control**
- `/git:commit-and-push` - Intelligent commits with semantic messages
- `/git:rewrite-commit-descriptions` - Improve commit messages

**Documentation**
- `/docs:capture-session` - Document work for team handoff
- `/docs:capture-strategy` - Capture strategic decisions
- `/docs:readme-audit` - Audit and optimize README files
- `/pdf2md` - Convert PDF to Markdown

**Planning & Implementation**
- `/implan:create` - Generate implementation plans
- `/implan:execute` - Execute implementation plans
- `/postmortem` - Analyze session issues

**Job Queue Management**
- `/jobs:do` - Execute queued jobs in parallel
- `/jobs:auto-improve` - Natural language project improvement
- `/jobs:queue-learnings` - Queue learnings for processing

**Code Quality & Validation**
- `/hackcheck` - Check for security issues and technical debt
- `/doublecheck` - Verify implementation completeness
- `/simplify` - Simplify complex code

**Context & Memory**
- `/learn` - Extract insights to CLAUDE.md
- `/claude:optimize-md` - Optimize CLAUDE.md files
- `/question` - Answer questions without taking action

**Framework Development**
- `/commands:create` - Create new slash commands
- `/commands:validate` - Validate commands
- `/subagents:optimize` - Optimize subagent definitions
- `/subagents:review-ecosystem` - Analyze agent interactions

**VS Code Integration**
- `/vs:settings-help` - VS Code settings assistance
- `/vs:tint-workspace` - Tint VS Code workspace

### Hooks
- `guard-cd.sh` - Prevents directory changes that lose context
- `show-cwd.sh` - Shows current working directory

### Output Styles
- `html-documentation` - HTML formatted documentation
- `yaml-structured` - YAML structured data

## Plugin vs Traditional Installation

| Feature | Plugin Installation | Traditional Setup |
|---------|-------------------|------------------|
| Installation | One command | Clone + setup script |
| Updates | Automatic | Manual git pull |
| File Management | Managed by Claude | Symlinks you create |
| Uninstall | `claude plugin uninstall` | Remove symlinks manually |
| Customization | Plugin overrides | Direct file editing |
| Multi-machine sync | Via plugin system | Via git + setup.sh |

## Managing the Plugin

```bash
# List installed plugins
claude plugin list

# Update plugin to latest version
claude plugin update lpclaude-config

# Disable plugin temporarily
claude plugin disable lpclaude-config

# Enable plugin
claude plugin enable lpclaude-config

# Uninstall plugin
claude plugin uninstall lpclaude-config
```

## Customizing the Plugin

### Option 1: Fork and Modify
1. Fork the repository on GitHub
2. Make your changes
3. Install from your fork: `claude plugin install yourusername/lpclaude`

### Option 2: Layer Your Own Config
The plugin installs into Claude Code's plugin directory, but you can still have your own configurations in `~/.claude/`:
- Your personal configs in `~/.claude/` take precedence
- Plugin provides the base functionality
- Best of both worlds: shared components + personal customizations

## Dependencies

Some features require additional tools (installed automatically by setup.sh if using traditional method):

- `jq` - JSON processor for some commands
- `llm` - External LLM delegation (optional)
- `marker` - PDF to Markdown conversion (optional)

Install manually if using plugin method:
```bash
brew install jq
pip install llm llm-claude-3
```

## Troubleshooting

### Plugin Installation Fails
- Ensure you're using Claude Code v1.5 or later
- Check internet connectivity for GitHub access
- Try direct URL installation method

### Commands Not Appearing
- Restart Claude Code after installation
- Run `claude plugin list` to verify installation
- Check plugin is enabled (not disabled)

### Conflicts with Existing Config
- Plugin files take precedence over `~/.claude/` files with same names
- To use your own version of a command/agent, disable the plugin or uninstall specific components

## Publishing to Official Marketplace

Once Anthropic opens the official plugin marketplace, this plugin will be submitted for community use. Until then:

1. Add via GitHub: `claude plugin marketplace add lpasqualis/lpclaude`
2. Or install directly: `claude plugin install https://github.com/lpasqualis/lpclaude`

## Support and Issues

- **Issues**: https://github.com/lpasqualis/lpclaude/issues
- **Discussions**: https://github.com/lpasqualis/lpclaude/discussions
- **Documentation**: See README.md for detailed component documentation

## What's Different from Traditional Install?

The plugin format:
- ✅ Easier installation and updates
- ✅ Managed by Claude Code
- ✅ Can be enabled/disabled without uninstalling
- ✅ Integrated with plugin marketplace

The traditional setup (setup.sh):
- ✅ Full control over file locations
- ✅ Direct editing of components
- ✅ Custom symlink arrangements
- ✅ Integration with your existing dotfiles

**Both methods are fully supported.** Choose based on your preference.
