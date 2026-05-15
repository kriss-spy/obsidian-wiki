#!/bin/bash
#
# obsidian-wiki setup — single-vault, no global state.
#
# Usage: bash setup.sh
#
# What it does:
#   1. Creates .env from .env.example (if not present)
#   2. Prompts for OBSIDIAN_VAULT_PATH
#   3. Creates the vault directory structure
#   4. Copies .agents/skills/* into $VAULT/.agents/skills/
#   5. Bootstraps repo-local agent context files (.hermes.md → AGENTS.md)
#   6. Prints a summary
#
# Nothing is written outside this repo or the vault you designate.
#
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/.agents/skills"

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║         obsidian-wiki — Vault Setup              ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# ── Step 1: .env ──────────────────────────────────────────────
if [ ! -f "$SCRIPT_DIR/.env" ]; then
  cp "$SCRIPT_DIR/.env.example" "$SCRIPT_DIR/.env"
  echo "✅  Created .env from .env.example"
else
  echo "✅  .env already exists"
fi

# ── Step 2: Resolve vault path ────────────────────────────────
VAULT_PATH=""
if [ -f "$SCRIPT_DIR/.env" ]; then
  VAULT_PATH=$(grep -E '^OBSIDIAN_VAULT_PATH=' "$SCRIPT_DIR/.env" | cut -d'=' -f2- | sed 's/^"//;s/"$//')
fi

if [ -z "$VAULT_PATH" ] || [ "$VAULT_PATH" = "/path/to/your/vault" ]; then
  echo ""
  read -p "  Where should your Obsidian vault live? (absolute path): " VAULT_PATH
  if [ -n "$VAULT_PATH" ]; then
    ESCAPED_PATH=$(printf '%s\n' "$VAULT_PATH" | sed -e 's/[\/\&]/\\&/g' -e 's/"/\\"/g')
    sed -i.bak "s|^OBSIDIAN_VAULT_PATH=.*|OBSIDIAN_VAULT_PATH=\"$ESCAPED_PATH\"|" "$SCRIPT_DIR/.env"
    rm -f "$SCRIPT_DIR/.env.bak"
  fi
fi

# Expand tilde in VAULT_PATH for mkdir
VAULT_PATH_EXPANDED="${VAULT_PATH/#\~/$HOME}"

if [ -z "$VAULT_PATH_EXPANDED" ]; then
  echo "❌  No vault path provided. Aborting."
  exit 1
fi

# ── Step 3: Create vault structure ────────────────────────────
mkdir -p "$VAULT_PATH_EXPANDED"/{concepts,entities,skills,references,synthesis,journal,projects,_archives,_raw,.obsidian}
echo "✅  Vault structure created at $VAULT_PATH_EXPANDED"

# ── Step 4: Copy skills into vault ────────────────────────────
VAULT_SKILLS_DIR="$VAULT_PATH_EXPANDED/.agents/skills"
mkdir -p "$VAULT_SKILLS_DIR"

# Remove old copies so we don't leave stale skills
rm -rf "$VAULT_SKILLS_DIR"/*

for skill in "$SKILLS_DIR"/*/; do
  skill_name=$(basename "$skill")
  cp -r "$skill" "$VAULT_SKILLS_DIR/$skill_name"
done

SKILL_COUNT=$(ls -1 "$VAULT_SKILLS_DIR" | wc -l)
echo "✅  Copied $SKILL_COUNT skills → $VAULT_PATH_EXPANDED/.agents/skills/"

# ── Step 5: Copy .env into vault ──────────────────────────────
# The vault must be self-contained. Copy .env so agents can find
# config when working directly from the vault.
cp "$SCRIPT_DIR/.env" "$VAULT_PATH_EXPANDED/.env"
echo "✅  Copied .env → vault root"

# ── Step 6: Bootstrap repo-local symlinks ─────────────────────
HERMES_BOOTSTRAP="$SCRIPT_DIR/.hermes.md"
if [ -L "$HERMES_BOOTSTRAP" ]; then
  rm "$HERMES_BOOTSTRAP"
elif [ -f "$HERMES_BOOTSTRAP" ]; then
  rm "$HERMES_BOOTSTRAP"
fi
ln -s AGENTS.md "$HERMES_BOOTSTRAP"
echo "✅  .hermes.md → AGENTS.md"

# ── Step 7: Summary ──────────────────────────────────────────
echo ""
echo "───────────────────────────────────────────────────"
echo " Setup complete!"
echo ""
echo " Vault:            $VAULT_PATH_EXPANDED"
echo " Skills:           $SKILL_COUNT copied to .agents/skills/"
echo ""
echo " Bootstrap files:"
echo "   CLAUDE.md                            → Claude Code"
echo "   GEMINI.md                            → Gemini / Antigravity"
echo "   AGENTS.md                            → Codex, OpenClaw, OpenCode, Aider, Droid, Trae"
echo "   .hermes.md                           → Hermes (symlink → AGENTS.md)"
echo "   .cursor/rules/obsidian-wiki.mdc      → Cursor"
echo "   .windsurf/rules/obsidian-wiki.md     → Windsurf"
echo "   .kiro/steering/obsidian-wiki.md      → Kiro"
echo "   .agent/rules/obsidian-wiki.md        → Google Antigravity"
echo "   .github/copilot-instructions.md      → GitHub Copilot (VS Code Chat)"
echo ""
echo " Next steps:"
echo "   1. Open this project in your agent"
echo "   2. Say: \"Set up my wiki\""
echo ""
echo " The agent will create index.md, log.md, hot.md, and"
echo " configure Obsidian settings inside your vault."
echo ""
echo " From any other project:"
echo "   - Put OBSIDIAN_VAULT_PATH in that project's .env"
echo "   - Or put it in ~/.env for a global default"
echo "   - Then use /wiki-update and /wiki-query"
echo "───────────────────────────────────────────────────"
echo ""
