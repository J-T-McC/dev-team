# Shared by the dev-team check-in scripts. Orca runs these as automation prechecks:
# exit 0 starts the check-in, any other exit skips it at no token cost.
cd "$(git rev-parse --show-toplevel 2>/dev/null)" || exit 1
STATE_DIR="$(git rev-parse --path-format=absolute --git-common-dir)/dev-team"
LOCK="$STATE_DIR/coordinator.lock"
mkdir -p "$STATE_DIR"
source "$(dirname "${BASH_SOURCE[0]}")/_workspace.sh" .

mtime() { stat -f %m "$1" 2>/dev/null || stat -c %Y "$1"; }

# A coordinator (interactive or check-in) is acting; stale after DEV_TEAM_LOCK_TTL_MIN.
lock_held() {
  [ -f "$LOCK" ] || return 1
  [ $(( $(date +%s) - $(mtime "$LOCK") )) -lt $(( ${DEV_TEAM_LOCK_TTL_MIN:-30} * 60 )) ]
}

# Outside the project's working hours (bin/hours): check-ins skip, so the team starts nothing on its own.
off_hours() {
  command -v python3 >/dev/null 2>&1 || return 1
  ! "$(dirname "${BASH_SOURCE[0]}")/hours" >/dev/null 2>&1
}

# Hash of the documents whose change means there is work to route.
docs_fingerprint() {
  cat "$WS/status.md" "$WS/backlog/index.md" "$FEATURES"/*/questions/*.md "$FEATURES"/*/tasks/index.md "$FEATURES"/*/review.md 2>/dev/null \
    | shasum | cut -d' ' -f1
}
