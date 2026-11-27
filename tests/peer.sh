#!/bin/bash
# Tests for bin/peer against a fake orca CLI (tests/fake-orca): the Orca calls each command makes, and its refusals.
# Run: tests/peer.sh
cd "$(dirname "$0")/.." || exit 1
REPO=$PWD PEER=$PWD/bin/peer
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
mkdir -p "$T/bin" "$T/orca" "$T/claude" "$T/proj"
ln -s "$REPO/tests/fake-orca" "$T/bin/orca"
cat > "$T/bin/gh" <<'EOF'
#!/usr/bin/env python3
# A stand-in for gh: PRs from $FAKE_GH_PRS ({"owner/repo#n": {...}, "mine": [n, ...]}).
import json, os, sys
a = sys.argv[1:]
prs = json.load(open(os.environ["FAKE_GH_PRS"])) if os.path.exists(os.environ["FAKE_GH_PRS"]) else {}
if a[:2] == ["repo", "view"]:
    print("acme/app")
elif a[:2] == ["pr", "view"]:
    p = prs.get(a[a.index("-R") + 1] + "#" + a[2])
    print(json.dumps(p)) if p else sys.exit(1)
elif a[:2] == ["pr", "list"]:
    print("\n".join(str(n) for n in prs.get("mine", [])))
EOF
chmod +x "$T/bin/gh"
unset CLAUDE_CODE_SESSION_ID DEV_TEAM_CLAUDE
export PATH="$T/bin:$PATH" FAKE_ORCA_DIR="$T/orca" CLAUDE_CONFIG_DIR="$T/claude" DEV_TEAM_WATCH_POLL=0 DEV_TEAM_STEP_SEC=0 \
       DEV_TEAM_RECHECK_SEC=0 FAKE_GH_PRS="$T/prs.json"
export ORCA_TERMINAL_HANDLE=term_coord
cd "$T/proj" && git init -q
runtime() { printf -- '- **Runtime: Orca.** Roles run as Orca peers. %s Peer size limit: 2k. Worktree cards: off.\n- **Role models:** senior-developer: sonnet/medium; reviewer: high\n' "$1" > CLAUDE.md; }
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
setreg() { python3 -c 'import json,sys;p=".git/dev-team/peers.json";r=json.load(open(p));exec(sys.argv[1]);json.dump(r,open(p,"w"))' "$1"; }
fake()  { python3 -c 'import json,sys;p=sys.argv[1];s=json.load(open(p));exec(sys.argv[2]);json.dump(s,open(p,"w"))' "$T/orca/state.json" "$1"; }
prs()   { python3 -c 'import json,sys;p=sys.argv[1];s=json.load(open(p));exec(sys.argv[2]);json.dump(s,open(p,"w"))' "$T/prs.json" "$1"; }

# dispatch: a new home, launched with the pinned settings
run dispatch dt-dev-1 senior-developer "Implement T01"
ok "new home needs --worktree"             '[ $RC = 2 ] && [[ $OUT == *"pass --worktree"* ]]'
ok "first call creates the team run"      'called run-create && [ "$(reg "r[\"run\"]")" = run_0a1b2c ]'
ok "the caller is the coordinator"         '[ "$(reg "r[\"coordinator\"][\"terminal\"]")" = term_coord ]'
run dispatch dt-dev-1 senior-developer "Implement T01" --worktree new-child --name feat-a --base-branch feat
ok "new worktree made as a child"          'called "\"worktree\", \"create\", \"--name\", \"feat-a\", \"--base-branch\", \"feat\", \"--parent-worktree\", \"current\""'
ok "role model and effort, no fallback twin" 'launched | grep -q "\"--worktree\", \"path:/wt/feat-a\", \"--title\", \"$(home dt-dev-1 name) · developer\", \"--command\", \"claude --model sonnet --effort medium\"\]"'
ok "the home has a name from the list"     'grep -q "\"$(home dt-dev-1 name)\"" "$REPO/bin/peer"'
ok "the role line tells the peer its name" 'start_args | grep -q "\[dev-team home dt-dev-1\]\. .*Your name on the team is $(home dt-dev-1 name)\."'
ok "worker-start takes the new terminal"   '[ $RC = 0 ] && start_args | grep -q "\"--terminal\", \"term_1\", \"--worktree\", \"path:/wt/feat-a\""'
ok "spec opens with the role line"         'start_args | grep -q "You are the dev-team senior-developer peer \[dev-team home dt-dev-1\]"'
ok "later calls reuse the run"             '! called run-create && called "\"run-use\", \"--id\", \"run_0a1b2c\""'
ok "home recorded with its model"          '[ "$(reg "[r[\"homes\"][\"dt-dev-1\"][k] for k in (\"terminal\",\"worktree\",\"model\",\"effort\")]")" = "['"'"'term_1'"'"', '"'"'/wt/feat-a'"'"', '"'"'sonnet'"'"', '"'"'medium'"'"']" ]'
run dispatch dt-architect principal-engineer "Plan F1" --worktree path:/wt/feat-a
ok "team model, role effort, fallback, advisor" '[ "$(command)" = "claude --model opus --effort xhigh --fallback-model sonnet --settings '"'"'{\"advisorModel\": \"fable\"}'"'"'" ]'
ok "advisor roles hear about it"           'start_args | grep -q "You have an advisor model"'
DEV_TEAM_CLAUDE="claude --permission-mode acceptEdits" run dispatch dt-reviewer reviewer "Review F1" --worktree path:/wt/feat-a
ok "effort-only override, no advisor"      '[ "$(command)" = "claude --permission-mode acceptEdits --model opus --effort high --fallback-model sonnet" ] && ! start_args | grep -q "advisor model"'
runtime "Worktree cards: off."
run dispatch dt-product product-manager "Brief APP-1" --worktree path:/wt/feat-a
ok "no Team model: refuses to launch"      '[ $RC = 2 ] && [[ $OUT == *"no Team model"* ]] && ! launched'
runtime "Team model: opus. Fallback model: sonnet. Advisor: fable."

# dispatch: refusals
run dispatch dt-dev-1 senior-developer "Implement T02"
ok "refuses a home still working"          '[ $RC = 2 ] && [[ $OUT == *"still working"* ]] && ! called worker-start'
state ready_fail true
run list
ok "a dispatch that failed at startup isn't working" '[[ $(grep "^dt-dev-1 " <<< "$OUT") != *working* ]]'
state ready_fail false
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
run tell dt-dev-1 "Install" "Yes" --wait
ok "tell refuses a sleeping peer"          '[ $RC = 2 ] && [[ $OUT == *"asleep"* ]] && ! called "\"send\""'
run dispatch --keep dt-dev-1 senior-developer "Fix"
ok "--keep refuses a sleeping peer"        '[ $RC = 2 ] && ! called worker-start'
run list
ok "list shows asleep, model and effort"   '[[ $OUT == *"dt-dev-1"*"asleep"*"sonnet/medium"* ]]'
run dispatch dt-dev-1 senior-developer "Implement T05"
ok "dispatch wakes it in its worktree"     '[ $RC = 0 ] && [[ $OUT == *"(wake,"* ]] && launched | grep -q "path:/wt/other" && ! called "\"close\""'

# tell
state stage '"settled"'
run tell dt-dev-1 "Install" "Yes, install the build" --wait
ok "tell refuses a settled peer"           '[ $RC = 2 ] && [[ $OUT == *"peer dispatch --keep"* ]] && ! called "\"send\""'
state stage '"running"'
run tell dt-dev-1 "Install" "Yes, install the build" --wait
ok "tell mails the dispatch and nudges"    '[ $RC = 0 ] && called "\"--to\", \"dispatch:$(home dt-dev-1 dispatch)\"" && called "From coordinator: Install" && [[ $OUT == *"nudge delivered"* ]]'
state send_reply '"accepted; retry with --retry-request 4f2a-9c; no turn start was observed"'; shows "$(home dt-dev-1 terminal)" "> From coordinator: Install"
run tell dt-dev-1 "Install" "Yes" --wait
ok "busy peer: nudge queued"               '[ $RC = 0 ] && [[ $OUT == *"nudge queued"* ]] && called "\"--retry-request\", \"4f2a-9c\""'
shows "$(home dt-dev-1 terminal)" ""
run tell dt-dev-1 "Install" "Yes" --wait
ok "unconfirmed nudge exits 2"             '[ $RC = 2 ] && [[ $OUT == *"NUDGE NOT CONFIRMED"* ]]'
waitfor() { for _ in $(seq 100); do eval "$1" && return 0; sleep 0.1; done; return 1; }
run tell dt-dev-1 "Install" "Yes"
ok "tell returns at once; the nudge runs in the background" '[ $RC = 0 ] && [[ $OUT == *"nudging dt-dev-1 in the background"* ]]'
waitfor '[ -s .git/dev-team/nudges-unconfirmed.txt ]'
run watch 0.02
ok "watch reports a nudge that didn't land"  '[[ $OUT == *"NUDGE | dt-dev-1 | not confirmed for '"'Install'"'"* ]]'
ok "a running watch holds the coordinator lock" '[ "$(cat .git/dev-team/coordinator.lock)" = owner ]'
echo advance > .git/dev-team/coordinator.lock
run watch 0.01
ok "but leaves a check-in's lock alone"        '[ "$(cat .git/dev-team/coordinator.lock)" = advance ]'
rm .git/dev-team/coordinator.lock
shows "$(home dt-dev-1 terminal)" "✻ Tinkering… (12s · esc to interrupt)"
run tell dt-dev-1 "Busy" "Yes"
sleep 1; waitfor '! pgrep -f "peer nudge dt-dev-1 Busy" >/dev/null'
run watch 0.01
ok "a busy peer's nudge isn't reported as missed" '[[ $OUT != *"NUDGE | dt-dev-1 | not confirmed for '"'Busy'"'"* ]]'
shows "$(home dt-dev-1 terminal)" ""
run watch 0.01
ok "and reports it once"                     '[[ $OUT != *NUDGE* ]]'
state send_reply '"sent"'; shows "$(home dt-dev-1 terminal)" "❯ "
run tell dt-dev-1 "Deploy" "Go"
ok "a background nudge reaches the terminal" 'waitfor "called \"From coordinator: Deploy\""'

# two peer commands saving side by side keep each other's changes (the registry is written under a lock, per home)
python3 - "$PEER" <<'PYEOF'
import importlib.machinery, importlib.util, sys
sys.dont_write_bytecode = True  # no bin/__pycache__ left behind
loader = importlib.machinery.SourceFileLoader("peer", sys.argv[1])
m = importlib.util.module_from_spec(importlib.util.spec_from_loader("peer", loader)); loader.exec_module(m)
a, b = m.load(), m.load()
a["homes"]["dt-dev-1"]["note"] = "from a"; m.save(a)
b["homes"]["dt-tmp"] = {"role": "senior-developer", "name": "Tess"}; m.save(b)
PYEOF
ok "side-by-side saves keep both changes"    '[ "$(home dt-dev-1 note)" = "from a" ] && [ "$(home dt-tmp name)" = Tess ]'
setreg 'r["homes"].pop("dt-tmp"); r["homes"]["dt-dev-1"].pop("note")'
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

# --- a second project: one-task models, re-check after start, stale shells, orphaned and dead sessions -----------
mkdir -p "$T/p2" && cd "$T/p2" && git init -q && rm -f "$T/orca/state.json"
runtime "Team model: opus. Fallback model: sonnet. Advisor: none."
run dispatch dt-dev-1 senior-developer "Spike" --worktree path:/wt/a --model haiku --effort low
ok "one-task model and effort"             '[ $RC = 0 ] && [ "$(command)" = "claude --model haiku --effort low --fallback-model sonnet" ] && [ "$(home dt-dev-1 once)" = True ]'
ok "list marks it as this task's"          '[[ $("$PEER" list) == *"haiku/low (this task)"* ]]'
run switch
ok "switch leaves a one-task model alone"  '[[ $OUT == *"dt-dev-1: on a model chosen for this one task"* ]] && ! called "/model"'
state stage '"settled"'
run dispatch --keep dt-dev-1 senior-developer "Fix" --model opus
ok "--keep refuses a one-task model"       '[ $RC = 2 ] && [[ $OUT == *"needs a fresh session"* ]]'
run dispatch dt-dev-1 senior-developer "T02"
ok "the next task is on the team settings" '[ "$(command)" = "claude --model sonnet --effort medium" ] && [ "$(home dt-dev-1 once)" = False ]'
state stage '"settled"'; state recheck_fail true
run dispatch dt-dev-1 senior-developer "T03"
ok "a dispatch that fails after ready is caught" '[ $RC = 1 ] && [[ $OUT == *"reported ready, but the dispatch failed"*"already owns an active dispatch"* ]] && [ "$(home dt-dev-1 dispatch)" != None ]'
state recheck_fail false; state stage '"settled"'; state version '"1.1.0"'
run dispatch --keep dt-dev-1 senior-developer "Fix findings"
ok "--keep refuses a shell from an older Orca" '[ $RC = 2 ] && [[ $OUT == *"started under Orca 1.0.0, and Orca is now 1.1.0"* ]] && ! called worker-start'
setreg 'r["homes"]["dt-dev-1"]["orca"] = None'; state start_fail true
run dispatch --keep dt-dev-1 senior-developer "Fix findings"
ok "a keep stuck at readiness says why"    '[ $RC = 1 ] && [[ $OUT == *"may predate the running Orca"* ]]'
state start_fail false; state orphan_on_close true
run sleep dt-dev-1
ok "an orphaned terminal counts as closed" '[[ $OUT == *"dt-dev-1: asleep"* ]] && [[ $OUT != *"did not close"* ]] && [ "$(home dt-dev-1 terminal)" = None ]'

state orphan_on_close false; state close_lag 2
setreg 'r["homes"]["dt-dev-1"].update(terminal="term_x", asleep=False)'; fake 's["terminals"]["term_x"]={"open": True, "path": "/wt/x"}'
run sleep dt-dev-1
ok "a terminal slow to close is waited for"  '[[ $OUT == *"dt-dev-1: asleep"* ]] && [[ $OUT != *"did not close"* ]]'
state close_lag 0
state orphan_on_close false
run dispatch dt-dev-1 senior-developer "T04"
state stage '"settled"'; fake "s['orphaned'] = ['$(home dt-dev-1 terminal)']"
run list
ok "list clears an orphaned terminal"      '[[ $OUT == *"dt-dev-1"*"asleep"* ]] && [ "$(home dt-dev-1 terminal)" = None ]'
state orphaned '[]'
run dispatch dt-dev-1 senior-developer "T05"
state stage '"settled"'
shows "$(home dt-dev-1 terminal)" "✻ Working… (esc to interrupt) · ← 1 agent
Resume this session with:
claude --resume 0f3c
$ "
run dispatch dt-dev-1 senior-developer "T06"
ok "a dead session's last screen is not busy" '[ $RC = 0 ] && [[ $OUT == *"(fresh,"* ]]'
state stage '"settled"'; TT=$(home dt-dev-1 terminal)
shows "$TT" "  2 background shells · ↓ to manage"
# Stand-ins run on python3: macOS hides the environment of system binaries such as /bin/sleep.
# bg <terminal> <command> [dir]: started outside this shell's jobs, in dir (default here).
bg() { (cd "${3:-.}" && ORCA_TERMINAL_HANDLE=$1 sh -c "$2 >/dev/null 2>&1 & echo \$!"); }
mkdir -p "$T/wt1" "$T/service"; setreg "r['homes']['dt-dev-1']['worktree'] = '$T/wt1'"
M=$(bg "$TT" "python3 -c 'import time; time.sleep(60)' fake-mcp-server" "$T/wt1")
V=$(bg "$TT" "python3 -c 'import time; time.sleep(60)' vite-dev" "$T/wt1")
W=$(bg "$TT" "python3 -c 'import time; time.sleep(60)' $T/wt1/node_modules/.bin/watcher" "$T/service")
S=$(bg "$TT" "python3 -c 'import time; time.sleep(60)' desktop-mcp-backend" "$T/service")
sleep 1
run dispatch dt-dev-1 senior-developer "T07"
ok "no Claude process in it: not busy"     '[ $RC = 0 ]'
ok "MCP servers it left are stopped"       '[[ $OUT == *"stopped 1 MCP server process(es)"*"fake-mcp-server"* ]] && ! kill -0 $M 2>/dev/null'
ok "anything else it left is named"        '[[ $OUT == *"still running from its closed session"*"vite-dev"* ]] && kill -0 $V'
ok "a process naming the worktree is named" '[[ $OUT == *"watcher"* ]] && kill -0 $W'
ok "a service run from elsewhere is left alone" '[[ $OUT != *"desktop-mcp-backend"* ]] && kill -0 $S'
kill $V $W $S
state stage '"settled"'; TT=$(home dt-dev-1 terminal)
shows "$TT" "✻ Working… (esc to interrupt)"
mkdir -p "$T/standin"; printf '#!/usr/bin/env python3\nimport time; time.sleep(60)\n' > "$T/standin/claude"; chmod +x "$T/standin/claude"
C=$(bg "$TT" "$T/standin/claude")
sleep 1
run dispatch dt-dev-1 senior-developer "T08"
ok "a live Claude mid-turn is busy"        '[ $RC = 2 ] && [[ $OUT == *"is busy"* ]]'
kill $C
shows "$TT" "✻ Pondering… (1m 12s · ↑ 1.2k tokens)"
run dispatch dt-dev-1 senior-developer "T08"
ok "the working line is busy"              '[ $RC = 2 ] && [[ $OUT == *"Pondering… (1m 12s"* ]]'
shows "$TT" "❯ 
  ⏵⏵ accept edits on · ← 1 agent · 1 monitor"
run sleep dt-dev-1
ok "a monitor beside '← 1 agent' is busy"   '[[ $OUT == *"is busy ('"'"'1 monitor'"'"'"* ]] && [ "$(home dt-dev-1 terminal)" = "$TT" ]'
shows "$TT" "❯ 
  ⏵⏵ accept edits on · ← 1 agent"
run sleep dt-dev-1
ok "an idle prompt's '← 1 agent' is not busy" '[[ $OUT == "dt-dev-1: asleep" ]]'
run dispatch dt-dev-1 senior-developer "T08"
state stage '"settled"'; shows "$(home dt-dev-1 terminal)" "❯ "
runtime "Team model: opus. Fallback model: sonnet. Advisor: none. Session caches: \`.cache/mcp-*\`, \`../outside\`."
mkdir -p "$T/wt2/.cache/mcp-browser" "$T/outside"
run dispatch dt-dev-2 senior-developer "T09" --worktree "path:$T/wt2"
state stage '"settled"'
run sleep dt-dev-2
ok "session caches cleared, inside the worktree only" '[[ $OUT == *"cleared $T/wt2/.cache/mcp-browser"* ]] && [ ! -e "$T/wt2/.cache/mcp-browser" ] && [ -d "$T/outside" ]'

# adopt: a terminal started outside peer becomes a home
fake 's["terminals"]["term_99"] = {"open": True, "path": "/wt/hand"}'
run adopt dt-dev-3 senior-developer term_99
ok "adopt makes a home of an open terminal" '[ $RC = 0 ] && [ "$(home dt-dev-3 worktree)" = /wt/hand ]'
run adopt dt-dev-4 senior-developer term_404
ok "adopt refuses a terminal that is not open" '[ $RC = 2 ]'
run dispatch dt-dev-3 senior-developer "T10"
ok "its next dispatch closes that terminal" '[ $RC = 0 ] && called "\"terminal\", \"close\", \"--terminal\", \"term_99\"" && launched | grep -q "path:/wt/hand"'

# a remote Orca server
state stage '"settled"'
run dispatch dt-dev-r senior-developer "Remote T1" --on gpu-box --worktree current
ok "remote: current is refused"            '[ $RC = 2 ] && [[ $OUT == *"ambiguous"* ]]'
run dispatch dt-dev-r senior-developer "Remote T1" --on gpu-box --worktree new-top-level --name feat-r
ok "remote: new-top-level needs --repo"    '[ $RC = 2 ] && [[ $OUT == *"needs --repo and --name"* ]]'
run dispatch dt-dev-r senior-developer "Remote T1" --on gpu-box --worktree new-top-level --repo name:app --name feat-r --model opus
ok "remote: Orca starts it, model and effort pinned" '[ $RC = 0 ] && ! launched && start_args | grep -q "\"--on\", \"gpu-box\", \"--agent\", \"claude\", \"--model\", \"opus\", \"--effort\", \"medium\", \"--worktree\", \"new-top-level\", \"--repo\", \"name:app\", \"--name\", \"feat-r\""'
ok "remote: what a launch there cannot take is said" '[[ $OUT == *"on gpu-box a launch takes only the model and effort"* ]]'
ok "remote: home keeps server, terminal, selector" '[ "$(home dt-dev-r env)" = gpu-box ] && [[ $(home dt-dev-r terminal) == rterm_* ]] && [ "$(home dt-dev-r worktree_sel)" = "id:repo1::/remote/feat-r" ]'
run tell dt-dev-r "Go" "Yes" --wait
ok "remote: tell nudges through its server" '[[ $OUT == *"nudge delivered"* ]] && called "\"--enter\", \"--environment\", \"gpu-box\""'
shows "$(home dt-dev-r terminal)" "  ⎿  API Error: 500 internal
❯ "
DEV_TEAM_STUCK_MIN=0 run watch 0.02
ok "remote: watch reads its screen there"  '[[ $OUT == "STUCK | dt-dev-r"* ]] && called "\"--screen\", \"--environment\", \"gpu-box\""'
hook stop '{"session_id":"x"}'
ok "remote: in flight for the guard hook"  '[[ $OUT == *"in flight ("*"dt-dev-r"* ]]'
state stage '"settled"'; RT=$(home dt-dev-r terminal)
run dispatch dt-dev-r senior-developer "Remote T2"
ok "remote: fresh closes there, relaunches in its worktree" '[ $RC = 0 ] && called "\"close\", \"--terminal\", \"$RT\", \"--environment\", \"gpu-box\"" && start_args | grep -q "\"--worktree\", \"id:repo1::/remote/feat-r\""'
state stage '"settled"'
run dispatch --keep dt-dev-r senior-developer "Fix"
ok "remote: --keep is refused"             '[ $RC = 2 ] && [[ $OUT == *"takes each task fresh"* ]]'
run sizes
ok "remote: no local transcript"           '[[ $OUT == *"dt-dev-r"*"on gpu-box: no local transcript"* ]]'

# PRs: owners, CI and conflict alerts, PR changes with the Owner board on, sweep
cat > "$T/prs.json" <<'EOF'
{"acme/app#12": {"state": "OPEN", "isDraft": true, "mergeable": "MERGEABLE", "statusCheckRollup": [{"name": "unit", "conclusion": "SUCCESS"}]},
 "acme/mobile#7": {"state": "OPEN", "isDraft": false, "mergeable": "MERGEABLE", "statusCheckRollup": []},
 "acme/app#30": {"state": "OPEN", "isDraft": false, "mergeable": "CONFLICTING", "statusCheckRollup": []},
 "mine": [12, 30]}
EOF
run pr dt-dev-1 12 https://github.com/acme/mobile/pull/7
ok "pr records the owner"                  '[[ $OUT == "dt-dev-1 owns #12, mobile#7" ]]'
DEV_TEAM_STALL_MIN=999 run watch 0.02
ok "a first look only records the PR"      '[[ $OUT == "nothing after 0.02 min" ]] && [ "$(reg "r[\"prs\"][\"acme/app#12\"][\"draft\"]")" = True ]'
prs 's["acme/app#12"]["statusCheckRollup"] = [{"name": "unit", "conclusion": "FAILURE"}]'
DEV_TEAM_STALL_MIN=999 run watch 0.02
ok "a failing check on an idle owner's PR" '[[ $OUT == "CI | #12 | dt-dev-1 | failed: unit: route it to dt-dev-1"* ]]'
DEV_TEAM_STALL_MIN=999 run watch 0.02
ok "the same failure wakes it once"        '[[ $OUT == "nothing after 0.02 min" ]]'
state stage '"running"'; prs 's["acme/app#12"]["statusCheckRollup"].append({"name": "lint", "conclusion": "FAILURE"})'
DEV_TEAM_STALL_MIN=999 run watch 0.02
ok "not while its owner is working"        '[[ $OUT == "nothing after 0.02 min" ]]'
state stage '"settled"'
DEV_TEAM_STALL_MIN=999 run watch 0.02
ok "once the owner is idle"                '[[ $OUT == "CI | #12 | dt-dev-1 | failed: lint"* ]]'
prs 's["acme/mobile#7"]["mergeable"] = "CONFLICTING"'
DEV_TEAM_STALL_MIN=999 run watch 0.02
ok "a merge conflict wakes it"             '[[ $OUT == "CONFLICT | mobile#7 | dt-dev-1 | merge conflict"* ]]'
printf -- '- **Owner board:** https://claude.ai/artifact/x\n' >> CLAUDE.md
prs 's["acme/app#12"]["isDraft"] = False; s["acme/mobile#7"]["state"] = "MERGED"'
DEV_TEAM_STALL_MIN=999 run watch 0.02
ok "board on: ready and merged wake it"    '[[ $OUT == *"PR | #12 | dt-dev-1 | marked ready"* ]] && [[ $OUT == *"PR | mobile#7 | dt-dev-1 | merged"* ]]'
state batches "[{\"deliveryId\":\"dlv_9\",\"messages\":[{\"type\":\"worker_done\",\"id\":\"msg_9\",\"from_handle\":\"$(home dt-dev-3 terminal)\",\"subject\":\"Done\",\"body\":\"Opened https://github.com/acme/app/pull/31\"}]}]"
run pending
ok "a PR link in a report records its owner" '[ "$(reg "r[\"prs\"][\"acme/app#31\"][\"home\"]")" = dt-dev-3 ]'
state batches '[]'
run prs --sweep
ok "sweep: failing and conflicting PRs, owners" '[ $RC = 1 ] && [[ $OUT == *"#12"*"dt-dev-1"*"failing: lint, unit"* ]] && [[ $OUT == *"#30"*"?"*"merge conflict"* ]]'

# the Owner board: stamp, guard, drift after a watch, peers rows
mkdir -p docs; echo "| f | Implementation |" > docs/status.md
hook prompt '{"session_id":"x"}'
ok "board guard: no stamp yet"             '[[ $OUT == *"no board write recorded yet: update the board, then"*"peer board-stamp"* ]]'
mkdir -p "$T/rows"
run board-stamp --rows "$T/rows"
hook stop '{"session_id":"x"}'
ok "board guard: quiet once stamped"       '[ -z "$OUT" ]'
echo "| g | Review |" >> docs/status.md
hook stop '{"session_id":"x"}'
ok "board guard: a status change blocks the stop" '[[ $OUT == *"block"*"status changed since the last board write: update the board, then"* ]]'
hook prompt '{"session_id":"x"}'
ok "board guard: the prompt hears it too"  '[[ $OUT == *"additionalContext"*"status changed since the last board write"* ]]'
ORCA_TERMINAL_HANDLE=$(home dt-dev-3 terminal) hook stop '{"session_id":"p"}'
ok "board guard: not in a peer's session"  '[ -z "$OUT" ]'
printf '%s' '{"data": {"pr": 7, "repo": "acme/mobile", "state": "review"}}' > "$T/rows/r1.json"
run board-stamp
DEV_TEAM_STALL_MIN=999 run watch 0.02
ok "watch reports drift on the listed rows" '[[ $OUT == *"BOARD | r1: board says review, should be done (PR merged)"* ]]'
DEV_TEAM_STALL_MIN=999 run watch 0.02
ok "the same drift wakes it once"          '[[ $OUT != *"BOARD | r1"* ]]'
run board-stamp --rows "$T/rows"
DEV_TEAM_STALL_MIN=999 run watch 0.02
ok "a new snapshot reports drift afresh"   '[[ $OUT == *"BOARD | r1"* ]]'
run list --board-json "$T/bj"
ok "board json: one peers row per home"    'python3 -c "import json,sys;d=json.load(open(sys.argv[1]));sys.exit(not (d[\"name\"]==sys.argv[2] and d[\"role\"]==\"senior-developer\" and d[\"doing\"].startswith(\"Idle · last: \") and d[\"order\"]==1))" "$T/bj/peers/dt-dev-1.json" "$(home dt-dev-1 name)"'
ok "board json: a sleeping home says so"   'grep -q "\"doing\": \"Asleep · last: T09\"" "$T/bj/peers/dt-dev-2.json"'
ok "board json: every home has its own name" '[ "$(reg "len({h[\"name\"] for h in r[\"homes\"].values()}) == len(r[\"homes\"])")" = True ]'

# team: the homes Team setup names, made now or by their first dispatch, each with a name
mkdir -p "$T/p4" && cd "$T/p4" && git init -q
printf -- '- **Runtime: Orca.** Roles run as Orca peers. Team model: opus. Fallback model: none. Advisor: none.\n## Team setup\n- **Homes.** `dt-product`, `dt-reviewer`, `dt-dev-1` to `dt-dev-3` (size medium), each in its own worktree named after the home.\n' > CLAUDE.md
run team --create
ok "team --create makes every named home"  '[ $RC = 0 ] && [ "$(reg "sorted(r[\"homes\"])")" = "['"'"'dt-dev-1'"'"', '"'"'dt-dev-2'"'"', '"'"'dt-dev-3'"'"', '"'"'dt-product'"'"', '"'"'dt-reviewer'"'"']" ]'
ok "worktrees only, top level, no session" 'called "\"worktree\", \"create\", \"--name\", \"dt-dev-3\", \"--no-parent\"" && ! launched && [ "$(home dt-dev-3 asleep)" = True ]'
ok "roles from the home names"             '[ "$(home dt-product role) $(home dt-dev-2 role)" = "product-manager senior-developer" ]'
ok "each worktree shows its name and role" 'called "\"--display-name\", \"$(home dt-product name) · product manager\""'
run team --create
ok "team --create again makes nothing"     '[ $RC = 0 ] && ! called "\"worktree\", \"create\""'
run dispatch dt-dev-2 senior-developer "Implement T02" --worktree new-top-level --name dt-dev-2
ok "first dispatch reuses the made worktree" '[ $RC = 0 ] && ! called "\"worktree\", \"create\"" && launched | grep -q "\"path:/wt/dt-dev-2\""'
run team --rename dt-dev-2 Sandra
ok "rename: the new name, on the worktree too" '[ "$(home dt-dev-2 name)" = Sandra ] && called "\"--display-name\", \"Sandra · developer\""'
run team --rename dt-dev-2 "two words"
ok "rename refuses what isn't one name"    '[ $RC = 2 ]'
run team
ok "team lists who is who"                 '[[ $OUT == *"dt-dev-2       Sandra · developer"* ]]'
printf -- '- **Runtime: Orca.** Roles run as Orca peers.\n' > CLAUDE.md
run team --create
ok "no Homes rule: team --create refuses"  '[ $RC = 2 ] && [[ $OUT == *"no Team setup"* ]]'

# a document role's own worktree moves to the latest default branch before each task (orca-recommended § Roles and git)
G="git -c user.name=t -c user.email=t@t"
mkdir -p "$T/p5" && cd "$T/p5" && git init -q -b main && $G commit -q --allow-empty -m one
git init -q --bare "$T/p5-origin.git" && git remote add origin "$T/p5-origin.git" && git push -q -u origin main 2>/dev/null
git remote set-head origin main
git worktree add -q --detach "$T/p5-wt/dt-product" && git worktree add -q --detach "$T/p5-wt/dt-dev-1"
printf -- '- **Runtime: Orca.** Roles run as Orca peers. Team model: opus. Fallback model: none. Advisor: none.\n' > CLAUDE.md
mkdir -p .git/dev-team && printf '{"run": "run_0a1b2c", "homes": {"dt-product": {"role": "product-manager", "worktree": "%s", "terminal": null, "asleep": true, "env": null, "name": "Ada"}, "dt-dev-1": {"role": "senior-developer", "worktree": "%s", "terminal": null, "asleep": true, "env": null, "name": "Bob"}}}\n' "$T/p5-wt/dt-product" "$T/p5-wt/dt-dev-1" > .git/dev-team/peers.json
$G commit -q --allow-empty -m two && git push -q origin main 2>/dev/null
tip() { git rev-parse --short origin/main; }
at()  { git -C "$T/p5-wt/$1" rev-parse --short HEAD; }
run dispatch dt-product product-manager "Write the PRD"
ok "a document role's worktree moves to the latest main" '[ $RC = 0 ] && [ "$(at dt-product)" = "$(tip)" ] && [[ $OUT == *"moved to the latest origin/main"* ]]'
run dispatch dt-dev-1 senior-developer "Implement T01"
ok "a developer's worktree is left where it is"           '[ $RC = 0 ] && [ "$(at dt-dev-1)" != "$(tip)" ]'
setreg 'r["homes"]["dt-product"].update(terminal=None, asleep=True, dispatch=None)'
$G commit -q --allow-empty -m three && git push -q origin main 2>/dev/null && touch "$T/p5-wt/dt-product/notes.md"
run dispatch dt-product product-manager "Revise the PRD"
ok "uncommitted changes: it stays, and says why"         '[ $RC = 0 ] && [ "$(at dt-product)" != "$(tip)" ] && [[ $OUT == *"uncommitted changes"* ]]'
rm "$T/p5-wt/dt-product/notes.md" && git -C "$T/p5-wt/dt-product" -c user.name=t -c user.email=t@t commit -q --allow-empty -m local
setreg 'r["homes"]["dt-product"].update(terminal=None, asleep=True, dispatch=None)'
run dispatch dt-product product-manager "Revise the PRD again"
ok "a commit on no remote branch: it stays"              '[ $RC = 0 ] && [ "$(at dt-product)" != "$(tip)" ] && [[ $OUT == *"on no remote branch"* ]]'

# a reviewer's worktree also starts each task on the latest main (a detached PR head carries its older CLAUDE.md)
git worktree add -q --detach "$T/p5-wt/dt-reviewer" HEAD~1
setreg 'r["homes"]["dt-reviewer"] = {"role": "reviewer", "worktree": "'"$T/p5-wt/dt-reviewer"'", "terminal": None, "asleep": True, "env": None, "name": "Uma"}'
run dispatch dt-reviewer reviewer "Review PR #3"
ok "a reviewer's worktree moves to the latest main"     '[ $RC = 0 ] && [ "$(at dt-reviewer)" = "$(tip)" ]'

# a home's own plugin install record follows the main checkout's (Claude Code keeps one per path)
mkdir -p "$T/claude/plugins" "$T/cache/new" "$T/cache/old"
rec() { printf '{"version": 2, "plugins": {"dev-team@dev-team": [{"scope": "local", "projectPath": "%s", "installPath": "%s/cache/new", "version": "new1"}, {"scope": "local", "projectPath": "%s", "installPath": "%s/cache/old", "version": "old1"}], "other@x": [{"scope": "local", "projectPath": "%s", "installPath": "/o", "version": "o"}]}}\n' "$T/p5" "$T" "$T/p5-wt/dt-dev-1" "$T" "$T/p5-wt/dt-dev-1" > "$T/claude/plugins/installed_plugins.json"; }
inst() { python3 -c 'import json,sys;d=json.load(open(sys.argv[1]))["plugins"];print(d[sys.argv[2]][int(sys.argv[3])]["version"])' "$T/claude/plugins/installed_plugins.json" "$1" "$2"; }
rec; setreg 'r["homes"]["dt-dev-1"].update(terminal=None, asleep=True, dispatch=None)'
run dispatch dt-dev-1 senior-developer "Implement T02"
ok "a home on an old plugin moves to the main checkout's" '[ $RC = 0 ] && [ "$(inst dev-team@dev-team 1)" = new1 ] && [[ $OUT == *"plugin moved from old1 to"*"new1"* ]]'
ok "other plugins' records are left alone"               '[ "$(inst other@x 0)" = o ]'
setreg 'r["homes"]["dt-dev-1"].update(terminal=None, asleep=True, dispatch=None)'
run dispatch dt-dev-1 senior-developer "Implement T03"
ok "a home already current: nothing to say"              '[ $RC = 0 ] && [[ $OUT != *"plugin moved"* ]]'
rm -rf "$T/claude/plugins"

mkdir -p "$T/p3/docs" && cd "$T/p3" && git init -q && echo x > docs/status.md
printf -- '- **Owner board:** https://claude.ai/artifact/x\n' > CLAUDE.md
OUT=$(echo '{}' | CLAUDE_PROJECT_DIR="$T/p3" CLAUDE_PLUGIN_ROOT="$REPO" "$REPO/hooks/coordinator.sh" stop)
ok "board guard without Orca, via the hook script" '[[ $OUT == *"block"*"no board write recorded yet"* ]]'
rm CLAUDE.md; OUT=$(echo '{}' | CLAUDE_PROJECT_DIR="$T/p3" CLAUDE_PLUGIN_ROOT="$REPO" "$REPO/hooks/coordinator.sh" stop)
ok "no board, no peers: the hook script is silent" '[ -z "$OUT" ]'

# without Python 3.9+, the guard hook stays quiet and SessionStart says why, once per session
mkdir -p "$T/nopy" && printf '#!/bin/sh\necho "python3: not found" >&2; exit 127\n' > "$T/nopy/python3" && chmod +x "$T/nopy/python3"
start() { CLAUDE_PROJECT_DIR="$T/p3" CLAUDE_PLUGIN_ROOT="$REPO" "$REPO/hooks/session-start.sh" 2>&1; }
printf -- '- **Owner board:** https://claude.ai/artifact/x\n' > CLAUDE.md
OUT=$(echo '{}' | PATH="$T/nopy:$PATH" CLAUDE_PROJECT_DIR="$T/p3" CLAUDE_PLUGIN_ROOT="$REPO" "$REPO/hooks/coordinator.sh" stop 2>&1); RC=$?
ok "no python3: the guard hook is silent"   '[ -z "$OUT" ] && [ $RC = 0 ]'
OUT=$(PATH="$T/nopy:$PATH" start)
ok "no python3: session start says so"      '[[ $OUT == *"need Python 3.9 or newer"* ]]'
OUT=$(start)
ok "with python3: session start doesn't"    '[[ $OUT != *Python* ]]'
rm CLAUDE.md; OUT=$(PATH="$T/nopy:$PATH" start)
ok "no board, Orca or check-ins: no warning" '[[ $OUT != *Python* ]]'

exit $fail
