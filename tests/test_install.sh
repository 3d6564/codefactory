#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

fail() { echo "FAIL: $1" >&2; exit 1; }
assert_file() { [[ -f "$1" ]] || fail "missing file $1"; }
assert_contains() { grep -qF -- "$2" "$1" || fail "$1 does not contain: $2"; }

assert_file "$PROJECT_DIR/components/codebrief/install.sh"
assert_file "$PROJECT_DIR/components/codereview/install.sh"
assert_contains "$PROJECT_DIR/README.md" 'pull request or merge request by URL or number'
assert_contains "$PROJECT_DIR/install.sh" 'pull request or merge request by URL or number'

if bash "$PROJECT_DIR/install.sh" >/dev/null 2>&1; then
    fail "missing component should fail"
fi

if bash "$PROJECT_DIR/install.sh" unknown --help >/dev/null 2>&1; then
    fail "unknown component should fail"
fi

mkdir -p "$TEMP_DIR/home" "$TEMP_DIR/project"

HOME="$TEMP_DIR/home" bash "$PROJECT_DIR/install.sh" \
    codebrief --agent prompt --global --yes >/dev/null
assert_file "$TEMP_DIR/home/.config/codebrief/codebrief.md"

bash "$PROJECT_DIR/install.sh" \
    codereview --agent prompt --local "$TEMP_DIR/project" --yes >/dev/null
assert_file "$TEMP_DIR/project/.codefactory/codereview.md"

echo "Codefactory dispatcher checks passed."
