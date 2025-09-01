# Git Practices

## Security & Commits

* Never expose or commit sensitive data, credentials, or API keys
* Use semantic commit messages (feat, fix, docs, refactor, test, chore, style, perf)
* Keep commits atomic - one logical change per commit
* Write commit messages that explain WHY, not just WHAT
* Review staged changes before committing (git diff --staged)
* Ensure all tests pass before committing feature changes

## Advanced Practices

* Keep commit history clean - squash fixup commits when appropriate
* Reference issue numbers in commits when applicable