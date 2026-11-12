#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage: ./install.sh <component|all|component,component> --agent NAME [--format skill|agent|both] [--global|--local DIR] [--yes]

Components: codebrief, codewriter, codereview
Formats: agent (default), skill, both
Agents: opencode, prompt, claude, cursor, copilot, codex
Examples:
  ./install.sh codewriter --agent opencode --global
  ./install.sh codewriter --agent claude --format skill --local .
  ./install.sh all --agent opencode --format both --local .
  ./install.sh codebrief,codewriter --agent codex --format skill --global
EOF
}

if (($# == 0)); then usage >&2; exit 1; fi
case "$1" in --help|-h) usage; exit 0 ;; esac
selection="$1"; shift
if [[ "$selection" == all ]]; then selection="codebrief,codewriter,codereview"; fi
IFS=',' read -r -a components <<< "$selection"
[[ "${#components[@]}" -gt 0 ]] || { usage >&2; exit 1; }
declare -A seen=()
for component in "${components[@]}"; do
  case "$component" in codebrief|codewriter|codereview) ;; *) echo "Unknown component: $component" >&2; exit 1 ;; esac
  [[ -z "${seen[$component]:-}" ]] || { echo "Duplicate component: $component" >&2; exit 1; }
  seen["$component"]=1
done

# Verify arguments before installing any component.
agent=""
format=agent
args=("$@")
for ((i=0; i<${#args[@]}; i++)); do
  case "${args[i]}" in
    --agent|--format|--local)
      ((i + 1 < ${#args[@]})) || { echo "Missing value: ${args[i]}" >&2; exit 1; }
      case "${args[i]}" in --agent) agent="${args[i+1]}" ;; --format) format="${args[i+1]}" ;; esac
      ((i+=1)) ;;
    --global|--yes|-y) ;;
    *) echo "Unknown option: ${args[i]}" >&2; exit 1 ;;
  esac
done
case "$agent" in opencode|prompt|claude|cursor|copilot|codex) ;;
  "") if [[ " $* " == *" --yes "* || " $* " == *" -y "* || ! -t 0 ]]; then
        echo "--agent is required in non-interactive mode." >&2; exit 1;
      fi ;;
  *) echo "Unknown agent: $agent" >&2; exit 1 ;;
esac
case "$format" in skill|agent|both) ;; *) echo "Unknown format: $format" >&2; exit 1 ;; esac

for component in "${components[@]}"; do
  bash "$ROOT/components/install-capability.sh" "$component" "$@"
done
