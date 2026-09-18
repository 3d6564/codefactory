# AGENTS.md - Codeskills

## Purpose

Codeskills packages reusable, separately installable skills for coding agents.
The first skill, `backlog-triage`, reviews project work before implementation.

## Working Rules

- Read and follow `../../INSTRUCTIONS.md` and `../../CONTRIBUTING.md`.
- Keep each skill under `skills/<skill-name>/` with its prompt and adapter frontmatter.
- Keep skills report-first. Do not change target repository files.
- Check applicable `INSTRUCTIONS.md` files for the Codebrief marker before a skill starts. Ask when it is absent.
- Ask before network access and before remote issue or board changes.
- Do not add an application runtime, model API dependency, skill, or agent install target without approval.

## Project Layout

- `skills/backlog-triage/`: project-work triage skill and adapter frontmatter.
- `install.sh`: installs every included skill for one selected coding agent.
- `tests/test_install.sh`: offline installer checks.

## Verification

Run `bash components/codeskills/tests/test_install.sh` from the repository root after changing this component.
