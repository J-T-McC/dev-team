#!/bin/bash
# The coordinator's guard hooks (workflow/orca.md § Guard hooks, workflow/board.md § Rules): $1 is prompt or stop.
# Silent unless this checkout has Orca peer homes or an Owner board.
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
[ -f "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)/dev-team/peers.json" ] ||
  grep -qs '\*\*Owner board:\*\*' CLAUDE.md CLAUDE.local.md || exit 0
# bin/peer needs Python 3.9+. Without it, stay quiet rather than fail on every prompt; the SessionStart hook says why once.
python3 -c 'import sys; sys.exit(sys.version_info < (3, 9))' 2>/dev/null || exit 0
exec "${CLAUDE_PLUGIN_ROOT}/bin/peer" hook "$1"
