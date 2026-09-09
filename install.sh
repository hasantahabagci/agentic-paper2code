#!/usr/bin/env bash
#
# Install agentic-paper2code into a project or into your home directory.
#
#   ./install.sh                    install into the current project
#   ./install.sh --global           install for every project on this machine
#   ./install.sh --project ~/work/x install into a specific project
#   ./install.sh --codex            also install Codex CLI prompts
#   ./install.sh --uninstall        remove what a previous run installed
#
# Or without cloning first:
#   curl -fsSL https://raw.githubusercontent.com/hasantahabagci/agentic-paper2code/main/install.sh | bash

set -euo pipefail

REPO_URL="https://github.com/hasantahabagci/agentic-paper2code.git"
SCOPE="project"
TARGET="$PWD"
WITH_CODEX=0
UNINSTALL=0
TMPDIR_CLONE=""

say()  { printf '%s\n' "$*"; }
step() { printf '  %s\n' "$*"; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

cleanup() { [ -n "$TMPDIR_CLONE" ] && rm -rf "$TMPDIR_CLONE"; }
trap cleanup EXIT

while [ $# -gt 0 ]; do
  case "$1" in
    --global)    SCOPE="global" ;;
    --project)   SCOPE="project"; TARGET="${2:?--project needs a directory}"; shift ;;
    --codex)     WITH_CODEX=1 ;;
    --uninstall) UNINSTALL=1 ;;
    -h|--help)   sed -n '3,14p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)           die "unknown option: $1" ;;
  esac
  shift
done

# Locate the toolkit source: the directory this script lives in, or a fresh
# clone when the script was piped in from the network.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/prompts" ]; then
  SRC="$SCRIPT_DIR"
else
  command -v git >/dev/null 2>&1 || die "git is required when running the installer remotely"
  TMPDIR_CLONE="$(mktemp -d)"
  say "Fetching agentic-paper2code..."
  git clone --depth 1 --quiet "$REPO_URL" "$TMPDIR_CLONE/toolkit"
  SRC="$TMPDIR_CLONE/toolkit"
fi

if [ "$SCOPE" = "global" ]; then
  TOOLKIT="$HOME/.paper2code"
  CLAUDE_DIR="$HOME/.claude"
  LABEL="$HOME (all projects)"
else
  [ -d "$TARGET" ] || die "no such directory: $TARGET"
  TARGET="$(cd "$TARGET" && pwd)"
  TOOLKIT="$TARGET/.p2c/toolkit"
  CLAUDE_DIR="$TARGET/.claude"
  LABEL="$TARGET"
fi
CODEX_DIR="$HOME/.codex/prompts"

if [ "$UNINSTALL" -eq 1 ]; then
  say "Removing agentic-paper2code from $LABEL"
  rm -rf "$TOOLKIT" "$CLAUDE_DIR/commands/p2c" "$CLAUDE_DIR/skills/paper2code"
  for a in paper-analyst paper-implementer fidelity-reviewer; do
    rm -f "$CLAUDE_DIR/agents/$a.md"
  done
  for p in paper2code paper2code-resume paper2code-status; do
    rm -f "$CODEX_DIR/$p.md"
  done
  step "done. Reproduction workspaces under .p2c/ were left alone."
  exit 0
fi

say "Installing agentic-paper2code into $LABEL"

mkdir -p "$TOOLKIT"
cp -R "$SRC/prompts" "$TOOLKIT/"
cp -R "$SRC/templates" "$TOOLKIT/" 2>/dev/null || true
cp "$SRC/AGENTS.md" "$TOOLKIT/AGENTS.md"
step "stage prompts      -> $TOOLKIT/prompts"

mkdir -p "$CLAUDE_DIR/commands" "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents"
rm -rf "$CLAUDE_DIR/commands/p2c"
cp -R "$SRC/.claude/commands/p2c" "$CLAUDE_DIR/commands/p2c"
step "slash commands     -> $CLAUDE_DIR/commands/p2c  (/p2c:run, /p2c:status, ...)"

rm -rf "$CLAUDE_DIR/skills/paper2code"
cp -R "$SRC/.claude/skills/paper2code" "$CLAUDE_DIR/skills/paper2code"
step "skill              -> $CLAUDE_DIR/skills/paper2code"

cp "$SRC"/.claude/agents/*.md "$CLAUDE_DIR/agents/"
step "subagents          -> $CLAUDE_DIR/agents"

if [ "$WITH_CODEX" -eq 1 ]; then
  mkdir -p "$CODEX_DIR"
  cp "$SRC"/.codex/prompts/*.md "$CODEX_DIR/"
  step "codex prompts      -> $CODEX_DIR  (/paper2code)"
fi

# Point a project's agent manual at the toolkit, without clobbering an existing one.
if [ "$SCOPE" = "project" ]; then
  MARK="<!-- agentic-paper2code -->"
  if [ -f "$TARGET/AGENTS.md" ]; then
    if ! grep -qF "$MARK" "$TARGET/AGENTS.md"; then
      {
        printf '\n%s\n' "$MARK"
        printf '%s\n' "## Reproducing papers"
        printf '%s\n' ""
        printf '%s\n' "When asked to reproduce, implement or port a research paper, follow"
        printf '%s\n' "\`.p2c/toolkit/AGENTS.md\` and run the stages under \`.p2c/toolkit/prompts/\`."
      } >> "$TARGET/AGENTS.md"
      step "appended a pointer to $TARGET/AGENTS.md"
    fi
  else
    {
      printf '%s\n\n' "$MARK"
      printf '%s\n\n' "# Agent instructions"
      printf '%s\n' "When asked to reproduce, implement or port a research paper, follow"
      printf '%s\n' "\`.p2c/toolkit/AGENTS.md\` and run the stages under \`.p2c/toolkit/prompts/\`."
    } > "$TARGET/AGENTS.md"
    step "wrote $TARGET/AGENTS.md"
  fi
fi

say ""
say "Done. In Claude Code, run:  /p2c:run 1706.03762"
if [ "$WITH_CODEX" -eq 1 ]; then
  say "In Codex, run:              /paper2code 1706.03762"
fi
say "With any other agent, tell it to follow $TOOLKIT/AGENTS.md."
