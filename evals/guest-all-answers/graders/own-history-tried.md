---
# The run's sandbox blocks writes to a new repository's .git/hooks and .git/config, so the workspace's own history
# can't be created in a run (evals/README.md). This grades the attempt; reports-own-history grades what the user is told.
type: regex
target: trace
pattern: 'git -C [^ ]*(\.dev-team|WS)[^ ]* init|cd [^;&|]*\.dev-team[^;&|]*(&&|;) *git init'
---
