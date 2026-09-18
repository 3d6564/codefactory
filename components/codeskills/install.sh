#!/usr/bin/env bash
set -euo pipefail

MODE="global"
TARGET_DIR=""
ASSUME_YES=0
AGENT=""
SKILL="backlog-triage"
AGENTS="opencode prompt claude cursor copilot codex"

usage() {
    cat <<'EOF'
Usage: ./install.sh --agent <name> [--global | --local <project-dir>] [--yes]

Installs every included Codeskills skill. --agent is required with --yes.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --agent) [[ $# -ge 2 ]] || { echo "--agent requires a name." >&2; exit 1; }; AGENT="$2"; shift 2 ;;
        --global) MODE="global"; shift ;;
        --local) [[ $# -ge 2 ]] || { echo "--local requires a project directory." >&2; exit 1; }; MODE="local"; TARGET_DIR="$2"; shift 2 ;;
        --yes|-y) ASSUME_YES=1; shift ;;
        --help|-h) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$SCRIPT_DIR/skills/$SKILL"
PROMPT_SOURCE="$SKILL_DIR/prompt.md"
PACKAGING="$SKILL_DIR/packaging"

[[ -f "$PROMPT_SOURCE" ]] || { echo "Codeskills prompt is missing: $PROMPT_SOURCE" >&2; exit 1; }

is_known_agent() {
    local candidate
    for candidate in $AGENTS; do [[ "$candidate" == "$1" ]] && return 0; done
    return 1
}

select_agent() {
    local reply
    echo "Select a coding agent:" >&2
    echo "  1) opencode" >&2
    echo "  2) prompt" >&2
    echo "  3) claude" >&2
    echo "  4) cursor" >&2
    echo "  5) copilot" >&2
    echo "  6) codex" >&2
    read -rp "Agent [1-6]: " reply
    case "$reply" in
        1|opencode) AGENT="opencode" ;;
        2|prompt) AGENT="prompt" ;;
        3|claude) AGENT="claude" ;;
        4|cursor) AGENT="cursor" ;;
        5|copilot) AGENT="copilot" ;;
        6|codex) AGENT="codex" ;;
        *) echo "Unknown agent selection: $reply" >&2; exit 1 ;;
    esac
}

if [[ -z "$AGENT" ]]; then
    [[ "$ASSUME_YES" != "1" ]] || { echo "--agent is required with --yes." >&2; exit 1; }
    [[ -t 0 ]] || { echo "--agent is required when stdin is not a terminal." >&2; exit 1; }
    select_agent
fi

is_known_agent "$AGENT" || { echo "Unknown agent: $AGENT" >&2; exit 1; }

if [[ "$MODE" == "local" ]]; then
    [[ -n "$TARGET_DIR" && -d "$TARGET_DIR" ]] || { echo "--local requires an existing project directory." >&2; exit 1; }
    TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
fi

confirm_replace() {
    local reply
    [[ "$ASSUME_YES" == "1" ]] && return 0
    read -rp "Replace existing Codeskills files? [y/N] " reply
    case "$reply" in y|Y|yes|YES|Yes) ;; *) echo "Installation stopped; existing files were left unchanged." >&2; exit 1 ;; esac
}

files_match() { [[ -f "$1" && -f "$2" ]] && cmp -s "$1" "$2"; }

install_file() {
    mkdir -p "$(dirname "$2")"
    install -m 0644 "$1" "$2"
    echo "Installed: $2"
}

write_composed_markdown() {
    local header="$1" dest="$2" tmp
    tmp="$(mktemp)"
    { cat "$header"; echo; cat "$PROMPT_SOURCE"; } > "$tmp"
    if files_match "$tmp" "$dest"; then rm -f "$tmp"; echo "Already up to date: $dest"; return 0; fi
    [[ ! -e "$dest" && ! -L "$dest" ]] || confirm_replace
    install_file "$tmp" "$dest"
    rm -f "$tmp"
}

write_raw_file() {
    local source="$1" dest="$2"
    if files_match "$source" "$dest"; then echo "Already up to date: $dest"; return 0; fi
    [[ ! -e "$dest" && ! -L "$dest" ]] || confirm_replace
    install_file "$source" "$dest"
}

write_codex_toml() {
    local dest="$1" tmp
    tmp="$(mktemp)"
    {
        printf '%s\n' 'name = "backlog-triage"'
        printf '%s\n' 'description = "Reviews project work and prepares the next implementation choice."'
        printf '%s\n' 'sandbox_mode = "read-only"'
        printf '%s\n' 'developer_instructions = """'
        cat "$PROMPT_SOURCE"
        printf '\n%s\n' '"""'
    } > "$tmp"
    if files_match "$tmp" "$dest"; then rm -f "$tmp"; echo "Already up to date: $dest"; return 0; fi
    [[ ! -e "$dest" && ! -L "$dest" ]] || confirm_replace
    install_file "$tmp" "$dest"
    rm -f "$tmp"
}

refuse_competing() {
    [[ ! -e "$1" && ! -L "$1" ]] || { echo "Competing Codeskills definition found: $1" >&2; exit 1; }
}

install_opencode() {
    local root
    if [[ "$MODE" == "global" ]]; then root="$HOME/.config/opencode"; else root="$TARGET_DIR/.opencode"; fi
    refuse_competing "$root/agent/$SKILL.md"
    refuse_competing "$root/command/$SKILL.md"
    write_composed_markdown "$PACKAGING/opencode/agent-frontmatter.md" "$root/agents/$SKILL.md"
    write_raw_file "$PACKAGING/opencode/command.md" "$root/commands/$SKILL.md"
}

install_prompt() {
    local dest
    if [[ "$MODE" == "global" ]]; then dest="$HOME/.config/codefactory/codeskills/$SKILL.md"; else dest="$TARGET_DIR/.codefactory/codeskills/$SKILL.md"; fi
    write_raw_file "$PROMPT_SOURCE" "$dest"
}

install_claude() {
    local root
    if [[ "$MODE" == "global" ]]; then root="$HOME/.claude"; else root="$TARGET_DIR/.claude"; fi
    write_composed_markdown "$PACKAGING/claude/agent-frontmatter.md" "$root/agents/$SKILL.md"
    write_composed_markdown "$PACKAGING/claude/skill-frontmatter.md" "$root/skills/$SKILL/SKILL.md"
}

install_cursor() {
    local root
    if [[ "$MODE" == "global" ]]; then root="$HOME/.cursor"; else root="$TARGET_DIR/.cursor"; fi
    write_composed_markdown "$PACKAGING/cursor/skill-frontmatter.md" "$root/skills/$SKILL/SKILL.md"
}

install_copilot() {
    local dest
    if [[ "$MODE" == "global" ]]; then dest="$HOME/.copilot/agents/$SKILL.agent.md"; else dest="$TARGET_DIR/.github/agents/$SKILL.agent.md"; fi
    write_composed_markdown "$PACKAGING/copilot/agent-frontmatter.md" "$dest"
}

install_codex() {
    local dest
    if [[ "$MODE" == "global" ]]; then dest="$HOME/.codex/agents/$SKILL.toml"; else dest="$TARGET_DIR/.codex/agents/$SKILL.toml"; fi
    write_codex_toml "$dest"
}

case "$AGENT" in
    opencode) install_opencode ;;
    prompt) install_prompt ;;
    claude) install_claude ;;
    cursor) install_cursor ;;
    copilot) install_copilot ;;
    codex) install_codex ;;
esac
