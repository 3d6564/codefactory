# Contributing

Codefactory packages focused coding-agent capabilities. Work happens on
short-lived branches and lands through pull requests.

People and coding agents follow this file. `INSTRUCTIONS.md` states the same
hard limits in shorter form.

## Select work

Use GitHub Issues as the workflow source. GitHub Projects is not configured;
do not invent a board workflow.

Before the first implementation edit:

1. Select one or more issues that share one concern.
2. Set `status: in-progress` on each. Keep only one status label at a time.
3. Ensure each issue has priority `P0`–`P4` (`P0` highest), size `XS`–`XL`,
   and category `bug`, `feature`, `docs`, or `packaging`.
4. If priority or size is missing, set it and report the value. If category is
   missing or a value is unclear, ask before editing.

Ask before putting unrelated issues on the same branch.

## Branches

1. Branch from current `main` as `feature/<short-description>` or
   `fix/<short-description>`.
2. Never implement on `main`.
3. Keep one concern per branch.
4. Do not reuse merged branches or use long-lived developer branches. If a
   merged branch was not deleted, delete it instead of adding more commits.

## Commits

Use Conventional Commits: `type(scope): subject`.

- Types: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`
- Scopes: `codebrief`, `codereview`, `codeskills`, `root`
- Reference the issue numbers in the message
- Do not rewrite history

## Required checks

```bash
bash tests/test_install.sh
bash components/codebrief/tests/test_install.sh
bash components/codereview/tests/test_install.sh
bash components/codeskills/tests/test_install.sh
```

The tests use temporary directories and do not change the user's agent config.
GitHub Actions runs the same commands on pull requests and on `main`. If a
required check cannot run, report the command, reason, and remaining risk.

## Pull requests

When required checks pass, open a pull request without waiting to be asked.
Set `status: in-review`. Tell the owner it is ready to review. Do not merge.

The pull request is the review handoff. State files changed, checks run, known
risks, and work left out of scope.

Pull requests to `main` require review from the owners in `.github/CODEOWNERS`.
GitHub does not let a pull-request author approve their own pull request. The
repository owner may merge their own pull requests through the `main` ruleset
bypass.

Squash merge after review.

## After merge

1. Set `status: done` on each selected issue.
2. Update local `main`.
3. Delete the local and remote topic branches.
4. Treat the merged branch as closed. For later work, fetch `origin`, create a
   new branch from current `origin/main`, and open a separate pull request.

## Change rules

- Read `AGENTS.md` and the changed component's `AGENTS.md`.
- Keep each component prompt under its `prompt/` directory or skill directory.
- Keep adapter frontmatter under its component or skill directory.
- Do not invent other tools' config shapes.
- Keep components independently installable.
- Do not add a third component or a new agent install target without approval.
- Update `README.md` when setup, commands, or install targets change.
- Do not commit secrets, `.env`, or generated local install copies.
