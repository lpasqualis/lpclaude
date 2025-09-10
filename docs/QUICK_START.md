# Understanding This Repository

## What This Actually Is

**This is my (Lorenzo's) personal Claude Code configuration.** I maintain it in a Git repository so I can:
- Version control my Claude customizations
- Share configurations across my multiple machines
- Keep my setup consistent and backed up

**This is NOT a product or framework to install.** It's shared publicly as an example of how one person organizes their Claude Code setup.

## Why This Might Be Useful to You

If you're looking to create your own Claude Code configuration, you can:
1. **See how I organize things** - Look at the folder structure and naming conventions
2. **Get ideas for your own agents/commands** - Browse what I've created for inspiration
3. **Copy individual components you like** - Take specific agents or commands and adapt them
4. **Learn the patterns** - Understand how to write agents, commands, hooks, etc.

## How I Use This Repository

On my machines, I use symlinks to connect `~/.claude/` folders to this repository. This lets me:
- Edit in one place and have changes available everywhere
- Keep everything in version control
- Maintain the same setup across different computers

**You probably don't want to do this with MY configuration.** Instead, consider creating your own repository with your own preferences and tools.

## If You Want to Try Individual Components

You can copy specific pieces you find useful:

```bash
# Clone to browse (use a temp directory)
git clone https://github.com/lpasqualis/lpclaude.git ~/temp-lpclaude
cd ~/temp-lpclaude

# Look at what's available
ls agents/       # My auto-triggering agents
ls commands/     # My slash commands
ls hooks/        # My event hooks

# If you like something, copy it to YOUR ~/.claude/
mkdir -p ~/.claude/agents
cp agents/hack-spotter.md ~/.claude/agents/

# Then customize it for your needs
vim ~/.claude/agents/hack-spotter.md
```

## Creating Your Own Configuration

If you want to create a similar setup for yourself:

1. **Start with YOUR preferences** - What do you do repeatedly that could be automated?
2. **Create your own repository** - `mkdir ~/my-claude-config && cd ~/my-claude-config`
3. **Build your components** - Write agents/commands that fit YOUR workflow
4. **Use my structure as a reference** - But don't feel bound by it

## The Components Explained

Here's what each folder in my setup contains:

- **agents/** - Auto-trigger based on conversation keywords
- **commands/** - Slash commands I type like `/git:commit-and-push`
- **hooks/** - Shell scripts that run on Claude events
- **output-styles/** - How I like Claude's responses formatted
- **directives/** - My coding standards and preferences
- **utils/** - Helper scripts like my `addjob` task queuing utility
- **workers/** - Templates for parallel processing

Each serves a specific purpose in MY workflow. Your needs will be different.

## Important Notes

- **This is a personal configuration** - It reflects my preferences and workflow
- **Not everything will be relevant to you** - I work on specific types of projects
- **Components may have dependencies** - Some commands rely on others being present
- **Feel free to fork and modify** - But make it yours, don't just use mine as-is

## Questions?

If you're curious about how something works or why I built it a certain way, the code is open for you to explore. Use it as inspiration for your own Claude Code setup!