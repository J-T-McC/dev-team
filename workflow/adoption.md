# Adoption (bringing this organization into an existing project)

Bootstrap assumes an empty field. An existing project is different in one way that matters: **most of the answers the standards ask for are already in the code.** Adoption harvests them instead of interrogating the Owner, and draws a line between work that predates the organization and work that follows it.

Run once, by the Project Owner, via the `bootstrap` skill. This file is the canonical home of the rules below; other documents reference it in ≤1 line.

## The line: nothing is documented backwards

**Shipped work is never retro-documented.** No PRD for a feature already in production, no plan for architecture already built, no ADR for a decision already made and living in the code. The running system is its own record; a back-filled PRD is a guess about intent, dressed as a requirement, that every downstream role will then treat as approved truth.

Documents are written **forward only** — for the next change, not the last one. Existing architecture gets an ADR the first time someone *changes* it, and that ADR states the decision being made now, not the one made two years ago.

The one exception: an in-flight feature that cannot continue without an upstream artifact (it is genuinely mid-Requirements) gets that artifact written **for the remaining work**, scoped to what is left.

## In-flight work

Features already under way when the organization arrives enter at their true phase:

- One row in `docs/status.md` per in-flight feature, `Phase` set to where the work actually is, `Approvals` recording `pre-adoption`.
- Gates **upstream** of that phase are waived by adoption — recorded once by the Owner, not re-litigated per role.
- Gates **downstream** apply in full from the adoption date. A feature adopted at Implementation still needs its review and its release approval.
- A role handed pre-adoption work must not refuse it for a missing upstream artifact; it must refuse it for a missing *downstream* gate exactly as normal.

Everything started after adoption runs the pipeline from the top with no exceptions.

## Harvesting standards and the stack

Placeholders are the wall a new adopter hits: roles stop and ask rather than guess, and in an existing codebase they are asking questions the repository can answer. So the Principal Engineer **proposes** filled standards, and the Owner approves or corrects — the ownership the standards headers already state, with a workflow behind it.

Evidence sources, in order of authority:

| Target | Read |
|---|---|
| `docs/stack/stack.md` | package manifests and lockfiles, CI workflow files, container and deploy config, test/lint/format config, `.tool-versions`-style pins |
| `docs/standards/coding.md` | directory layout, a representative sample of source files (naming, structure, error handling, logging), formatter and linter config; existing commit history for the commit-message section |
| `docs/standards/testing.md` | test directory layout, test framework in the manifest, coverage config, CI test invocation |

Rules that keep the harvest honest:

- **Cite or leave blank.** Every proposed line names the file it came from. Anything the repository does not answer stays `_TBD_` — a plausible guess in a standards file is worse than a placeholder, because placeholders make roles ask and guesses make them confident.
- **Describe, do not reform.** The harvest records what the project *does*, including things the Principal Engineer would not have chosen. Improving a convention is a later, separate proposal.
- **Conflicting evidence is a question, not an average.** Two error-handling patterns in the codebase means the Owner picks one; it does not mean the standard says "either".
- The Owner approves the whole file; the result is project-owned like any other seed.

## Before writing anything: survey

Two collisions to settle first, because both are cheaper to resolve before the scaffold lands than after.

**An existing `docs/` directory.** The organization's directories are additive and coexist with ordinary project documentation. The real risk is a `docs/` that is a *published site* or a generated artifact, where new subdirectories get built, deployed, or wiped. Report what is already there and confirm with the Owner before creating anything inside it.

**An existing `CLAUDE.md`.** Appending the seed section is only safe when the file does not already rule on the same subjects. Scan for existing rules on commit messages, document locations, review or approval process, and branch/PR policy. Report each conflict as a pair — the project's rule and the seed's rule — and let the Owner name the winner. Delete the loser rather than leaving both; two rules on one subject is worse than either rule alone.

## Order

1. **Survey** — existing `docs/`, existing `CLAUDE.md` conflicts. Resolve both with the Owner.
2. **Scaffold** — seed sync creates directories and copies missing seeds.
3. **Harvest** — Principal Engineer proposes `stack.md`, `coding.md`, `testing.md` with citations; Owner approves. Remaining standards stay as seeded.
4. **Declare in-flight work** — status rows at true phases, `pre-adoption` approvals recorded.
5. **Stop.** Nothing else is documented. The next *new* feature runs the pipeline from the top.
