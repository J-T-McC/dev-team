#!/bin/bash
# Tests for .github/pr-title.sh: a PR title must be a conventional commit, since it sets the release.
# Run: tests/pr-title.sh
cd "$(dirname "$0")/.." || exit 1
fail=0
check() { bash .github/pr-title.sh "$2" 2>/dev/null; rc=$?
          if { [ "$1" = pass ] && [ $rc = 0 ]; } || { [ "$1" = fail ] && [ $rc != 0 ]; }; then echo "ok   $1: $2"
          else echo "FAIL $1: $2"; fail=1; fi; }

check pass 'feat(audit): /dev-team:audit measures what the team reads and loads, and trims it'
check pass 'fix(workspace): features folder misread when its path ends in "features"'
check pass 'feat(peer,board): remote peers, PR owners, board guard, cleanup after sessions'
check pass 'docs: two runtimes up front, llms.txt, and search metadata'
check pass 'feat!: a change that breaks existing projects'
check pass 'ci(release): tag releases from PR titles'
check fail 'Grant Playwright MCP to senior-developer and reviewer'
check fail 'feature: not a type'
check fail 'Feat: types are lower case'
check fail 'feat(audit) no colon'
check fail 'feat: '
check fail 'feat(): empty scope'

msg=$(bash .github/pr-title.sh 'Add a thing' 2>&1)
if [[ $msg == *'type(scope)!: summary'* ]]; then echo "ok   the failure says what a title looks like"
else echo "FAIL the failure says what a title looks like"; fail=1; fi
exit $fail
