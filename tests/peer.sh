#!/bin/bash
# Tests for bin/peer against a fake orca CLI (tests/fake-orca): the Orca calls each command makes, and its refusals.
# Run: tests/peer.sh
cd "$(dirname "$0")/.." || exit 1
REPO=$PWD PEER=$PWD/bin/peer
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
mkdir -p "$T/bin" "$T/orca" "$T/claude" "$T/proj"
ln -s "$REPO/tests/fake-orca" "$T/bin/orca"
unset CLAUDE_CODE_SESSION_ID DEV_TEAM_CLAUDE
export PATH="$T/bin:$PATH" FAKE_ORCA_DIR="$T/orca" CLAUDE_CONFIG_DIR="$T/claude" DEV_TEAM_WATCH_POLL=0 DEV_TEAM_STEP_SEC=0
export ORCA_TERMINAL_HANDLE=term_coord
cd "$T/proj" && git init -q
runtime() { printf -- '- **Runtime: Orca.** Roles run as Orca peers. %s Peer size limit: 2k. Board: off.\n- **Role models:** senior-developer: sonnet/medium; reviewer: high\n' "$1" > CLAUDE.md; }
runtime "Team model: opus. Fallback model: sonnet. Advisor: fable."
fail=0

ok()    { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }
state() { python3 -c 'import json,sys;p=sys.argv[1];s=json.load(open(p));s[sys.argv[2]]=json.loads(sys.argv[3]);json.dump(s,open(p,"w"))' "$T/orca/state.json" "$1" "$2"; }
shows() { python3 -c 'import json,sys;p=sys.argv[1];s=json.load(open(p));s["screens"][sys.argv[2]]=sys.argv[3];json.dump(s,open(p,"w"))' "$T/orca/state.json" "$1" "$2"; }
run()   { : > "$T/orca/calls.log"; OUT=$("$PEER" "$@" 2>&1); RC=$?; }
hook()  { : > "$T/orca/calls.log"; OUT=$(echo "$2" | "$PEER" hook "$1" 2>&1); RC=$?; }
called() { grep -q -- "$1" "$T/orca/calls.log"; }
launched() { grep '"terminal", "create"' "$T/orca/calls.log"; }
command() { python3 -c 'import json,sys;print([c for c in map(json.loads,open(sys.argv[1])) if c[:2]==["terminal","create"]][-1][-1])' "$T/orca/calls.log"; }
start_args() { grep '"worker-start"' "$T/orca/calls.log"; }
reg()   { python3 -c 'import json,sys;r=json.load(open(".git/dev-team/peers.json"));print(eval(sys.argv[1]))' "$1"; }
home()  { reg "r['homes']['$1']['$2']"; }

# dispatch: a new home, launched with the pinned settings
run dispatch dt-dev-1 senior-developer "Implement T01"
ok "new home needs --worktree"             '[ $RC = 2 ] && [[ $OUT == *"pass --worktree"* ]]'
ok "first call creates the team run"      'called run-create && [ "$(reg "r[\"run\"]")" = run_0a1b2c ]'
ok "the caller is the coordinator"         '[ "$(reg "r[\"coordinator\"][\"terminal\"]")" = term_coord ]'
run dispatch dt-dev-1 senior-developer "Implement T01" --worktree new-child --name feat-a --base-branch feat
ok "new worktree made as a child"          'called "\"worktree\", \"create\", \"--name\", \"feat-a\", \"--base-branch\", \"feat\", \"--parent-worktree\", \"current\""'
ok "role model and effort, no fallback twin" 'launched | grep -q "\"--worktree\", \"path:/wt/feat-a\", \"--title\", \"dt-dev-1\", \"--command\", \"claude --model sonnet --effort medium\"\]"'
ok "worker-start takes the new terminal"   '[ $RC = 0 ] && start_args | grep -q "\"--terminal\", \"term_1\", \"--worktree\", \"path:/wt/feat-a\""'
ok "spec opens with the role line"         'start_args | grep -q "You are the dev-team senior-developer peer \[dev-team home dt-dev-1\]"'
ok "later calls reuse the run"             '! called run-create && called "\"run-use\", \"--id\", \"run_0a1b2c\""'
ok "home recorded with its model"          '[ "$(reg "[r[\"homes\"][\"dt-dev-1\"][k] for k in (\"terminal\",\"worktree\",\"model\",\"effort\")]")" = "['"'"'term_1'"'"', '"'"'/wt/feat-a'"'"', '"'"'sonnet'"'"', '"'"'medium'"'"']" ]'
run dispatch dt-architect principal-engineer "Plan F1" --worktree path:/wt/feat-a
ok "team model, role effort, fallback, advisor" '[ "$(command)" = "claude --model opus --effort xhigh --fallback-model sonnet --settings '"'"'{\"advisorModel\": \"fable\"}'"'"'" ]'
ok "advisor roles hear about it"           'start_args | grep -q "You have an advisor model"'
DEV_TEAM_CLAUDE="claude --permission-mode acceptEdits" run dispatch dt-reviewer reviewer "Review F1" --worktree path:/wt/feat-a
ok "effort-only override, no advisor"      '[ "$(command)" = "claude --permission-mode acceptEdits --model opus --effort high --fallback-model sonnet" ] && ! start_args | grep -q "advisor model"'
runtime "Board: off."
run dispatch dt-product product-manager "Brief APP-1" --worktree path:/wt/feat-a
ok "no Team model: refuses to launch"      '[ $RC = 2 ] && [[ $OUT == *"no Team model"* ]] && ! launched'
runtime "Team model: opus. Fallback model: sonnet. Advisor: fable."

# dispatch: refusals
run dispatch dt-dev-1 senior-developer "Implement T02"
ok "refuses a home still working"          '[ $RC = 2 ] && [[ $OUT == *"still working"* ]] && ! called worker-start'
state stage '"settled"'
run dispatch dt-dev-1 reviewer "Review"
ok "refuses a role the home does not hold" '[ $RC = 2 ] && [[ $OUT == *"is a senior-developer home"* ]]'
run dispatch --keep dt-dev-1 senior-developer "Fix" --worktree path:/wt/other
ok "refuses --keep with a worktree"        '[ $RC = 2 ] && ! called worker-start'
shows term_1 "Done.
  2 background shells · ↓ to manage"
run dispatch dt-dev-1 senior-developer "Implement T02"
ok "refuses a peer with a background shell" '[ $RC = 2 ] && [[ $OUT == *"is busy"* ]] && ! called "\"close\"" && ! launched'
shows term_1 "❯ "

# dispatch: fresh, keep, another worktree, a failed start
run dispatch dt-dev-1 senior-developer "Implement T02"
ok "fresh task: old session closed"        '[ $RC = 0 ] && called "\"worker-release\", \"--dispatch\", \"ctx_1\"" && called "\"terminal\", \"close\", \"--terminal\", \"term_1\""'
ok "fresh task: relaunched, same worktree" 'launched | grep -q "path:/wt/feat-a" && start_args | grep -q "\"--terminal\", \"term_4\"" && [ "$(home dt-dev-1 terminal)" = term_4 ]'
state stage '"settled"'
run dispatch --keep dt-dev-1 senior-developer "Fix review findings"
ok "--keep: same session, no launch"       '[ $RC = 0 ] && ! launched && ! called "\"close\"" && start_args | grep -q "\"--terminal\", \"term_4\""'
state stage '"settled"'
run dispatch dt-dev-1 senior-developer "Implement T03" --worktree path:/wt/other
ok "another worktree: launched there"      'launched | grep -q "path:/wt/other" && [ "$(home dt-dev-1 worktree)" = /wt/other ]'
state stage '"settled"'; state start_fail true
run dispatch dt-dev-1 senior-developer "Implement T04"
ok "failed start: new terminal still recorded" '[ $RC = 1 ] && [ "$(home dt-dev-1 terminal)" = term_6 ] && [ "$(home dt-dev-1 dispatch)" = None ]'
state start_fail false
run dispatch dt-dev-1 senior-developer "Implement T04"
ok "next dispatch closes it"               '[ $RC = 0 ] && called "\"terminal\", \"close\", \"--terminal\", \"term_6\""'

# switch: live peers get the new model and effort, confirmed on screen
runtime "Team model: claude-opus-5-5. Fallback model: sonnet. Advisor: fable."
shows term_2 "/model claude-opus-5-5
  ⎿  Set model to Opus 5.5
  ⎿  Set effort level to xhigh"
run switch dt-architect dt-dev-1
ok "switch types /model and /effort"       'called "\"--text\", \"/model claude-opus-5-5\"" && called "\"--text\", \"/effort xhigh\""'
ok "switch confirms on the screen"         '[[ $OUT == *"dt-architect: switched to claude-opus-5-5/xhigh"* ]] && [ "$(home dt-architect model)" = claude-opus-5-5 ]'
ok "role override is unchanged"            '[[ $OUT == *"dt-dev-1: already on sonnet/medium"* ]]'
run switch dt-reviewer
ok "unconfirmed switch is reported"        '[[ $OUT == *"not confirmed"* ]] && [ "$(home dt-reviewer model)" = opus ]'

# sleep and wake
state stage '"running"'
run sleep dt-dev-1
ok "sleep leaves a working peer awake"     '[[ $OUT == *"still working"* ]] && ! called "\"close\""'
state stage '"settled"'
run sleep --idle
ok "sleep --idle closes every idle peer"   '[[ $OUT == *"dt-dev-1: asleep"* ]] && [[ $OUT == *"dt-reviewer: asleep"* ]] && [ "$(home dt-dev-1 terminal)" = None ]'
run tell dt-dev-1 "Install" "Yes"
ok "tell refuses a sleeping peer"          '[ $RC = 2 ] && [[ $OUT == *"asleep"* ]] && ! called "\"send\""'
run dispatch --keep dt-dev-1 senior-developer "Fix"
ok "--keep refuses a sleeping peer"        '[ $RC = 2 ] && ! called worker-start'
run list
ok "list shows asleep, model and effort"   '[[ $OUT == *"dt-dev-1"*"asleep"*"sonnet/medium"* ]]'
run dispatch dt-dev-1 senior-developer "Implement T05"
ok "dispatch wakes it in its worktree"     '[ $RC = 0 ] && [[ $OUT == *"(wake,"* ]] && launched | grep -q "path:/wt/other" && ! called "\"close\""'

# tell
state stage '"settled"'
run tell dt-dev-1 "Install" "Yes, install the build"
ok "tell refuses a settled peer"           '[ $RC = 2 ] && [[ $OUT == *"peer dispatch --keep"* ]] && ! called "\"send\""'
state stage '"running"'
run tell dt-dev-1 "Install" "Yes, install the build"
ok "tell mails the dispatch and nudges"    '[ $RC = 0 ] && called "\"--to\", \"dispatch:$(home dt-dev-1 dispatch)\"" && called "From coordinator: Install" && [[ $OUT == *"nudge delivered"* ]]'
state send_reply '"accepted; retry with --retry-request 4f2a-9c; no turn start was observed"'; shows "$(home dt-dev-1 terminal)" "> From coordinator: Install"
run tell dt-dev-1 "Install" "Yes"
ok "busy peer: nudge queued"               '[ $RC = 0 ] && [[ $OUT == *"nudge queued"* ]] && called "\"--retry-request\", \"4f2a-9c\""'
shows "$(home dt-dev-1 terminal)" ""
run tell dt-dev-1 "Install" "Yes"
ok "unconfirmed nudge exits 2"             '[ $RC = 2 ] && [[ $OUT == *"NUDGE NOT CONFIRMED"* ]]'
state send_reply '"sent"'; shows "$(home dt-dev-1 terminal)" "❯ "
run tell dt-dev-1 "Re: schedule" "Weekly" --reply msg_9
ok "--reply answers the ask"               'called "\"reply\", \"--run\", \"run_0a1b2c\", \"--id\", \"msg_9\""'

# pending and watch
BODY=$(python3 -c 'print("x" * 800 + "\nFriction: #4 +1")')
state batches "[{\"deliveryId\":\"dlv_1\",\"messages\":[{\"type\":\"heartbeat\",\"subject\":\"alive\"}]},
                {\"deliveryId\":\"dlv_2\",\"messages\":[{\"type\":\"status\",\"id\":\"msg_3\",\"from_handle\":\"$(home dt-dev-1 terminal)\",\"subject\":\"Done\",\"body\":$(python3 -c 'import json,sys;print(json.dumps(sys.argv[1]))' "$BODY")},
                {\"type\":\"question\",\"id\":\"msg_4\",\"from_handle\":\"$(home dt-dev-1 terminal)\",\"subject\":\"May I install?\",\"body\":\"Steps ready\"}]}]"
run pending
ok "pending acks a heartbeat-only batch"   'called "\"--ack\", \"dlv_1\""'
ok "pending shows the real batch"          '[ $RC = 1 ] && [[ $OUT == *"question | dt-dev-1 | id msg_4 | May I install?"* ]] && [[ $OUT == *"--ack dlv_2"* ]] && ! called "--ack\", \"dlv_2"'
ok "a cut-off report keeps its Friction line" '[[ $OUT == *"… Friction: #4 +1"* ]]'
run watch 0.02
ok "watch returns on the batch"            '[ $RC = 0 ] && [[ $OUT == *"May I install?"* ]] && [ ! -e .git/dev-team/watch.pid ]'

# guard hooks
hook prompt '{"session_id":"s1"}'
ok "hook: questions first, then reports"   '[[ $OUT == *"additionalContext"* ]] && python3 -c "import json,sys;t=json.loads(sys.argv[1])[\"hookSpecificOutput\"][\"additionalContext\"];sys.exit(not t.index(\"PEER QUESTIONS\") < t.index(\"msg_4\") < t.index(\"not handled yet\") < t.index(\"msg_3\"))" "$OUT"'
hook stop '{"session_id":"s1"}'
ok "hook: stop blocks on unhandled reports" '[[ $OUT == *"\"decision\": \"block\""* ]]'
hook stop '{"session_id":"s1","stop_hook_active":true}'
ok "hook: a second stop is let through"    '[ -z "$OUT" ]'
ORCA_TERMINAL_HANDLE=term_2 hook stop '{"session_id":"s2"}'
ok "hook: quiet in a peer's session"       '[ -z "$OUT" ] && ! called check'
state batches '[]'
hook stop '{"session_id":"s1"}'
ok "hook: work in flight, no watcher"      '[[ $OUT == *"block"* ]] && [[ $OUT == *"1 peer task(s) in flight (dt-dev-1)"* ]]'
sleep 30 & W=$!; echo $W > .git/dev-team/watch.pid
hook stop '{"session_id":"s1"}'
ok "hook: quiet while a watcher runs"      '[ -z "$OUT" ]'
kill $W; wait $W 2>/dev/null
mv CLAUDE.md CLAUDE.off; hook prompt '{}'; mv CLAUDE.off CLAUDE.md
ok "hook: quiet outside an Orca project"   '[ -z "$OUT" ] && ! called check'
run pending
ok "pending: nothing unhandled"            '[ $RC = 0 ] && [[ $OUT == "no unhandled reports" ]]'

# watch: stuck screens, usage limits, and what launches do about them
T1=$(home dt-dev-1 terminal)
shows "$T1" "⏺ Reading the plan
  ⎿  API Error: 529 {\"type\":\"error\",\"error\":{\"type\":\"overloaded_error\"}}
❯ "
DEV_TEAM_STUCK_MIN=0 run watch 0.02
ok "watch reports STUCK on an API error"   '[[ $OUT == "STUCK | dt-dev-1 | API Error: 529"* ]] && [[ $OUT == *"peer tell dt-dev-1"* ]]'
shows "$T1" "✻ Retrying… API Error: 529 (esc to interrupt)"
DEV_TEAM_STUCK_MIN=0 DEV_TEAM_STALL_MIN=999 run watch 0.02
ok "a retry in progress is not STUCK"      '[[ $OUT == "nothing after 0.02 min" ]]'
shows "$T1" "  ⎿  You've hit your Fable limit · resets Nov 29
❯ "
DEV_TEAM_STUCK_MIN=0 run watch 0.02
ok "watch reports LIMIT"                   '[[ $OUT == "LIMIT | dt-dev-1 | hit your Fable limit · resets Nov 29"* ]]'
run limits
ok "the limit is recorded"                 '[[ $OUT == "fable"*"resets Nov 29"* ]]'
state stage '"settled"'
run dispatch dt-architect principal-engineer "Plan F2"
ok "advisor skipped while its model is out" '[ $RC = 0 ] && [[ $OUT == *"advisor fable is out of usage"* ]] && ! launched | grep -q advisorModel'
shows "$T1" "❯ "; shows "$(home dt-architect terminal)" "hit your Opus 5.5 limit · resets Nov 29"
DEV_TEAM_STUCK_MIN=0 run watch 0.02
state stage '"settled"'
run dispatch dt-architect principal-engineer "Plan F3"
ok "team model out: launches on the fallback" '[[ $OUT == *"launching on the fallback, sonnet"* ]] && [ "$(command)" = "claude --model sonnet --effort xhigh" ]'
run limits --clear fable
ok "limits --clear removes one"            '[[ $OUT == "cleared: fable" ]] && [[ "$("$PEER" limits)" != *fable* ]]'
python3 - <<'PY'
import json, datetime
y = datetime.date.today() - datetime.timedelta(days=1)
json.dump({"opus": {"text": f"hit your Opus limit · resets {y:%b} {y.day}", "seen": str(y)}}, open(".git/dev-team/limits.json", "w"))
PY
run limits
ok "a limit past its reset day expires"    '[[ $OUT == "no model is out of usage" ]]'

# sizes and SIZE: transcripts are found by the home marker, also when homes share a worktree
shows "$T1" "❯ "; state stage '"running"'
D="$T/claude/projects/-wt-feat-a"; mkdir -p "$D"
python3 - "$D" <<'PY'
import json, os, sys, time
d = sys.argv[1]
def write(name, home, tokens, age):
    p = os.path.join(d, name)
    with open(p, "w") as f:
        f.write(json.dumps({"type": "user", "message": {"content": f"[dev-team home {home}]"}}) + "\n")
        f.write(json.dumps({"type": "assistant", "message": {"usage": {"input_tokens": 100, "cache_read_input_tokens": tokens}}}) + "\n")
    os.utime(p, (time.time() - age, time.time() - age))
write("a.jsonl", "dt-dev-1", 5000, 60)
write("b.jsonl", "dt-reviewer", 1000, 0)
PY
python3 -c 'import json;p=".git/dev-team/peers.json";r=json.load(open(p));r["homes"]["dt-dev-1"]["worktree"]=r["homes"]["dt-reviewer"]["worktree"]="/wt/feat-a";json.dump(r,open(p,"w"))'
run sizes
ok "sizes picks each home's transcript"    '[[ $OUT == *"dt-dev-1"*"~5k / 2k  OVER"* ]] && [[ $OUT == *"dt-reviewer"*"~1k / 2k"* ]]'
DEV_TEAM_STALL_MIN=999 run watch 0.02
ok "watch reports SIZE"                    '[[ $OUT == "SIZE | dt-dev-1 | ~5k"* ]]'
DEV_TEAM_STALL_MIN=999 run watch 0.02
ok "SIZE fires once per session"           '[[ $OUT == "nothing after 0.02 min" ]]'
DEV_TEAM_STALL_MIN=0 run watch 0.02
ok "watch reports STALL"                   '[[ $OUT == "STALL | "* ]]'

exit $fail
