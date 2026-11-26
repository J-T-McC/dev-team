# Adoption (bringing this organization into an existing project)

Bootstrap assumes an empty field. An existing project is different in one way that matters: **most of the answers the standards ask for are already in the code.** Adoption harvests them instead of interrogating the Owner, and draws a line between work that predates the organization and work that follows it.

Run once, by the Project Owner, via the `bootstrap` skill. This file is the canonical home of the rules below; other documents reference it in ≤1 line.

## The line: nothing is documented backwards

**Shipped work is never retro-documented.** No PRD for a feature already in production, no plan for architecture already built, no ADR for a decision already made and living in the code. The running system is its own record; a back-filled PRD is a guess about intent, dressed as a requirement, that every downstream role will then treat as approved truth.

Documents are written **forward only** — for the next change, not the last one. Existing architecture gets an ADR the first time someone *changes* it, and that ADR states the decision being made now, not the one made two years ago.

The one exception: an in-flight feature that cannot continue without an upstream artifact (it is genuinely mid-Requirements) gets that artifact written **for the remaining work**, scoped to what is left.

## In-flight work

Features already under way when the organization arrives enter at their true phase:

- One row in `<ws>/status.md` per in-flight feature, `Phase` set to where the work actually is, `Approvals` recording `pre-adoption`.
- Gates **upstream** of that phase are waived by adoption — recorded once by the Owner, not re-litigated per role.
- Gates **downstream** apply in full from the adoption date. A feature adopted at Implementation still needs its review and its release approval.
- A role handed pre-adoption work must not refuse it for a missing upstream artifact; it must refuse it for a missing *downstream* gate exactly as normal.

Everything started after adoption begins at Product Manager triage, like any new work, with no exceptions.

## Harvesting standards and the stack

Open standards are the wall a new adopter hits: roles stop and ask rather than guess, and in an existing codebase they are asking questions the repository can answer. So the Principal Engineer **proposes** filled standards, and the Owner approves or corrects them in one go, in setup's digest — the ownership the standards headers already state, with a workflow behind it.

Evidence sources, in order of authority:

| Target | Read |
|---|---|
| `<ws>/stack/stack.md` | package manifests and lockfiles, CI workflow files, container and deploy config, test/lint/format config, `.tool-versions`-style pins |
| `<ws>/standards/coding.md` | directory layout, a representative sample of source files (naming, structure, error handling, logging), formatter and linter config; existing commit history for the commit-message section |
| `<ws>/standards/testing.md` | test directory layout, test framework in the manifest, coverage config, CI test invocation |

Rules that keep the harvest honest:

- **What runs is the standard.** A tool counts when the project's scripts, CI, or git hooks run it (`bin/setup-detect`: `code.runs`, `code.tools_run`). Config that nothing runs (`code.config_not_run`), and a tool only a README or an editor setting mentions, are not the project's standard. Each such mismatch becomes one `debt` backlog item; it is never a question for the Owner at setup.
- **Cite, or suggest and say so.** Every line found in the repository names the file it came from. A section the repository does not answer gets a suggestion from current practice for this stack, including what helps agents work well (one command that runs every check, strict types, fast targeted tests, errors that say what to do), marked `(suggested at setup)` and listed in the digest for the Owner's yes. An unlabelled guess is worse than an open section, because open sections make roles ask and guesses make them confident.
- **Describe, do not reform.** The harvest records what the project *does*, including things the Principal Engineer would not have chosen. Improving a convention is a later, separate proposal.
- **Conflicting evidence is a question, not an average.** Two error-handling patterns in the codebase means the Owner picks one, in the digest, with the more common one suggested; it does not mean the standard says "either".
- **Guest mode** records only what the repository does not already document.
- The Owner approves the result in the digest; it is project-owned like any other seed.

## Before writing anything: survey

Two collisions to settle first, because both are cheaper to resolve before the scaffold lands than after.

**Where the workspace goes.** Setup's default root, `dev-team/` (`.dev-team/` for a guest), stays clear of the project's own folders. If that folder already exists and is not a dev-team workspace (`setup-detect`: `dev_team_dir: taken`), use another name and say so in the digest. Never put the workspace in a *published site* or a generated folder, where new subdirectories get built, deployed, or wiped. A project dev-team does not own uses guest mode.

**An existing `CLAUDE.md`.** Appending the seed section is only safe when the file does not already rule on the same subjects. Scan for existing rules on commit messages, document locations, review or approval process, and branch/PR policy. The project's rule wins by default, since it is the one in use: leave the seed's rule on that subject out, or adapt it to the project's. The digest lists each pair, so the Owner can take the seed's rule instead; then the project's line goes, with the Owner's yes. Never edit or delete the project's own lines otherwise. Two rules on one subject is worse than either rule alone.

## Order

1. **Survey** — workspace location (or guest mode), existing `CLAUDE.md` conflicts.
2. **Scaffold** — seed sync creates directories and copies missing seeds.
3. **Harvest** — Principal Engineer writes `stack.md`, `coding.md`, `testing.md` with citations and labelled suggestions, and files each tool mismatch to the backlog. Remaining standards stay as seeded.
4. **Declare in-flight work** — status rows at true phases, `pre-adoption` approvals recorded; the Owner's open pull requests (`setup-detect`: `open_prs`) are the first candidates.
5. **Digest** — one message to the Owner: what was found and from where, the suggestions, the conflicts, the backlog items, the in-flight rows. Use these / show me the files first / change something.
6. **Stop.** Nothing else is documented. The next *new* piece of work starts at Product Manager triage.
