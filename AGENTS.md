# AGENTS.md - Codefactory

## Purpose

Codefactory packages focused, separately installable capabilities for coding
agents. Current components are `codebrief` and `codereview`.

## Working Rules

- Read and follow `INSTRUCTIONS.md` and `CONTRIBUTING.md`.
- Keep each component focused and separately installable.
- Keep component prompts and adapter frontmatter inside that component.
- Before a Codefactory capability starts, check applicable `INSTRUCTIONS.md`
  files for `<!-- codebrief -->`. Treat the marker as confirmation that
  Codebrief was used; otherwise ask.
- Read the closest component `AGENTS.md` before changing that component.
- Do not add an application runtime or model API dependency without approval.
- Do not add a third component or a new agent install target without approval.
- Never implement on `main`. Create and switch to a topic branch first.
- Before the first implementation edit, select one or more GitHub Issues, set
  `status: in-progress`, and require `P0`–`P4`, `XS`–`XL`, and `bug` /
  `feature` / `docs` / `packaging`. Set and report a missing priority or size.
  Ask when category is missing or any required value is unclear.
- After required checks pass, open the pull request, set `status: in-review`,
  and tell the owner it is ready to review.
- After merge, set `status: done`, update local `main`, and delete the local
  and remote topic branches.

## Project Layout

- `components/codebrief/`: project-instruction interview capability.
- `components/codereview/`: report-first pull-request review capability.
- `INSTRUCTIONS.md`: shared repository working, safety, and reporting rules.
- `CONTRIBUTING.md`: issue, branch, pull-request, and review workflow.
- `install.sh`: dispatches installation to one selected component.
- `tests/test_install.sh`: root dispatcher checks.

## Verification

Run all checks after changing repository-level installation or packaging:

```bash
bash tests/test_install.sh
bash components/codebrief/tests/test_install.sh
bash components/codereview/tests/test_install.sh
```
