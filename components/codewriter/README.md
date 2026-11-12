# CodeWriter

CodeWriter is a portable coding skill for implementing changes in existing projects. The standalone contract is in [SKILL.md](SKILL.md).

Its preferred workflow begins with [CodeBrief](../codebrief/README.md): inspect the project's `INSTRUCTIONS.md`, confirm the CodeBrief marker, and follow the project's decisions. CodeWriter also works independently. If the marker is absent, it recommends CodeBrief and asks whether to proceed with existing project guidance.

CodeWriter has guided (default), focused, and autonomous operating behaviors. None overrides project permissions. It emphasizes clear human-readable code, memory-conscious algorithms, trust-boundary security, tests, and concise searchable docstrings. It can hand completed changes to [CodeReview](../codereview/README.md) when the host supports delegation.

## Standalone use

Give the content of [SKILL.md](SKILL.md) to an existing coding agent as its skill instructions, or reference that file using your agent's own skill-loading mechanism. The skill itself is tool-neutral: it does not provide filesystem, terminal, Git, network, or model access. Agent adapters and installer support are separate follow-up packaging work.

## Scope

The core skill does not create a runtime, edit agent configuration, or grant approvals. Read the target project's instructions before running it.
