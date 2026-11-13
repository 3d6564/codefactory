<p align="center">
  <img src="docs/art/codefactory.svg" width="100%" alt="CodeBrief defines project rules, CodeWriter implements changes, and CodeReview checks the result.">
</p>

# CodeFactory

CodeFactory provides three independently installable coding capabilities. Each can be installed as an agent or a standalone skill for any supported host. No CodeFactory runtime or model API is required.

| Component | Role | Documentation |
| --- | --- | --- |
| `codebrief` | Interview developers and write project-specific `INSTRUCTIONS.md`. | [CodeBrief](components/codebrief/README.md) |
| `codewriter` | Implement, test, and document changes under project rules. | [CodeWriter](components/codewriter/README.md) |
| `codereview` | Review one pull request or merge request by URL or number. | [CodeReview](components/codereview/README.md) |

## Install

Specify a supported host (`opencode`, `claude`, `cursor`, `copilot`, `codex`, or `prompt`), the installation format, and the scope:

```bash
./install.sh codewriter --agent opencode --global
./install.sh codewriter --agent claude --format skill --local /path/to/project
./install.sh codebrief --agent codex --format skill --global
./install.sh codereview --agent copilot --format skill --local .
./install.sh all --agent opencode --format both --local .
```

- `--format skill`: install a reusable skill without creating an agent definition.
- `--format agent`: install the host-specific agent definition (default; preserves existing commands).
- `--format both`: install both where the host supports separate agent definitions.
- `--global`: install for the current user (default); `--local DIR`: install into an existing project.
- `--yes`: replace existing generated files without prompting. Without it, confirm replacements.

Select one component, a comma-separated set, or `all`. Component installers also support `--format`. Re-run the installer after updating CodeFactory.

**Host differences:** Cursor uses its skill as the agent invocation surface rather than a separate agent definition. `prompt` produces portable prompt text, not a host-specific agent. Codex standalone skills use `.agents/skills`; Codex agent configurations use `.codex/agents`. An installed skill does not grant any tool permissions or automatic delegation.

## Workflow

Run CodeBrief to create project instructions, use CodeWriter to implement under those rules, then invoke CodeReview independently. Each component also works without the other two. CodeWriter recommends CodeBrief when the project's instructions lack its marker.

## Verify

```bash
bash tests/test_install.sh
bash components/codebrief/tests/test_install.sh
bash components/codewriter/tests/test_skill.sh
bash components/codewriter/tests/test_install.sh
bash components/codereview/tests/test_install.sh
```

Tests use temporary directories and do not modify the user's agent configuration.

See [CONTRIBUTING.md](CONTRIBUTING.md) for development workflow. MIT License; see [LICENSE](LICENSE).
