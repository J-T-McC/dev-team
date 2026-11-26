#!/bin/bash
# Tests for .github/release-due.sh: the release job runs only when a commit since the last tag calls for a release.
# Run: tests/release-due.sh
cd "$(dirname "$0")/.." || exit 1
SCRIPT=$PWD/.github/release-due.sh
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail=0
g() { git -c user.name=t -c user.email=t@example.com "$@"; }
# repo <name> <message>…: a repo with one commit per message; a message "TAG" tags the commit before it v1.0.<n>.
repo() { local d=$T/$1 n=0; shift; mkdir -p "$d" && cd "$d" && git init -q -b main
         for m; do if [ "$m" = TAG ]; then n=$((n+1)); g tag "v1.0.$n"; else g commit -q --allow-empty -m "$m"; fi; done; cd - >/dev/null; }
check() { (cd "$T/$2" && bash "$SCRIPT" >/dev/null); rc=$?
          if { [ "$1" = due ] && [ $rc = 0 ]; } || { [ "$1" = skip ] && [ $rc != 0 ]; }; then echo "ok   $1: $3"
          else echo "FAIL $1: $3"; fail=1; fi; }

repo a 'feat: first';                                       check due  a 'no tag yet, a feat'
repo b 'feat: first' TAG 'test(evals): cases';              check skip b 'a test commit after the tag'
repo c 'feat: first' TAG;                                   check skip c 'nothing since the tag'
repo d 'feat: first' TAG 'docs: words' 'fix(hook): quiet';  check due  d 'a fix after a docs commit'
repo e 'feat: first' TAG 'perf: faster';                    check due  e 'perf'
repo f 'feat: first' TAG 'ci(release): skip';               check skip f 'a ci commit'
repo g 'feat: first' TAG 'chore!: drop node 18';            check due  g 'a ! on any type'
repo h 'feat: first' TAG 'Revert "feat: x"';                check due  h 'a revert'
repo i 'feat: first' TAG 'feat(setup): detect' 'test: more'; check due  i "a feat whose release didn't run, then a test commit"
repo j 'feat: first' TAG 'feat: old' TAG 'docs: readme';    check skip j 'only commits after the newest tag count'
repo k 'feat: first' TAG 'featured: not a type';            check skip k 'a type that only starts with feat'
mkdir -p "$T/l" && (cd "$T/l" && git init -q -b main && g commit -q --allow-empty -m 'feat: first' && g tag v1.0.1 &&
  g commit -q --allow-empty -m 'refactor: tidy' -m 'BREAKING CHANGE: the config moved'); check due l 'a BREAKING CHANGE footer'
mkdir -p "$T/m" && (cd "$T/m" && git init -q -b main);     check due  m "no commits at all: can't tell, so run"

out=$(cd "$T/d" && bash "$SCRIPT")
[[ $out == 'release due since v1.0.1: fix(hook): quiet' ]] && echo "ok   it names the commit that calls for the release" ||
  { echo "FAIL it names the commit that calls for the release: $out"; fail=1; }
exit $fail
