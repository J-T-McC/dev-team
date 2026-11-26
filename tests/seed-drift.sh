#!/bin/bash
# Tests for bin/seed-drift (sync's drift check). Each case starts from a project that is an exact copy of the seeds.
# Run: tests/seed-drift.sh
cd "$(dirname "$0")/.." || exit 1
REPO=$PWD
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail=0
ok() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }
fresh() {  # fresh <claude-file> [workspace root]: a project whose dev-team section, files, and standards match the seeds
  rm -rf "$T/p"; W="$T/p/${2:-docs}"; mkdir -p "$W/standards" "$W/stack" "$W/backlog"
  cp "$REPO"/seeds/standards/*.md "$W/standards/"
  cp "$REPO/seeds/stack.md" "$W/stack/stack.md"; cp "$REPO/seeds/backlog-index.md" "$W/backlog/index.md"
  cp "$REPO/seeds/backlog-archive.md" "$W/backlog/archive.md"
  for f in status status-done triage friction-log; do cp "$REPO/seeds/$f.md" "$W/$f.md"; done
  sed "s|\`dev-team\` · features \`dev-team/features\`|\`${2:-docs}\` · features \`${2:-docs}/features\`|" \
    "$REPO/seeds/CLAUDE.project.md" > "$T/p/$1"
}
run() { OUT=$("$REPO/bin/seed-drift" "$T/p"); RC=$?; }
drop() { python3 -c 'import sys;p=sys.argv[1];s=open(p).read();assert sys.argv[2] in s;open(p,"w").write(s.replace(sys.argv[2],sys.argv[3]))' "$@"; }

fresh CLAUDE.md; run
ok "seed copy is up to date"                 '[ $RC = 0 ] && [ "$OUT" = "up to date" ]'

fresh CLAUDE.md
drop "$T/p/docs/standards/review.md" "## Review order (active)" "## Notes"
drop "$T/p/docs/standards/testing.md" "## Test types and coverage" "## TEST TYPES AND COVERAGE (customized)"
run
ok "missing section reported"                '[ $RC = 1 ] && [[ $OUT == *"standards/review.md: missing section \"Review order (active)\""* ]]'
ok "renamed suffix or case is not drift"     '[[ $OUT != *"Test types"* ]]'

fresh CLAUDE.md
rm "$T/p/docs/friction-log.md"; run
ok "missing workspace file reported"         '[ $RC = 1 ] && [ "$OUT" = "docs/friction-log.md: missing file (seed friction-log.md)" ]'

fresh CLAUDE.md
drop "$T/p/CLAUDE.md" "- **Build small.**" "- Keep it small:"
drop "$T/p/CLAUDE.md" "**Autonomy: standard.**" "**Autonomy: autonomous; Owner keeps: release.**"
drop "$T/p/CLAUDE.md" "- **Not now is not lost.**" "- **Not now is not lost (Owner, 2026-01-05).**"
run
ok "missing rule reported"                   '[[ $OUT == *"CLAUDE.md: missing rule \"Build small\""* ]]'
ok "changed rule value is not drift"         '[[ $OUT != *Autonomy* ]]'
ok "a note in brackets is not drift"         '[[ $OUT != *"Not now"* ]]'

fresh CLAUDE.md
drop "$T/p/CLAUDE.md" "- **Run roles in this conversation.**" "- **Runtime: Orca.** Roles run as Orca peers. Peer clear threshold: 25% of the peer's context window. Board: off.
- Old:"
run
ok "Orca: in-conversation rule not required" '[[ $OUT != *"Run roles in this conversation"* ]]'
ok "Orca: clear threshold rename reported"   '[[ $OUT == *"\"Peer clear threshold\" is now \"Peer size limit: 400k\""* ]]'
drop "$T/p/CLAUDE.md" "Peer clear threshold: 25% of the peer's context window. Board: off." "Peer size limit: 300k."
run
ok "Orca: missing worktree-cards setting"    '[[ $OUT == *"no \"Worktree cards:\" setting"* ]] && [[ $OUT != *"Peer size limit"* ]]'
ok "Orca: missing launch settings reported"  '[[ $OUT == *"no \"Team model:\" setting"* ]] && [[ $OUT == *"no \"Fallback model:\""* ]] && [[ $OUT == *"no \"Advisor:\""* ]]'
drop "$T/p/CLAUDE.md" "Peer size limit: 300k." "Team model: opus. Fallback model: none. Advisor: none. Peer size limit: 300k. Board: on."
run
ok "Orca: Board renamed to Worktree cards"   '[[ $OUT == *"\"Board:\" is now \"Worktree cards:\""* ]]'
drop "$T/p/CLAUDE.md" "Board: on." "Worktree cards: on."
run
ok "Orca: current Runtime line is quiet"     '[ $RC = 0 ]'

fresh CLAUDE.md
sed -n '/^## Team setup/,$p' "$REPO/seeds/orca-recommended.md" >> "$T/p/CLAUDE.md"
run
ok "Team setup: a full copy is quiet"        '[ $RC = 0 ]'
drop "$T/p/CLAUDE.md" "- **Tests.** Mid-work" "- Tests: mid-work"
run
ok "Team setup: a missing rule reported"     '[[ $OUT == *"CLAUDE.md: Team setup has no \"Tests\" rule"* ]] && [[ $OUT != *"missing rule"* ]]'

fresh CLAUDE.md
mkdir -p "$T/p/docs/features/a"; ln -s .. "$T/p/docs/features/a/up"; ln -s ../../docs "$T/p/docs/features/self"
ln -s "$T/p" "$T/p/docs/root"; ln -s ../stack "$T/p/docs/features/stack"; ln -s status.md "$T/p/docs/status-link.md"
run
ok "links back into the workspace reported"  '[[ $OUT == *"docs/features/self: links to a folder that contains it (../../docs)"* ]] && [[ $OUT == *"docs/root: links to a folder"* ]] && [[ $OUT == *"docs/features/a/up: links to a folder"* ]]'
ok "links elsewhere are fine"                '[[ $OUT != *"features/stack"* ]] && [[ $OUT != *status-link* ]]'
OUT=$(cd "$T/p" && "$REPO/bin/seed-drift" .)
ok "run as '.' from the project: same links"  '[[ $OUT == *"docs/features/self: links to a folder that contains it (../../docs)"* ]] && [[ $OUT != *"features/stack"* ]] && [[ $OUT != *status-link* ]]'

fresh CLAUDE.md
drop "$T/p/CLAUDE.md" "- **Run roles in this conversation.**" "- Run roles here:"
run
ok "no Orca: in-conversation rule required"  '[[ $OUT == *"missing rule \"Run roles in this conversation\""* ]]'

fresh CLAUDE.local.md .dev-team
printf '# Their project\n\n- **Their own rule.** Something.\n' > "$T/p/CLAUDE.md"
drop "$T/p/.dev-team/standards/planning.md" "## Agent limits (active)" "## Limits"
run
ok "guest: workspace root from local file"   '[[ $OUT == *"standards/planning.md: missing section \"Agent limits (active)\""* ]]'
ok "guest: their CLAUDE.md is not checked"   '[[ $OUT != *"CLAUDE.md: missing"* ]]'

rm -rf "$T/p"; mkdir -p "$T/p"; printf '# Some project\n\n- **Unrelated.** Rule.\n' > "$T/p/CLAUDE.md"; run
ok "no dev-team section, nothing to report"  '[ $RC = 0 ] && [ "$OUT" = "up to date" ]'
exit $fail
