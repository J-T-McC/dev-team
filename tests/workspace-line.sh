#!/bin/bash
# Regression tests for bin/_workspace.sh (the Workspace line parser). Run: tests/workspace-line.sh
cd "$(dirname "$0")/.." || exit 1
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail=0
check() {  # check '<line>' '<expected WS|FEATURES|COMMITTED|MODE>' [file the line is in, default CLAUDE.md]
  rm -f "$T"/CLAUDE*.md; printf -- '%s\n' "$1" > "$T/${3:-CLAUDE.md}"
  got=$(source bin/_workspace.sh "$T"; echo "$WS|$FEATURES|$WS_COMMITTED|$WS_MODE")
  if [ "$got" = "$2" ]; then echo "ok   $2"; else echo "FAIL $1 -> $got (want $2)"; fail=1; fi
}
check '- **Workspace:** `docs` · features `docs/features` · folders `slug` · committed'                 'docs|docs/features|yes|shared'
check '- **Workspace:** `docs/dev-team` · features `docs/features` · folders `<ticket>-slug` · committed' 'docs/dev-team|docs/features|yes|shared'
check '- **Workspace:** `my-features` · features `x/features` · folders `slug` · not committed'          'my-features|x/features|no|shared'
check '- **Workspace:** `.dev-team` · features `docs/agent-tasks` · folders `slug` · committed'          '.dev-team|docs/agent-tasks|yes|shared'
check '- **Workspace:** `docs`'                                                                             'docs|docs/features|yes|shared'
check 'no workspace line'                                                                                   'docs|docs/features|yes|shared'
check '- **Workspace:** `dev-team` · features `dev-team/features` · folders `slug` · committed'           'dev-team|dev-team/features|yes|shared'
check '- **Workspace:** `dev-team` · features `dev-team/features` · folders `slug` · not committed · just me' 'dev-team|dev-team/features|no|just-me' CLAUDE.local.md
check '- **Workspace:** `.dev-team` · features `.dev-team/features` · folders `slug` · not committed'     '.dev-team|.dev-team/features|no|guest' CLAUDE.local.md

# CLAUDE.local.md wins over CLAUDE.md (guest mode in someone else's project that has its own dev-team section).
printf -- '- **Workspace:** `docs` · committed\n' > "$T/CLAUDE.md"
printf -- '- **Workspace:** `.dev-team` · not committed\n' > "$T/CLAUDE.local.md"
got=$(source bin/_workspace.sh "$T"; echo "$WS|$WS_MODE")
if [ "$got" = ".dev-team|guest" ]; then echo "ok   CLAUDE.local.md first"; else echo "FAIL CLAUDE.local.md first -> $got"; fail=1; fi

# The SessionStart hook tells guest mode from "just me" by the line, not by the file it is in.
start() { mkdir -p "$T/$WS"; touch "$T/$WS/status.md"; CLAUDE_PROJECT_DIR="$T" CLAUDE_PLUGIN_ROOT="$PWD" bash hooks/session-start.sh; }
rm -f "$T"/CLAUDE*.md; WS=.dev-team; printf -- '- **Workspace:** `.dev-team` · not committed\n' > "$T/CLAUDE.local.md"
case $(start) in *"Guest mode:"*) echo "ok   session start: guest" ;; *) echo "FAIL session start: guest"; fail=1 ;; esac
WS=dev-team; printf -- '- **Workspace:** `dev-team` · not committed · just me\n' > "$T/CLAUDE.local.md"
case $(start) in *"Guest mode"*) echo "FAIL session start: just me reads as guest"; fail=1 ;;
  *"(just me)"*) echo "ok   session start: just me" ;; *) echo "FAIL session start: just me"; fail=1 ;; esac
exit $fail
