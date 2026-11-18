#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$ROOT/SKILL.md"

fail() { echo "FAIL: $1" >&2; exit 1; }
[[ -f "$SKILL" ]] || fail "missing standalone skill"
[[ -f "$ROOT/AGENTS.md" ]] || fail "missing scoped agent instructions"
[[ -f "$ROOT/README.md" ]] || fail "missing README"
grep -qF 'src="docs/art/codewriter.svg"' "$ROOT/README.md" || fail "missing README banner reference"
[[ -f "$ROOT/docs/art/codewriter.svg" ]] || fail "missing Codewriter banner"
for label in 'PLAN  /  IMPLEMENT  /  VERIFY' 'CODEWRITER' 'CODE + TESTS' 'aria-labelledby="title desc"'; do
    grep -qF -- "$label" "$ROOT/docs/art/codewriter.svg" || fail "missing banner label: $label"
done
for token in '<!-- codebrief -->' 'guided' 'focused' 'autonomous' 'memory' 'authorization' 'docstring' 'tests' 'trust' 'CodeReview' 'Do not' ; do
    grep -qiF -- "$token" "$SKILL" || fail "missing contract term: $token"
done
grep -q 'def read_records' "$SKILL" || fail "missing docstring example"
# Regression contract for #38. These checks guard prompt rules, not model execution.
for rule in \
    'Read the project `INSTRUCTIONS.md` directly' \
    'An unmarked parent file does not cancel a valid project marker.' \
    'Do not load or rerun CodeBrief merely because its marker is present.' \
    'A failed or unavailable check is not an absent marker.' \
    'Do not require `rg` or hide search errors' \
    'Ask only once for the current project' \
    'Carry this record into handoff and context-compaction summaries.' \
    'If the record is missing after resuming, reread the applicable instruction files before asking.' \
    'Recheck when the project or applicable guidance changes.'
do
    grep -qF -- "$rule" "$SKILL" || fail "missing CodeBrief confirmation rule: $rule"
done
echo "CodeWriter skill contract checks passed."
