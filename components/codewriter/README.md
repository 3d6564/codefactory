# CodeWriter

CodeWriter implements changes under the project's instructions. Its [SKILL.md](SKILL.md) defines readable code, efficient memory use, input and authorization safeguards, focused tests, and concise searchable docstrings.

CodeWriter reads project and scoped instruction files directly. A valid CodeBrief marker or user confirmation is enough to follow the existing decisions; neither starts a new interview. An unmarked parent file does not override a marked project file, and a failed file check does not mean the marker is absent.

When confirmation is missing, CodeWriter recommends CodeBrief and asks once whether to continue with existing guidance. It carries the project-specific answer and checked paths into handoff and context-compaction summaries. After resuming without that record, it rereads the guidance before asking again. It rechecks when the project or applicable guidance changes.

## Install

```bash
./install.sh codewriter --agent opencode --format agent --global
./install.sh codewriter --agent claude --format skill --local .
./install.sh codewriter --agent codex --format both --local .
```

Use the repository-root installer or `components/codewriter/install.sh` with the same options. Skill-only mode never installs agent definitions. The `prompt` target produces a portable instruction file, and Cursor uses the skill as its invocation surface.

## Use

Choose **guided** (default), **focused**, or **autonomous** behavior. All modes obey project permissions and approval limits. Run CodeReview separately when an independent review is useful.

## Verify

```bash
bash components/codewriter/tests/test_skill.sh
bash components/codewriter/tests/test_install.sh
```

See the root [README](../../README.md) and [CONTRIBUTING.md](../../CONTRIBUTING.md). MIT License.

The offline checks verify prompt requirements and installed copies. They do not run a model or prove its behavior after context compaction.
