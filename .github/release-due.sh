#!/bin/bash
# release-due.sh: passes when a commit since the last release tag calls for a release (feat, fix, perf, revert, `!` or a
# BREAKING CHANGE footer), so the release workflow skips its job when none does (.github/workflows/release.yml).
# It reads every commit since the tag, not just the newest: a release whose run failed is retried on the next merge.
# When unsure it passes, and semantic-release decides.
last=$(git describe --tags --abbrev=0 --match 'v*' 2>/dev/null)
range=${last:+$last..}HEAD
subjects=$(git log --format=%s "$range" 2>/dev/null) || { echo "can't read commits since ${last:-the start}: running"; exit 0; }
hit=$(grep -E -m1 '^(feat|fix|perf|revert)(\([^)]*\))?!?: |^[a-z]+(\([^)]*\))?!: |^Revert ' <<<"$subjects") ||
  { git log --format=%b "$range" | grep -Eq '^BREAKING[ -]CHANGE: ' && hit='a BREAKING CHANGE footer'; }
if [ -n "$hit" ]; then echo "release due since ${last:-the start}: $hit"; exit 0; fi
echo "no release due since ${last:-the start}"
exit 1
