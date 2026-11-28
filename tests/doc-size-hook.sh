#!/bin/bash
# Tests for hooks/doc-size.sh: a live workspace document that grows past the size limit gets one warning per session,
# in the main checkout and in peers' worktrees.
# Run: tests/doc-size-hook.sh
cd "$(dirname "$0")/.." || exit 1
REPO=$PWD
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail=0
ok() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }
hook() { OUT=$(printf '{"session_id":"%s","tool_name":"Edit","tool_input":{"file_path":"%s","old_string":"a"}}' "$1" "$2" |
               CLAUDE_PROJECT_DIR="${PROJ:-$T/p}" CLAUDE_PLUGIN_ROOT="$REPO" bash "$REPO/hooks/doc-size.sh"); RC=$?; }
big() { python3 -c 'import sys; open(sys.argv[1], "w").write("x" * int(sys.argv[2]) * 1024)' "$1" "$2"; }

mkdir -p "$T/p/docs/features/a" "$T/p/docs/standards"
git -C "$T/p" init -q
printf -- '- **Workspace:** `docs` · features `docs/features` · folders `slug` · committed\n' > "$T/p/CLAUDE.md"
echo "# Status" > "$T/p/docs/status.md"
big "$T/p/docs/features/a/plan.md" 30
big "$T/p/docs/features/a/brief.md" 10
big "$T/p/docs/notes.md" 30

hook s1 "$T/p/docs/features/a/plan.md"
ok "over the limit: tells the agent"         '[ $RC = 0 ] && [[ $OUT == *additionalContext*"docs/features/a/plan.md is now 30 KB, over the 25 KB limit"* ]]'
ok "the warning is valid JSON"               'printf "%s" "$OUT" | python3 -m json.tool >/dev/null'
hook s1 "$T/p/docs/features/a/plan.md"
ok "once per session and document"          '[ -z "$OUT" ]'
hook s2 "$T/p/docs/features/a/plan.md"
ok "a new session is told again"            '[[ $OUT == *"plan.md is now 30 KB"* ]]'
hook s1 "$T/p/docs/features/a/brief.md"
ok "under the limit: silent"                '[ -z "$OUT" ]'
hook s1 "$T/p/docs/notes.md"
ok "elsewhere in the workspace: told too"   '[[ $OUT == *"docs/notes.md is now 30 KB"* ]]'
mkdir -p "$T/p/docs/backlog"
for f in friction-log.md status-done.md friction-archive.md backlog/archive.md; do big "$T/p/docs/$f" 30; done
big "$T/p/README.md" 30
for f in docs/friction-log.md docs/status-done.md docs/friction-archive.md docs/backlog/archive.md README.md; do
  hook s1 "$T/p/$f"; ok "silent: $f"        '[ -z "$OUT" ]'
done

printf '# Documentation Standards\n\n## Size and reading\n- Live briefs, plans and designs stay under about 40 KB.\n\n## Other\n- 10 KB\n' \
  > "$T/p/docs/standards/documentation.md"
hook s3 "$T/p/docs/features/a/plan.md"
ok "the project's own limit applies"        '[ -z "$OUT" ]'
big "$T/p/docs/features/a/plan.md" 41
hook s3 "$T/p/docs/features/a/plan.md"
ok "and is the one named"                   '[[ $OUT == *"over the 40 KB limit"* ]]'
printf '# Documentation Standards\n\n## Size and reading\n- History: the old plan reached 95 KB.\n- A live brief stays under about 20 KB.\n' \
  > "$T/p/docs/standards/documentation.md"
hook s3b "$T/p/docs/features/a/plan.md"
ok "the rule's own number, not the first KB figure" '[[ $OUT == *"over the 20 KB limit"* ]]'
rm "$T/p/docs/standards/documentation.md"

# Peers. One layout links the workspace into each worktree; another keeps a copy there while peers write the main one.
git -C "$T/p" add CLAUDE.md && git -C "$T/p" -c user.name=t -c user.email=t@t commit -qm init
git -C "$T/p" worktree add -q --detach "$T/wt1" && ln -s "$T/p/docs" "$T/wt1/docs"
PROJ=$T/wt1 hook p1 "$T/wt1/docs/features/a/plan.md"
ok "worktree with a linked workspace: told" '[[ $OUT == *"docs/features/a/plan.md is now 41 KB"* ]]'
PROJ=$T/wt1 hook p1b "$T/wt1/docs/notes.md"
ok "and outside the features folder too"    '[[ $OUT == *"docs/notes.md is now 30 KB"* ]]'
git -C "$T/p" worktree add -q --detach "$T/wt2" && mkdir -p "$T/wt2/docs/features/a" && echo "# Status" > "$T/wt2/docs/status.md"
PROJ=$T/wt2 hook p2 "$T/p/docs/features/a/plan.md"
ok "worktree writing the main checkout's workspace: told" '[[ $OUT == *"docs/features/a/plan.md is now 41 KB"* ]]'
big "$T/wt2/docs/features/a/small.md" 5; PROJ=$T/wt2 hook p3 "$T/wt2/docs/features/a/small.md"
ok "its own small copy: silent"            '[ -z "$OUT" ]'

mkdir -p "$T/q/docs" && git -C "$T/q" init -q && cp "$T/p/CLAUDE.md" "$T/q/" && echo "# Status" > "$T/q/docs/status.md"
big "$T/q/README.md" 30
PROJ=$T/q hook q1 "$T/q/README.md"
ok "no features folder yet: other files stay silent" '[ -z "$OUT" ]'

rm "$T/p/docs/status.md"
hook s4 "$T/p/docs/features/a/plan.md"
ok "no dev-team workspace: silent"          '[ -z "$OUT" ] && [ $RC = 0 ]'
exit $fail
