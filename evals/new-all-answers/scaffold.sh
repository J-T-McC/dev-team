#!/bin/bash
# Fixture "empty": a new git repository with one empty commit.
set -e
# macOS: an eval run's shell is a login shell, whose path_helper puts /usr/bin/git first: an xcrun stub that fails in
# the run's sandbox. This scaffold's HOME is the run's home, so a wrapper there reaches the real git (evals/README.md).
if d=$(xcode-select -p 2>/dev/null) && [ -x "$d/usr/bin/git" ]; then
  mkdir -p "$HOME/.eval-bin" && printf '#!/bin/sh\nexec "%s" "$@"\n' "$d/usr/bin/git" > "$HOME/.eval-bin/git" && chmod +x "$HOME/.eval-bin/git"
  for f in .zshrc .zprofile .bashrc .bash_profile; do echo 'export PATH="$HOME/.eval-bin:$PATH"' >> "$HOME/$f"; done
fi
git init -q -b main
git -c user.name=dev -c user.email=dev@example.com commit -q --allow-empty -m "chore: start"
