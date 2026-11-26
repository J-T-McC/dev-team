#!/bin/bash
# Fixture "set-up": a small project dev-team already set up, not in Orca.
# Shared by rerun and checkins-plain-words: keep the copies identical (tests/evals.sh).
set -e
# macOS: /usr/bin/git and /usr/bin/python3 are xcrun stubs that fail in a run's sandbox. This scaffold's HOME is the
# run's home, so wrappers there, first in the startup files the run's shell snapshot is taken from, reach the real
# tools (evals/README.md § git on macOS).
if d=$(xcode-select -p 2>/dev/null); then
  mkdir -p "$HOME/.eval-bin"
  for t in git python3; do
    if [ -x "$d/usr/bin/$t" ]; then printf '#!/bin/sh\nexec "%s" "$@"\n' "$d/usr/bin/$t" > "$HOME/.eval-bin/$t"; chmod +x "$HOME/.eval-bin/$t"; fi
  done
  for f in .zshrc .zprofile .bashrc .bash_profile; do echo 'export PATH="$HOME/.eval-bin:$PATH"' >> "$HOME/$f"; done
fi
g() { git -c user.name=dev -c user.email=dev@example.com "$@"; }
git init -q -b main
mkdir -p dev-team/standards dev-team/stack dev-team/features dev-team/backlog dev-team/architecture dev-team/fixes
cat > CLAUDE.md <<'EOF'
# Habits

A habit tracker web app.

# Development Organization

- **Workspace:** `dev-team` · features `dev-team/features` · folders `slug` · committed
- **Autonomy:** standard
EOF
printf '# Project Status\n\n| Feature | Phase | Current Role | Blockers | Approvals | Path |\n|---|---|---|---|---|---|\n' > dev-team/status.md
printf '# Stack\n\n| Area | Choice |\n|---|---|\n| Languages | TypeScript |\n' > dev-team/stack/stack.md
printf '# Coding Standards\n\n## Commit messages (active)\n\nFormat: `<type>(<scope>): <ID> <what changed>`\n' > dev-team/standards/coding.md
printf '# Backlog\n\n| ID | Item | Priority |\n|---|---|---|\n' > dev-team/backlog/index.md
g add -A && g commit -q -m "chore: set up dev-team"
