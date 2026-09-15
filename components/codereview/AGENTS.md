# AGENTS.md - Codereview

## Purpose

Codereview is Codefactory's report-first pull-request and merge-request review
capability.
It does not implement product features in a target repository.

## Working Rules

- Read and follow `../../INSTRUCTIONS.md` and `../../CONTRIBUTING.md`.
- Keep each capability focused and separately installable.
- Before a review starts, check whether `<!-- codebrief -->` is a standalone
  comment on the first nonblank line after the top-level title in an applicable
  `INSTRUCTIONS.md`. Treat only that placement as confirmation that Codebrief
  was used; otherwise ask with Yes as the recommended first choice.
- If the marker has that placement or the user confirms Codebrief was used,
  read applicable instruction files before acting and treat them as
  project-specific requirements.
- Review is report-only until the user explicitly requests provider comments,
  reviews, issues, or other remote changes.
- Make approved changes only to the selected provider's review workflow. Never
  edit target repository files, implement fixes, create commits, push code,
  modify branches, or merge the review item.
- Do not read secrets, generated evidence, local databases, or private notes.
- Keep the canonical capability prompt under `prompt/` and adapter frontmatter
  under `packaging/`.
- Do not add an application runtime or model API dependency without approval.

## Project Layout

- `prompt/codereview.md`: main review capability prompt.
- `packaging/`: per-agent frontmatter and OpenCode command.
- `install.sh`: installer for supported coding agents.
- `tests/test_install.sh`: offline installer checks.
- Root `LICENSE`: MIT.


## Verification

- Run `bash components/codereview/tests/test_install.sh` from the repository root
  after changing prompts, packaging, or install.
- Keep README examples aligned with `install.sh`.
