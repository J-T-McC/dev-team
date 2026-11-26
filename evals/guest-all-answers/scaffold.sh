#!/bin/bash
# Fixture "ts-shop": an existing TypeScript storefront. Biome is wired into scripts and CI; Prettier is configured but
# nothing runs it; the README mentions Oxlint. 20 conventional commits with ENG- ticket IDs.
# Shared by existing-no-answers, existing-all-answers and guest-all-answers: keep the copies identical (tests/evals.sh).
set -e
# macOS: an eval run's shell is a login shell, whose path_helper puts /usr/bin/git first: an xcrun stub that fails in
# the run's sandbox. This scaffold's HOME is the run's home, so a wrapper there reaches the real git (evals/README.md).
if d=$(xcode-select -p 2>/dev/null) && [ -x "$d/usr/bin/git" ]; then
  mkdir -p "$HOME/.eval-bin" && printf '#!/bin/sh\nexec "%s" "$@"\n' "$d/usr/bin/git" > "$HOME/.eval-bin/git" && chmod +x "$HOME/.eval-bin/git"
  for f in .zshrc .zprofile .bashrc .bash_profile; do echo 'export PATH="$HOME/.eval-bin:$PATH"' >> "$HOME/$f"; done
fi
g() { git -c user.name=dev -c user.email=dev@example.com "$@"; }
git init -q -b main
mkdir -p src .vscode .github/workflows
cat > package.json <<'EOF'
{
  "name": "shop",
  "private": true,
  "scripts": {
    "test": "vitest run",
    "lint": "biome check .",
    "format": "biome format --write .",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": { "react": "^19.0.0", "react-dom": "^19.0.0" },
  "devDependencies": { "@biomejs/biome": "^2.0.0", "typescript": "^5.6.0", "vitest": "^3.0.0" }
}
EOF
echo '{ "compilerOptions": { "strict": true, "jsx": "react-jsx" } }' > tsconfig.json
echo '{ "formatter": { "indentStyle": "space" } }' > biome.json
echo '{ "semi": false }' > .prettierrc
echo '{ "editor.defaultFormatter": "esbenp.prettier-vscode", "[typescript]": { "editor.defaultFormatter": "biomejs.biome" } }' > .vscode/settings.json
cat > .github/workflows/ci.yml <<'EOF'
name: ci
on: [pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: pnpm install && pnpm lint && pnpm test
EOF
printf '# Shop\n\nA small storefront. Lint with Oxlint, test with Vitest.\n' > README.md
printf '# Shop\n\nUse pnpm. Run `pnpm lint` before committing.\n' > CLAUDE.md
printf 'node_modules/\ndist/\n' > .gitignore
echo 'export function total(items: { price: number }[]): number { return items.reduce((s, i) => s + i.price, 0) }' > src/cart.ts
echo 'import { total } from "./cart"; import { test, expect } from "vitest"; test("empty", () => expect(total([])).toBe(0))' > src/cart.test.ts
echo 'export const App = () => <main>Shop</main>' > src/App.tsx
: > pnpm-lock.yaml
g add -A && g commit -q -m "feat(cart): ENG-1 start the shop"
for i in $(seq 2 20); do echo "// $i" >> src/cart.ts; g commit -q -am "feat(cart): ENG-$i handle cart case $i"; done
