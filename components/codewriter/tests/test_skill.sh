#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$ROOT/SKILL.md"

fail() { echo "FAIL: $1" >&2; exit 1; }
[[ -f "$SKILL" ]] || fail "missing standalone skill"
[[ -f "$ROOT/AGENTS.md" ]] || fail "missing scoped agent instructions"
[[ -f "$ROOT/README.md" ]] || fail "missing README"
for token in '<!-- codebrief -->' 'guided' 'focused' 'autonomous' 'memory' 'authorization' 'docstring' 'tests' 'trust' 'CodeReview' 'Do not' ; do
    grep -qiF -- "$token" "$SKILL" || fail "missing contract term: $token"
done
grep -q 'def read_records' "$SKILL" || fail "missing docstring example"
echo "CodeWriter skill contract checks passed."
