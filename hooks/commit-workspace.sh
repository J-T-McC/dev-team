#!/bin/bash
# Stop hook: an uncommitted workspace is its own git repo (workflow/workspace.md § Guest mode).
# Commit it whenever it changed, so its history is kept without touching the project's repo.
P="${CLAUDE_PROJECT_DIR:-.}"
source "${CLAUDE_PLUGIN_ROOT}/bin/_workspace.sh" "$P"
[ "$WS_COMMITTED" = no ] || exit 0
[ -d "$P/$WS/.git" ] || exit 0
git -C "$P/$WS" add -A 2>/dev/null
git -C "$P/$WS" diff --cached --quiet 2>/dev/null && exit 0
git -C "$P/$WS" commit -qm "dev-team: $(date '+%Y-%m-%d %H:%M')" 2>/dev/null
exit 0
