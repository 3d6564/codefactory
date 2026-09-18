#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

fail() { echo "FAIL: $1" >&2; exit 1; }
assert_file() { [[ -f "$1" ]] || fail "missing file $1"; }
assert_contains() { grep -qF -- "$2" "$1" || fail "$1 does not contain: $2"; }

assert_file "$PROJECT_DIR/skills/backlog-triage/prompt.md"
assert_file "$PROJECT_DIR/skills/backlog-triage/packaging/opencode/agent-frontmatter.md"
assert_file "$PROJECT_DIR/skills/backlog-triage/packaging/opencode/command.md"
assert_contains "$PROJECT_DIR/skills/backlog-triage/prompt.md" 'Has Codebrief been used for this project?'
assert_contains "$PROJECT_DIR/skills/backlog-triage/prompt.md" 'Triage is read-only by default.'
assert_contains "$PROJECT_DIR/skills/backlog-triage/prompt.md" 'show the exact change and ask for explicit approval'

if bash "$PROJECT_DIR/install.sh" --global --yes >/dev/null 2>&1; then fail "--yes without --agent should fail"; fi

mkdir -p "$TEMP_DIR/home" "$TEMP_DIR/project"

HOME="$TEMP_DIR/home" bash "$PROJECT_DIR/install.sh" --agent opencode --global --yes >/dev/null
assert_file "$TEMP_DIR/home/.config/opencode/agents/backlog-triage.md"
assert_file "$TEMP_DIR/home/.config/opencode/commands/backlog-triage.md"
assert_contains "$TEMP_DIR/home/.config/opencode/agents/backlog-triage.md" 'edit: deny'

HOME="$TEMP_DIR/home" bash "$PROJECT_DIR/install.sh" --agent prompt --global --yes >/dev/null
assert_file "$TEMP_DIR/home/.config/codefactory/codeskills/backlog-triage.md"

bash "$PROJECT_DIR/install.sh" --agent claude --local "$TEMP_DIR/project" --yes >/dev/null
assert_file "$TEMP_DIR/project/.claude/agents/backlog-triage.md"
assert_file "$TEMP_DIR/project/.claude/skills/backlog-triage/SKILL.md"

bash "$PROJECT_DIR/install.sh" --agent cursor --local "$TEMP_DIR/project" --yes >/dev/null
assert_file "$TEMP_DIR/project/.cursor/skills/backlog-triage/SKILL.md"

bash "$PROJECT_DIR/install.sh" --agent copilot --local "$TEMP_DIR/project" --yes >/dev/null
assert_file "$TEMP_DIR/project/.github/agents/backlog-triage.agent.md"

HOME="$TEMP_DIR/home" bash "$PROJECT_DIR/install.sh" --agent codex --global --yes >/dev/null
assert_file "$TEMP_DIR/home/.codex/agents/backlog-triage.toml"
assert_contains "$TEMP_DIR/home/.codex/agents/backlog-triage.toml" 'sandbox_mode = "read-only"'

if command -v opencode >/dev/null 2>&1; then
    HOME="$TEMP_DIR/home" opencode --pure debug agent backlog-triage >/dev/null
fi

echo "Codeskills installer checks passed."
