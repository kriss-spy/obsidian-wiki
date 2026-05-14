#!/usr/bin/env bash
# Source this from your shell rc file to get wiki freshness reminders on terminal open.
#
# Setup (shell-specific):
#   zsh/bash:  source /path/to/obsidian-wiki/scripts/wiki-notify.sh
#   fish:      bass source /path/to/obsidian-wiki/scripts/wiki-notify.sh
#              (or copy _wiki_notify logic natively using fish syntax)
#
# State is vault-scoped under each vault's .agents/state/ directory.
# Multiple vaults are supported — all stale vaults are shown.

_wiki_notify() {
  # Find all vault state directories by looking for .agents/state under common vault parent paths.
  # The user can also set OBSIDIAN_VAULT_PATH explicitly before sourcing this script.
  local vault_paths=()

  if [[ -n "${OBSIDIAN_VAULT_PATH:-}" ]]; then
    vault_paths+=("$OBSIDIAN_VAULT_PATH")
  fi

  # Also discover from ~/.config/obsidian-wiki/config if it exists (wiki-switch users)
  if [[ -f "$HOME/.config/obsidian-wiki/config" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.config/obsidian-wiki/config"
    if [[ -n "${OBSIDIAN_VAULT_PATH:-}" ]]; then
      vault_paths+=("$OBSIDIAN_VAULT_PATH")
    fi
  fi

  local now age_s age_h stale vault_path shown=0
  now=$(date +%s)

  for vault_path in "${vault_paths[@]}"; do
    local state_dir="$vault_path/.agents/state"
    [[ -f "$state_dir/.last_update" ]] || continue

    last=$(cat "$state_dir/.last_update" 2>/dev/null || echo 0)
    age_s=$(( now - last ))

    # Only show if >20 hours stale
    (( age_s > 72000 )) || continue

    age_h=$(( age_s / 3600 ))
    stale=$(cat "$state_dir/.pending_delta" 2>/dev/null || echo 0)

    echo "┌─ wiki: last synced ${age_h}h ago · ${vault_path##*/}$([ "$stale" -gt 0 ] && echo " · ${stale} source(s) have new content" || echo "")"
    echo "│  /wiki-history-ingest claude   sync Claude sessions"
    echo "│  /wiki-status                  see full delta"
    echo "└─ /memory-bridge diff           compare tool memories"
    shown=$(( shown + 1 ))
  done
}

_wiki_notify
