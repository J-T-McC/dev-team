#!/bin/bash
# pr-title.sh <title>: passes when a PR title is a conventional commit. The squash commit takes the title,
# and the release workflow reads it to set the version (.github/workflows/release.yml).
types='feat|fix|perf|refactor|docs|test|build|ci|chore|style|revert'
re="^($types)(\([A-Za-z0-9][A-Za-z0-9,./_-]*\))?!?: [^ ].*"
[[ $1 =~ $re ]] && exit 0
cat >&2 <<EOF
The PR title is not a conventional commit: "$1"
Write it as type(scope)!: summary, with the scope and ! optional. Types: ${types//|/, }.
feat makes a minor release, fix or perf a patch, ! a major one; the other types make none.
EOF
exit 1
