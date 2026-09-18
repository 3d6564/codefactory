# Codeskills

Codeskills is a collection of reusable skills for coding agents. Each skill is installed for one selected agent. The installer currently includes `backlog-triage`.

Each skill has a portable `SKILL.md` with `name` and `description` YAML frontmatter. Adapter-specific frontmatter stays separate when a target needs additional metadata.

## Install

```bash
./install.sh codeskills --agent opencode --global
./install.sh codeskills --agent claude --local /path/to/project
```

| Agent | Global path | Local path | How to run |
| --- | --- | --- | --- |
| `opencode` | `~/.config/opencode/agents/` and `commands/` | `.opencode/agents/` and `commands/` | Select `backlog-triage` or run `/backlog-triage` |
| `prompt` | `~/.config/codefactory/codeskills/` | `.codefactory/codeskills/` | Point an agent at `backlog-triage.md` |
| `claude` | `~/.claude/agents/` and `~/.claude/skills/` | `.claude/agents/` and `.claude/skills/` | `/backlog-triage` or `claude --agent backlog-triage` |
| `cursor` | `~/.cursor/skills/` | `.cursor/skills/` | `/backlog-triage` in Agent chat |
| `copilot` | `~/.copilot/agents/` | `.github/agents/` | Select the `backlog-triage` custom agent |
| `codex` | `~/.codex/agents/` | `.codex/agents/` | Ask Codex to use `backlog-triage` |

Use `--yes` for a non-interactive install. The installer copies files, so rerun it after updating Codefactory. Restart the target agent after installation.

## Backlog Triage

`backlog-triage` reviews open project work and recommends the next suitable item for a developer or coding agent. It reads repository guidance first, asks before network access, and reports before making remote changes.

```text
/backlog-triage
/backlog-triage focus on ready security work
/backlog-triage refine issue 16
```

It can inspect issues, labels, dependencies, board fields, and owner signals. It identifies ready, blocked, stale, and inconsistent work. It changes issue or board data only after the user approves the exact change.

## Verify

```bash
bash components/codeskills/tests/test_install.sh
```

## Contributing

See the repository [CONTRIBUTING.md](../../CONTRIBUTING.md).
