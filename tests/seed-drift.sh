#!/bin/bash
# Tests for bin/seed-drift (sync's drift check). Each case starts from a project that is an exact copy of the seeds.
# Run: tests/seed-drift.sh
cd "$(dirname "$0")/.." || exit 1
REPO=$PWD
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail=0
ok() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }
fresh() {  # fresh <claude-file> [workspace root]: a project whose dev-team section and standards match the seeds
  rm -rf "$T/p"; mkdir -p "$T/p/${2:-docs}/standards"
  cp "$REPO"/seeds/standards/*.md "$T/p/${2:-docs}/standards/"
  sed "s|\`docs\` · features \`docs/features\`|\`${2:-docs}\` · features \`${2:-docs}/features\`|" \
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
drop "$T/p/CLAUDE.md" "- **Build small.**" "- Keep it small:"
drop "$T/p/CLAUDE.md" "**Autonomy: standard.**" "**Autonomy: autonomous; Owner keeps: release.**"
run
ok "missing rule reported"                   '[[ $OUT == *"CLAUDE.md: missing rule \"Build small\""* ]]'
ok "changed rule value is not drift"         '[[ $OUT != *Autonomy* ]]'

fresh CLAUDE.md
drop "$T/p/CLAUDE.md" "- **Run roles in this conversation.**" "- **Runtime: Orca.** Roles run as Orca peers. Peer clear threshold: 25% of the peer's context window. Board: off.
- Old:"
run
ok "Orca: in-conversation rule not required" '[[ $OUT != *"Run roles in this conversation"* ]]'
ok "Orca: clear threshold rename reported"   '[[ $OUT == *"\"Peer clear threshold\" is now \"Peer size limit: 400k\""* ]]'
drop "$T/p/CLAUDE.md" "Peer clear threshold: 25% of the peer's context window. Board: off." "Peer size limit: 300k."
run
ok "Orca: missing Board setting reported"    '[[ $OUT == *"no \"Board:\" setting"* ]] && [[ $OUT != *"Peer size limit"* ]]'
drop "$T/p/CLAUDE.md" "Peer size limit: 300k." "Peer size limit: 300k. Board: on."
run
ok "Orca: current Runtime line is quiet"     '[ $RC = 0 ]'

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
