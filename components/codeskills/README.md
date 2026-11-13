# Codeskills

Codeskills is a collection of reusable skills. Install a skill for one selected host without installing an agent definition. The installer currently includes `backlog-triage`.

Each skill has a portable `SKILL.md` with `name` and `description` YAML frontmatter. Host-specific skill frontmatter stays separate when a target needs additional metadata.

## Install

```bash
./install.sh codeskills --agent opencode --format skill --global
./install.sh codeskills --agent claude --format skill --local /path/to/project
```

| Host | Global path | Local path | How to run |
| --- | --- | --- | --- |
| `opencode` | `~/.config/opencode/skills/` | `.opencode/skills/` | Ask OpenCode to use `backlog-triage` |
| `prompt` | `~/.config/codefactory/skills/` | `.codefactory/skills/` | Give the installed `SKILL.md` to your agent |
| `claude` | `~/.claude/skills/` | `.claude/skills/` | `/backlog-triage` |
| `cursor` | `~/.cursor/skills/` | `.cursor/skills/` | `/backlog-triage` in Agent chat |
| `copilot` | `~/.copilot/skills/` | `.github/skills/` | Ask Copilot to use `backlog-triage` |
| `codex` | `~/.agents/skills/` | `.agents/skills/` | Ask Codex to use `backlog-triage` |

Use `--yes` for a non-interactive install. The installer copies files, so rerun it after updating Codefactory. Restart the target host if it does not detect new skills automatically.

## Backlog Triage

`backlog-triage` reviews open project work and recommends the next suitable item for a developer or coding agent. It reads repository guidance first, asks before network access, and reports before making remote changes. It does not edit repository files or install an agent definition.

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
