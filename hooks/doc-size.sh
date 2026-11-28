#!/bin/bash
# PostToolUse hook on Write and Edit: tell the agent, once per session and document, when a live document in the
# workspace has grown past the size limit (<ws>/standards/documentation.md § Size and reading; 25 KB by default).
# Logs and archives only grow, so they are left out. Peers count too: a worktree whose workspace is a symlink, or a
# peer writing the main checkout's workspace by absolute path. Silent everywhere else, and in projects without a
# dev-team workspace.
P="${CLAUDE_PROJECT_DIR:-.}"
in=$(cat)
field() { printf '%s' "$in" | grep -o "\"$1\" *: *\"[^\"]*\"" | head -1 | sed 's/^[^:]*: *"//; s/"$//'; }
f=$(field file_path)
case "$f" in *.md) ;; *) exit 0 ;; esac
[ -f "$f" ] || exit 0
case "$(basename "$f")" in *-log.md | *-archive.md | archive.md | status-done.md) exit 0 ;; esac
real="$(cd "$(dirname "$f")" && pwd -P)/$(basename "$f")"
resolve() { case "$2" in /*) (cd "$2" 2>/dev/null && pwd -P) ;; *) (cd "$1/$2" 2>/dev/null && pwd -P) ;; esac; }

# This checkout first, then the main checkout: a peer's worktree may hold its own copy while it writes the main one.
main=$(git -C "$P" worktree list --porcelain 2>/dev/null | sed -n '1s/^worktree //p')
root="" rel=""
for r in "$P" ${main:+"$main"}; do
  source "${CLAUDE_PLUGIN_ROOT}/bin/_workspace.sh" "$r"
  [ -f "$r/$WS/status.md" ] || continue
  for dir in "$WS" "$FEATURES"; do
    base=$(resolve "$r" "$dir") && [ -n "$base" ] || continue  # a folder not made yet matches nothing
    case "$real" in "$base"/*) root=$r rel="$dir/${real#"$base"/}"; break 2 ;; esac
  done
done
[ -n "$root" ] || exit 0

# The limit is the rule's own number ("stay under about 25 KB"), not the first KB figure in the section.
sec=$(sed -n '/^## Size and reading/,/^## /p' "$root/$WS/standards/documentation.md" 2>/dev/null)
limit=$(printf '%s\n' "$sec" | grep -oiE '(under|below) (about )?[0-9]+ ?KB' | head -1 | grep -oE '[0-9]+')
limit=${limit:-$(printf '%s\n' "$sec" | grep -oE '[0-9]+ ?KB' | head -1 | grep -oE '[0-9]+')}
limit=${limit:-25}
size=$(wc -c < "$f" | tr -d ' ')
[ "$size" -gt $((limit * 1024)) ] || exit 0

# Once per session and document: the warning is for the edit that pushed it over, not for every edit after.
state="$(git -C "$P" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)/dev-team"
if [ "$state" != /dev-team ] && mkdir -p "$state" 2>/dev/null; then
  key="$(field session_id) $real"
  grep -qxF "$key" "$state/doc-size-warned" 2>/dev/null && exit 0
  echo "$key" >> "$state/doc-size-warned"
  [ "$(wc -l < "$state/doc-size-warned")" -gt 1000 ] && tail -200 "$state/doc-size-warned" > "$state/doc-size-warned.tmp" &&
    mv "$state/doc-size-warned.tmp" "$state/doc-size-warned"
fi

msg="dev-team: $rel is now $(( (size + 1023) / 1024 )) KB, over the $limit KB limit for live documents ($WS/standards/documentation.md § Size and reading). Replace superseded text in place instead of adding below it; if it is still over, split it into part files."
printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' "$(printf '%s' "$msg" | tr '"\\' "''")"
exit 0
