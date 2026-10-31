#!/bin/bash
# Tests for bin/peer against a fake orca CLI (tests/fake-orca): the Orca calls each command makes, and its refusals.
# Run: tests/peer.sh
cd "$(dirname "$0")/.." || exit 1
REPO=$PWD PEER=$PWD/bin/peer
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
mkdir -p "$T/bin" "$T/orca" "$T/claude" "$T/proj"
ln -s "$REPO/tests/fake-orca" "$T/bin/orca"
export PATH="$T/bin:$PATH" FAKE_ORCA_DIR="$T/orca" CLAUDE_CONFIG_DIR="$T/claude" DEV_TEAM_WATCH_POLL=0
cd "$T/proj" && git init -q
printf -- '- **Runtime: Orca.** Peer size limit: 2k. Board: off.\n- **Role models:** senior-developer: sonnet/medium\n' > CLAUDE.md
fail=0

ok()    { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }
state() { python3 -c 'import json,sys;p=sys.argv[1];s=json.load(open(p));s[sys.argv[2]]=json.loads(sys.argv[3]);json.dump(s,open(p,"w"))' "$T/orca/state.json" "$1" "$2"; }
run()   { : > "$T/orca/calls.log"; OUT=$("$PEER" "$@" 2>&1); RC=$?; }
called() { grep -q -- "$1" "$T/orca/calls.log"; }
start_args() { grep '"worker-start"' "$T/orca/calls.log"; }
reg()   { python3 -c 'import json,sys;r=json.load(open(".git/dev-team/peers.json"));print(eval(sys.argv[1]))' "$1"; }

# dispatch: a new home
run dispatch dt-dev-1 senior-developer "Implement T01"
ok "new home needs --worktree"             '[ $RC = 2 ] && [[ $OUT == *"pass --worktree"* ]]'
ok "first call creates the team run"      'called run-create && [ "$(reg "r[\"run\"]")" = run_0a1b2c ]'
run dispatch dt-dev-1 senior-developer "Implement T01" --worktree new-child --name feat-a --base-branch feat
ok "new home launches claude"              '[ $RC = 0 ] && start_args | grep -q "\"--agent\", \"claude\", \"--worktree\", \"new-child\", \"--name\", \"feat-a\", \"--base-branch\", \"feat\""'
ok "new home gets the role model"          'start_args | grep -q "\"--model\", \"sonnet\", \"--effort\", \"medium\""'
ok "spec opens with the role line"         'start_args | grep -q "You are the dev-team senior-developer peer \[dev-team home dt-dev-1\]"'
ok "later calls reuse the run"             '! called run-create && called "\"run-use\", \"--id\", \"run_0a1b2c\""'
ok "home recorded"                         '[ "$(reg "r[\"homes\"][\"dt-dev-1\"][\"terminal\"], r[\"homes\"][\"dt-dev-1\"][\"worktree\"]")" = "('"'"'term_1'"'"', '"'"'/wt/feat-a'"'"')" ]'

# dispatch: refusals
run dispatch dt-dev-1 senior-developer "Implement T02"
ok "refuses a home still working"          '[ $RC = 2 ] && [[ $OUT == *"still working"* ]] && ! called worker-start'
state stage '"settled"'
run dispatch dt-dev-1 reviewer "Review"
ok "refuses a role the home does not hold" '[ $RC = 2 ] && [[ $OUT == *"is a senior-developer home"* ]]'
run dispatch --keep dt-dev-1 senior-developer "Fix" --worktree path:/wt/other
ok "refuses --keep with a worktree"        '[ $RC = 2 ] && ! called worker-start'

# dispatch: fresh, keep, restart
run dispatch dt-dev-1 senior-developer "Implement T02"
ok "fresh task clears, same terminal"      'called "\"/clear\"" && start_args | grep -q "\"--terminal\", \"term_1\", \"--worktree\", \"path:/wt/feat-a\"" && ! start_args | grep -q -- --agent'
state stage '"settled"'
run dispatch --keep dt-dev-1 senior-developer "Fix review findings"
ok "--keep does not clear"                 '! called "\"/clear\"" && start_args | grep -q "\"--terminal\", \"term_1\""'
state stage '"settled"'
run dispatch dt-dev-1 senior-developer "Implement T03" --worktree path:/wt/other
ok "new worktree restarts"                 'called "\"worker-release\", \"--dispatch\", \"ctx_3\"" && start_args | grep -q "\"--agent\", \"claude\", \"--worktree\", \"path:/wt/other\""'
state stage '"settled"'; state mode '"chat"'
run dispatch dt-dev-1 senior-developer "Implement T04"
ok "chat-mode worker restarts"             'called worker-release && start_args | grep -q -- "--agent" && ! called "\"/clear\""'
state mode '"terminal"'; state stage '"settled"'
run dispatch --restart dt-dev-1 senior-developer "Implement T05"
ok "--restart restarts"                    'called worker-release && start_args | grep -q -- "--agent"'

# tell
state stage '"settled"'
run tell dt-dev-1 "Install" "Yes, install the build"
ok "tell refuses a settled peer"           '[ $RC = 2 ] && [[ $OUT == *"peer dispatch --keep"* ]] && ! called "\"send\""'
state stage '"running"'
run tell dt-dev-1 "Install" "Yes, install the build"
ok "tell mails the dispatch and nudges"    '[ $RC = 0 ] && called "\"--to\", \"dispatch:ctx_6\"" && called "From coordinator: Install" && [[ $OUT == *"nudge delivered"* ]]'
state send_reply '"accepted; retry with --retry-request 4f2a-9c; no turn start was observed"'; state screen '"> From coordinator: Install"'
run tell dt-dev-1 "Install" "Yes"
ok "busy peer: nudge queued"               '[ $RC = 0 ] && [[ $OUT == *"nudge queued"* ]] && called "\"--retry-request\", \"4f2a-9c\""'
state screen '""'
run tell dt-dev-1 "Install" "Yes"
ok "unconfirmed nudge exits 2"             '[ $RC = 2 ] && [[ $OUT == *"NUDGE NOT CONFIRMED"* ]]'
state send_reply '"sent"'
run tell dt-dev-1 "Re: schedule" "Weekly" --reply msg_9
ok "--reply answers the ask"               'called "\"reply\", \"--run\", \"run_0a1b2c\", \"--id\", \"msg_9\""'

# pending and watch
state batches '[{"deliveryId":"dlv_1","messages":[{"type":"heartbeat","subject":"alive"}]},
                {"deliveryId":"dlv_2","messages":[{"type":"status","id":"msg_3","from_handle":"term_6","subject":"May I install?","body":"Steps ready"}]}]'
run pending
ok "pending acks a heartbeat-only batch"   'called "\"--ack\", \"dlv_1\""'
ok "pending shows the real batch"          '[ $RC = 1 ] && [[ $OUT == *"status | dt-dev-1 | id msg_3 | May I install?"* ]] && [[ $OUT == *"--ack dlv_2"* ]] && ! called "--ack\", \"dlv_2"'
run watch 0.02
ok "watch returns on a status message"     '[ $RC = 0 ] && [[ $OUT == *"May I install?"* ]]'
state batches '[]'
run pending
ok "pending: nothing unhandled"            '[ $RC = 0 ] && [[ $OUT == "no unhandled reports" ]]'

# sizes and SIZE: transcripts are found by the home marker, also when homes share a worktree
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
python3 -c 'import json;p=".git/dev-team/peers.json";r=json.load(open(p));h=r["homes"]["dt-dev-1"];h["worktree"]="/wt/feat-a";r["homes"]["dt-reviewer"]=dict(h,role="reviewer");json.dump(r,open(p,"w"))'
run sizes
ok "sizes picks each home's transcript"    '[[ $OUT == *"dt-dev-1"*"~5k / 2k  OVER"* ]] && [[ $OUT == *"dt-reviewer"*"~1k / 2k"* ]]'
DEV_TEAM_STALL_MIN=999 run watch 0.02
ok "watch reports SIZE"                    '[[ $OUT == "SIZE | dt-dev-1 | ~5k"* ]]'
DEV_TEAM_STALL_MIN=999 run watch 0.02
ok "SIZE fires once per session"           '[[ $OUT == "nothing after 0.02 min" ]]'
DEV_TEAM_STALL_MIN=0 run watch 0.02
ok "watch reports STALL"                   '[[ $OUT == "STALL | "* ]]'

# release and list
run release dt-dev-1
ok "release refuses a working peer"        '[ $RC = 2 ] && ! called worker-release'
state stage '"settled"'
run release dt-dev-1
ok "release closes a settled peer"         '[ $RC = 0 ] && called worker-release && [ "$(reg "r[\"homes\"][\"dt-dev-1\"][\"terminal\"]")" = None ]'
run list
ok "list shows the released home"          '[ $RC = 0 ] && [[ $OUT == *"dt-dev-1"*"released"* ]]'

exit $fail
