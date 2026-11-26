#!/bin/bash
# Tests for hooks/doc-size.sh: a feature document that grows past the size limit gets one warning per session.
# Run: tests/doc-size-hook.sh
cd "$(dirname "$0")/.." || exit 1
REPO=$PWD
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail=0
ok() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }
hook() { OUT=$(printf '{"session_id":"%s","tool_name":"Edit","tool_input":{"file_path":"%s","old_string":"a"}}' "$1" "$2" |
               CLAUDE_PROJECT_DIR="$T/p" CLAUDE_PLUGIN_ROOT="$REPO" bash "$REPO/hooks/doc-size.sh"); RC=$?; }
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
ok "outside the features folder: silent"    '[ -z "$OUT" ]'

printf '# Documentation Standards\n\n## Size and reading\n- Live briefs, plans and designs stay under about 40 KB.\n\n## Other\n- 10 KB\n' \
  > "$T/p/docs/standards/documentation.md"
hook s3 "$T/p/docs/features/a/plan.md"
ok "the project's own limit applies"        '[ -z "$OUT" ]'
big "$T/p/docs/features/a/plan.md" 41
hook s3 "$T/p/docs/features/a/plan.md"
ok "and is the one named"                   '[[ $OUT == *"over the 40 KB limit"* ]]'

rm "$T/p/docs/status.md"
hook s4 "$T/p/docs/features/a/plan.md"
ok "no dev-team workspace: silent"          '[ -z "$OUT" ] && [ $RC = 0 ]'
exit $fail
