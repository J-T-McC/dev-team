# Read the project's Workspace line (workflow/workspace.md). Source with the project dir as $1.
# Sets WS (workspace root), FEATURES (features folder), WS_COMMITTED (yes|no), WS_MODE (shared|just-me|guest),
# WS_LINE (raw line).
_dir=${1:-.}
WS_LINE=$(grep -h '\*\*Workspace:\*\*' "$_dir/CLAUDE.local.md" 2>/dev/null | head -1)
# A section in CLAUDE.local.md is guest mode, unless its line says "just me": your own project, not shared yet.
if [ -n "$WS_LINE" ]; then case "$WS_LINE" in *"just me"*) WS_MODE=just-me ;; *) WS_MODE=guest ;; esac
else WS_LINE=$(grep -h '\*\*Workspace:\*\*' "$_dir/CLAUDE.md" 2>/dev/null | head -1); WS_MODE=shared
fi
WS=$(printf '%s' "$WS_LINE" | sed -n 's/.*\*\*Workspace:\*\* *`\([^`]*\)`.*/\1/p'); WS=${WS:-docs}
# Settings are words after a space ("· features `x`"); a path that merely ends in "features" must not match.
FEATURES=$(printf '%s' "$WS_LINE" | sed -n 's/.*[[:space:]]features[[:space:]][[:space:]]*`\([^`]*\)`.*/\1/p'); FEATURES=${FEATURES:-$WS/features}
case "$WS_LINE" in *"not committed"*) WS_COMMITTED=no ;; *) WS_COMMITTED=yes ;; esac
WS=${WS%/}; FEATURES=${FEATURES%/}
