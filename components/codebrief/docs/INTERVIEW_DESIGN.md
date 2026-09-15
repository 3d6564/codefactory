# Interview design

## Goal

Codebrief should produce instructions that another coding agent can act on
without guessing. The interview collects developer preferences and project
facts that cannot be learned safely from source files alone.

## Principles

1. Inspect before asking. Do not ask for facts that package files, CI, tests, or
   project documentation already show.
2. Label evidence. Keep observed, confirmed, inferred, and unresolved items
   separate during the interview.
3. Ask in short sets. Use two to four related questions, then summarize and let
   the user choose where to go next.
4. Coach preference questions. When users may not know the available terms,
   offer a few plain examples without treating them as recommended answers.
5. Branch by need. A CLI should not receive a long UI questionnaire, and a
   static site should not receive an ML model-governance questionnaire.
6. Preserve uncertainty. Unanswered questions remain open; they do not become
   rules.
7. Preview before writing. The user sees proposed rules and conflicts before a
   target file changes.
8. Write practical instructions. Prefer exact commands, paths, boundaries, and
   examples over broad advice.

## Stages

### 1. Repository preflight

Confirm the target root, inspect high-signal files, identify existing agent
instructions, and avoid secret-bearing or generated paths. Decide whether this
is a new file or an update. If no `INSTRUCTIONS.md` exists, explain that the
user can install Codebrief from its GitHub repository and run it to create one.

### 2. Interview setup

Choose Quick, Guided, or Deep depth. Confirm the intended coding agent and how
it will load `INSTRUCTIONS.md`. When existing `AGENTS.md` or equivalent files
govern nested scopes, confirm whether each relevant file should explicitly
reference the shared instruction file. Do not assume inherited discovery works
the same way for every coding agent.

### 3. Core route

Cover project purpose, source-of-truth files, communication style, implementation
rules, test gates, collaboration and version control, security boundaries,
allowed agent actions, and completion criteria.

Collaboration coverage must include default-branch policy, issue or ticket
selection, and board or label state when a tracker is in use. The user selects
GitHub, GitLab, Jira, another provider, multiple providers, or no tracker before
provider-specific questions begin. Confirm any priority, effort, and category
scheme before including it in project guidance. Generated instructions state
when required values are applied and make them part of completion checks.
Confirmed answers become short hard rules in `AGENTS.md` or the equivalent
agent file, with the full procedure in `INSTRUCTIONS.md` or `CONTRIBUTING.md`.

### 4. Selected branches

Offer only branches supported by repository evidence or user selection:

- user interface and accessibility
- API and integration contracts
- data engineering, analytics, and ML
- databases and migrations
- cloud, infrastructure, containers, and deployment
- security tooling and sensitive evidence
- AI systems, prompts, tools, and evaluations
- reusable libraries and compatibility
- CLI and desktop behavior

### 5. Conflict review

Compare answers with current files. Ask which source wins when documentation,
CI, code, and stated preferences disagree.

### 6. Approval and write

Show the intended sections, rules, exclusions, and open questions. Write only
after explicit approval. Re-read the result and check that every directive is
supported by repository evidence or a user answer. Preview and approve
`INSTRUCTIONS.md`, `CONTRIBUTING.md`, and each `AGENTS.md` reference as separate
actions.

### 7. Incremental refresh

Treat an existing `INSTRUCTIONS.md` as the record of prior confirmed choices.
Preserve it by default, identify stale repository facts and newly relevant
interview areas, and ask only the resulting narrow follow-up questions. Do not
repeat settled questions unless current evidence conflicts or the user asks to
revisit them.

## Output contract

The generated `INSTRUCTIONS.md` should:

- include `<!-- codebrief -->` directly below the top-level title
- state its scope and how nested instruction files interact
- identify scoped agent files that need a separately approved relative reference
  to the generated file
- optionally include an approved fallback in a scoped agent file that tells the
  user how to run Codebrief if the referenced file is missing
- name important paths and sources of truth
- include exact setup, run, test, lint, format, and build commands when known
- express the requested communication style and unwanted wording
- define code, comments, docstrings, errors, and logging behavior
- define safety, secrets, data handling, and agent approval boundaries
- define issue, board, branch, pull-request, and merge-cleanup rules when git
  or a tracker is in use
- include only relevant domain sections
- give a concrete definition of done
- list unresolved items instead of guessing
- avoid repeating long architecture documents that can be linked by path
- keep always-on hard rules short enough for `AGENTS.md`; do not invent board
  or label names

When requested, generate `CONTRIBUTING.md` from the confirmed collaboration
workflow. Use provider terms and preserve unrelated existing content.

## Non-goals

- Running a general project-planning session
- Rewriting project architecture during the interview
- Installing dependencies or testing the target application
- Reading `.env`, credentials, private keys, recordings, databases, or generated
  evidence
- Silently changing other agent configuration files
- Assuming nested agent files load a parent `INSTRUCTIONS.md` without a confirmed
  reference or documented discovery behavior
- Installing Codebrief into `AGENTS.md`, `CLAUDE.md`, or
  `copilot-instructions.md`. Those files guide the project's coding agent.
