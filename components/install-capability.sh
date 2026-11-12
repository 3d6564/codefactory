#!/usr/bin/env bash
set -euo pipefail
BASE="$(cd "$(dirname "$0")" && pwd)"
NAME="$1"; shift
case "$NAME" in codebrief|codewriter|codereview) ;; *) exit 1 ;; esac
AGENT=""; FORMAT=agent; TARGET=global; DIR=""; YES=0
while (($#)); do
 case "$1" in
 --agent) AGENT="$2"; shift 2 ;;
 --format) FORMAT="$2"; shift 2 ;;
 --global) TARGET=global; shift ;;
 --local) TARGET=local; DIR="$2"; shift 2 ;;
 --yes|-y) YES=1; shift ;;
 --help|-h) echo "Usage: --agent NAME [--format skill|agent|both] [--global|--local DIR] [--yes]"; exit 0 ;;
 *) echo "Unknown option: $1" >&2; exit 1 ;;
 esac
done
case "$FORMAT" in skill|agent|both) ;; *) exit 1 ;; esac
case "$AGENT" in opencode|prompt|claude|cursor|copilot|codex) ;; *) echo "Unknown or missing agent: $AGENT" >&2; exit 1 ;; esac
if [[ "$TARGET" == local ]]; then
 [[ -d "$DIR" ]] || { echo "Missing project: $DIR" >&2; exit 1; }
 DIR="$(cd "$DIR" && pwd)"
else DIR="$HOME"; fi
SOURCE="$BASE/$NAME/prompt/$NAME.md"
[[ "$NAME" == codewriter ]] && SOURCE="$BASE/codewriter/SKILL.md"
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
 front="$BASE/$NAME/packaging/$AGENT/skill-frontmatter.md"
 if [[ -f "$front" ]]; then compose "$front" "$root/skills/$NAME/SKILL.md"
 elif [[ "$AGENT" == prompt ]]; then write "$SOURCE" "$root/skills/$NAME/SKILL.md"
 else
  tmp="$(mktemp)"
  { printf '%s\n' '---' "name: $NAME" "description: Use the $NAME coding skill." '---'; echo; cat "$SOURCE"; } > "$tmp"
  if write "$tmp" "$root/skills/$NAME/SKILL.md"; then rm -f "$tmp"; else rm -f "$tmp"; return 1; fi
 fi
}
