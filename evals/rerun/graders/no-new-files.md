---
# Catches workspace files written with Bash (cp, sed, redirects), which the Write and Edit graders miss.
# Only files created during the run count, so the fixture's own files don't.
type: file_exists
path: "**/*.md"
exists: false
---
