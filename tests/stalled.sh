#!/bin/bash
# Tests for bin/stalled's worker check: only this project's team Run counts, since one Orca serves every project.
# Run: tests/stalled.sh
cd "$(dirname "$0")/.." || exit 1
REPO=$PWD
T=$(mktemp -d "${TMPDIR:-/tmp}/stalled.XXXXXX"); trap 'rm -rf "$T"' EXIT
mkdir -p "$T/bin" "$T/proj"
cat > "$T/bin/orca" <<'PY'
#!/usr/bin/env python3
# A stand-in for `orca orchestration worker-list`: one failed worker per Run, filtered by --run like the real one.
import json, os, sys
a = sys.argv[1:]
open(os.environ["CALLS"], "a").write(json.dumps(a) + "\n")
run = a[a.index("--run") + 1] if "--run" in a else None
rows = [{"runId": r, "projection": {"dispatchId": "ctx_" + r, "attention": {"requiresAction": True}}}
        for r in ("run_here", "run_other") if run in (None, r)]
print(json.dumps({"ok": True, "result": {"workers": rows}}))
PY
chmod +x "$T/bin/orca"
export PATH="$T/bin:$PATH" CALLS="$T/calls.log"
cd "$T/proj" && git init -q && mkdir -p docs && printf '| F | Phase |\n|---|---|\n' > docs/status.md
fail=0
ok() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }
run() { : > "$CALLS"; "$REPO/bin/stalled" stalled 4 >/dev/null 2>&1; RC=$?; }

run
ok "no team Run here: other projects' workers don't count" '[ $RC = 1 ] && ! grep -q worker-list "$CALLS"'
mkdir -p .git/dev-team && echo '{"run": "run_here", "homes": {}}' > .git/dev-team/peers.json
run
ok "a worker in this project's Run that needs action fires" '[ $RC = 0 ] && grep -q "\"--run\", \"run_here\"" "$CALLS"'
run
ok "the same worker fires once"                        '[ $RC = 1 ]'
ok "other projects' workers never counted"             '! grep -q run_other .git/dev-team/stalled.seen'
rm .git/dev-team/stalled.seen
LATER=$(python3 -c 'import datetime; print((datetime.date.today() + datetime.timedelta(days=2)).strftime("%a"))')
printf -- '- **Hours: %s 00:00–00:01.** When the team works on its own.\n' "$LATER" > CLAUDE.md
run
ok "outside working hours, a check-in never starts"    '[ $RC = 1 ] && ! grep -q worker-list "$CALLS"'
rm CLAUDE.md
exit $fail
