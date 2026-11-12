#!/usr/bin/env bash
set -euo pipefail

# Delegate explicitly selected packaging formats to the shared installer.
for option in "$@"; do
    if [[ "$option" == --format ]]; then
        COMPONENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        exec bash "$COMPONENT_DIR/../install-capability.sh" codebrief "$@"
    fi
done

MODE="global"
TARGET_DIR=""
ASSUME_YES=0
AGENT=""

AGENTS="opencode prompt claude cursor copilot codex"

usage() {
    cat <<'EOF'
Usage: ./install.sh --agent <name> [--global | --local <project-dir>] [--yes]

--agent is required. Use --agent with --yes. Without --yes, an interactive
terminal can choose an agent if --agent is omitted.

Agents:
  opencode   OpenCode primary agent and /codebrief command
  prompt     Canonical prompt file for any other tool
  claude     Claude Code agent and /codebrief skill
  cursor     Cursor /codebrief skill
  copilot    GitHub Copilot / VS Code custom agent
  codex      Codex custom agent

Options:
  --agent <name>         Coding agent to install for. Required with --yes.
  --global               Install for the current user. This is the default.
  --local <project-dir>  Install only in one project.
  --yes, -y              Replace existing Codebrief files without prompting.
  --help, -h             Show this help.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --agent)
            if [[ $# -lt 2 ]]; then
                echo "--agent requires a name." >&2
                exit 1
            fi
            AGENT="$2"
            shift 2
            ;;
        --global)
            MODE="global"
            shift
            ;;
        --local)
            if [[ $# -lt 2 ]]; then
                echo "--local requires a project directory." >&2
                exit 1
            fi
            MODE="local"
            TARGET_DIR="$2"
            shift 2
            ;;
        --yes|-y)
            ASSUME_YES=1
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_SOURCE="$SCRIPT_DIR/prompt/codebrief.md"
PACKAGING="$SCRIPT_DIR/packaging"

if [[ ! -f "$PROMPT_SOURCE" ]]; then
    echo "Codebrief prompt is missing: $PROMPT_SOURCE" >&2
    exit 1
fi

is_known_agent() {
    local name="$1"
    local candidate
    for candidate in $AGENTS; do
        if [[ "$candidate" == "$name" ]]; then
            return 0
        fi
    done
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
        *)
            echo "Unknown agent selection: $reply" >&2
            exit 1
            ;;
    esac
}

if [[ -z "$AGENT" ]]; then
    if [[ "$ASSUME_YES" == "1" ]]; then
        echo "--agent is required with --yes." >&2
        usage >&2
        exit 1
    fi
    if [[ ! -t 0 ]]; then
        echo "--agent is required when stdin is not a terminal." >&2
        usage >&2
        exit 1
    fi
    select_agent
fi

if ! is_known_agent "$AGENT"; then
    echo "Unknown agent: $AGENT" >&2
    echo "Known agents: $AGENTS" >&2
    exit 1
fi

if [[ "$MODE" == "local" ]]; then
    if [[ -z "$TARGET_DIR" || ! -d "$TARGET_DIR" ]]; then
        echo "--local requires an existing project directory." >&2
        exit 1
    fi
    TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
fi

confirm_replace() {
    local reply
    if [[ "$ASSUME_YES" == "1" ]]; then
        return 0
    fi
    read -rp "Replace existing Codebrief files? [y/N] " reply
    case "$reply" in
        y|Y|yes|YES|Yes) return 0 ;;
        *)
            echo "Installation stopped; existing files were left unchanged." >&2
            exit 1
            ;;
    esac
}

files_match() {
    local left="$1"
    local right="$2"
    [[ -f "$left" && -f "$right" ]] && cmp -s "$left" "$right"
}

install_file() {
    local source="$1"
    local dest="$2"
    mkdir -p "$(dirname "$dest")"
    install -m 0644 "$source" "$dest"
    echo "Installed: $dest"
}

write_composed_markdown() {
    local header="$1"
    local dest="$2"
    local tmp
    tmp="$(mktemp)"
    {
        cat "$header"
        echo
        cat "$PROMPT_SOURCE"
    } > "$tmp"
    if files_match "$tmp" "$dest"; then
        rm -f "$tmp"
        echo "Already up to date: $dest"
        return 0
    fi
    if [[ -e "$dest" || -L "$dest" ]]; then
        confirm_replace
    fi
    install_file "$tmp" "$dest"
    rm -f "$tmp"
}

write_raw_file() {
    local source="$1"
    local dest="$2"
    if files_match "$source" "$dest"; then
        echo "Already up to date: $dest"
        return 0
    fi
    if [[ -e "$dest" || -L "$dest" ]]; then
        confirm_replace
    fi
    install_file "$source" "$dest"
}

write_codex_toml() {
    local dest="$1"
    local tmp
    tmp="$(mktemp)"
    {
        printf '%s\n' 'name = "codebrief"'
        printf '%s\n' 'description = "Interviews a developer and writes INSTRUCTIONS.md for coding agents."'
        printf '%s\n' 'sandbox_mode = "workspace-write"'
        printf '%s\n' 'developer_instructions = """'
        cat "$PROMPT_SOURCE"
        printf '\n%s\n' '"""'
    } > "$tmp"
    if files_match "$tmp" "$dest"; then
        rm -f "$tmp"
        echo "Already up to date: $dest"
        return 0
    fi
    if [[ -e "$dest" || -L "$dest" ]]; then
        confirm_replace
    fi
    install_file "$tmp" "$dest"
    rm -f "$tmp"
}

refuse_competing() {
    local path="$1"
    if [[ -e "$path" || -L "$path" ]]; then
        echo "Competing Codebrief definition found: $path" >&2
        echo "Move or remove it before installing Codebrief." >&2
        exit 1
    fi
}

install_opencode() {
    local root dest_agent dest_command
    if [[ "$MODE" == "global" ]]; then
        root="$HOME/.config/opencode"
    else
        root="$TARGET_DIR/.opencode"
    fi
    dest_agent="$root/agents/codebrief.md"
    dest_command="$root/commands/codebrief.md"
    refuse_competing "$root/agent/codebrief.md"
    refuse_competing "$root/command/codebrief.md"
    write_composed_markdown "$PACKAGING/opencode/agent-frontmatter.md" "$dest_agent"
    write_raw_file "$PACKAGING/opencode/command.md" "$dest_command"
    echo "Restart OpenCode, then select the codebrief agent or run /codebrief."
}

install_prompt() {
    local dest
    if [[ "$MODE" == "global" ]]; then
        dest="$HOME/.config/codebrief/codebrief.md"
    else
        dest="$TARGET_DIR/.codebrief/codebrief.md"
    fi
    write_raw_file "$PROMPT_SOURCE" "$dest"
    echo "Point your coding agent at $dest, or paste it as a custom agent prompt."
}

install_claude() {
    local agent_dest skill_dest
    if [[ "$MODE" == "global" ]]; then
        agent_dest="$HOME/.claude/agents/codebrief.md"
        skill_dest="$HOME/.claude/skills/codebrief/SKILL.md"
    else
        agent_dest="$TARGET_DIR/.claude/agents/codebrief.md"
        skill_dest="$TARGET_DIR/.claude/skills/codebrief/SKILL.md"
    fi
    write_composed_markdown "$PACKAGING/claude/agent-frontmatter.md" "$agent_dest"
    write_composed_markdown "$PACKAGING/claude/skill-frontmatter.md" "$skill_dest"
    echo "Restart Claude Code if it did not already watch the agents directory."
    echo "Run /codebrief, or start a session with --agent codebrief."
}

install_cursor() {
    local dest
    if [[ "$MODE" == "global" ]]; then
        dest="$HOME/.cursor/skills/codebrief/SKILL.md"
    else
        dest="$TARGET_DIR/.cursor/skills/codebrief/SKILL.md"
    fi
    write_composed_markdown "$PACKAGING/cursor/skill-frontmatter.md" "$dest"
    echo "In Cursor Agent chat, run /codebrief. Use it as a Custom Mode to keep it on for the session."
}

install_copilot() {
    local dest
    if [[ "$MODE" == "global" ]]; then
        dest="$HOME/.copilot/agents/codebrief.agent.md"
    else
        dest="$TARGET_DIR/.github/agents/codebrief.agent.md"
    fi
    write_composed_markdown "$PACKAGING/copilot/agent-frontmatter.md" "$dest"
    echo "Select the codebrief custom agent in Copilot chat or the agents dropdown."
}

install_codex() {
    local dest
    if [[ "$MODE" == "global" ]]; then
        dest="$HOME/.codex/agents/codebrief.toml"
    else
        dest="$TARGET_DIR/.codex/agents/codebrief.toml"
    fi
    write_codex_toml "$dest"
    echo "Ask Codex to use the codebrief custom agent, or spawn it by name."
}

case "$AGENT" in
    opencode) install_opencode ;;
    prompt) install_prompt ;;
    claude) install_claude ;;
    cursor) install_cursor ;;
    copilot) install_copilot ;;
    codex) install_codex ;;
esac
