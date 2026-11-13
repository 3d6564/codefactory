<p align="center">
  <img src="docs/art/codefactory.svg" width="100%" alt="CodeBrief defines project rules, CodeWriter implements changes, and CodeReview checks the result.">
</p>

# CodeFactory

CodeFactory provides three coding agents and a separate collection of reusable skills. You can install a skill without installing an agent definition. No CodeFactory runtime or model API is required.

| Component | Role | Documentation |
| --- | --- | --- |
| `codebrief` | Interview developers and write project-specific `INSTRUCTIONS.md`. | [CodeBrief](components/codebrief/README.md) |
| `codewriter` | Implement, test, and document changes under project rules. | [CodeWriter](components/codewriter/README.md) |
| `codereview` | Review one pull request or merge request by URL or number. | [CodeReview](components/codereview/README.md) |
| `codeskills` | Install reusable skills, starting with backlog triage. | [Codeskills](components/codeskills/README.md) |

## Install

Specify a supported host (`opencode`, `claude`, `cursor`, `copilot`, `codex`, or `prompt`), the installation format, and the scope:

```bash
./install.sh codewriter --agent opencode --global
./install.sh codewriter --agent claude --format skill --local /path/to/project
./install.sh codebrief,codereview --agent cursor --format skill --local .
./install.sh codeskills --agent cursor --format skill --local .
./install.sh all --agent opencode --format both --local .
```

- `--format skill`: install a reusable skill without creating an agent definition.
- `--format agent`: install the host-specific agent definition.
- `--format both`: install both where the host supports separate agent definitions.
- `--format auto`: use an agent definition for CodeBrief, CodeWriter, or CodeReview, and a standalone skill for Codeskills (default).
- `--global`: install for the current user (default); `--local DIR`: install into an existing project.
- `--yes`: replace existing generated files without prompting. Without it, confirm replacements.

Select one component, a comma-separated set, or `all`. `all` includes the three agent components and the Codeskills skill package. `codeskills` never installs an agent definition; `--format agent` skips it. Re-run the installer after updating CodeFactory.

**Host differences:** Cursor uses its skill as the agent invocation surface rather than a separate agent definition. `prompt` produces portable prompt text, not a host-specific agent. Codex standalone skills use `.agents/skills`; Codex agent configurations use `.codex/agents`. An installed skill does not grant any tool permissions or automatic delegation.

## Workflow

Run CodeBrief to create project instructions, use CodeWriter to implement under those rules, then invoke CodeReview independently. Install Codeskills only when you need its skills. CodeWriter recommends CodeBrief when the project's instructions lack its marker.

## Releases

Codefactory releases are versioned source snapshots. See [VERSIONS.md](VERSIONS.md) for tag and release rules.

## Verify

```bash
bash tests/test_install.sh
bash components/codebrief/tests/test_install.sh
bash components/codewriter/tests/test_skill.sh
bash components/codewriter/tests/test_install.sh
bash components/codereview/tests/test_install.sh
bash components/codeskills/tests/test_install.sh
```

Tests use temporary directories and do not modify the user's agent configuration.

See [CONTRIBUTING.md](CONTRIBUTING.md) for development workflow. MIT License; see [LICENSE](LICENSE).
