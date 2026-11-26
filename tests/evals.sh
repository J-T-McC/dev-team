#!/bin/bash
# Free checks on the paid eval suite (evals/): it loads, its fixtures build what its cases grade, and the README maps it.
# Nothing here runs an eval. Run: tests/evals.sh
cd "$(dirname "$0")/.." || exit 1
REPO=$PWD
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail=0
ok() { if [ -z "$2" ]; then echo "ok   $1"; else echo "FAIL $1 — $2"; fail=1; fi; }

# Case files and grader keys, against https://code.claude.com/docs/en/plugin-evals.md
ok "every case and grader uses documented fields" "$(python3 - <<'PY'
import glob, os, re
keys = {"regex": {"pattern", "flags", "match", "target"}, "tool_used": {"tool", "input_match", "min", "max"},
        "tool_order": {"before", "after"}, "file_exists": {"path", "exists"}, "llm": {"criteria", "focus"},
        "baseline": {"baseline_file", "criteria"}}
common = {"type", "weight", "arm"}
bad = []
for d in sorted(glob.glob("evals/*/")):
    name = os.path.basename(d.rstrip("/"))
    if name == "results": continue
    y = open(d + "case.yaml").read() if os.path.exists(d + "case.yaml") else ""
    if 'schema_version: "1.1"' not in y or f"\nname: {name}\n" not in y: bad.append(f"{name}: case.yaml schema_version or name")
    if not os.access(d + "scaffold.sh", os.X_OK): bad.append(f"{name}: scaffold.sh missing or not executable")
    graders = glob.glob(d + "graders/*.md")
    if not graders: bad.append(f"{name}: no graders")
    for g in graders:
        fm = re.match(r"---\n(.*?)\n---", open(g).read(), re.S)
        lines = [l for l in (fm.group(1) if fm else "").splitlines() if l and not l.startswith("#")]
        got = {l.split(":")[0].strip() for l in lines if not l.startswith(" ")}
        t = next((l.split(":", 1)[1].strip() for l in lines if l.startswith("type:")), None)
        if t not in keys: bad.append(f"{g}: type {t}")
        elif got - keys[t] - common: bad.append(f"{g}: unknown {sorted(got - keys[t] - common)}")
print("; ".join(bad))
PY
)"

# Fixtures shared by several cases stay identical.
same() { local a=$1; shift; for b; do cmp -s "evals/$a/scaffold.sh" "evals/$b/scaffold.sh" || echo "$b differs from $a "; done; }
ok "shared fixtures are identical" "$(same new-no-answers stack-missing-facts new-all-answers)$(same existing-no-answers existing-all-answers guest-all-answers)$(same rerun checkins-plain-words)"

# Each fixture builds, in an environment as bare as the eval's, and gives setup-detect what its cases grade.
# Like an eval run: the scaffold's HOME is the run's home ($T/<name>), its working directory the run's ($T/<name>/cwd).
build() { mkdir -p "$T/$1/cwd" && (cd "$T/$1/cwd" && env -i PATH=/usr/bin:/bin HOME="$T/$1" bash "$REPO/evals/$2/scaffold.sh") >/dev/null 2>&1 || echo "$2: scaffold failed"; }
q() { (cd "$T/$1/cwd" && env -i PATH=/usr/bin:/bin HOME="$T/$1" "$REPO/bin/setup-detect") |
      python3 -c 'import json,sys; d=json.load(sys.stdin); sys.exit(0 if eval(sys.argv[1]) else 1)' "$2" || echo "$1: $2"; }
ok "empty fixture: a new project"            "$(build empty new-no-answers)$(q empty 'd["project"]["state"]=="new" and d["project"]["commits"]==1')"
ok "ts-shop fixture: conventional, ENG"      "$(build shop existing-no-answers)$(q shop 'd["project"]["state"]=="existing" and d["commits"]["style"]=="conventional" and d["commits"]["ticket_prefix"]=="ENG"')"
ok "ts-shop fixture: Biome runs, Prettier doesn't" "$(q shop '"biome" in d["code"]["tools_run"] and d["code"]["config_not_run"]==["prettier (.prettierrc, .vscode/settings.json)"]')"
ok "set-up fixture: a re-run"                "$(build setup rerun)$(q setup 'd["project"]["state"]=="set-up" and d["project"]["dev_team_dir"]=="ours"')"

# macOS: every scaffold gives the run's login shell a git and python3 that work in the sandbox, ahead of /usr/bin's
# xcrun stubs.
ok "every scaffold has the macOS wrappers" "$(for f in evals/*/scaffold.sh; do grep -q 'for t in git python3' "$f" || echo "$f "; done)"
if command -v xcode-select >/dev/null; then
  ok "macOS: the run's login shell finds the wrappers" "$(for s in zsh bash; do
    for t in git python3; do w=$(env -i HOME="$T/empty" PATH=/usr/bin:/bin /bin/$s -l -c "command -v $t" 2>/dev/null)
    [ "$w" = "$T/empty/.eval-bin/$t" ] || echo "$s finds $t at $w "; done; done)"
else echo "ok   macOS git wrapper: skipped, not macOS"; fi

# The shell prefix (tests/eval-shell-prefix) runs what it's given, with the wrapper first, and logs it.
mkdir -p "$T/pfx/.eval-bin" && printf '#!/bin/sh\necho wrapper\n' > "$T/pfx/.eval-bin/git" && chmod +x "$T/pfx/.eval-bin/git"
out=$(env -i HOME="$T/pfx" PATH=/usr/bin:/bin "$REPO/tests/eval-shell-prefix" 'git; exit 3'); rc=$?
ok "shell prefix runs the command with the wrapper first" "$([ "$out" = wrapper ] && [ $rc = 3 ] || echo "got '$out', exit $rc")"
ok "shell prefix logs each command" "$(grep -q 'git; exit 3' "$T/pfx/.eval-prefix.log" 2>/dev/null || echo 'not logged')"

# The README's case map names every case.
ok "README maps every case" "$(for d in evals/*/; do n=$(basename "$d"); [ "$n" = results ] && continue
  grep -q "\`$n\`" evals/README.md || echo "$n "; done)"

exit $fail
