---
# The run's permission mode refuses writes into .git/, so the exclude line can't be added in a run (evals/README.md).
# This grades the attempt, by Bash or Edit; reports-exclude grades what the user is told.
type: regex
target: trace
pattern: '"command":\s*"(\\"|[^"])*(\.dev-team(\\"|[^"])*info/exclude|info/exclude(\\"|[^"])*\.dev-team)|"file_path":\s*"[^"]*\.git/info/exclude"'
---
