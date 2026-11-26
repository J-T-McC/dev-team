#!/bin/bash
# Fixture for env-git: a repository with one commit. On macOS it also tries the git fixes (evals/README.md § git on
# macOS) and makes every shell startup file note in ~/.eval-startup.log when the run's shell reads it.
set -e
if d=$(xcode-select -p 2>/dev/null) && [ -x "$d/usr/bin/git" ]; then
  mkdir -p "$HOME/.eval-bin" && printf '#!/bin/sh\nexec "%s" "$@"\n' "$d/usr/bin/git" > "$HOME/.eval-bin/git" && chmod +x "$HOME/.eval-bin/git"
  for f in .profile .zshenv .zprofile .zshrc .bashrc .bash_profile; do
    printf 'echo %s >> "$HOME/.eval-startup.log" 2>/dev/null\nexport PATH="$HOME/.eval-bin:$PATH"\n' "$f" >> "$HOME/$f"
  done
fi
git init -q -b main
git -c user.name=dev -c user.email=dev@example.com commit -q --allow-empty -m "chore: env probe commit"
