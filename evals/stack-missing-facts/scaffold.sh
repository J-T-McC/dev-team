#!/bin/bash
# Fixture "empty": a new git repository with one empty commit.
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
git init -q -b main
git -c user.name=dev -c user.email=dev@example.com commit -q --allow-empty -m "chore: start"
