#!/bin/bash
# Tests for hooks/commit-workspace.sh: an uncommitted workspace is committed on Stop, and pushed once it has an upstream.
# Run: tests/workspace-hook.sh
cd "$(dirname "$0")/.." || exit 1
REPO=$PWD
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail=0
ok() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }
g() { git -c user.name=t -c user.email=t@example.com "$@"; }
hook() { CLAUDE_PROJECT_DIR="$T/p" CLAUDE_PLUGIN_ROOT="$REPO" GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.com \
         GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.com bash "$REPO/hooks/commit-workspace.sh"; }
pushed() {  # pushed: the remote reaches the workspace's head within 10 seconds (the push runs in the background)
  for _ in $(seq 1 50); do
    [ "$(git -C "$T/remote.git" rev-parse -q --verify main 2>/dev/null)" = "$(git -C "$T/p/.dev-team" rev-parse HEAD)" ] && return 0
    python3 -c 'import time; time.sleep(0.2)'
  done; return 1
}

mkdir -p "$T/p/.dev-team"
printf -- '- **Workspace:** `.dev-team` · features `.dev-team/features` · folders `slug` · not committed\n' > "$T/p/CLAUDE.local.md"
git -C "$T/p/.dev-team" init -q -b main && echo a > "$T/p/.dev-team/status.md"
hook; RC=$?
ok "no upstream: commits, exits 0"           '[ $RC = 0 ] && [ "$(git -C "$T/p/.dev-team" rev-list --count HEAD)" = 1 ]'

git init -q --bare -b main "$T/remote.git"
git -C "$T/p/.dev-team" remote add origin "$T/remote.git" && git -C "$T/p/.dev-team" push -q -u origin main
echo b >> "$T/p/.dev-team/status.md"
hook
ok "with an upstream: commits and pushes"    'pushed'

g -C "$T/p/.dev-team" commit -q --allow-empty -m "made by hand"
hook
ok "unchanged, but behind: pushes"           'pushed'

printf -- '- **Workspace:** `.dev-team` · committed\n' > "$T/p/CLAUDE.local.md"
echo c >> "$T/p/.dev-team/status.md"
hook
ok "committed workspace: left alone"         '[ -n "$(git -C "$T/p/.dev-team" status --porcelain)" ]'
exit $fail
