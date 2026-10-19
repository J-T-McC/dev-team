# Read the project's Workspace line (workflow/workspace.md). Source with the project dir as $1.
# Sets WS (workspace root), FEATURES (features folder), WS_COMMITTED (yes|no), WS_LINE (raw line).
_dir=${1:-.}
WS_LINE=$(grep -h '\*\*Workspace:\*\*' "$_dir/CLAUDE.local.md" "$_dir/CLAUDE.md" 2>/dev/null | head -1)
WS=$(printf '%s' "$WS_LINE" | sed -n 's/.*\*\*Workspace:\*\* *`\([^`]*\)`.*/\1/p'); WS=${WS:-docs}
FEATURES=$(printf '%s' "$WS_LINE" | sed -n 's/.*features *`\([^`]*\)`.*/\1/p'); FEATURES=${FEATURES:-$WS/features}
case "$WS_LINE" in *"not committed"*) WS_COMMITTED=no ;; *) WS_COMMITTED=yes ;; esac
WS=${WS%/}; FEATURES=${FEATURES%/}
