# claude-code-workflow-cli-utils
Bash functions for automating common workflows with Claude Code: issue specs, implementation, PR creation, and automating code reviews.

## Setup

Source the file in your shell profile (e.g. `~/.bashrc` or `~/.zshrc`):

```bash
source /path/to/claude-code-workflow-cli-utils.sh
```

## Usage

### 1. Improve a GitHub issue description

Refine an underspecified issue into a well-structured spec:

```bash
claude-specs https://github.com/acme/app/issues/42
```

### 2. Implement GitHub issue

Implement an issue with a TDD-first plan:

```bash
claude-implement https://github.com/acme/app/issues/42
```

### 3. Create a PR from the current branch

Create a PR from the current branch:

```bash
claude-pr
```

### 4. Re-review Claude PR comments

This assumes that you have set up [Claude Code GitHub Actions](https://code.claude.com/docs/en/github-actions) on your repository, and that the action has finished running on the PR. This will re-review the comments left by the action, and fix any test coverage gaps.

```bash
claude-review https://github.com/acme/app/pull/17
```
