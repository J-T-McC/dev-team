#!/bin/bash
# UserPromptSubmit and Stop hook for the Orca coordinator (workflow/orca.md § Guard hooks): lists peer questions and
# reports not handled yet; Stop sends the turn back while one is, or while work is in flight and nothing watches it.
# Does nothing unless this checkout has peer homes, and acts only in the coordinator's own session.
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
[ -f "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)/dev-team/peers.json" ] || exit 0
exec "${CLAUDE_PLUGIN_ROOT}/bin/peer" hook "$1"
