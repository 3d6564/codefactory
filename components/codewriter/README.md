# CodeWriter

CodeWriter implements changes under the project's instructions. Its [SKILL.md](SKILL.md) defines readable code, efficient memory use, input and authorization safeguards, focused tests, and concise searchable docstrings.

CodeWriter reads the project rules first. It verifies the CodeBrief marker in `INSTRUCTIONS.md` and follows CodeBrief decisions. When the marker is absent, CodeWriter recommends CodeBrief and asks whether to continue with the existing guidance.

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
