#!/usr/bin/env bash
set -euo pipefail
BASE="$(cd "$(dirname "$0")" && pwd)"
NAME="$1"; shift
case "$NAME" in codebrief|codewriter|codereview|codeskills) ;; *) exit 1 ;; esac
AGENT=""; FORMAT=auto; TARGET=global; DIR=""; YES=0
while (($#)); do
 case "$1" in
 --agent) AGENT="$2"; shift 2 ;;
 --format) FORMAT="$2"; shift 2 ;;
 --global) TARGET=global; shift ;;
 --local) TARGET=local; DIR="$2"; shift 2 ;;
 --yes|-y) YES=1; shift ;;
  --help|-h) echo "Usage: --agent NAME [--format auto|skill|agent|both] [--global|--local DIR] [--yes]"; exit 0 ;;
 *) echo "Unknown option: $1" >&2; exit 1 ;;
 esac
done
 case "$FORMAT" in auto|skill|agent|both) ;; *) exit 1 ;; esac
case "$AGENT" in opencode|prompt|claude|cursor|copilot|codex) ;; *) echo "Unknown or missing agent: $AGENT" >&2; exit 1 ;; esac
if [[ "$TARGET" == local ]]; then
 [[ -d "$DIR" ]] || { echo "Missing project: $DIR" >&2; exit 1; }
 DIR="$(cd "$DIR" && pwd)"
else DIR="$HOME"; fi
SOURCE="$BASE/$NAME/prompt/$NAME.md"
SKILL_NAME="$NAME"
SKILL_PACKAGING="$BASE/$NAME/packaging"
case "$NAME" in
 codewriter) SOURCE="$BASE/codewriter/SKILL.md" ;;
 codeskills)
  SKILL_NAME=backlog-triage
  SOURCE="$BASE/codeskills/skills/$SKILL_NAME/SKILL.md"
  SKILL_PACKAGING="$BASE/codeskills/skills/$SKILL_NAME/packaging"
  ;;
esac
[[ -f "$SOURCE" ]] || exit 1
write() {
 local from="$1" to="$2" answer
 [[ ! -L "$to" ]] || { echo "Symlink refused: $to" >&2; return 1; }
 if [[ -f "$to" ]] && cmp -s "$from" "$to"; then return; fi
 if [[ -e "$to" ]] && (( ! YES )); then
  read -rp "Replace $to? [y/N] " answer || return 1
  [[ "$answer" == y || "$answer" == yes ]] || return 1
 fi
 mkdir -p "$(dirname "$to")"
 install -m 0644 "$from" "$to"
}
compose() {
 local tmp; tmp="$(mktemp)"
 { cat "$1"; echo; cat "$SOURCE"; } > "$tmp"
 if write "$tmp" "$2"; then rm -f "$tmp"; else rm -f "$tmp"; return 1; fi
}
skill() {
  local root front tmp
 case "$AGENT" in
 opencode) root="$DIR/.opencode"; [[ "$TARGET" == global ]] && root="$HOME/.config/opencode" ;;
 claude) root="$DIR/.claude" ;;
 cursor) root="$DIR/.cursor" ;;
 copilot) root="$DIR/.github"; [[ "$TARGET" == global ]] && root="$HOME/.copilot" ;;
 codex) root="$DIR/.agents" ;;
 prompt) root="$DIR/.codefactory"; [[ "$TARGET" == global ]] && root="$HOME/.config/codefactory" ;;
 esac
  front="$SKILL_PACKAGING/$AGENT/skill-frontmatter.md"
  if [[ -f "$front" ]]; then
   tmp="$(mktemp)"
   { cat "$front"; echo; skill_body; } > "$tmp"
   if write "$tmp" "$root/skills/$SKILL_NAME/SKILL.md"; then rm -f "$tmp"; else rm -f "$tmp"; return 1; fi
  elif [[ "$AGENT" == prompt ]]; then write "$SOURCE" "$root/skills/$SKILL_NAME/SKILL.md"
  else
   tmp="$(mktemp)"
   { printf '%s\n' '---' "name: $SKILL_NAME" "description: Use the $SKILL_NAME coding skill." '---'; echo; skill_body; } > "$tmp"
   if write "$tmp" "$root/skills/$SKILL_NAME/SKILL.md"; then rm -f "$tmp"; else rm -f "$tmp"; return 1; fi
  fi
}
skill_body() {
 if [[ "$NAME" == codeskills ]]; then
  awk 'BEGIN { delimiters=0 } /^---$/ { delimiters++; if (delimiters == 2) { body=1; next } } body { print }' "$SOURCE"
 else
  cat "$SOURCE"
 fi
}
writer_agent() {
 local root tmp
 case "$AGENT" in
 opencode)
  root="$DIR/.opencode"; [[ "$TARGET" == global ]] && root="$HOME/.config/opencode"
  [[ ! -e "$root/agent/codewriter.md" && ! -e "$root/command/codewriter.md" ]] || { echo "Competing CodeWriter agent definition" >&2; return 1; }
  compose "$BASE/codewriter/packaging/opencode/agent-frontmatter.md" "$root/agents/codewriter.md"
  write "$BASE/codewriter/packaging/opencode/command.md" "$root/commands/codewriter.md" ;;
 claude)
  root="$DIR/.claude"
  compose "$BASE/codewriter/packaging/claude/agent-frontmatter.md" "$root/agents/codewriter.md" ;;
 copilot)
  root="$DIR/.github"; [[ "$TARGET" == global ]] && root="$HOME/.copilot"
  compose "$BASE/codewriter/packaging/copilot/agent-frontmatter.md" "$root/agents/codewriter.agent.md" ;;
 codex)
  root="$DIR/.codex"
  tmp="$(mktemp)"
  { printf '%s\n' 'name = "codewriter"' 'description = "Implement code using CodeBrief project rules."' 'sandbox_mode = "workspace-write"' "developer_instructions = '''"
    cat "$SOURCE"; printf '\n%s\n' "'''"
  } > "$tmp"
  if write "$tmp" "$root/agents/codewriter.toml"; then rm -f "$tmp"; else rm -f "$tmp"; return 1; fi ;;
 cursor) skill ;;
 prompt)
  root="$DIR/.codefactory"; [[ "$TARGET" == global ]] && root="$HOME/.config/codefactory"
  write "$SOURCE" "$root/codewriter.md" ;;
 esac
}
agent() {
  if [[ "$NAME" == codeskills ]]; then
   echo "Codeskills has no agent format; skipping it. Use --format skill to install its skills." >&2
   return 0
  fi
 if [[ "$NAME" == codewriter ]]; then writer_agent; return; fi
 local args=(--agent "$AGENT")
 if [[ "$TARGET" == global ]]; then args+=(--global); else args+=(--local "$DIR"); fi
 if ((YES)); then args+=(--yes); fi
 bash "$BASE/$NAME/install.sh" "${args[@]}"
}
case "$FORMAT" in
 auto) if [[ "$NAME" == codeskills ]]; then skill; else agent; fi ;;
 skill) skill ;;
 agent) agent ;;
 both) if [[ "$NAME" == codeskills ]]; then skill; else agent; skill; fi ;;
esac
