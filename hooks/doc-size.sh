#!/bin/bash
# PostToolUse hook on Write and Edit: tell the agent, once per session and document, when a document in the features
# folder has grown past the size limit (<ws>/standards/documentation.md § Size and reading; 25 KB by default).
# Silent everywhere else, and in projects without a dev-team workspace.
P="${CLAUDE_PROJECT_DIR:-.}"
in=$(cat)
field() { printf '%s' "$in" | grep -o "\"$1\" *: *\"[^\"]*\"" | head -1 | sed 's/^[^:]*: *"//; s/"$//'; }
f=$(field file_path)
case "$f" in *.md) ;; *) exit 0 ;; esac
source "${CLAUDE_PLUGIN_ROOT}/bin/_workspace.sh" "$P"
[ -f "$P/$WS/status.md" ] && [ -f "$f" ] || exit 0
case "$FEATURES" in /*) base=$FEATURES ;; *) base="$(cd "$P" && pwd -P)/$FEATURES" ;; esac
case "$(cd "$(dirname "$f")" && pwd -P)/$(basename "$f")" in "$base"/*) ;; *) exit 0 ;; esac

limit=$(sed -n '/^## Size and reading/,/^## /p' "$P/$WS/standards/documentation.md" 2>/dev/null |
        grep -oE '[0-9]+ ?KB' | head -1 | grep -oE '[0-9]+')
limit=${limit:-25}
size=$(wc -c < "$f" | tr -d ' ')
[ "$size" -gt $((limit * 1024)) ] || exit 0

# Once per session and document: the warning is for the edit that pushed it over, not for every edit after.
state="$(git -C "$P" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)/dev-team"
if [ "$state" != /dev-team ] && mkdir -p "$state" 2>/dev/null; then
  key="$(field session_id) $f"
  grep -qxF "$key" "$state/doc-size-warned" 2>/dev/null && exit 0
  echo "$key" >> "$state/doc-size-warned"
  [ "$(wc -l < "$state/doc-size-warned")" -gt 1000 ] && tail -200 "$state/doc-size-warned" > "$state/doc-size-warned.tmp" &&
    mv "$state/doc-size-warned.tmp" "$state/doc-size-warned"
fi

rel=${f#"$P"/}
msg="dev-team: $rel is now $(( (size + 1023) / 1024 )) KB, over the $limit KB limit for live documents ($WS/standards/documentation.md § Size and reading). Replace superseded text in place instead of adding below it; if it is still over, split it into part files."
printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' "$(printf '%s' "$msg" | tr '"\\' "''")"
exit 0
