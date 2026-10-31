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
 "acme/mobile#7": {"state": "CLOSED", "isDraft": false, "statusCheckRollup": []}}
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
printf '%s' '{"data": {"pr": 7, "repo": "acme/mobile", "state": "review"}}' > "$T/rows/sub/other.json"

OUT=$("$REPO/bin/board-drift" "$T/rows"); RC=$?
ok "drift exits 1"                         '[ $RC = 1 ]'
ok "merged PR → done"                      '[[ $OUT == *"merged: board says building, should be done (PR merged)"* ]]'
ok "failed check → fixing"                 '[[ $OUT == *"failed: board says review, should be fixing (a check failed)"* ]]'
ok "draft PR is not ready"                 '[[ $OUT == *"draft: board says ready, should be building or review"* ]]'
ok "ready PR is not building"              '[[ $OUT == *"ready: board says building, should be ready or review"* ]]'
ok "row repo wins, nested files read"      '[[ $OUT == *"other: board says review, should be done (PR closed)"* ]] && grep -q "acme/mobile" "$T/gh.log"'
ok "in-sync rows stay quiet"               '[[ $OUT != *reviewing* && $OUT != *waiting* && $OUT != *nopr* ]]'
ok "done rows are not looked up"           '[ "$(grep -c "\"1\"" "$T/gh.log")" = 1 ]'
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
  ok "render: updated stamp"               '[[ $DOM == *"Updated 3 min ago"* ]]'
  python3 -c 'import json,sys;s=json.load(open(sys.argv[1]));s["meta/config"]={"owner":"Sam"};s["work"][0]["repo"]="acme/mobile";json.dump(s,open(sys.argv[2],"w"))' \
    examples/board/sample.json "$T/s2.json"
  DOM=$(dom "$T/s2.json")
  ok "render: owner name from config"      '[[ $DOM == *">Waiting on Sam<"* ]]'
  ok "render: no ticket URL, plain IDs"    '[[ $DOM != *"example.com/tickets"* ]] && [[ $DOM == *">APP-207<"* ]]'
  ok "render: no repo, row repo still links" '[[ $DOM == *"https://github.com/acme/mobile/pull/409"* ]] && [[ $DOM != *"acme/app/pull"* ]]'
fi
exit $fail
