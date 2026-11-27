#!/bin/bash
# Tests for bin/hours: parsing the Hours line, open and closed times, and when the state flips.
# Run: tests/hours.sh
cd "$(dirname "$0")/.." || exit 1
REPO=$PWD
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail=0
ok() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }

OUT=$(python3 - "$REPO/bin/hours" <<'PY'
import importlib.util, sys
from datetime import datetime
from importlib.machinery import SourceFileLoader
loader = SourceFileLoader("hours", sys.argv[1])
h = importlib.util.module_from_spec(importlib.util.spec_from_loader("hours", loader))
loader.exec_module(h)
ws = h.windows("Mon–Fri 09:00–17:00")
fri = lambda hh, mm=0: datetime(2026, 11, 27, hh, mm)  # a Friday
checks = {
    "weekday, inside": h.open_at(ws, fri(16, 59)),
    "weekday, at the end": not h.open_at(ws, fri(17)),
    "weekend": not h.open_at(ws, datetime(2026, 11, 28, 10)),
    "closing flips at 17:00": h.change(ws, fri(12)) == fri(17),
    "Friday evening opens Monday": h.change(ws, fri(18)) == datetime(2026, 11, 30, 9),
    "overnight, before midnight": h.open_at(h.windows("daily 22:00–06:00"), fri(23)),
    "overnight, after midnight": h.open_at(h.windows("daily 22:00–06:00"), datetime(2026, 11, 28, 5, 59)),
    "overnight ends": not h.open_at(h.windows("daily 22:00–06:00"), datetime(2026, 11, 28, 6)),
    "two windows, the gap": not h.open_at(h.windows("weekdays 9–12; weekdays 13–17"), fri(12, 30)),
    "am/pm and day lists": h.open_at(h.windows("Sat,Sun 10am-2pm"), datetime(2026, 11, 29, 13, 59)),
    "a week that wraps (Fri–Mon)": h.open_at(h.windows("Fri–Mon 9–17"), datetime(2026, 11, 30, 10)),
    "any is no hours": h.windows("any") is None and h.windows("") is None,
}
for bad in ("Mon-Fri", "Funday 9-17", "9-25"):
    try:
        h.windows(bad)
        checks[f"refuses {bad!r}"] = False
    except ValueError:
        checks[f"refuses {bad!r}"] = True
for name, good in checks.items():
    print(("ok   " if good else "FAIL ") + name)
PY
)
echo "$OUT"; [[ $OUT == *FAIL* ]] && fail=1

cd "$T" && git init -q
OUT=$("$REPO/bin/hours"); RC=$?
ok "no Hours line: open"                   '[ $RC = 0 ] && [ "$OUT" = "open: no working hours set" ]'
LATER=$(python3 -c 'import datetime; print((datetime.date.today() + datetime.timedelta(days=2)).strftime("%a"))')
printf -- '- **Hours: %s 09:00–17:00.** When the team works on its own.\n' "$LATER" > CLAUDE.md
OUT=$("$REPO/bin/hours"); RC=$?
ok "outside the window: closed, and until when" '[ $RC = 1 ] && [ "$OUT" = "closed ($LATER 09:00–17:00) until $LATER 09:00" ]'
printf -- '- **Hours: daily 00:00–24:00.**\n' > CLAUDE.local.md
OUT=$("$REPO/bin/hours"); RC=$?
ok "CLAUDE.local.md wins, all day: open"   '[ $RC = 0 ] && [[ $OUT == "open (daily 00:00–24:00)"* ]]'
printf -- '- **Hours: sometimes.**\n' > CLAUDE.local.md
OUT=$("$REPO/bin/hours" 2>&1); RC=$?
ok "a line that doesn't parse: open, and says so" '[ $RC = 0 ] && [[ $OUT == *"doesn'"'"'t parse"* ]]'
exit $fail
