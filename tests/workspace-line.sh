#!/bin/bash
# Regression tests for bin/_workspace.sh (the Workspace line parser). Run: tests/workspace-line.sh
cd "$(dirname "$0")/.." || exit 1
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail=0
check() {  # check '<line>' '<expected WS|FEATURES|COMMITTED>'
  printf -- '%s\n' "$1" > "$T/CLAUDE.md"
  got=$(source bin/_workspace.sh "$T"; echo "$WS|$FEATURES|$WS_COMMITTED")
  if [ "$got" = "$2" ]; then echo "ok   $2"; else echo "FAIL $1 -> $got (want $2)"; fail=1; fi
}
check '- **Workspace:** `docs` · features `docs/features` · folders `slug` · committed'                 'docs|docs/features|yes'
check '- **Workspace:** `docs/dev-team` · features `docs/features` · folders `<ticket>-slug` · committed' 'docs/dev-team|docs/features|yes'
check '- **Workspace:** `my-features` · features `x/features` · folders `slug` · not committed'          'my-features|x/features|no'
check '- **Workspace:** `.dev-team` · features `docs/agent-tasks` · folders `slug` · committed'          '.dev-team|docs/agent-tasks|yes'
check '- **Workspace:** `docs`'                                                                             'docs|docs/features|yes'
check 'no workspace line'                                                                                   'docs|docs/features|yes'
exit $fail
