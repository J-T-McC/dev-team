#!/bin/bash
# Stop hook: an uncommitted workspace is its own git repo (workflow/workspace.md § Guest mode).
# Commit it whenever it changed, so its history is kept without touching the project's repo, and push it when the
# repo has an upstream, so other machines can pull the specs.
P="${CLAUDE_PROJECT_DIR:-.}"
source "${CLAUDE_PLUGIN_ROOT}/bin/_workspace.sh" "$P"
[ "$WS_COMMITTED" = no ] || exit 0
[ -d "$P/$WS/.git" ] || exit 0
git -C "$P/$WS" add -A 2>/dev/null
git -C "$P/$WS" diff --cached --quiet 2>/dev/null ||
  git -C "$P/$WS" commit -qm "dev-team: $(date '+%Y-%m-%d %H:%M')" 2>/dev/null
# In the background, never prompting: a slow or failed push must not hold the session; the next stop retries it.
if [ -n "$(git -C "$P/$WS" rev-list '@{u}..HEAD' 2>/dev/null | head -1)" ]; then
  GIT_TERMINAL_PROMPT=0 nohup git -C "$P/$WS" push -q </dev/null >/dev/null 2>&1 &
fi
exit 0
