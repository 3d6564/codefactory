<p align="center">
  <img src="docs/art/codereview.svg" width="100%" alt="Codereview examines pull-request context and repository guidance, verifies findings, and reports before remote action.">
</p>

# Codereview

Codereview is Codefactory's report-first pull-request and merge-request
reviewer.

Before reviewing, Codereview checks whether `<!-- codebrief -->` is a standalone
comment on the first nonblank line after the top-level title in an applicable
`INSTRUCTIONS.md`. If not, it asks whether Codebrief has been used with Yes as
the recommended first choice. A marker in that placement or a confirmed answer
makes the applicable instruction files required review context.

## Install

Choose an agent. `--agent` is required with `--yes`. Without `--yes`, an
interactive terminal can pick one.

```bash
./install.sh codereview --agent opencode --global
./install.sh codereview --agent claude --local /path/to/project
./install.sh codereview --global
```

| Agent | Global path | Local path | How to run |
| --- | --- | --- | --- |
| `opencode` | `~/.config/opencode/agents/` and `commands/` | `.opencode/agents/` and `commands/` | Select `codereview` or run `/codereview 42` |
| `prompt` | `~/.config/codefactory/codereview.md` | `.codefactory/codereview.md` | Point any agent at the prompt |
| `claude` | `~/.claude/agents/` and `skills/` | `.claude/agents/` and `.claude/skills/` | `/codereview 42` or `claude --agent codereview` |
| `cursor` | `~/.cursor/skills/` | `.cursor/skills/` | `/codereview 42` in Agent chat |
| `copilot` | `~/.copilot/agents/` | `.github/agents/` | Select the custom agent |
| `codex` | `~/.codex/agents/` | `.codex/agents/` | Ask Codex to use `codereview` |

Use `--yes` for a non-interactive install. If Codefactory files already exist,
the installer asks before replacing them unless `--yes` is set. The installer
copies files, so rerun it after changing Codefactory itself. Restart the target
agent after install.

## Use

Run Codereview from the target repository and provide one provider URL or an
unambiguous pull-request or merge-request number:

```text
/codereview 42
/codereview https://gitlab.example.com/group/project/-/merge_requests/42
```

Codereview detects the repository provider and supports GitHub, GitLab, and
other configured providers through available tools. It asks before network
access, performs a read-only review by default, and reports findings with file
and line references. It makes provider review-workflow changes only when
explicitly requested. Never edit target repository files, create commits, push
code, modify branches, or merge the review item.

For a follow-up review, ask Codereview to recheck prior findings. It marks each
finding Fixed, Not fixed, or Cannot check from current code and test evidence.
It then previews only Fixed review comments and asks for approval before it
resolves them.

## Verify

```bash
bash components/codereview/tests/test_install.sh
```

The tests use temporary directories and do not change the user's agent
configuration.

## Contributing

See the repository [CONTRIBUTING.md](../../CONTRIBUTING.md).

## License

MIT License. See the repository [LICENSE](../../LICENSE).
