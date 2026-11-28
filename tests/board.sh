#!/bin/bash
# Tests for the Owner board: bin/board-drift against a fake gh, and templates/board.html rendered with
# examples/board/sample.json in headless Chrome (skipped when no Chrome is found). Run: tests/board.sh
cd "$(dirname "$0")/.." || exit 1
REPO=$PWD
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail=0
ok() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }

# --- board-drift --------------------------------------------------------------------------------------------------
mkdir -p "$T/bin" "$T/rows/sub"
cat > "$T/bin/gh" <<'EOF'
#!/usr/bin/env python3
import json, os, sys
a = sys.argv[1:]
open(os.environ["FAKE_GH_LOG"], "a").write(json.dumps(a) + "\n")
if a[:2] == ["repo", "view"]:
    print("acme/app"); sys.exit(0)
prs = json.load(open(os.environ["FAKE_GH_PRS"]))
print(json.dumps(prs.get(a[a.index("-R") + 1] + "#" + a[2], {})))
EOF
chmod +x "$T/bin/gh"
export PATH="$T/bin:$PATH" FAKE_GH_LOG="$T/gh.log" FAKE_GH_PRS="$T/prs.json"
cat > "$T/prs.json" <<'EOF'
{"acme/app#1": {"state": "MERGED", "isDraft": false, "statusCheckRollup": []},
 "acme/app#2": {"state": "OPEN", "isDraft": false, "statusCheckRollup": [{"conclusion": "FAILURE"}]},
 "acme/app#3": {"state": "OPEN", "isDraft": true,  "statusCheckRollup": [{"conclusion": "SUCCESS"}]},
 "acme/app#4": {"state": "OPEN", "isDraft": false, "statusCheckRollup": [{"state": "PENDING"}]},
 "acme/app#5": {"state": "OPEN", "isDraft": false, "statusCheckRollup": []},
 "acme/app#6": {"state": "OPEN", "isDraft": true,  "statusCheckRollup": [{"conclusion": "FAILURE"}]},
 "acme/mobile#7": {"state": "CLOSED", "isDraft": false, "statusCheckRollup": []},
 "acme/web#9": {"state": "OPEN", "isDraft": false, "statusCheckRollup": [{"conclusion": "FAILURE"}]},
 "acme/app#10": {"state": "OPEN", "isDraft": false, "statusCheckRollup": []},
 "acme/app#11": {"state": "MERGED", "isDraft": false, "statusCheckRollup": []},
 "acme/app#12": {"state": "CLOSED", "isDraft": false, "statusCheckRollup": []},
 "acme/web#11": {"state": "OPEN", "isDraft": false, "statusCheckRollup": []},
 "acme/web#12": {"state": "MERGED", "isDraft": false, "statusCheckRollup": []},
 "acme/mobile#853": {"state": "OPEN", "isDraft": false, "statusCheckRollup": []},
 "acme/app#853": {"state": "MERGED", "isDraft": false, "statusCheckRollup": []},
 "acme/app#854": {"state": "MERGED", "isDraft": false, "statusCheckRollup": []}}
EOF
row() { printf '%s' "$2" > "$T/rows/$1.json"; }
row merged    '{"data": {"pr": 1, "state": "building"}}'
row failed    '{"data": {"pr": 2, "state": "review"}}'
row draft     '{"data": {"pr": 3, "state": "ready"}}'
row ready     '{"pr": 4, "state": "building"}'
row reviewing '{"data": {"pr": 5, "state": "review"}}'
row waiting   '{"data": {"pr": 6, "state": "owner"}}'
row done      '{"data": {"pr": 1, "state": "done"}}'
row nopr      '{"data": {"state": "planning"}}'
row missing   '{"data": {"pr": 8, "state": "review"}}'
row planned   '{"data": {"pr": 4, "state": "planning"}}'
row queued    '{"data": {"pr": 5, "state": "queued"}}'
row fixready  '{"data": {"pr": 5, "state": "fixing"}}'
row fixdraft  '{"data": {"pr": 3, "state": "fixing"}}'
row held      '{"data": {"pr": 3, "state": "held"}}'
row heldgone  '{"data": {"pr": 11, "state": "held"}}'
row short     '{"data": {"pr": 9, "repo": "web", "state": "review"}}'
printf '%s' '{"data": {"pr": 7, "repo": "acme/mobile", "state": "review"}}' > "$T/rows/sub/other.json"

OUT=$("$REPO/bin/board-drift" "$T/rows"); RC=$?
ok "drift exits 1"                         '[ $RC = 1 ]'
ok "merged PR → done"                      '[[ $OUT == *"merged: board says building, should be done (PR merged)"* ]]'
ok "failed check → fixing"                 '[[ $OUT == *"failed: board says review, should be fixing (a check failed)"* ]]'
ok "draft PR is not ready"                 '[[ $OUT == *"draft: board says ready, should be building or review"* ]]'
ok "ready PR is not building"              '[[ $OUT == *"ready: board says building, should be ready or review"* ]]'
ok "row repo wins, nested files read"      '[[ $OUT == *"other: board says review, should be done (PR closed)"* ]] && grep -q "acme/mobile" "$T/gh.log"'
ok "missing PR is reported"               '[[ $OUT == *"missing: PR #8 not found"* ]]'
ok "ready PR is not planning"              '[[ $OUT == *"planned: board says planning, should be ready or review"* ]]'
ok "ready PR is not queued"                '[[ $OUT == *"queued: board says queued, should be ready or review"* ]]'
ok "in-sync rows stay quiet"               '[[ $OUT != *reviewing* && $OUT != *waiting* && $OUT != *nopr* ]]'
ok "a ready PR may be fixing"              '[[ $OUT != *fixready* ]]'
ok "a draft PR, no failed check, not fixing" '[[ $OUT == *"fixdraft: board says fixing, should be building or review"* ]]'
ok "held rows: only a merge or close moves them" '[[ $OUT != *"held: "* ]] && [[ $OUT == *"heldgone: board says held, should be done (PR merged)"* ]]'
ok "short repo name: same owner by default" '[[ $OUT == *"short: board says review, should be fixing"* ]] && grep -q "acme/web" "$T/gh.log"'
ok "done rows are not looked up"           '[ "$(grep -c "\"1\"" "$T/gh.log")" = 1 ]'
mkdir -p "$T/mapped/meta"; printf '%s' '{"data": {"pr": 9, "repo": "site", "state": "review"}}' > "$T/mapped/a.json"
printf '%s' '{"data": {"repo": "acme/app", "repos": {"site": "acme/web"}}}' > "$T/mapped/meta/config.json"
OUT=$("$REPO/bin/board-drift" "$T/mapped")
ok "short repo name mapped in config"      '[[ $OUT == "a: board says review, should be fixing"* ]]'
cat > "$T/status.md" <<'EOF'
| Feature | Phase | Current Role | Blockers | Approvals | Path |
|---|---|---|---|---|---|
| export (APP-1) | Review | reviewer | — | — | #11, #12 |
| import (APP-2) | Implementation | senior-developer | — | — | #10 |
| sync (APP-3) | Review | reviewer | — | — | #11 and web#9 |
| notes | Requirements | product-manager | — | — | brief |
EOF
OUT=$("$REPO/bin/board-drift" --status "$T/status.md"); RC=$?
ok "status: rows whose PRs are all done"   '[ $RC = 1 ] && [[ $OUT == "export (APP-1): every PR it names is done (#11 merged, #12 closed)"* ]]'
ok "status: an open PR or no PR is quiet"  '[[ $OUT != *import* && $OUT != *sync* && $OUT != *notes* ]]'
# Another repo's PR written with a space, "mobile #853": never this repo's #853.
cat > "$T/status2.md" <<'EOF'
| Feature | Phase | Current Role | Blockers | Approvals | Path |
|---|---|---|---|---|---|
| app side | Review | reviewer | — | — | mobile #853 |
| unplaced | Review | reviewer | — | — | Phone #854 |
| billing | Review | reviewer | — | — | PR #11 |
| site | Review | reviewer | — | — | site #11 |
EOF
printf '%s' '{"repos": {"mobile": "acme/mobile", "site": "acme/web"}}' > "$T/statuscfg.json"
OUT=$("$REPO/bin/board-drift" --status "$T/status2.md" --config "$T/statuscfg.json")
ok "status: '<repo> #N' is that repo's PR"   '[[ $OUT != *"app side"* && $OUT != *"site:"* ]]'
ok "status: an unknown repo name is reported unchecked" '[[ $OUT == *"unplaced: not checked — \"Phone #854\" is not a PR it can find; write #854 for this repo"* ]]'
ok "status: and is never marked done"       '[[ $OUT != *"unplaced: every PR"* ]]'
ok "status: 'PR #N' is this repo's"         '[[ $OUT == *"billing: every PR it names is done (#11 merged)"* ]]'
printf '%s\n' '| Feature | Phase | Current Role | Next | Path |' '|---|---|---|---|---|' \
  '| reviewed | Review | reviewer | review #11 | build |' '| ticketed | Review | reviewer | APP-7 #12 | build |' > "$T/status4.md"
OUT=$("$REPO/bin/board-drift" --status "$T/status4.md")
ok "status: 'review #N' is this repo's PR"   '[[ $OUT == *"reviewed: every PR it names is done (#11 merged)"* ]]'
ok "status: '<ticket key> #N' is this repo's PR" '[[ $OUT == *"ticketed: every PR it names is done (#12 closed)"* ]]'
mkdir -p "$T/g" && git -C "$T/g" init -q && mkdir -p "$T/g/.git/dev-team"
printf '%s\n' '| Feature | Phase | Current Role | Blockers | Approvals | Path |' '|---|---|---|---|---|---|' \
  '| site | Review | reviewer | — | — | site #12 |' > "$T/status3.md"
OUT=$(cd "$T/g" && "$REPO/bin/board-drift" --status "$T/status3.md"); RC=$?
ok "status: an unmapped repo name is reported" '[ $RC = 1 ] && [[ $OUT == "site: not checked — \"site #12\" is not a PR"* ]]'
printf '{"rows": "%s"}' "$T/mapped" > "$T/g/.git/dev-team/board.json"
OUT=$(cd "$T/g" && "$REPO/bin/board-drift" --status "$T/status3.md"); RC=$?
ok "status: the stamped rows' config maps repo names" '[ $RC = 1 ] && [[ $OUT == "site: every PR it names is done (web#12 merged)"* ]]'
# Task counts against each feature's task index, and cells grown into a log: no gh needed.
mkdir -p "$T/ws/features/export/tasks" "$T/ws/features/import/tasks"
printf '%s\n' '| ID | Task | Status |' '|---|---|---|' '| T01 | a | done (PR #1) |' '| T02 | b | done |' '| T03 | c | dropped |' \
  '| T04 | d | in progress (draft PR #4) |' > "$T/ws/features/export/tasks/index.md"
printf '%s\n' '| ID | Task | Status |' '|---|---|---|' '| T01 | a | done |' '| T02 | b | pending |' > "$T/ws/features/import/tasks/index.md"
LONG=$(printf 'T%.0s merged, ' {1..40})
printf '%s\n' '| Feature | Phase | Current Role | Next | Path |' '|---|---|---|---|---|' \
  '| export (APP-1) | Implementation: 2 of 4 tasks | senior-developer | T04: Bob | tasks |' \
  '| import | Implementation: 0 of 2 tasks | senior-developer | T02 | tasks |' \
  "| notes | Requirements | product-manager | $LONG | brief |" > "$T/ws/status.md"
: > "$FAKE_GH_LOG"
OUT=$("$REPO/bin/board-drift" --status "$T/ws/status.md" --no-prs); RC=$?
ok "status: a count behind its task index"   '[ $RC = 1 ] && [[ $OUT == *"import: status.md says 0 of 2 tasks; its task index has 1 of 2 done"* ]]'
ok "status: a dropped task may count or not" '[[ $OUT != *export* ]]'
ok "status: a cell grown into a log"         '[[ $OUT == *"notes: its Next cell is "*" characters — keep one line"* ]]'
ok "status: --no-prs calls no gh"            '[ ! -s "$FAKE_GH_LOG" ]'
mkdir -p "$T/sync"; printf '%s' '{"data": {"pr": 5, "state": "review"}}' > "$T/sync/a.json"
OUT=$("$REPO/bin/board-drift" "$T/sync"); RC=$?
ok "in sync exits 0"                       '[ $RC = 0 ] && [ "$OUT" = "board in sync" ]'

# --- template render ----------------------------------------------------------------------------------------------
CH=${CHROME:-}
for c in google-chrome google-chrome-stable chromium chromium-browser \
         "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
         "$HOME"/Library/Caches/ms-playwright/chromium-*/chrome-mac*/"Google Chrome for Testing.app"/Contents/MacOS/"Google Chrome for Testing"; do
  [ -n "$CH" ] && break
  command -v "$c" >/dev/null 2>&1 && CH=$c
done
if [ -z "$CH" ]; then
  echo "skip template render: no Chrome found (set CHROME=<path>)"
else
  dom() { python3 tests/board-preview.py "$T/p.html" light "$1" && "$CH" --headless --disable-gpu --no-sandbox \
            --virtual-time-budget=4000 --dump-dom "file://$T/p.html" 2>/dev/null; }
  DOM=$(dom examples/board/sample.json)
  count() { printf '%s' "$DOM" | grep -o "$1" | wc -l | tr -d ' '; }
  ok "render: 2 asks"                      '[ "$(count "class=\"ask\"")" = 2 ]'
  ok "render: 7 peers"                     '[ "$(count "class=\"peer[\" ]")" = 7 ]'
  ok "render: 3 groups, open counts"       '[ "$(count "class=\"group\"")" = 3 ] && [[ $DOM == *"2 open · 3 total"* ]]'
  ok "render: owner state defaults to you" '[ "$(count ">Waiting on you<")" = 2 ]'
  ok "render: ticket links from config"    '[[ $DOM == *"href=\"https://example.com/tickets/APP-207\""* ]]'
  ok "render: PR links from config repo"   '[[ $DOM == *"href=\"https://github.com/acme/app/pull/409\""* ]]'
  ok "render: stacked PRs, lower waits"     '[[ $DOM == *"merges with #420, not alone"* ]] && [[ $DOM == *"https://github.com/acme/app/pull/420"* ]] && [[ $DOM == *"stacked on #409"* ]]'
  ok "render: a stack stays together, bottom up" 'printf "%s" "$DOM" | python3 -c "import re,sys;d=sys.stdin.read();i,j=d.find(\"invoice query\"),d.find(\"streaming writer\");sys.exit(0 if 0<=i<j and not re.search(r\"APP-2(?!07)\",d[i:j]) else 1)"'
  ok "render: updated stamp"               '[[ $DOM == *"Updated 3 min ago"* ]]'
  python3 -c 'import json,sys;s=json.load(open(sys.argv[1]));s["meta/config"]={"owner":"Sam"};s["work"][0]["repo"]="acme/mobile";json.dump(s,open(sys.argv[2],"w"))' \
    examples/board/sample.json "$T/s2.json"
  DOM=$(dom "$T/s2.json")
  ok "render: owner name from config"      '[[ $DOM == *">Waiting on Sam<"* ]]'
  ok "render: no ticket URL, plain IDs"    '[[ $DOM != *"example.com/tickets"* ]] && [[ $DOM == *">APP-207<"* ]]'
  ok "render: no repo, row repo still links" '[[ $DOM == *"https://github.com/acme/mobile/pull/409"* ]] && [[ $DOM != *"acme/app/pull"* ]]'
  python3 -c 'import json,sys;s=json.load(open(sys.argv[1]));s["meta/config"]["repos"]={"web":"acme/web"};s["work"][0].update(repo="web",state="held");json.dump(s,open(sys.argv[2],"w"))' \
    examples/board/sample.json "$T/s3.json"
  DOM=$(dom "$T/s3.json")
  ok "render: held is the Owner's, muted"  '[[ $DOM == *"<tr class=\"held\">"* ]] && [[ $DOM == *">Held by you<"* ]]'
  ok "render: short repo name links via config" '[[ $DOM == *"https://github.com/acme/web/pull/409"* ]] && [[ $DOM == *">web #409<"* ]]'
fi
exit $fail
