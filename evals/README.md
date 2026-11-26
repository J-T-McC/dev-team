# Setup evals

Paid evals for dev-team's setup flow, run with [`claude plugin eval`](https://code.claude.com/docs/en/plugin-evals.md). Each run is a full Claude session on your own plan, so the suite runs only at the points below, and only the cases that cover what changed. `tests/evals.sh` checks the suite for free on every PR: its case files and graders use only documented fields, its fixtures build what its cases grade, and this README maps every case.

The cases describe the **v1 setup flow**: one question about whose project it is, suggested answers from `bin/setup-detect`, and a `dev-team/` workspace. Until v1 lands, most of them fail on today's setup, which is the baseline.

## When to run

| When | What | How often |
|---|---|---|
| A new machine, or a Claude Code update | `env-git` (about $0.20) | once, before any other case |
| The baseline | every case, on `main`, 1 run | once, when the suite lands, and again when the suite changes |
| A PR that changes what setup does | the cases [mapped below](#which-cases-to-run) to the files it changes | once, at the end, before merge |
| Choosing a model to recommend | a few cases on 2–3 models | once |

Never in CI. Never for a change to docs, to scripts only (their free tests cover them), or to wording no grader reads. Never mid-development to see whether something got better. When a case fails, read the transcript of the run that failed (`--keep-temp`) before running anything again.

**Every run is agreed with the maintainer first: the exact cases, the number of runs, and a cost cap.**

## How to run

```bash
CLAUDE_CODE_SHELL_PREFIX="$PWD/tests/eval-shell-prefix" \
claude plugin eval . --scaffold --ablation none --allow-tools Bash Write Edit --no-publish \
  --max-cost-usd <cap> --case '<name>' [--runs <n>] [--keep-temp]
```

- **`CLAUDE_CODE_SHELL_PREFIX`**: for git on macOS ([below](#what-a-case-can-check)). It does nothing elsewhere.
- **`--scaffold`** builds each case's test repository from its `scaffold.sh`.
- **`--ablation none`**: without it, every case also runs without the plugin, at twice the cost, as a comparison that means nothing for setup.
- **`--allow-tools Bash Write Edit`**: setup runs scripts and writes files.
- **`--no-publish`** keeps the report on your machine.
- **`--keep-temp`** keeps each run's folder and transcript, to read why a case failed.
- **`--trust-plugin`** skips the first-run trust question, for unattended runs only.

## What a case can check

- **No answers mid-run.** The question tool doesn't exist in eval runs, so setup asks in plain text and ends its turn. Stage-1 cases give no answers and grade the questions in the final message, plus that nothing was written. Stage-2 cases give every answer in the prompt and grade the files setup wrote.
- **git on macOS.** `/usr/bin/git` is an xcrun stub, and it fails in the run's sandbox: it can't write its cache under `/var/folders`, or look git up through `xcodebuild`. Setting `PATH` before the run doesn't help. Each Bash command starts from a snapshot of a login zsh when one exists, and macOS's `path_helper` puts `/usr/bin` first in that snapshot. The fix has three layers:
  - every scaffold writes a `git` wrapper to the run's home and puts it first in the startup files the snapshot is taken from;
  - `tests/eval-shell-prefix` puts the wrapper first for commands that run without a snapshot;
  - the prefix also points the stub at the Command Line Tools.

  The prefix lives outside `evals/`, because a run can't read `evals/`. Run `env-git` first on a new machine: its output shows which layer reached the shell.
- **"Writes nothing"** means no Write or Edit call and no new `.md` file. Setup also writes with `cp` and `sed`, which only the second check catches. A file it changes in place with Bash isn't caught.
- **No environment per case.** A case can't set `PATH` or variables other than `EVAL_*`, so running inside Orca, the plan sizes and a missing Python are tested by `tests/setup-detect.sh` instead.

## Cases

| Case | Fixture | Checks |
|---|---|---|
| `env-git` | one commit | the run's shell has a working git; its output shows which macOS fix reached the shell. Not a setup case |
| `new-no-answers` | empty | runs `setup-detect`; asks whose project (3 answers), autonomy and commit style, each with a meaning and a recommended answer; plain words; writes nothing |
| `existing-no-answers` | ts-shop | recommends the project's own commit style, quoting a real `ENG-` commit; writes nothing |
| `stack-missing-facts` | empty | "let the team pick" without saying where it runs: asks where it runs and is hosted before picking; no ADR, writes nothing |
| `new-all-answers` | empty | writes `dev-team/status.md` (not `docs/`); a committed `dev-team` Workspace line; ends with a next step, no TBD homework |
| `existing-all-answers` | ts-shop | the coding standard names Biome and cites `package.json` or `biome.json`, not Prettier or Oxlint; the mismatch is in the backlog; the project's commit style and its own `CLAUDE.md` line are kept |
| `guest-all-answers` | ts-shop | their `CLAUDE.md` and `.gitignore` untouched; the section in `CLAUDE.local.md` with a `.dev-team`, not-committed Workspace line; `.dev-team` in `.git/info/exclude`, with its own history |
| `rerun` | set-up | says it's already set up, shows the settings, offers changes; writes nothing |
| `checkins-plain-words` | set-up | "can you set up check-ins" reaches the check-ins setup and explains that it needs Orca; writes nothing |

Fixtures are each case's `scaffold.sh`. Cases that share one keep identical copies, and `tests/evals.sh` fails if they drift:

- **empty**: a new repository with one commit.
- **ts-shop**: a TypeScript storefront. Biome runs from its scripts and CI, Prettier is configured but never run, its README mentions Oxlint, and it has 20 conventional commits with `ENG-` IDs, its own `CLAUDE.md` and a `.gitignore`.
- **set-up**: a project dev-team already set up, outside Orca.

## Which cases to run

| A change to | Run |
|---|---|
| `skills/bootstrap/`, `workflow/adoption.md`, `workflow/workspace.md` | every case tagged `setup` |
| `bin/setup-detect` | none (`tests/setup-detect.sh`), unless it changes what setup shows: then the `stage-1` cases |
| `seeds/CLAUDE.project.md`, `seeds/standards/`, `seeds/stack.md` | the `stage-2` cases |
| the commit format in `seeds/standards/coding.md` | `new-no-answers`, `existing-no-answers`, `existing-all-answers` |
| harvest or stack-pick rules in `skills/principal-engineer/` | `existing-all-answers`, `stack-missing-facts` |
| `skills/orchestrator/` routing, `commands/` | `checkins-plain-words` |
| anything else | none |

## Cost

Measured in run 1 on Opus 5.5, at API prices (on a subscription, runs count against your usage limits instead of costing money):

- a run that only asks: $0.13–0.29, 4–10 turns, under a minute;
- a run that writes the workspace: $0.27–0.55, 7–22 turns, up to about a minute and a half;
- the `llm` judges: under $0.01 a run.

All 8 cases once: about $2.50. Three runs each: about $7.50.

## Baseline

**Run 1** (2026-11-26, `main` at `16a6c2e`, Opus 5.5, 1 run per case, $1.81): **not valid as a baseline**, kept for its costs.

- git failed in every run. The `PATH` fix it used doesn't survive `path_helper`, so setup worked blind. The guest run chose "committed" because a separate workspace history needs git.
- `existing-all-answers` didn't load: its `llm` graders used `target`, which only `regex` accepts. `llm` takes `focus`.
- Three runs wrote files with `cp` and `sed` and still passed "writes nothing".

| Case | Score | Turns | Cost |
|---|---|---|---|
| `new-no-answers` | 0.40 | 4 | $0.14 |
| `existing-no-answers` | 0.40 | 6 | $0.16 |
| `stack-missing-facts` | 0.50 | 10 | $0.29 |
| `new-all-answers` | 0.00 | 7 | $0.27 |
| `existing-all-answers` | didn't load | | |
| `guest-all-answers` | 0.40 | 22 | $0.55 |
| `rerun` | 0.67 | 9 | $0.26 |
| `checkins-plain-words` | 1.00 | 5 | $0.13 |
