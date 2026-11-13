# AGENTS.md - CodeWriter

## Purpose

CodeWriter implements requested changes according to CodeBrief project guidance and the target project's own instructions. Its standalone source of truth is `SKILL.md`.

## Rules

- Follow root `INSTRUCTIONS.md` and `CONTRIBUTING.md` when changing CodeFactory itself.
- Keep the skill usable without an agent adapter, model runtime, network, or any other CodeFactory component.
- Agent adapters may add host-specific invocation and permissions, but must not change the skill's implementation, safety, or approval contract.
- Do not describe an instruction file as CodeBrief output without verifying the exact marker or user confirmation.
- Enforce readable code, bounded resource use, explicit trust boundaries, focused tests, and concise searchable docstrings.
- Do not add an install target, runtime dependency, or agent adapter without updating documentation and offline tests.
