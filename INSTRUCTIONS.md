# INSTRUCTIONS.md

<!-- codebrief -->

## Project

Codefactory packages focused, separately installable coding-agent capabilities.
Current components are `codebrief` and `codereview`.

Harden those two components and add behavior inside them. Do not add a third
component without approval. Do not add a new agent install target beyond
`opencode`, `prompt`, `claude`, `cursor`, `copilot`, and `codex` without
approval. Do not add an application runtime or model API dependency without
approval.

## Scope and instruction priority

- Apply this file to the Codefactory repository and its components.
- Extend the rules in `AGENTS.md`; do not replace them.
- Before working, read the closest scoped instruction files and any files they
  name as current sources.
- Closer, more specific instructions take priority. If relevant files disagree,
  report the conflict and ask rather than guessing.

## Project map and sources of truth

Treat these as the named sources:

- root `AGENTS.md`, `INSTRUCTIONS.md`, and `CONTRIBUTING.md`
- `components/codebrief/AGENTS.md` and `components/codereview/AGENTS.md`
- each component `prompt/` directory
- each component `packaging/` directory
- root `install.sh` and each component `install.sh`
- `tests/test_install.sh`, `components/codebrief/tests/test_install.sh`, and
  `components/codereview/tests/test_install.sh`

Follow `CONTRIBUTING.md` for the full git and GitHub Issues procedure.

## Communication

- Use concise, direct, practical software-engineering language.
- Prefer simple common words over academic or jargon-heavy terms.
- Follow ASD-STE100 Simplified Technical English as an adapted writing style.
  Do not claim formal compliance.
- Prefer short sentences, one main idea per sentence, and specific names over
  vague shorthand.
- Define a specialized term when it is first used.
- Use "fixture" only for internal tests and documentation about those tests. In
  other prose, name the actual item, such as test server or sample data.
- In new prose, use "main," "official," or the named source instead of
  "canonical"; use "use" instead of "utilize" or "leverage"; name the specific
  quality instead of "robust," "clean," or "proper"; and omit "simply,"
  "obviously," or "just."
- Do not explain routine actions unless asked.
- In the final response, list changed files, checks, risks, assumptions, and
  deferred work.

## Working method

- Treat review, audit, and inspection requests as report-only until editing is
  separately requested or approved.
- Present a plan before broad, unclear, security-sensitive, or hard-to-reverse
  work.
- Follow the repository's existing language, versions, tools, layout, and style.
- Keep work within the requested scope. Nearby cleanup is allowed when it
  supports the task.
- Ask before editing a file that already contains unrelated user changes.
- Ask when expected behavior is unclear, a choice has lasting effects, or work
  grows beyond the plan.
- Codefactory capabilities are opt-in. Before using one, follow its prompt and
  check applicable `INSTRUCTIONS.md` files for `<!-- codebrief -->`. Treat the
  marker as confirmation that Codebrief was used; otherwise ask.

## Collaboration and version control

- Never implement on `main`. Create and switch to a topic branch first.
- Branch from current `main` as `feature/<short-description>` or
  `fix/<short-description>`.
- Keep one concern per branch. A branch may reference more than one issue. Ask
  before putting unrelated issues on the same branch.
- Before the first implementation edit, select one or more GitHub Issues. Set
  `status: in-progress` on each. Keep only one status label at a time.
- Before the first implementation edit, each selected issue must have:
  - priority `P0`, `P1`, `P2`, `P3`, or `P4` (`P0` highest, `P4` lowest)
  - size `XS`, `S`, `M`, `L`, or `XL`
  - category `bug`, `feature`, `docs`, or `packaging`
- If priority or size is missing, set it and report the value. If category is
  missing or any required value is unclear, ask before editing.
- Use Conventional Commits: `type(scope): subject` with type `feat`, `fix`,
  `docs`, `test`, `refactor`, or `chore` and scope `codebrief`, `codereview`, or
  `root`. Reference the issue numbers. Do not rewrite history.
- After required checks pass, open the pull request, set `status: in-review`,
  and tell the owner it is ready to review. Do not wait to be asked. Do not
  merge.
- After merge, set `status: done`, update local `main`, and delete the local and
  remote topic branches. Do not reuse a merged branch.

## Code and documentation

- Ask before changing major design choices, public interfaces, dependencies,
  package tools, or core development tools.
- Add concise docstrings to public functions and non-obvious behavior.
- Use comments for reasons and tradeoffs, not to repeat code.
- Give TODO comments an issue or task reference.
- Update documentation when setup, commands, public behavior, or an approved
  major design changes.

## Errors and logging

- Follow the local error pattern. Handle errors when recovery or useful context
  is possible; otherwise let failures surface.
- User-facing errors state what failed and the next useful step without
  unnecessary internal detail.
- Use the existing logger, fields, levels, and destination. Ask before adding a
  new logging system.
- Redact sensitive values in normal output.
- Advanced debug output may show full local detail only when explicitly enabled.
  Keep that output local and out of version control.
- Test logs or structured events only when other code or tools rely on them.

## Testing and verification

Run every applicable required check. Do not invent commands where none are
documented.

```bash
bash tests/test_install.sh
bash components/codebrief/tests/test_install.sh
bash components/codereview/tests/test_install.sh
```

GitHub Actions runs the same commands on pull requests and on `main`.

- Add or update a focused test for changed behavior when a test setup exists.
- For bug fixes, reproduce the failure, identify the cause, and add a test that
  prevents it from returning.
- If a required check cannot run, report the exact command, reason, and remaining
  risk. Do not claim it passed.

## Security and data handling

- Without asking, the agent may read safe project files, edit the requested
  scope, run offline checks, and run already approved local containers.
- Access secrets, recordings, transcripts, private notes, generated evidence,
  and local databases only when the task requires it and closer instructions
  allow it.
- Ask before editing private or generated data unless closer instructions allow
  the exact change.
- Ask before dependency changes, releases, deployments, cloud changes, remote
  data changes other than the GitHub Issue and pull-request steps above, or
  non-GitHub network calls.
- Ask before deletion, resets, history rewrites, or other hard-to-reverse actions
  unless closer instructions allow the exact cleanup.
- Check user input, files, external responses, and model output before using them
  in commands, paths, code, logs, or further prompts.
- Do not send project data to hosted models, APIs, telemetry, or other external
  services without approval.

## Agent permissions

For work that already has the required issue labels and `status: in-progress`,
the agent may create the topic branch, commit, push, set the required GitHub
Issue labels, and open the pull request when required checks pass.

Ask before merge, release, a new component, a new agent install target, a
dependency change, a hosted-model send, or other network use.

## Definition of ready for review

- Requested behavior and stated acceptance conditions are met.
- Existing public behavior remains intact unless an approved change requires
  otherwise.
- Work is on a `feature/` or `fix/` topic branch, not on `main`.
- Each selected issue has priority, size, category, and `status: in-review`.
- Required checks above passed, or each blocked check is reported with its
  reason and risk.
- Setup, command, or public-behavior documentation matches the change.
- A pull request is open, and the owner has been told it is ready to review.
- No unapproved component, agent install target, runtime, model API, merge, or
  non-GitHub network action occurred.
- The final response lists changed files, checks, risks, assumptions, and
  deferred work.

## Definition of done after merge

- Each selected issue has `status: done`.
- Local `main` matches `origin/main`.
- The local and remote topic branches are deleted.
- The merged branch is not reused.

## GitHub Projects

- GitHub Projects is not configured. Use GitHub Issue labels for state. Do not
  invent project identifiers, fields, statuses, or board transitions.
