#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
fail() { echo "FAIL: $1" >&2; exit 1; }
assert_file() { [[ -f "$1" ]] || fail "Missing $1"; }
assert_has() { grep -qF -- "$2" "$1" || fail "Missing $2 in $1"; }

bash "$ROOT/components/codewriter/tests/test_skill.sh"
mkdir -p "$TMP/home" "$TMP/project"

# All supported agents can install the standalone skill without creating agents.
for agent in opencode claude cursor copilot codex prompt; do
  dest="$TMP/project"
  case "$agent" in
    opencode) dest="$dest/.opencode/skills/codewriter/SKILL.md"; other="$TMP/project/.opencode/agents/codewriter.md" ;;
    claude) dest="$dest/.claude/skills/codewriter/SKILL.md"; other="$TMP/project/.claude/agents/codewriter.md" ;;
    cursor) dest="$dest/.cursor/skills/codewriter/SKILL.md"; other="$TMP/project/.cursor/agents/codewriter.md" ;;
    copilot) dest="$dest/.github/skills/codewriter/SKILL.md"; other="$TMP/project/.github/agents/codewriter.agent.md" ;;
    codex) dest="$dest/.agents/skills/codewriter/SKILL.md"; other="$TMP/project/.codex/agents/codewriter.toml" ;;
    prompt) dest="$dest/.codefactory/skills/codewriter/SKILL.md"; other="$TMP/project/.codefactory/codewriter.md" ;;
  esac
  bash "$ROOT/install.sh" codewriter --agent "$agent" --format skill --local "$TMP/project" --yes
  assert_file "$dest"
  assert_has "$dest" "# CodeWriter"
  [[ ! -e "$other" ]] || fail "Skill-only installation created agent: $other"
done

# Agent packaging uses the same core source, with host-specific metadata.
bash "$ROOT/install.sh" codewriter --agent opencode --format both --local "$TMP/project" --yes
assert_file "$TMP/project/.opencode/agents/codewriter.md"
assert_file "$TMP/project/.opencode/commands/codewriter.md"
assert_has "$TMP/project/.opencode/agents/codewriter.md" "# CodeWriter"
assert_has "$TMP/project/.opencode/agents/codewriter.md" "mode: primary"
bash "$ROOT/install.sh" codewriter --agent claude --format both --local "$TMP/project" --yes
assert_file "$TMP/project/.claude/agents/codewriter.md"
bash "$ROOT/install.sh" codewriter --agent copilot --format both --local "$TMP/project" --yes
assert_file "$TMP/project/.github/agents/codewriter.agent.md"
bash "$ROOT/install.sh" codewriter --agent codex --format both --local "$TMP/project" --yes
assert_file "$TMP/project/.codex/agents/codewriter.toml"
assert_has "$TMP/project/.codex/agents/codewriter.toml" "developer_instructions"
if command -v python3 >/dev/null 2>&1; then
  python3 - "$TMP/project/.codex/agents/codewriter.toml" <<'PY'
import pathlib
import sys
import tomllib

config = tomllib.loads(pathlib.Path(sys.argv[1]).read_text())
assert config["name"] == "codewriter"
assert "def read_records" in config["developer_instructions"]
assert '"""Stream validated records' in config["developer_instructions"]
PY
fi
bash "$ROOT/install.sh" codewriter --agent prompt --format agent --local "$TMP/project" --yes
assert_file "$TMP/project/.codefactory/codewriter.md"

# Existing components provide skill-only packages without agent definitions.
bash "$ROOT/install.sh" codebrief,codereview --agent opencode --format skill --local "$TMP/project" --yes
assert_file "$TMP/project/.opencode/skills/codebrief/SKILL.md"
assert_file "$TMP/project/.opencode/skills/codereview/SKILL.md"
[[ ! -e "$TMP/project/.opencode/agents/codebrief.md" ]] || fail "CodeBrief skill created an agent"
[[ ! -e "$TMP/project/.opencode/agents/codereview.md" ]] || fail "CodeReview skill created an agent"

# A suite install produces the three agents and the standalone Codeskills skill.
HOME="$TMP/home" bash "$ROOT/install.sh" all --agent claude --format both --global --yes
for name in codebrief codewriter codereview; do
  assert_file "$TMP/home/.claude/skills/$name/SKILL.md"
  assert_file "$TMP/home/.claude/agents/$name.md"
done
assert_file "$TMP/home/.claude/skills/backlog-triage/SKILL.md"
[[ ! -e "$TMP/home/.claude/agents/backlog-triage.md" ]] || fail "Codeskills created an agent"

# Reject malformed arguments and protect existing files.
for invalid in unknown "codewriter,unknown" "codewriter,codewriter"; do
  if bash "$ROOT/install.sh" "$invalid" --agent opencode --format skill --local "$TMP/project" --yes >/dev/null 2>&1; then
    fail "Accepted invalid component selection: $invalid"
  fi
done
if bash "$ROOT/install.sh" codewriter --agent unknown --format skill --local "$TMP/project" --yes >/dev/null 2>&1; then fail "Accepted invalid agent"; fi
if bash "$ROOT/install.sh" codewriter --agent opencode --format unknown --local "$TMP/project" --yes >/dev/null 2>&1; then fail "Accepted invalid format"; fi
if bash "$ROOT/install.sh" codewriter --agent opencode --format skill --local "$TMP/missing" --yes >/dev/null 2>&1; then fail "Accepted missing project"; fi

printf "user data\n" > "$TMP/project/.opencode/skills/codewriter/SKILL.md"
if printf "n\n" | bash "$ROOT/install.sh" codewriter --agent opencode --format skill --local "$TMP/project" >/dev/null 2>&1; then fail "Overwrote without approval"; fi
assert_has "$TMP/project/.opencode/skills/codewriter/SKILL.md" "user data"

rm -f "$TMP/project/.opencode/skills/codewriter/SKILL.md"
ln -s "$TMP/project/.claude/skills/codewriter/SKILL.md" "$TMP/project/.opencode/skills/codewriter/SKILL.md"
if bash "$ROOT/install.sh" codewriter --agent opencode --format skill --local "$TMP/project" --yes >/dev/null 2>&1; then fail "Followed symlink"; fi
echo "CodeWriter installer checks passed."
