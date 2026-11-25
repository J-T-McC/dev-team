#!/bin/bash
# Tests for bin/slot: heavy jobs take turns, critical path first.
# Run: tests/slot.sh
cd "$(dirname "$0")/.." || exit 1
SLOT=$PWD/bin/slot
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
export DEV_TEAM_SLOT_DIR="$T/slots" DEV_TEAM_SLOTS=1 DEV_TEAM_SLOT_POLL=0.05
fail=0
ok() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }
cd "$T" || exit 1

"$SLOT" run build -- sleep 1.5 2>/dev/null & HOLD=$!
sleep 0.4
"$SLOT" run low --prio 5 -- sh -c 'echo low >> order' 2>/dev/null &
sleep 0.3
"$SLOT" run critical --prio 1 -- sh -c 'echo critical >> order' 2>/dev/null &
sleep 0.3
STATUS=$("$SLOT" status)
ok "status: who holds and who waits"  '[[ $STATUS == *"slot 1: build"* ]] && [[ $STATUS == *"waiting 1: critical (prio 1)"*"waiting 2: low (prio 5)"* ]]'
wait
ok "critical path goes first"         '[ "$(cat order | tr "\n" " ")" = "critical low " ]'
ok "slots free once their jobs end"   '[[ $("$SLOT" status) == "slot 1: free" ]]'

"$SLOT" run fails -- sh -c 'exit 3' 2>/dev/null
ok "the job's exit code comes back"   '[ $? = 3 ]'

DEV_TEAM_SLOTS=2 "$SLOT" run a -- sleep 0.6 2>/dev/null &
DEV_TEAM_SLOTS=2 "$SLOT" run b -- sleep 0.6 2>/dev/null &
sleep 0.3
ok "two slots run two jobs at once"   '[[ $(DEV_TEAM_SLOTS=2 "$SLOT" status) == *"slot 1: "[ab]*"slot 2: "[ab]* ]]'
wait

"$SLOT" run db --pool containers -- sleep 1 2>/dev/null &
sleep 0.3
"$SLOT" run tests -- sh -c 'echo ran > pooled' 2>/dev/null
ok "a container pool never blocks test runs" '[ -f pooled ] && [[ $("$SLOT" status) == *"pool containers:"*"slot 1: db"* ]]'
DEV_TEAM_SLOTS_CONTAINERS=1 DEV_TEAM_SLOT_WAIT=0.005 "$SLOT" run db2 --pool containers -- true 2>/dev/null
ok "a pool has slots of its own"        '[ $? = 75 ]'
wait

"$SLOT" run hold -- sleep 1 2>/dev/null &
sleep 0.3
DEV_TEAM_SLOT_WAIT=0.005 "$SLOT" run late -- true 2>/dev/null
ok "gives up past the longest wait"   '[ $? = 75 ]'
wait
kill -9 "$HOLD" 2>/dev/null
exit $fail
