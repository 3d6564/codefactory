#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(cd "$PROJECT_DIR/../.." && pwd)"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

fail() { echo "FAIL: $1" >&2; exit 1; }
assert_file() { [[ -f "$1" ]] || fail "missing file $1"; }
assert_contains() { grep -qF -- "$2" "$1" || fail "$1 does not contain: $2"; }

assert_file "$PROJECT_DIR/skills/backlog-triage/SKILL.md"
assert_contains "$PROJECT_DIR/skills/backlog-triage/SKILL.md" 'name: backlog-triage'
assert_contains "$PROJECT_DIR/skills/backlog-triage/SKILL.md" 'Has Codebrief been used for this project?'
assert_contains "$PROJECT_DIR/skills/backlog-triage/SKILL.md" 'Triage is read-only by default.'
assert_contains "$PROJECT_DIR/skills/backlog-triage/SKILL.md" 'show the exact change and ask for explicit approval'

bash "$ROOT/install.sh" codeskills --agent opencode --format agent --local "$TEMP_DIR" --yes >/dev/null 2>&1
[[ ! -e "$TEMP_DIR/.opencode/agents/backlog-triage.md" ]] || fail "agent format created a Codeskills agent"

mkdir -p "$TEMP_DIR/project"
for agent in opencode prompt claude cursor copilot codex; do
    case "$agent" in
        opencode) dest="$TEMP_DIR/project/.opencode/skills/backlog-triage/SKILL.md"; other="$TEMP_DIR/project/.opencode/agents/backlog-triage.md" ;;
        prompt) dest="$TEMP_DIR/project/.codefactory/skills/backlog-triage/SKILL.md"; other="$TEMP_DIR/project/.codefactory/agents/backlog-triage.md" ;;
        claude) dest="$TEMP_DIR/project/.claude/skills/backlog-triage/SKILL.md"; other="$TEMP_DIR/project/.claude/agents/backlog-triage.md" ;;
        cursor) dest="$TEMP_DIR/project/.cursor/skills/backlog-triage/SKILL.md"; other="$TEMP_DIR/project/.cursor/agents/backlog-triage.md" ;;
        copilot) dest="$TEMP_DIR/project/.github/skills/backlog-triage/SKILL.md"; other="$TEMP_DIR/project/.github/agents/backlog-triage.agent.md" ;;
        codex) dest="$TEMP_DIR/project/.agents/skills/backlog-triage/SKILL.md"; other="$TEMP_DIR/project/.codex/agents/backlog-triage.toml" ;;
    esac
    bash "$ROOT/install.sh" codeskills --agent "$agent" --format skill --local "$TEMP_DIR/project" --yes >/dev/null
    assert_file "$dest"
    assert_contains "$dest" '# Backlog Triage'
    [[ ! -e "$other" ]] || fail "skill-only install created agent: $other"
done

HOME="$TEMP_DIR/home" bash "$ROOT/install.sh" codeskills --agent prompt --global --yes >/dev/null
assert_file "$TEMP_DIR/home/.config/codefactory/skills/backlog-triage/SKILL.md"

echo "Codeskills installer checks passed."
