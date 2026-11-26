#!/bin/bash
# Tests for bin/setup-detect: what it finds in test repos and fake environments, and what it suggests from that.
# gh, claude, docker and orca are fakes; PATH is cut down to them plus the system tools, so the machine's own don't leak in.
# Run: tests/setup-detect.sh
cd "$(dirname "$0")/.." || exit 1
REPO=$PWD DETECT=$PWD/bin/setup-detect
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail=0
ok() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; echo "     $OUT" | head -c 600; echo; fail=1; fi; }
mkdir -p "$T/bin" "$T/orca-bin" "$T/nopy" "$T/claude"
cat > "$T/bin/gh" <<'EOF'
#!/bin/bash
case "$1 $2" in
  "--version "*)    echo "gh version 2.99.0 (2026-01-01)" ;;
  "auth status")    [ -n "$FAKE_GH_LOGGED_IN" ] ;;
  "extension list") [ -n "$FAKE_GH_STACK" ] && echo "gh stack  github/gh-stack  v1.0.0" ;;
  "api graphql")    echo "$FAKE_GH_PERM" ;;
  "pr list")        echo "${FAKE_GH_PRS:-[]}" ;;
esac
EOF
printf '#!/bin/bash\n[ "$1 $2" = "auth status" ] && echo "$FAKE_CLAUDE_AUTH"\n' > "$T/bin/claude"
printf '#!/bin/bash\n[ "$1" = --version ] && echo "Docker version 27.0.1, build x" && exit\n[ -n "$FAKE_DOCKER_UP" ] && echo 27.0.1\n' > "$T/bin/docker"
printf '#!/bin/bash\necho "1.2.3"\n' > "$T/orca-bin/orca"
printf '#!/bin/sh\necho "python3: not found" >&2; exit 127\n' > "$T/nopy/python3"
chmod +x "$T"/bin/* "$T/orca-bin/orca" "$T/nopy/python3"
BASE="$T/bin:/usr/bin:/bin"

# detect <dir> [VAR=value ...]: run setup-detect there with a clean environment plus the given variables.
detect() {
  local d=$1; shift
  OUT=$(cd "$d" && env -i HOME="$T" CLAUDE_CONFIG_DIR="$T/claude" PATH="$BASE" "$@" "$DETECT" 2>&1)
}
# q <python expression on d>: true when the expression holds for the JSON in $OUT.
q() { python3 -c 'import json,sys; d=json.loads(sys.argv[1]); sys.exit(0 if eval(sys.argv[2]) else 1)' "$OUT" "$1" 2>/dev/null; }
g() { git -C "$1" -c user.name=t -c user.email=t@example.com "${@:2}"; }
repo() {  # repo <name> <subject>...: a git repo with one empty commit per subject, oldest first
  local d="$T/$1"; shift; mkdir -p "$d" && git -C "$d" init -q
  for s in "$@"; do g "$d" commit -q --allow-empty -m "$s"; done
  printf '%s' "$d"
}

# -- the project --------------------------------------------------------------------------------------------------
mkdir "$T/empty"; detect "$T/empty"
ok "valid JSON"                                      'q "True"'
ok "empty folder: new, no remote, mine-shared"       'q "d[\"project\"][\"state\"]==\"new\" and d[\"project\"][\"access\"]==\"no remote\" and d[\"suggest\"][\"project\"][\"value\"]==\"mine-shared\""'
ok "empty folder: too few commits, dev-team style"   'q "d[\"commits\"][\"style\"]==\"too few\" and d[\"suggest\"][\"commits\"][\"value\"]==\"dev-team\""'

rm -rf "$T/conv"; mkdir -p "$T/conv" && git -C "$T/conv" init -q
for i in $(seq 1 20); do g "$T/conv" commit -q --allow-empty -m "feat(cart): ENG-$i handle item $i"; done
detect "$T/conv"
ok "conventional history: style, ticket prefix"     'q "d[\"commits\"][\"style\"]==\"conventional\" and d[\"commits\"][\"ticket_prefix\"]==\"ENG\""'
ok "conventional history: newest subject as example" 'q "d[\"commits\"][\"example\"]==\"feat(cart): ENG-20 handle item 20\""'
ok "conventional history: suggests the project's"   'q "d[\"suggest\"][\"commits\"][\"value\"]==\"project\""'

R=$(repo free "fix the thing" "Update README" "wip" "more stuff" "Merge branch main" "tweak")
detect "$R"
ok "free-form history: suggests dev-team's style"   'q "d[\"commits\"][\"style\"]==\"free\" and d[\"commits\"][\"ticket_prefix\"] is None and d[\"suggest\"][\"commits\"][\"value\"]==\"dev-team\""'

R=$(repo tickets "ENG-12 fix login" "ENG-13 add logout" "tidy up" "ENG-14 rate limit" "notes")
detect "$R"
ok "free-form with tickets: suggests the project's"  'q "d[\"commits\"][\"ticket_prefix\"]==\"ENG\" and d[\"suggest\"][\"commits\"][\"value\"]==\"project\" and d[\"commits\"][\"example\"]==\"ENG-14 rate limit\""'

R=$(repo utf "fix UTF-8 names" "more UTF-8 work" "UTF-8 everywhere" "done" "really done")
detect "$R"
ok "UTF-8 is not a ticket prefix"                    'q "d[\"commits\"][\"ticket_prefix\"] is None"'

R=$(repo quotes 'fix: handle "quoted" \ paths' "chore: a" "chore: b" "chore: c" "chore: d")
detect "$R"
ok "quotes and backslashes stay valid JSON"          'q "d[\"commits\"][\"example\"]==\"chore: d\""'
g "$R" commit -q --allow-empty -m 'fix: handle "quoted" \ paths'; detect "$R"
ok "...and come back intact"                         'q "d[\"commits\"][\"example\"]==\"fix: handle \\\"quoted\\\" \\\\ paths\""'

# -- who owns it ------------------------------------------------------------------------------------------------
R=$(repo remote "chore: start")
git -C "$R" remote add origin "https://someone:secret-token@github.com/acme/shop.git"
detect "$R"
ok "remote: no credentials in the output"            'q "d[\"project\"][\"remote\"]==\"github.com/acme/shop\"" && [[ $OUT != *secret* ]]'
ok "gh logged out: access unknown, no suggestion"   'q "d[\"project\"][\"access\"]==\"unknown\" and d[\"suggest\"][\"project\"][\"value\"] is None"'
detect "$R" FAKE_GH_LOGGED_IN=1 FAKE_GH_PERM="me ADMIN me"
ok "your own repo: mine-shared"                      'q "d[\"project\"][\"access\"]==\"owner\" and d[\"suggest\"][\"project\"][\"value\"]==\"mine-shared\""'
detect "$R" FAKE_GH_LOGGED_IN=1 FAKE_GH_PERM="me ADMIN acme"
ok "an organisation repo you admin: mine-just-me"   'q "d[\"project\"][\"access\"]==\"admin\" and d[\"suggest\"][\"project\"][\"value\"]==\"mine-just-me\""'
detect "$R" FAKE_GH_LOGGED_IN=1 FAKE_GH_PERM="me WRITE acme"
ok "a repo you don't admin: guest"                   'q "d[\"project\"][\"access\"]==\"write\" and d[\"suggest\"][\"project\"][\"value\"]==\"guest\""'
git -C "$R" remote set-url origin git@github.com:acme/shop.git; detect "$R"
ok "ssh remote normalised"                           'q "d[\"project\"][\"remote\"]==\"github.com/acme/shop\""'

# -- the code ---------------------------------------------------------------------------------------------------
C="$T/code"; mkdir -p "$C/.vscode" "$C/.github/workflows" "$C/src" && git -C "$C" init -q
cat > "$C/package.json" <<'EOF'
{
  "name": "shop",
  "scripts": {
    "test": "vitest run",
    "lint": "biome check .",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": { "react": "^19.0.0" }
}
EOF
echo '{}' > "$C/tsconfig.json"; echo '{}' > "$C/biome.json"; echo '{}' > "$C/.prettierrc"; : > "$C/pnpm-lock.yaml"
echo '{ "editor.defaultFormatter": "esbenp.prettier-vscode" }' > "$C/.vscode/settings.json"
printf 'jobs:\n  t:\n    steps:\n      - run: pnpm playwright test\n' > "$C/.github/workflows/ci.yml"
echo 'Lint with Oxlint.' > "$C/README.md"; echo 'export const App = () => null' > "$C/src/App.tsx"
g "$C" add -A && g "$C" commit -q -m "feat: start"
detect "$C"
ok "code: existing, typescript, UI"                  'q "d[\"project\"][\"state\"]==\"existing\" and d[\"code\"][\"languages\"]==[\"typescript\"] and d[\"code\"][\"ui\"]"'
ok "code: runs via pnpm"                             'q "d[\"code\"][\"runs\"]=={\"test\":\"pnpm test\",\"lint\":\"pnpm run lint\",\"typecheck\":\"pnpm run typecheck\"}"'
ok "code: tools that run, from scripts and CI"      'q "set(d[\"code\"][\"tools_run\"])=={\"biome\",\"vitest\",\"tsc\",\"playwright\"}"'
ok "code: prettier is configured but never run"     'q "d[\"code\"][\"config_not_run\"]==[\"prettier (.prettierrc, .vscode/settings.json)\"]"'
ok "code: a README mention is not config"            'q "not any(\"oxlint\" in x for x in d[\"code\"][\"config_not_run\"])"'
ok "code: CI files listed"                           'q "d[\"code\"][\"ci\"]==[\".github/workflows/ci.yml\"]"'

G="$T/goapp"; mkdir -p "$G" && git -C "$G" init -q && printf 'module x\n' > "$G/go.mod" && echo 'package main' > "$G/main.go"
printf 'test:\n\tgo test ./...\nlint:\n\tgolangci-lint run\n' > "$G/Makefile"; : > "$G/.golangci.yml"
g "$G" add -A && g "$G" commit -q -m "start"; detect "$G"
ok "go: no UI, make targets, golangci-lint runs"    'q "d[\"code\"][\"languages\"]==[\"go\"] and not d[\"code\"][\"ui\"] and d[\"code\"][\"runs\"]=={\"test\":\"make test\",\"lint\":\"make lint\"} and d[\"code\"][\"tools_run\"]==[\"golangci-lint\"] and d[\"code\"][\"config_not_run\"]==[]"'

# -- Claude and Orca --------------------------------------------------------------------------------------------
A='{ "loggedIn": true, "authMethod": "claude.ai", "subscriptionType": "max", "planTier": "max_20x" }'
ORCA=(PATH="$T/orca-bin:$BASE" ORCA_TERMINAL_HANDLE=term_1 FAKE_GH_LOGGED_IN=1)
detect "$T/empty" "${ORCA[@]}" FAKE_CLAUDE_AUTH="$A"
ok "in Orca on Max 20x: large"                       'q "d[\"claude\"][\"plan\"]==\"max_20x\" and d[\"claude\"][\"in_orca\"] and d[\"suggest\"][\"runtime\"][\"value\"]==\"orca-large\""'
detect "$T/empty" "${ORCA[@]}" FAKE_CLAUDE_AUTH="${A/max_20x/max_5x}"
ok "in Orca on Max 5x: medium"                       'q "d[\"suggest\"][\"runtime\"][\"value\"]==\"orca-medium\""'
detect "$T/empty" "${ORCA[@]}" FAKE_CLAUDE_AUTH='{ "authMethod": "claude.ai", "subscriptionType": "pro" }'
ok "in Orca on Pro: in-conversation"                 'q "d[\"claude\"][\"plan\"]==\"pro\" and d[\"suggest\"][\"runtime\"][\"value\"]==\"in-conversation\""'
detect "$T/empty" "${ORCA[@]}" FAKE_CLAUDE_AUTH='{ "authMethod": "api_key" }'
ok "in Orca with an API key: small"                  'q "d[\"claude\"][\"plan\"]==\"api\" and d[\"suggest\"][\"runtime\"][\"value\"]==\"orca-small\""'
detect "$T/empty" PATH="$T/nopy:$T/orca-bin:$BASE" ORCA_TERMINAL_HANDLE=term_1 FAKE_GH_LOGGED_IN=1 FAKE_CLAUDE_AUTH="$A"
ok "no python3: in-conversation, says why"           'q "d[\"suggest\"][\"runtime\"][\"value\"]==\"in-conversation\" and \"python3\" not in d[\"machine\"][\"tools\"]"'
ok "no python3: board and check-ins unavailable"    'q "d[\"suggest\"][\"extras\"][\"available\"]==[] and len(d[\"suggest\"][\"extras\"][\"unavailable\"])==2 and any(\"Python 3.9\" in n for n in d[\"notices\"])"'
detect "$T/empty" PATH="$T/orca-bin:$BASE" FAKE_GH_LOGGED_IN=1 FAKE_CLAUDE_AUTH="$A"
ok "Orca installed, not inside it: in-conversation" 'q "d[\"suggest\"][\"runtime\"][\"value\"]==\"in-conversation\" and \"running inside\" in d[\"suggest\"][\"runtime\"][\"why\"] and \"check-ins\" in d[\"suggest\"][\"extras\"][\"available\"]"'
detect "$T/empty"
ok "no Orca: in-conversation, gh notice"             'q "d[\"suggest\"][\"runtime\"][\"why\"].endswith(\"installed\") and any(\"gh auth login\" in n for n in d[\"notices\"])"'
detect "$T/empty" FAKE_GH_LOGGED_IN=1 FAKE_GH_STACK=1 FAKE_DOCKER_UP=1
ok "machine: gh logged in, gh-stack, docker running" 'q "d[\"machine\"][\"tools\"][\"gh\"]==\"2.99.0 logged in\" and d[\"machine\"][\"gh_stack\"] and d[\"machine\"][\"tools\"][\"docker\"]==\"27.0.1 running\""'

echo '{ "enabledPlugins": { "dev-team@dev-team": true } }' > "$T/claude/settings.json"; detect "$T/empty"
ok "user-scope install: says so"                     'q "d[\"claude\"][\"install_scope\"]==[\"user\"] and any(\"user scope\" in n for n in d[\"notices\"])"'
rm "$T/claude/settings.json"; mkdir -p "$T/empty/.claude"
echo '{ "enabledPlugins": { "dev-team@dev-team": true } }' > "$T/empty/.claude/settings.local.json"; detect "$T/empty"
ok "local install: no notice"                        'q "d[\"claude\"][\"install_scope\"]==[\"local\"] and not any(\"user scope\" in n for n in d[\"notices\"])"'

# -- open PRs, re-runs, a taken folder --------------------------------------------------------------------------
R=$(repo prs "chore: a" "chore: b" "chore: c" "chore: d"); git -C "$R" remote add origin https://github.com/acme/shop
detect "$R" FAKE_GH_LOGGED_IN=1 FAKE_GH_PERM="me WRITE acme" FAKE_GH_PRS='[{"number":88,"title":"feat: saved carts","branch":"eng-401"}]'
ok "existing GitHub repo: your open PRs"             'q "d[\"open_prs\"]==[{\"number\":88,\"title\":\"feat: saved carts\",\"branch\":\"eng-401\"}] and \"tickets: GitHub\" in d[\"suggest\"][\"extras\"][\"available\"]"'
printf -- '- **Workspace:** `dev-team` · committed\n' > "$R/CLAUDE.md"; detect "$R"
ok "a dev-team section: set-up (a re-run)"           'q "d[\"project\"][\"state\"]==\"set-up\""'
mkdir -p "$R/dev-team" && echo notes > "$R/dev-team/notes.md"; detect "$R"
ok "someone else's dev-team/ folder: says so"        'q "d[\"project\"][\"dev_team_dir\"]==\"taken\" and any(\"dev-team/ folder\" in n for n in d[\"notices\"])"'
echo x > "$R/dev-team/status.md"; detect "$R"
ok "our own dev-team/ folder: no notice"             'q "d[\"project\"][\"dev_team_dir\"]==\"ours\""'

# -- other projects, only when asked ----------------------------------------------------------------------------
O="$T/others"; mkdir -p "$O/web" "$O/api" "$O/notes"
git -C "$O/web" init -q && echo '{ "dependencies": { "react": "1", "next": "1" } }' > "$O/web/package.json" && echo '{}' > "$O/web/tsconfig.json"
git -C "$O/api" init -q && echo '{ "require": { "laravel/framework": "^12" } }' > "$O/api/composer.json"
detect "$T/empty"
ok "other projects: not read unless asked"           'q "\"other_projects\" not in d"'
OUT=$(cd "$O/web" && env -i HOME="$T" CLAUDE_CONFIG_DIR="$T/claude" PATH="$BASE" "$DETECT" --other-projects "$O" 2>&1)
ok "other projects: what they're built with, not this one" 'q "d[\"other_projects\"]=={\"projects\":1,\"built_with\":{\"php\":1,\"laravel/framework\":1}}"'
OUT=$(cd "$T/empty" && env -i HOME="$T" CLAUDE_CONFIG_DIR="$T/claude" PATH="$BASE" "$DETECT" --other-projects "$O" 2>&1)
ok "other projects: counts across repos"             'q "d[\"other_projects\"][\"projects\"]==2 and d[\"other_projects\"][\"built_with\"][\"react\"]==1 and d[\"other_projects\"][\"built_with\"][\"typescript\"]==1"'

exit $fail
