#!/bin/bash
# Fixture for env-git: a repository with one commit. On macOS it also tries the git fixes (evals/README.md § git on
# macOS) and makes every shell startup file note in ~/.eval-startup.log when the run's shell reads it.
set -e
if d=$(xcode-select -p 2>/dev/null); then
  mkdir -p "$HOME/.eval-bin"
  for t in git python3; do
    if [ -x "$d/usr/bin/$t" ]; then printf '#!/bin/sh\nexec "%s" "$@"\n' "$d/usr/bin/$t" > "$HOME/.eval-bin/$t"; chmod +x "$HOME/.eval-bin/$t"; fi
  done
  for f in .profile .zshenv .zprofile .zshrc .bashrc .bash_profile; do
    printf 'echo %s >> "$HOME/.eval-startup.log" 2>/dev/null\nexport PATH="$HOME/.eval-bin:$PATH"\n' "$f" >> "$HOME/$f"
  done
fi
git init -q -b main
git -c user.name=dev -c user.email=dev@example.com commit -q --allow-empty -m "chore: env probe commit"
