#!/bin/bash
# The docs site names everything a project can run or set, so the plugin can't outgrow it unnoticed.
cd "$(dirname "$0")/.." || exit 1
fail=0
ok() { if [ -z "$2" ]; then echo "ok   $1"; else echo "FAIL $1 — $2"; fail=1; fi; }

# missing <page> <python expression>: the expression's strings that the page lacks. With page "-", the strings
# themselves are the problems. An error, or a list that comes back empty for a page, is a failure too.
missing() {
  python3 - "$1" "$2" <<'PY'
import glob, os, re, sys
page, expr = sys.argv[1], sys.argv[2]
read = lambda p: open(p).read()
try:
    items = list(eval("(" + expr + ")"))
except Exception as e:
    sys.exit(print(f"the check itself failed: {e!r}"))
if page == "-":
    print(", ".join(items))
elif not items:
    print("found nothing to look for: the test no longer matches the plugin")
else:
    text = read(f"site/src/content/docs/{page}")
    gone = [x for x in items if x not in text]
    print("missing: " + ", ".join(gone) if gone else "")
PY
}

ok "every peer command is in the commands page" "$(missing reference/commands.md '
  ["peer " + k for k in re.findall(r"\"([\w-]+)\":", re.search(r"CMDS = \{(.*?)\}", read("bin/peer"), re.S).group(1))]')"
ok "every slash command is in the commands page" "$(missing reference/commands.md '
  ["/dev-team:" + os.path.basename(f)[:-3] for f in glob.glob("commands/*.md")]')"
ok "every script is in the commands page" "$(missing reference/commands.md '
  [os.path.basename(f) for f in glob.glob("bin/*") if os.path.isfile(f) and not os.path.basename(f).startswith("_")]')"
ok "every environment variable is in the settings page" "$(missing reference/settings.md '
  sorted({v for f in glob.glob("bin/*") + glob.glob("hooks/*") if os.path.isfile(f) for v in re.findall(r"DEV_TEAM_[A-Z_]*[A-Z]", read(f))})')"
ok "every Runtime-line setting is in the settings page" "$(missing reference/settings.md '
  [k + ":" for k in re.findall(r"([A-Z][a-z]+(?: [a-z]+)*): ", read("workflow/orca.md").split("never spawn subagents.")[1].split("\n")[0])]
  + [k + ":" for k in re.findall(r"`([A-Z][a-z]+(?: [a-z]+)*):[^`]*` to the (?:project.s )?Runtime line", read("workflow/orca.md"))]')"
ok "every board state is in the board page" "$(missing board.mdx '
  ["`" + (a or b) + "`" for a, b in re.findall(r"`(\w+)` \(|, `(\w+)`", read("workflow/board.md").split("`state` is one of:")[1].split("\n")[0])]')"
ok "every plugin file the site links to exists" "$(missing - '
  [p for f in glob.glob("site/src/content/docs/**/*.md*", recursive=True)
     for p in re.findall(r"github\.com/J-T-McC/dev-team/blob/main/([^)#\s]+)", read(f)) if not os.path.exists(p)]')"

exit $fail
