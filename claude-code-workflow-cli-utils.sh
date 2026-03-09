claude-specs() {
  if [ -z "$1" ]; then
    echo "Usage: claude-specs <issue-url>"
    return 1
  fi

  claude --permission-mode plan --model claude-sonnet-4-6 "Use the GitHub MCP to fetch ${1} — read the issue title, description, labels, and any comments. Also explore the relevant areas of the codebase mentioned in or implied by the issue.

Your goal is to evaluate whether this issue has enough detail to be implemented unambiguously, and if not, rewrite the description.

A well-specified issue must have these sections:

1. **Summary** — What and why. User story format ('As a [role], I want [goal], so that [benefit]') is recommended but not mandatory. What matters is clearly stating the problem or need, not just the solution.
2. **Acceptance Criteria** — Testable, unambiguous statements. Use Given/When/Then or simple checklists. Each criterion must be verifiable by a developer or reviewer without needing to ask clarifying questions.
3. **Out of Scope** — Explicitly bounds the work to prevent scope creep and misaligned expectations.
4. **Technical Notes** (optional) — Context for the implementer: relevant code areas, dependencies, API contracts, migration concerns.
5. **Screenshots** (optional) — Links or embedded visuals when UI is involved.

Evaluate the existing description against these criteria. Consider:
- Are the acceptance criteria actually testable, or are they vague ('should work well', 'handle edge cases')?
- Is the scope bounded, or could an implementer reasonably interpret it too broadly or too narrowly?
- Is the 'why' clear, or does the issue only describe a solution without motivating the problem?
- Are there implicit assumptions that should be made explicit?

If the issue already meets all required criteria, say so and do not modify it. Explain briefly what's already covered.

If the issue is underspecified, produce a rewritten description that:
- Preserves all existing information and intent — do not discard anything the author wrote
- Fills in gaps by inferring from context (title, labels, comments, and codebase exploration)
- Clearly marks any assumptions you made so I can verify them
- Uses the section structure above

Present the rewritten description to me as a plan. After I approve, use the GitHub MCP to update the issue body.

If you cannot confidently infer key details (e.g., the intended behavior is genuinely ambiguous), list specific questions to ask the issue author rather than guessing."
}

claude-implement() {
  if [ -z "$1" ]; then
    echo "Usage: claude-implement <issue-url>"
    return 1
  fi

  claude --permission-mode plan --model claude-opus-4-6 "Use the GitHub MCP to fetch ${1} — read the issue title, description, and view any attachments such as screenshots.

Your goal is to implement this issue. Start by understanding the requirements, then explore the relevant parts of the codebase.

Produce a plan that:
1. Breaks the work into small, testable steps
2. Follows a TDD approach — write/update tests before implementation and aim for 100% code coverage
3. Only makes changes directly required by the issue
4. Make the Change Easy, Then Make the Easy Change - Often (but not always) it is easier to perform a refactor first and then implement your changes, rather than going right into development. I highly encourage this approach when it is applicable.

You do not need to perform any \`git\` operations, I will handle that for you.

If the issue is ambiguous or underspecified, ask me rather than guessing."
}

claude-pr() {
  local branch=$(git branch --show-current)

  if [ "$branch" = "main" ]; then
    echo "Already on main, nothing to PR."
    return 1
  fi

  claude --permission-mode acceptEdits --model claude-sonnet-4-6 "Look at the git diff between ${branch} and main, and read the commit messages.

Use the GitHub MCP to create a pull request from ${branch} targeting main.

For the PR title: write a concise summary in imperative mood (e.g. 'Add user export endpoint').

For the PR body, use exactly this format:

### ➕ Added

1. (list each new feature, endpoint, component, or capability — one per line)

### ♻️ Changed

1. (list each modification to existing behavior — one per line)

### 🐞 Fixed

1. (list each bug fix — one per line)

If a section has no items, omit it entirely.

Rules:
- Each item should be one sentence describing the what and why, not the how
- Do not list internal refactors or test additions as their own items — mention them under the feature they support
- Do not editorialize or add commentary beyond what the diff shows
- If a commit message is vague, read the actual diff to understand the change

If the diff is large enough that the PR should probably be split, warn me and suggest how to split it instead of creating the PR."
}

claude-review() {
  if [ -z "$1" ]; then
    echo "Usage: claude-review <pr-url>"
    return 1
  fi

  claude --permission-mode plan --model claude-opus-4-6 "Use the GitHub MCP to fetch ${1} — both the diff and all issue-level comments.

These comments were left by an automated reviewer and are often wrong. For each comment:
1. Read the relevant code in the diff
2. Determine if the concern is valid
3. If invalid, briefly say why it's wrong

Additionally, find the github-actions bot comment containing the Vitest coverage report. Inside the <details> block there is a per-file coverage table for changed files. For any file where Statements, Branches, Functions, or Lines are below 85%, plan to add tests to bring them above 85%. The uncovered line numbers in the table tell you exactly what needs coverage.

Then produce a plan to fix only the genuinely valid review issues and the coverage gaps. Please follow a TDD approach to all fixes.

Do not plan to make any changes that are not directly related to the reviewer's comments or to insufficient test coverage on modified files.

If you're unsure whether a comment is valid after reading the code, ask me rather than guessing.

If there are no comments, wait and try again using the bash command 'sleep 10m'"
}
