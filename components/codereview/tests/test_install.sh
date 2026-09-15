#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

fail() { echo "FAIL: $1" >&2; exit 1; }
assert_file() { [[ -f "$1" ]] || fail "missing file $1"; }
assert_contains() { grep -qF -- "$2" "$1" || fail "$1 does not contain: $2"; }

assert_marker_contract() {
    local placement='comment on the first nonblank line after the top-level title'
    local file normalized

    for file in "$PROJECT_DIR/prompt/codereview.md" \
        "$PROJECT_DIR/AGENTS.md" "$PROJECT_DIR/README.md"; do
        normalized="$(tr '\n\t' '  ' < "$file" | tr -s ' ')"
        [[ "$normalized" == *"$placement"* ]] \
            || fail "$file does not define the Codebrief marker placement"
    done
}

assert_no_code_changes_contract() {
    local rule='Never edit target repository files'
    local file normalized

    for file in "$PROJECT_DIR/prompt/codereview.md" \
        "$PROJECT_DIR/AGENTS.md" "$PROJECT_DIR/README.md"; do
        normalized="$(tr '\n\t' '  ' < "$file" | tr -s ' ')"
        [[ "$normalized" == *"$rule"* ]] \
            || fail "$file does not prohibit target repository edits"
    done
}

assert_file "$PROJECT_DIR/prompt/codereview.md"
assert_file "$PROJECT_DIR/packaging/opencode/agent-frontmatter.md"
assert_file "$PROJECT_DIR/packaging/opencode/command.md"
assert_contains "$PROJECT_DIR/prompt/codereview.md" 'For a more independent review'
assert_contains "$PROJECT_DIR/prompt/codereview.md" 'Has Codebrief been used'
assert_marker_contract
assert_contains "$PROJECT_DIR/prompt/codereview.md" 'Use these choices in this'
assert_contains "$PROJECT_DIR/prompt/codereview.md" '**Yes (Recommended)**, **No**, and **I don'
assert_contains "$PROJECT_DIR/prompt/codereview.md" 'GitHub, GitLab, and other'
assert_contains "$PROJECT_DIR/prompt/codereview.md" 'provider URL or a positive'
assert_contains "$PROJECT_DIR/prompt/codereview.md" 'Do not block a local review'
assert_contains "$PROJECT_DIR/prompt/codereview.md" 'Follow-up Verification'
assert_contains "$PROJECT_DIR/prompt/codereview.md" 'Fixed**, **Not fixed**, or **Cannot check'
assert_contains "$PROJECT_DIR/prompt/codereview.md" 'Network approval does not authorize review-comment resolution'
assert_contains "$PROJECT_DIR/prompt/codereview.md" 'Do not resolve unrelated, outdated, informational, or duplicate review'
assert_no_code_changes_contract

if bash "$PROJECT_DIR/install.sh" --local >/dev/null 2>&1; then
    fail "--local without a path should fail"
fi

if bash "$PROJECT_DIR/install.sh" --global --yes >/dev/null 2>&1; then
    fail "--yes without --agent should fail"
fi

if bash "$PROJECT_DIR/install.sh" --agent unknown --global --yes >/dev/null 2>&1; then
    fail "unknown --agent should fail"
fi

mkdir -p "$TEMP_DIR/home" "$TEMP_DIR/project"

HOME="$TEMP_DIR/home" bash "$PROJECT_DIR/install.sh" --agent opencode --global --yes >/dev/null
assert_file "$TEMP_DIR/home/.config/opencode/agents/codereview.md"
assert_file "$TEMP_DIR/home/.config/opencode/commands/codereview.md"
assert_contains "$TEMP_DIR/home/.config/opencode/agents/codereview.md" 'edit: deny'

bash "$PROJECT_DIR/install.sh" --agent claude --local "$TEMP_DIR/project" --yes >/dev/null
assert_file "$TEMP_DIR/project/.claude/agents/codereview.md"
assert_file "$TEMP_DIR/project/.claude/skills/codereview/SKILL.md"

bash "$PROJECT_DIR/install.sh" --agent cursor --local "$TEMP_DIR/project" --yes >/dev/null
assert_file "$TEMP_DIR/project/.cursor/skills/codereview/SKILL.md"

bash "$PROJECT_DIR/install.sh" --agent copilot --local "$TEMP_DIR/project" --yes >/dev/null
assert_file "$TEMP_DIR/project/.github/agents/codereview.agent.md"

HOME="$TEMP_DIR/home" bash "$PROJECT_DIR/install.sh" --agent codex --global --yes >/dev/null
assert_file "$TEMP_DIR/home/.codex/agents/codereview.toml"
assert_contains "$TEMP_DIR/home/.codex/agents/codereview.toml" 'sandbox_mode = "read-only"'

HOME="$TEMP_DIR/home" bash "$PROJECT_DIR/install.sh" --agent prompt --global --yes >/dev/null
assert_file "$TEMP_DIR/home/.config/codefactory/codereview.md"

bash "$PROJECT_DIR/install.sh" --agent opencode --local "$TEMP_DIR/project" --yes >/dev/null
assert_file "$TEMP_DIR/project/.opencode/agents/codereview.md"
assert_file "$TEMP_DIR/project/.opencode/commands/codereview.md"
assert_contains "$TEMP_DIR/project/.opencode/agents/codereview.md" "For a more independent review"
assert_contains "$TEMP_DIR/project/.opencode/agents/codereview.md" "Has Codebrief been used"
assert_contains "$TEMP_DIR/project/.opencode/commands/codereview.md" 'reference `$ARGUMENTS`'

mkdir -p "$TEMP_DIR/refusal-home/.config/opencode/agents"
printf 'old agent\n' > "$TEMP_DIR/refusal-home/.config/opencode/agents/codereview.md"
if printf 'n\n' | HOME="$TEMP_DIR/refusal-home" \
    bash "$PROJECT_DIR/install.sh" --agent opencode --global >/dev/null 2>&1; then
    fail "declining replacement should return a failure"
fi
[[ ! -e "$TEMP_DIR/refusal-home/.config/opencode/commands/codereview.md" ]] \
    || fail "declined install should not create a command"

mkdir -p "$TEMP_DIR/conflict-home/.config/opencode/agent"
printf 'competing agent\n' > "$TEMP_DIR/conflict-home/.config/opencode/agent/codereview.md"
if HOME="$TEMP_DIR/conflict-home" \
    bash "$PROJECT_DIR/install.sh" --agent opencode --global --yes >/dev/null 2>&1; then
    fail "alternate agent path should block installation"
fi

echo "Codefactory installer checks passed."
