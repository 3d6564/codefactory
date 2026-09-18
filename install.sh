#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    cat <<'EOF'
Usage: ./install.sh <component> [component options]

Components:
  codebrief   Create project-specific coding-agent instructions
  codereview  Review one pull request or merge request by URL or number
  codeskills  Install reusable coding-agent skills

Examples:
  ./install.sh codebrief --agent opencode --global
  ./install.sh codereview --agent claude --local /path/to/project
  ./install.sh codeskills --agent cursor --global
EOF
}

if [[ $# -eq 0 ]]; then
    usage >&2
    exit 1
fi

case "$1" in
    --help|-h)
        usage
        exit 0
        ;;
    codebrief|codereview|codeskills)
        component="$1"
        shift
        exec bash "$SCRIPT_DIR/components/$component/install.sh" "$@"
        ;;
    *)
        echo "Unknown component: $1" >&2
        usage >&2
        exit 1
        ;;
esac
