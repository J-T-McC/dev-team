#!/bin/bash
# Tests for bin/token-audit against made-up transcripts: reads matched to their results, whole and partial, by reader,
# inside the window only; then what every session loads and the documents over the size limit.
# Run: tests/token-audit.sh
cd "$(dirname "$0")/.." || exit 1
REPO=$PWD
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail=0
ok() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }
row() { printf '%s\n' "$OUT" | tr -s ' ' | grep -F -- "$1"; }  # the lines that name $1, spaces collapsed
reader() { printf '%s\n' "$OUT" | sed -n '/^By reader/,/^$/p' | tr -s ' ' | grep -E -- " $1\$"; }
server() { printf '%s\n' "$OUT" | sed -n '/^MCP servers/,/^$/p' | tr -s ' ' | grep -E -- " $1\$"; }

g() { git -c user.name=t -c user.email=t@example.com "$@"; }
mkdir -p "$T/p/docs/features/a" "$T/p/docs/many" "$T/p/docs/standards" "$T/p/docs/old"
cd "$T/p" && g init -q -b main && g commit -q --allow-empty -m init && g worktree add -q "$T/wt-dev" 2>/dev/null
P=$(git rev-parse --show-toplevel) W=$(cd "$T/wt-dev" && pwd -P)
cd "$REPO" || exit 1
python3 - "$P" "$W" "$T/claude" <<'PY'
import json, os, re, sys, time
from datetime import datetime, timedelta, timezone
P, W, C = sys.argv[1:]
open(f"{P}/CLAUDE.md", "w").write("# App\n\nSee @docs/extra.md for more.\n\n# Development Organization\n\n"
                                  "- **Workspace:** `docs` · committed\n- **Runtime: Orca.** Peer size limit: 400k.\n\n## Rules\n- one\n")
open(f"{P}/docs/extra.md", "w").write("extra\n" * 100)
open(f"{P}/docs/status.md", "w").write("# Status\n")
open(f"{P}/docs/standards/documentation.md", "w").write("# Docs\n\n## Size and reading\n- History: one plan reached 95 KB.\n- Stay under about 20 KB.\n")
open(f"{P}/docs/features/a/plan.md", "w").write("# Plan\n" + "## Part\n" + "x" * 30000 + "\n")
open(f"{P}/docs/features/a/brief.md", "w").write("# Brief\n")
open(f"{P}/docs/features/a/notes.md", "w").write("y" * 12000 + "\n")
for i in range(6):
    open(f"{P}/docs/many/f{i}.md", "w").write("z\n")
open(f"{P}/docs/old/history.md", "w").write("h" * 30000)
os.utime(f"{P}/docs/old/history.md", (time.time() - 90 * 86400,) * 2)

slug = lambda p: re.sub(r"[^A-Za-z0-9]", "-", p)
now = datetime.now(timezone.utc)
ts = lambda days=0: (now - timedelta(days=days)).strftime("%Y-%m-%dT%H:%M:%S.000Z")
def use(i, name, **inp):
    return {"type": "assistant", "cwd": cwd, "timestamp": ts(), "message": {"content": [{"type": "tool_use", "id": i, "name": name, "input": inp}]}}
def res(i, chars, file=None, days=0, text="r"):
    e = {"type": "user", "cwd": cwd, "timestamp": ts(days),
         "message": {"content": [{"type": "tool_result", "tool_use_id": i, "content": (text * chars)[:chars]}]}}
    if file:
        e["toolUseResult"] = {"type": "text", "file": dict(zip(("startLine", "numLines", "totalLines"), file))}
    return e
def write(path, entries):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, "w").write("".join(json.dumps(e) + "\n" for e in entries))

cwd, d = P, f"{C}/projects/{slug(P)}"
main = [
    {"type": "user", "cwd": P, "timestamp": ts(), "message": {"content": "hello"}},
    {"type": "attachment", "cwd": P, "timestamp": ts(), "attachment": {"type": "hook_success", "hookEvent": "SessionStart",
     "command": "/x/.claude/plugins/cache/mkt/dev-team/abc/hooks/session-start.sh", "stdout": "s" * 400, "content": "s" * 400}},
    {"type": "attachment", "cwd": P, "timestamp": ts(), "attachment": {"type": "hook_success", "hookEvent": "SessionStart",
     "command": "node /x/.claude/plugins/cache/mkt/recall/1.0/start.js",
     "stdout": json.dumps({"hookSpecificOutput": {"additionalContext": "m" * 2048}}), "content": ""}},
    use("r1", "Read", file_path=f"{P}/docs/features/a/plan.md"), res("r1", 4000, (1, 100, 100)),
    use("r2", "Read", file_path=f"{P}/docs/features/a/plan.md", offset=10, limit=5), res("r2", 400, (10, 5, 100)),
    use("k1", "Skill", skill="dev-team:principal-engineer"), res("k1", 10),
    use("b1", "Bash", command="cd docs && cat features/a/plan.md"), res("b1", 2000),
    use("b2", "Bash", command="grep -n foo docs/features/a/brief.md 2>/dev/null | head -5"), res("b2", 80),
    use("b3", "Bash", command="grep -n z docs/many/*.md"), res("b3", 400),
    use("b4", "Bash", command="npm test 2>&1 | tail -20"), res("b4", 4000),
    use("b5", "Bash", command="sed -i '' 's/a/b/' docs/features/a/brief.md"), res("b5", 40),
    use("b6", "Bash", command="python3 - <<'PY'\nprint(open('docs/features/a/brief.md').read())\ncat x.md\nPY"), res("b6", 40),
    use("v1", "Bash", command='S=docs/status.md; grep -n foo "$S"'), res("v1", 80),
    use("v2", "Bash", command='export D="$PWD/docs" && sed -n 1,5p "${D}/status.md" && cat "$UNSET/x.md"'), res("v2", 80),
    use("n1", "Read", file_path=f"{P}/docs/features/a/notes.md"), res("n1", 1200, (1, 1, 1)),
    use("o1", "Read", file_path=f"{P}/docs/features/a/plan.md"), res("o1", 9999, (1, 100, 100), days=30),
]
write(f"{d}/s1.jsonl", main)
write(f"{d}/s1-resumed.jsonl", main[3:5])  # a resumed session repeats history: counted once, in the first
os.utime(f"{d}/s1-resumed.jsonl", (time.time() + 5,) * 2)
os.makedirs(f"{d}/memory", exist_ok=True)
open(f"{d}/memory/MEMORY.md", "w").write("- [a](a.md)\n" * 10)
write(f"{d}/s1/subagents/agent-1.jsonl", [use("a1", "Read", file_path=f"{P}/docs/features/a/plan.md", offset=1, limit=9),
                                          res("a1", 800, (1, 9, 100))])
open(f"{d}/s1/subagents/agent-1.meta.json", "w").write(json.dumps({"agentType": "dev-team:reviewer"}))

cwd, d = W, f"{C}/projects/{slug(W)}"
write(f"{d}/w1.jsonl", [
    {"type": "user", "cwd": W, "timestamp": ts(), "message": {"content": "Read your task."}},
    use("t0", "Read", file_path=f"{W}/docs/features/a/brief.md"), res("t0", 200, (1, 3, 3)),
    use("t1", "Bash", command="orca orchestration check"),
    res("t1", 120, text="=== TASK === You are the dev-team senior-developer peer [dev-team home dt-dev-1]. Go. "),
    use("w2", "Read", file_path=f"{W}/docs/features/a/plan.md"), res("w2", 4000, (1, 100, 100)),
    # what each call carries, and each call's usage
    {"type": "api-request-shape", "shape": {"tools": [{"name": "Bash", "d": "b" * 380}, {"name": "Artifact", "d": "a" * 3980},
                                                      {"name": "mcp__db__query", "d": "q" * 360}]}},
    {"type": "attachment", "cwd": W, "timestamp": ts(), "attachment": {"type": "deferred_tools_delta",
     "addedNames": ["mcp__rea__a", "mcp__rea__b", "Monitor"], "addedLines": ["mcp__rea__a", "mcp__rea__b", "Monitor"]}},
    {"type": "attachment", "cwd": W, "timestamp": ts(), "attachment": {"type": "mcp_instructions_delta",
     "addedNames": ["rea", "claude.ai Docs"], "addedBlocks": ["i" * 400, "d" * 800]}},
    *[{"type": "assistant", "cwd": W, "timestamp": ts(), "message": {"id": "m1", "content": [], "usage": {
        "input_tokens": 10, "cache_creation_input_tokens": 1000, "cache_read_input_tokens": 0, "output_tokens": 100,
        "cache_creation": {"ephemeral_1h_input_tokens": 1000}}}}] * 2,  # streamed: one call, two lines
    {"type": "assistant", "cwd": W, "timestamp": ts(), "message": {"id": "m2", "usage": {
        "input_tokens": 10, "cache_creation_input_tokens": 990, "cache_read_input_tokens": 3000, "output_tokens": 50},
        "content": [{"type": "tool_use", "id": "q1", "name": "mcp__db__query", "input": {}}]}},
    {"type": "system", "subtype": "compact_boundary", "cwd": W, "timestamp": ts(),
     "compactMetadata": {"trigger": "auto", "preTokens": 368000}},
    {"type": "assistant", "cwd": W, "timestamp": ts(days=30), "message": {"id": "m0", "content": [], "usage": {
        "input_tokens": 99999, "output_tokens": 1}}},
])
PY
OUT=$(CLAUDE_CONFIG_DIR="$T/claude" bin/token-audit "$T/p" --days 7 2>&1); RC=$?
PLAN="plan.md [2 heading"
# plan.md: r1 1000 whole, r2 100, b1 500 whole (cat after cd), w2 1000 whole (peer), a1 200 (agent); o1 is too old.
ok "runs, counting each session file"           '[ $RC = 0 ] && [[ $OUT == "Reads, last 7 days: 4 sessions"* ]]'
ok "a file's reads add up, inside the window"   '[[ $(row "$PLAN") == " 2.8k 5 3 / 2.5k 2 / 300 docs/"* ]]'
ok "top readers: main role, peer home, agent"   '[[ $(row "$PLAN") == *"— principal-engineer 1.6k, dt-dev-1 1.0k, reviewer (agent) 200" ]]'
ok "a big file shows its largest section"       '[[ $(row "$PLAN") == *"[2 heading(s), largest section 29.3 KB]"* ]]'
ok "a big file without headings is flagged"     '[[ $(row "notes.md") == *"notes.md [no headings]"* ]]'
ok "piped grep is partial, a full Read whole"   '[[ $(row "brief.md —") == " 70 2 1 / 50 1 / 20 docs/features/a/brief.md — dt-dev-1 50, principal-engineer 20" ]]'
ok "a search over many files counts once"       '[[ $(row "(shell searches over more than 5 files)") == " 100 1 0 / 0 1 / 100 "* ]]'
ok "edits, heredocs and test runs are not reads" '! row " x.md" | grep -q . && [ "$(printf "%s\n" "$OUT" | grep -c "docs/features/a/brief.md —")" = 1 ]'
ok "reads through shell variables count"     '[[ $(row "docs/status.md —") == " 40 2 0 / 0 2 / 40 docs/status.md — principal-engineer 40" ]] && ! row "x.md —" | grep -q .'
ok "the peer is named before its task arrived"  '! row "wt-dev" | grep -q .'
ok "by reader"                                  '[[ $(reader principal-engineer) == " 2.1k 8 1.8k principal-engineer" ]] && [[ $(reader dt-dev-1) == " 1.1k 2 1.1k dt-dev-1" ]] && [[ $(reader "reviewer \(agent\)") == " 200 1 0 reviewer (agent)" ]]'
ok "CLAUDE.md, its dev-team section, imports"   '[[ $(row " CLAUDE.md") == *"CLAUDE.md — dev-team section"* ]] && [[ $(row "docs/extra.md") == *"imported by CLAUDE.md" ]]'
ok "the memory index"                           '[[ $(row "memory index") == *"(10 lines)" ]]'
ok "SessionStart output that reached the model" '[[ $(row "SessionStart hook output") == " 2.4 KB ≈ 612 SessionStart hook output, average of 1 session(s): recall 2.0 KB, dev-team 0.4 KB" ]]'
ok "the project's size limit"                   '[[ $OUT == *"Workspace docs over 20 KB, read or changed"* ]]'
ok "a live doc over it, with its reads"         '[[ $(row "KB docs/features/a/plan.md") == *"read 5× for 2.8k (3 whole)" ]]'
ok "history over it is only counted"            '[[ $OUT == *"and 1 more, neither read nor changed"* ]] && ! row "history.md" | grep -q .'

# m1: context 1,010, 10 + 1,000 × 2 + 100 × 5 = 2,510; m2: context 4,000, 10 + 990 × 1.25 + 3,000 × 0.1 + 50 × 5 = 1,797.5
ok "calls from usage, each once, in the window"  '[[ $(row "dt-dev-1" | grep "at ~") == " 4.3k 2 2.5k 1.0k 1 at ~368k dt-dev-1" ]]'
ok "the calls' total, for always-loaded savings" '[[ $OUT == *"4.3k      2  in 1 session(s), all readers"* ]]'
ok "a size limit compaction always beats"       '[[ $OUT == *"compacted 1 time(s), at a median 368k: the Peer size limit (400k) is above that"* ]]'
ok "the tool schemas every call carries"        '[[ $OUT == *"tool schemas of ~1.1k (median session); the largest: Artifact 1.0k, Bash 101"* ]]'
ok "MCP servers: size, loaded, used"            '[[ $(server rea) == " 116 1 0 23 rea" ]] && [[ $(server claude_ai_Docs) == " 200 1 0 40 claude_ai_Docs" ]] && [[ $(server db) == " 98 1 1 19 db" ]]'

OUT=$(CLAUDE_CONFIG_DIR="$T/empty" bin/token-audit "$T/p" 2>&1); RC=$?
ok "no transcripts: says so, still sizes"       '[ $RC = 0 ] && [[ $OUT == *"no file reads found"* ]] && [[ $OUT == *"Always loaded"* ]]'
exit $fail
