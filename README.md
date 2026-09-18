<p align="center">
  <img src="docs/art/codefactory.svg" width="100%" alt="Codebrief prepares project instructions that guide better coding, then Codereview inspects the work before improved code leaves the factory.">
</p>

# Codefactory

Codefactory packages focused capabilities for coding agents. Each component is
independently installable and keeps its own prompt, adapters, documentation, and
tests.

## Components

| Component | Purpose | Documentation |
| --- | --- | --- |
| `codebrief` | Interviews a developer and writes project-specific `INSTRUCTIONS.md`. | [Codebrief](components/codebrief/README.md) |
| `codereview` | Reviews one pull request or merge request by URL or number and reports findings before remote changes. | [Codereview](components/codereview/README.md) |
| `codeskills` | Installs reusable coding-agent skills, starting with backlog triage. | [Codeskills](components/codeskills/README.md) |

## Install

Select a component, then pass its installer options:

```bash
./install.sh codebrief --agent opencode --global
./install.sh codereview --agent claude --local /path/to/project
./install.sh codeskills --agent cursor --global
```

Run `./install.sh --help` to list components. Each component installer can also
be run directly from its component directory.

## Verify

```bash
bash tests/test_install.sh
bash components/codebrief/tests/test_install.sh
bash components/codereview/tests/test_install.sh
bash components/codeskills/tests/test_install.sh
```

The tests use temporary directories and do not change the user's agent
configuration.

## Releases

Codefactory releases are versioned source snapshots. See [VERSIONS.md](VERSIONS.md)
for tag and release rules.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License. See [LICENSE](LICENSE).
