#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

fail() {
    echo "FAIL: $1" >&2
    exit 1
}

assert_file() {
    [[ -f "$1" ]] || fail "missing file $1"
}

assert_contains() {
    grep -qF -- "$2" "$1" || fail "$1 does not contain: $2"
}

assert_marker_follows_title() {
    local file="$1"
    local found_title=false

    while IFS= read -r line; do
        if [[ "$found_title" == false ]]; then
            [[ "$line" == "# INSTRUCTIONS.md" ]] && found_title=true
            continue
        fi
        [[ -z "$line" ]] && continue
        [[ "$line" == '<!-- codebrief -->' ]] \
            || fail "$file does not place the Codebrief marker after the title"
        return
    done < "$file"

    fail "$file does not contain the INSTRUCTIONS.md marker example"
}

assert_file "$PROJECT_DIR/prompt/codebrief.md"
assert_file "$PROJECT_DIR/packaging/opencode/agent-frontmatter.md"
assert_file "$PROJECT_DIR/packaging/opencode/command.md"
assert_file "$PROJECT_DIR/docs/INTERVIEW_DESIGN.md"
assert_file "$PROJECT_DIR/docs/art/codebrief.svg"

assert_contains "$PROJECT_DIR/prompt/codebrief.md" "Collaboration, issues, and version control"
assert_contains "$PROJECT_DIR/prompt/codebrief.md" "Hard-rule follow-up"
assert_contains "$PROJECT_DIR/prompt/codebrief.md" "Scoped-reference follow-up"
assert_contains "$PROJECT_DIR/prompt/codebrief.md" "should explicitly reference a shared"
assert_contains "$PROJECT_DIR/prompt/codebrief.md" "record of prior confirmed decisions"
assert_contains "$PROJECT_DIR/prompt/codebrief.md" "Do not repeat questions the existing file already answers"
assert_contains "$PROJECT_DIR/prompt/codebrief.md" "the missing file as an existing project rule."
assert_contains "$PROJECT_DIR/prompt/codebrief.md" "Treat these reference edits as a separate approved action."
assert_contains "$PROJECT_DIR/prompt/codebrief.md" "list the exact files that would"
assert_marker_follows_title "$PROJECT_DIR/prompt/codebrief.md"
assert_contains "$PROJECT_DIR/prompt/codebrief.md" 'standalone comment on the first'
assert_contains "$PROJECT_DIR/docs/INTERVIEW_DESIGN.md" "### 7. Incremental refresh"
assert_contains "$PROJECT_DIR/docs/INTERVIEW_DESIGN.md" '<!-- codebrief -->'
assert_contains "$PROJECT_DIR/prompt/codebrief.md" "https://github.com/3d6564/codefactory"
assert_contains "$PROJECT_DIR/prompt/codebrief.md" "If the host has a choice or question tool"
assert_contains "$PROJECT_DIR/prompt/codebrief.md" 'instead of "canonical"'
assert_contains "$PROJECT_DIR/prompt/codebrief.md" 'GitLab Issues and Boards, Jira'
assert_contains "$PROJECT_DIR/prompt/codebrief.md" 'Writing `CONTRIBUTING.md`'
assert_contains "$PROJECT_DIR/prompt/codebrief.md" 'In Quick mode, still choose the provider route'
assert_contains "$PROJECT_DIR/prompt/codebrief.md" 'always ask whether to preview shared'
assert_contains "$PROJECT_DIR/prompt/codebrief.md" 'only to guidance files that were approved'
assert_contains "$PROJECT_DIR/prompt/codebrief.md" 'priority, effort, or category labels'
assert_contains "$PROJECT_DIR/prompt/codebrief.md" 'T-shirt sizes'
assert_contains "$PROJECT_DIR/prompt/codebrief.md" 'When the user confirmed a classification scheme'
assert_contains "$PROJECT_DIR/prompt/codebrief.md" 'tags, or equivalent mechanism'
assert_contains "$PROJECT_DIR/prompt/codebrief.md" 'Include classification only when the'
assert_contains "$PROJECT_DIR/prompt/codebrief.md" "provider's pull request or merge request"
assert_contains "$PROJECT_DIR/packaging/opencode/agent-frontmatter.md" "mode: primary"
assert_contains "$PROJECT_DIR/packaging/opencode/agent-frontmatter.md" '"*": deny'
assert_contains "$PROJECT_DIR/packaging/opencode/agent-frontmatter.md" '"*.env": deny'
assert_contains "$PROJECT_DIR/packaging/opencode/agent-frontmatter.md" "task: deny"
assert_contains "$PROJECT_DIR/packaging/opencode/command.md" 'User focus or target: `$ARGUMENTS`'
assert_contains "$PROJECT_DIR/docs/INTERVIEW_DESIGN.md" "collaboration and version control"
assert_contains "$PROJECT_DIR/docs/INTERVIEW_DESIGN.md" "should explicitly"
assert_contains "$PROJECT_DIR/docs/INTERVIEW_DESIGN.md" "Incremental refresh"
assert_contains "$PROJECT_DIR/README.md" 'after updating Codefactory or changing Codebrief'

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
OPENCODE_ROOT="$TEMP_DIR/home/.config/opencode"
assert_file "$OPENCODE_ROOT/agents/codebrief.md"
assert_file "$OPENCODE_ROOT/commands/codebrief.md"
assert_contains "$OPENCODE_ROOT/agents/codebrief.md" "mode: primary"
assert_contains "$OPENCODE_ROOT/agents/codebrief.md" "# Codebrief"
cmp -s "$PROJECT_DIR/packaging/opencode/command.md" "$OPENCODE_ROOT/commands/codebrief.md" \
    || fail "opencode command differs from packaging"

HOME="$TEMP_DIR/home" bash "$PROJECT_DIR/install.sh" --agent opencode --global --yes >/dev/null

bash "$PROJECT_DIR/install.sh" --agent opencode --local "$TEMP_DIR/project" --yes >/dev/null
assert_file "$TEMP_DIR/project/.opencode/agents/codebrief.md"
assert_file "$TEMP_DIR/project/.opencode/commands/codebrief.md"

HOME="$TEMP_DIR/home" bash "$PROJECT_DIR/install.sh" --agent prompt --global --yes >/dev/null
assert_file "$TEMP_DIR/home/.config/codebrief/codebrief.md"
cmp -s "$PROJECT_DIR/prompt/codebrief.md" "$TEMP_DIR/home/.config/codebrief/codebrief.md" \
    || fail "prompt install differs from source"

bash "$PROJECT_DIR/install.sh" --agent claude --local "$TEMP_DIR/project" --yes >/dev/null
assert_file "$TEMP_DIR/project/.claude/agents/codebrief.md"
assert_file "$TEMP_DIR/project/.claude/skills/codebrief/SKILL.md"
assert_contains "$TEMP_DIR/project/.claude/agents/codebrief.md" "name: codebrief"
assert_contains "$TEMP_DIR/project/.claude/skills/codebrief/SKILL.md" "disable-model-invocation: true"
assert_contains "$TEMP_DIR/project/.claude/skills/codebrief/SKILL.md" "# Codebrief"

bash "$PROJECT_DIR/install.sh" --agent cursor --local "$TEMP_DIR/project" --yes >/dev/null
assert_file "$TEMP_DIR/project/.cursor/skills/codebrief/SKILL.md"
assert_contains "$TEMP_DIR/project/.cursor/skills/codebrief/SKILL.md" "disable-model-invocation: true"

HOME="$TEMP_DIR/home" bash "$PROJECT_DIR/install.sh" --agent copilot --global --yes >/dev/null
assert_file "$TEMP_DIR/home/.copilot/agents/codebrief.agent.md"
assert_contains "$TEMP_DIR/home/.copilot/agents/codebrief.agent.md" "name: codebrief"

bash "$PROJECT_DIR/install.sh" --agent copilot --local "$TEMP_DIR/project" --yes >/dev/null
assert_file "$TEMP_DIR/project/.github/agents/codebrief.agent.md"

HOME="$TEMP_DIR/home" bash "$PROJECT_DIR/install.sh" --agent codex --global --yes >/dev/null
assert_file "$TEMP_DIR/home/.codex/agents/codebrief.toml"
assert_contains "$TEMP_DIR/home/.codex/agents/codebrief.toml" 'name = "codebrief"'
assert_contains "$TEMP_DIR/home/.codex/agents/codebrief.toml" "developer_instructions"

mkdir -p "$TEMP_DIR/refusal-home/.config/opencode/agents"
printf 'old agent\n' > "$TEMP_DIR/refusal-home/.config/opencode/agents/codebrief.md"
if printf 'n\n' | HOME="$TEMP_DIR/refusal-home" \
    bash "$PROJECT_DIR/install.sh" --agent opencode --global >/dev/null 2>&1; then
    fail "declining replacement should return a failure"
fi
[[ ! -e "$TEMP_DIR/refusal-home/.config/opencode/commands/codebrief.md" ]] \
    || fail "declined install should not create a command"

mkdir -p "$TEMP_DIR/conflict-home/.config/opencode/agent"
printf 'competing agent\n' > "$TEMP_DIR/conflict-home/.config/opencode/agent/codebrief.md"
if HOME="$TEMP_DIR/conflict-home" \
    bash "$PROJECT_DIR/install.sh" --agent opencode --global --yes >/dev/null 2>&1; then
    fail "alternate agent path should block installation"
fi

if command -v opencode >/dev/null 2>&1; then
    HOME="$TEMP_DIR/home" opencode --pure debug agent codebrief >/dev/null
fi

echo "Codebrief scaffold checks passed."
